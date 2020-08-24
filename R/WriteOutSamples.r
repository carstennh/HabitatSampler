#' Sample Collection for Habitat Types
#'
#'Writes out a set of samples (SpatialPointsDataFrame) into an ESRI shapefile for a selected habitat type. Each point represents a valid sample location that identifies the selected habitat type.
#' 
#' @param inPath file path (character) for results of habitat type sampling and probability mapping (same as outPath from function multi_Class_Sampling)
#' @param step step number (numeric) 
#' @param className name (character) of habitat type for which samples should be selected
#'
#' @return ESRI shapefile with name: RefHaSa_className_step.shp 
#' 1) Point Shape represents pixel that belong to selected habitat type and can be used as reference for further model building 
#'
#'
#' @export

###write out selected samples for step = 6 using 
write_Out_Samples <- function (inPath, step, className) {
paste(inPath,"step_",step,"_",className,".tif",sep="")
run1<-get(load(paste(inPath,"Run",step,sep="")))
load(paste(inPath,"threshold_step_",step,sep=""))
dummy<-raster::raster(paste(inPath,"step_",step,"_",className,".tif",sep=""))
thres<-threshold[6]
dummy[dummy < thres]<-NA
dummy[dummy >=thres]<-1

collect<-list()
j<-0

###extract only class samples
for ( i in 1:length(run1@ref_samples)) {if (length(dim(run1@ref_samples[[i]])) != 0) 
                                                                 {if (is.na(run1@switch[i]) == F) {   j=j+1;collect[[j]]<-run1@ref_samples[[i]][which(run1@ref_samples[[i]]@data==1),]}else 
                                                                    {j=j+1;collect[[j]]<-run1@ref_samples[[i]][which(run1@ref_samples[[i]]@data==2),]}}}
result<-do.call(rbind,collect)                                                                    
                     
res<-raster::extract(dummy,result)    
if (length(which(is.na(res))) >0) { res<-result[-which(is.na(res)),] }

rgdal::writeOGR(res, layer="result", dsn=paste(inPath,"RefHaSa_",className,"_",step,".shp",sep=""), driver="ESRI Shapefile")
}
