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

###write out selected samples for step = 6 using 
run1<-get(load("./Data/Results/Run06"))
load("./Data/Results/threshold_step_06")
dummy<-raster("./Data/Results/step_06_xeric_grass.tif")
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
                     
res<-extract(dummy,result)    
res<-result[-which(is.na(res)),]

writeOGR(res, layer="result",dsn="./Data/Results/RefHaSa_HabitatType_06.shp",driver="ESRI Shapefile")
