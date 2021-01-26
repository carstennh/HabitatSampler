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

########################################################################################
##0)##
#####

##0.1##
wd<-"./demo/"
setwd(wd)

##0.2##
inPath<-"./Funktionen/"
dataPath<-"./Data/"
outPath<-paste(wd,"Data/Results/",sep="")

##0.3##
install.packages("https://cran.r-project.org/src/contrib/Archive/BH/BH_1.69.0-1.tar.gz", repos=NULL, type="source")
install.packages("https://cran.r-project.org/src/contrib/Archive/sf/sf_0.8-1.tar.gz", repos=NULL, type="source")
install.packages("https://cran.r-project.org/src/contrib/Archive/sp/sp_1.4-1.tar.gz", repos=NULL, type="source")
install.packages("https://cran.r-project.org/src/contrib/Archive/rgdal/rgdal_1.4-8.tar.gz", repos=NULL, type="source")
remotes::install_git(
    "https://github.com/carstennh/HabitatSampler.git",
    ref = "master",
    subdir = "R-package",
    dependencies = NA,
    upgrade=FALSE,
    build = TRUE,
    build_manual = TRUE,
    build_vignettes = TRUE
)
libraries <- c("rgdal", "raster", "rgeos", "sp", "sf", "HaSa")
lapply(libraries, library, character.only = TRUE)
rasterOptions(tmpdir="./RasterTmp/")
########################################################################################
##1)##
######


##1.a.1##
a1<-brick(paste(dataPath,"SentinelStack_2018.tif",sep=""))
##1.a.2##
cut<-readOGR("...")
a1<-clip(a1,cut)


##1.b.1##
ref<-read.table(paste(dataPath,"Example_Reference_table.txt", sep=""),header=T)
##1.b.2##
shp<-readOGR(paste(dataPath,"Example_Reference_Points.shp", sep=""))
proj4string(shp)<- "+proj=utm +zone=33 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"
shp<-spTransform(shp,CRS( "+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0"))
ref<-as.data.frame(extract(a1,shp))


##1.c.1##
p <- as(extent(a1), 'SpatialPolygons') 
p <- SpatialPolygonsDataFrame(p, data.frame( ID=1:length(p)))
proj4string(p)<-proj4string(a1)

##1.c.2##
r=19; g=20; b=21;
plotRGB(a1,r=r,g=g,b=b,stretch="lin", axes=T)
plot(shp,pch=21,bg="red",col="yellow",cex=1.9,lwd=2.5,add=T)
##1.c.3##
col<-colorRampPalette(c("lightgrey","orange","yellow","limegreen","forestgreen"))
##1.c.4##
classNames<-c("deciduous","coniferous","heather_young","heather_old","heather_shrub","bare_ground","xeric_grass")

########################################################################################
##2)##
######

##2.a.1##
multi_Class_Sampling(in.raster=a1,init.samples=50,sample_type="regular",nb_models=200,nb_it=10,buffer=15,reference=ref,model="rf",area=p,mtry=10,last=F,
seed=3,init.seed="sample", outPath=outPath,step=1,classNames=classNames,n_classes=7,multiTest=1,RGB=c(19,20,21),overwrite=TRUE)

##2.b.1##
multi_Class_Sampling(in.raster=out.raster,init.samples=50,sample_type="regular",nb_models=300,nb_it=10,buffer=15,reference=out.reference,model="rf",area=p,mtry=10,last=F,seed=3,init.seed="sample", outPath=outPath,step=6,classNames=out.names,n_classes=7,multiTest=1,RGB=c(19,20,21),overwrite=TRUE)

########################################################################################
##3)##
######

##3.a.1##
plot_results(inPath=outPath)


