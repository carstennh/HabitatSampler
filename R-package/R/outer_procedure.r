#' Perform Habitat Sampling and Probability Mapping
#'
#'This is the main function that performs everything: specify the input imagery, select model type, initiate sampling and model building, generates interactive maps and produce final probability raster output
#' 
#' @param in.raster satellite time series stack (rasterBrickObject) or just any type of image (*rasterObject)
#' @param init.samples starting number of spatial locations
#' @param sample_type distribution of spatial locations c("random","regular")
#' @param nb_models number of models (independent classifiers) to collect
#' @param nb_it number of iterations for model accuracy
#' @param buffer distance (in m) for new sample collection around initial samples (depends on pixel size)
#' @param reference reference spectra either SpatialPointsDataFrame (shape file) or data.frame with lines = classes, column = predictors]
#' @param model which machine learning classifier to use c("rf", "svm") for random forest or suppurt vector machine implementation
#' @param mtry number of predictor used at random forest splitting nodes (mtry << n predictors)
#' @param last only true for one class classifier c("FALSE", TRUE")
#' @param seed set seed for reproducable results
#' @param init.seed "sample" for new or use run1@seeds to reproduce previous steps
#' @param outPath output path for saving results
#' @param step at which step should the procedure start, e.g. use step = 2 if the first habitat is already extracted
#' @param  classNames character vector with class names in the order of reference spectra
#' @param n_classes total number of classes (habitat types) to be separated
#' @param multiTest number of test runs to compare different probability outputs
#' @param RGB rgb channel numbers for image plot 
#'
#' @return 4 files per step: 
#' 1) Habitat type probability map as geocoded *.kml layer and *.tif raster files and  *.png image output 
#' 2) A Habitat object consisting of 7 slots: \cr 
#' run1@models - list of selcted classifiers \cr 
#' run1@ref_samples - list of SpatialPointsDataFrames with same length as run1@models holding reference labels [1,2] for each selected model \cr  
#' run1@switch - vector of lenght run1@models indicating if target class equals 2, if not NA the labels need to be switched \cr 
#' run1@layer - raster map of habitat type probability \cr 
#' run1@mod_all - list of all classifiers (equals nb_models) \cr 
#' run1@class_ind - vector of predictive distance measure for all habitats \cr 
#' run1@seeds - vector of seeds for random sampling \cr 
#' all files are saved with step number, the *.tif file is additionally saved with class names 
#'
#' @examples
#' ###################
#' library(HaSa)
#' raster::plotRGB(Sentinel_Stack_2018, r = 19, g = 20, b = 21, stretch = "lin", axes = T)
#' sp::plot(Example_Reference_Points, pch = 21, bg = "red", col = "yellow", cex = 1.9, lwd = 2.5, add = T)
#' multi_Class_Sampling(in.raster = Sentinel_Stack_2018, init.samples = 30, sample_type = "regular", nb_models = 200, nb_it = 10, buffer = 15, 
#' reference = Example_Reference_Points, model = "rf", mtry = 10, last = F, seed = 3, init.seed = "sample", outPath="C:/", step = 1, 
#' classNames = c("deciduous", "coniferous", "heath_young", "heath_old", "heath_shrub", "bare_ground", "xeric_grass"), n_classes = 7, 
#' multiTest = 1, RGB = c(19, 20, 21))
#' ###################
#' an interactive map is plotting in a web browser
#'
#' next steps start automatically, after command line input of:
#' 1) number of the apropriate map if multiTest > 1
#' 2) probability threshold for habitat type extraction 
#' 3) decision to sample again y/n
#' 4) adjust starting number of samples and number of models
#'   
#' for threshold evaluation an interactive map is plotted in the web browser
#'
#' if convergence fails / no models can be selected / init.samples are to little / or another error occurs, restart next step with: 
#' in.raster = out.raster 
#' reference = out.reference 
#' step = specify next step number 
#' classNames = out.names
#'
#' @export

###################################################################################
multi_Class_Sampling<-function(in.raster, init.samples=30, sample_type="regular", nb_models=200, nb_it=10, buffer, reference, model="rf", mtry=10, last=F, seed=3, init.seed="sample", outPath, step=1, classNames, n_classes, multiTest=1,RGB=c(19,20,21)) {

###first steps: data preparation
if (class(reference) == "SpatialPointsDataFrame") { reference<-as.data.frame(raster::extract(in.raster,reference)) }

area <- as(raster::extent(in.raster), 'SpatialPolygons') 
area <- sp::SpatialPolygonsDataFrame(area, data.frame( ID=1:length(area)))
sp::proj4string(area)<-sp::proj4string(in.raster)

r<-RGB[1]; g<-RGB[2]; b<-RGB[3]
col<-colorRampPalette(c("lightgrey","orange","yellow","limegreen","forestgreen"))

#############################################################################################
r<-n_classes
if (names(in.raster)[1] != colnames(reference)[1]) { colnames(reference)<-names(in.raster) }
if (step != 1) {if (step<11) {load(paste(outPath,paste("threshold_step_0",step-1,sep=""),sep=""))}else{load(paste(outPath,paste("threshold_step_",step-1,sep=""),sep=""))}}

for ( i in step:r) {print(paste(paste("init.samples = ",init.samples),paste("models = ",nb_models))); if ( i == r) {last=T}


if ( multiTest > 1 ) { test<-list(); maFo<-list(); new.names<-list(); decision = "0" 
####################################################################################################################
  
  while (decision == "0") {
  for ( rs in 1:multiTest ) { 

  ########################
  maFo_rf<-sample_nb(raster=in.raster,nb_samples=seq(init.samples,init.samples,init.samples),sample_type=sample_type,nb_mean=nb_models,nb_it=nb_it,buffer=buffer,reference=reference,model=model,area=area,mtry=mtry,last=last,seed=seed,init.seed=init.seed)
  ########################
  maFo[[rs]]<-maFo_rf
  test[[rs]]<-maFo_rf@layer[[1]]
  new.names[[rs]]<-index
  if ( rs == multiTest ) {par(mar=c(2,2,2,3),mfrow=n2mfrow(multiTest))
                         for ( rr in 1:length(test) ) { plot(test[[rr]], col = col(200),main="", legend.shrink=1); mtext(side=3, paste(rr,classNames[new.names[[rr]]], sep=" "),font =2) }}

  }
  decision<-readline("Which distribution is acceptable/ or sample again [../0]:  ")
  }
  maFo_rf<-maFo[[as.numeric(decision)]]   
  index<-new.names[[as.numeric(decision)]]
####################################################################################################################
  
}else{
########################
maFo_rf<-sample_nb(raster=in.raster,nb_samples=seq(init.samples,init.samples,init.samples),sample_type=sample_type,nb_mean=nb_models,nb_it=nb_it,buffer=buffer,reference=reference,model=model,area=area,mtry=mtry,last=last,seed=seed,init.seed=init.seed)
########################
}

dummy<-maFo_rf@layer[[1]]
iplot(x=dummy,y=a1,HaTy=classNames[index])

decision<-readline("Threshold for Habitat Extraction or Sample Again [../0]:  ")

    sample2<-init.samples
    models2<-nb_models
    while (decision == "0") { decision2<-readline("Adjust init.samples/nb.models or auto [../.. or 0]:  ")
    if (decision2 != "0") {sample2<-as.numeric(strsplit(decision2, split="/")[[1]][1])
                                      models2<-as.numeric(strsplit(decision2, split="/")[[1]][2])}else
    {sample2<-sample2+50
    models2<-models2+15}
    print(paste(paste("init.samples = ",sample2),paste("models = ",models2)))
    maFo_rf<-sample_nb(raster=in.raster,nb_samples=seq(sample2,sample2,sample2),sample_type=sample_type,nb_mean=models2,nb_it=nb_it,buffer=buffer,reference=reference,model=model,area=area,mtry=mtry,last=last,seed=seed,init.seed=init.seed)
    ########################

    dummy<-maFo_rf@layer[[1]]
    iplot(x=dummy,y=a1,HaTy=classNames[index])
    
    decision<-readline("Threshold for Habitat Extraction or Sample Again [../0]:  ")
    }
 
run1<-maFo_rf
if (i <10) {ni<-paste("0",i,sep="")}else{ni<-i}
save(run1,file=paste(outPath,paste("Run",ni,sep=""),sep=""))
raster :: writeRaster(dummy,filename=paste(outPath,paste("step_",ni,paste("_",classNames[index],sep=""),".tif",sep=""),sep=""), format="GTiff")
#savePlot("step_1.png",type="png")
kml<-raster :: projectRaster(dummy, crs="+proj=longlat +datum=WGS84", method='ngb')
raster :: KML(kml,paste(outPath,paste("step_",ni,sep=""),sep=""))

thres<-as.numeric(decision)
dummy<-maFo_rf@layer[[1]]
dummy[dummy < thres]<-1
dummy[dummy >=thres]<-NA
reference<-reference[-index,]; out.reference<<-reference 
classNames<-classNames[-index]; out.names<<-classNames
in.raster<-in.raster*dummy; out.raster<<-in.raster

print(paste(paste("Habitat",i),"Done"))

if( i == r ) {print("Congratulation - you finally made it towards the last habitat"); break()}

colnames(reference)<-names(in.raster)
if ( i == 1) {threshold<-thres; save(threshold,file=paste(outPath,paste("threshold_step_",ni,sep=""),sep=""))}else{threshold<-append(threshold,thres); save(threshold,file=paste(outPath,paste("threshold_step_",ni,sep=""),sep=""))}

decision2<-readline("Adjust init.samples/nb.models or auto [../.. or 0]:  ")

if (decision2 != "0") {init.samples<-as.numeric(strsplit(decision2, split="/")[[1]][1])
                                  nb_models<-as.numeric(strsplit(decision2, split="/")[[1]][2])}else {init.samples<-init.samples+50
                                                                                                      nb_models<-nb_models+15}
}
}
