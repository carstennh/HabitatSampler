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
###########################################################################################################
iplot<-function(x,y,HaTy,r,g,b, acc, outPath) {#x=layerInfo, y=RGB Image
###########################################################################################################
if (exists("color")==F) {pal <- leaflet::colorNumeric(c("lightgrey","orange","yellow","limegreen","forestgreen"), domain=NULL, na.color = "transparent")}else
                                   {pal <- leaflet::colorNumeric(color, domain=NULL, na.color = "transparent")}
###########################################################################################################
###[1] Create RGB Colors (z) and RGB Image Representation (rr) -> code based on raster::plotRGB
 linStretchVec <- function (x) {
    v <- stats::quantile(x, c(0.02, 0.98), na.rm = TRUE)
    temp <- (255 * (x - v[1]))/(v[2] - v[1])
    temp[temp < 0] <- 0
    temp[temp > 255] <- 255
    return(temp)
}
palo<-function(y) { d<-which(y<=0); if (length(d)>0) {y[d]<-1;z[y]}else {z[y]} }

    maxpixels=10000000;colNA="#FFFAFA99";bgalpha=0;alpha=1
  	r <- raster::sampleRegular(raster::raster(y,r), maxpixels,  asRaster=TRUE, useGDAL=TRUE)
	g <- raster::sampleRegular(raster::raster(y,g), maxpixels, asRaster=TRUE, useGDAL=TRUE)
	b <- raster::sampleRegular(raster::raster(y,b), maxpixels,  asRaster=TRUE, useGDAL=TRUE)
	
    RGB <- cbind(raster::getValues(r), raster::getValues(g), raster::getValues(b))
    naind<-which(is.na(RGB[,1]))
    RGB <- stats::na.omit(RGB)
    RGB[,1] <- linStretchVec(RGB[,1])
    RGB[,2] <- linStretchVec(RGB[,2])
    RGB[,3] <- linStretchVec(RGB[,3])

    scale <- 255
    bg <- grDevices::col2rgb(colNA)
    bg <- grDevices::rgb(bg[1], bg[2], bg[3], alpha=bgalpha, max=255)
    z <- rep( bg, times=raster::ncell(r))
    if (length(naind) >0) {z[-naind] <- grDevices::rgb(RGB[,1], RGB[,2], RGB[,3],  max=scale)}else
                                       {z <- grDevices::rgb(RGB[,1], RGB[,2], RGB[,3],  max=scale)}#hier sind die finalen Farbwerte
######
#z <- matrix(z, nrow=nrow(r), ncol=ncol(r), byrow=T)
#bb <- as.vector(t(bbox(r)))
#xlim=c(bb[1], bb[2])
#ylim=c(bb[3], bb[4])
#plot(NA, NA, xlim=xlim, ylim=ylim, type = "n", xaxs='i', yaxs='i', xlab="", ylab="", asp=1, axes=T)
#graphics::rasterImage(z, bb[1], bb[3], bb[2], bb[4], interpolate=F)
######
rr<-x
raster::values(rr)<-1:raster::ncell(rr)

###########################################################################################################
##[2] Create Leaflet Html output for Webbrowser
mv<- leaflet::leaflet() 
  #addTiles(urlTemplate ='http://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png') %>% 
  mv<- leaflet::addProviderTiles(map=mv, "CartoDB.PositronNoLabels")

  mv<- leaflet::addRasterImage(map=mv, rr, colors=palo, opacity = 1, project = TRUE, method="ngb", group = "RGB Composite",
                 layerId = "RGB Composite") 
 
  mv<- leaflet::addRasterImage(map=mv, x, colors=pal, opacity = 1, project = TRUE, method="ngb", group = HaTy,
                 layerId = HaTy) 
  
  mv<- leafem::addImageQuery(map=mv, x, project = TRUE,
                layerId = HaTy, prefix = "Habitat Type")

  mv<- leaflet::addLegend(map=mv, "bottomright",pal = pal, values = raster::cellStats(x,"range"),
               title = "Habitat Type Probability",opacity = 1)
  mv<- leaflet::addLayersControl(map=mv, overlayGroups = c("RGB Composite", HaTy))
 
 if(.Platform$OS.type == "unix") {  
                                                        htmlwidgets::saveWidget(mv, paste(outPath,'leaflet.html',sep="")) 
                                                        cat("<style>.leaflet-container {cursor: crosshair !important;}</style>", file = paste(outPath,'leaflet.html',sep=""), append = TRUE)
                                                        utils::browseURL(paste(outPath,'leaflet.html',sep=""),browser="firefox")
} else {                                            htmlwidgets::saveWidget(mv, selfcontained = FALSE, paste(outPath,'leaflet.html',sep=""))
                                                        cat("<style>.leaflet-container {cursor: crosshair !important;}</style>", file = paste(outPath,'leaflet.html',sep=""), append = TRUE)
                                                        utils::browseURL(paste(outPath,'leaflet.html',sep=""))
}
 #cat("<style>.leaflet-clickable {cursor: crosshair !important;}</style>", file = "leaflet.html", append = TRUE)
}

########################################################################################################### 
#str(mv$dependencies)
#mv$dependencies[3] <- list(
#  htmlDependency(
#    name = "test"
#    ,version = "1"
#    # if local file use file instead of href below
#    #  with an absolute path
#    ,src = c("C:/Analysen/Projekte/DBH_Landsat_Change")
#    ,stylesheet = "test.css"
#  )
#)
########################################################################################################### 

