# HaSa - HabitatSampler
#
# Copyright (C) 2020  Carsten Neumann (GFZ Potsdam, carsten.neumann@gfz-potsdam.de)
#
# This software was developed within the context of the project 
# NaTec - KRH (www.heather-conservation-technology.com) funded
# by the German Federal Ministry of Education and Research BMBF
# (grant number: 01 LC 1602A). 
# The BMBF supports this project as research for sustainable development (FONA); www.fona.de. 
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free
# Software Foundation, either version 3 of the License, or (at your option) any
# later version.
#
# This program is distributed in the hope that it will be useful, but WITHOUT
# ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
# FOR A PARTICULAR PURPOSE. See the GNU General Public License for more
# details.
#
# You should have received a copy of the GNU General Public License along
# with this program.  If not, see <http://www.gnu.org/licenses/>.

###################################################################################
multi_Class_Sampling<- function(in.raster,init.samples,sample_type,nb_models,nb_it,buffer,reference,model,area,mtry,last,seed,init.seed,outPath,step,classNames,n_classes,multiTest) {

source(paste(inPath,"inner_procedure.r",sep=""))
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
writeRaster(dummy,filename=paste(outPath,paste("step_",ni,paste("_",classNames[index],sep=""),".tif",sep=""),sep=""), format="GTiff")
#savePlot("step_1.png",type="png")
kml<-projectRaster(dummy, crs="+proj=longlat +datum=WGS84", method='ngb')
KML(kml,paste(outPath,paste("step_",ni,sep=""),sep=""))

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
