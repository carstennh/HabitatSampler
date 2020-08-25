#' Sentinel-2A/B satellite time series stack 
#'
#'co-registrated and atmospherically corrected (reflectance) 9-waveband scenes for an entire phenological cylce in 2018
#' 
#'
#'The area recorded is a open heathland (dominant species:Calluna vulgaris) under different management status on a former military training ground in NE Germany, trees are mainly pine, birch and oak
#'
#' @source Data: ESA European Space Agency
#' @source Processing: GTS2 German Research Centre for Geosciences GFZ 
#'  
#' @format A RasterBrick object  (package:raster) with 54 layers:
#' \describe{
#'  \item{Wavebands:}{"blue", "green", "red", "redEdge1", "redEdge2", "redEdge3", "nearInfrared", "shortwaveInfrared1", "shortwaveInfrared2", }
#'  \item{Dates:}{"2018-03-18", "2018-04-17", "2018-05-07", "2018-06-06", "2018-07-16", "2018-07-31", "2018-09-09", "2018-09-19", "2018-10-14", }
#'  \item{Pixel Size:}{resampled to 10m, }
#'  \item{Region:}{Kyritz-Ruppiner Heide, NE Germany, Brandenburg.}
#' }
"Sentinel_Stack_2018" 

#' Habitat type point locations  
#'
#'Spatial points of habitat types marked on Sentinel_Stack_2018 
#' 
#'
#'Example data set for habitat types that can be marked as spatial points in a known area of the input image 
#'
#' @source German Research Centre for Geosciences GFZ 
#'  
#' @format A SpatialPointsDataFrame  (package:sp) with 7 points:
#' \describe{
#'  \item{Data$class:}{deciduous", "coniferous", "heath_young", "heath_old", "heath_shrub", "bare_ground", "xeric_grass", }
#'  \item{Projection:}{"+proj=utm +zone=32 +datum=WGS84 +units=m +no_defs +ellps=WGS84 +towgs84=0,0,0". }
#' }
"Example_Reference_Points" 

#' Habitat type spectra  
#'
#'Habitat types (rows) and corresponding spectral predictors (columns)
#' 
#'
#'Example data set for habitat types that can be extracted from imagery using spatial points or that is generated from a reference databases (spectral libary) with spectral predictors that correspond to the layers of the input image
#'
#' @source German Research Centre for Geosciences GFZ 
#'  
#' @format A Data.Frame with 7 observations and 54 variables:
#' \describe{
#'  \item{rows:}{class.names - deciduous", "coniferous", "heath_young", "heath_old", "heath_shrub", "bare_ground", "xeric_grass", }
#'  \item{columns:}{spectral predictors either extracted from spectral library with columns = image layers or extracted from spatial point locations. }
#' }
"Example_Reference_Table"
