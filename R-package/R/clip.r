#' Clip
#'
#' Clips a raster object
#'
#' @param raster
#' @param shape
#'
#' @return a raster object
#' @export

clip <- function(raster, shape) {
  raster::rasterOptions(progress = "text")
  a1_crop <- raster::crop(raster, shape)
  step1 <- raster::rasterize(shape, a1_crop)
  step1 <- raster::reclassify(step1, c(1, 200, 1))
  a1_crop * step1
}
