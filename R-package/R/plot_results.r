#' Plot Habitat Types
#'
#'A quick wrapper to produce a habitat type map and habitat type proportions in a pie chart.
#'
#' @param inPath file path (character) for results of habitat type sampling and probability mapping (same as outPath from function multi_Class_Sampling)
#' @param color colors for different habitat types, have to be a color vector of length number of habitat types, there is a default colorRamp provided
#'
#' @return two plot windows
#' 1) raster map of habitat type distribution
#' 2) pie chart of habitat type proportions
#' 3) a raster map with delineated habitat types -> HabitatMap_final.tif
#'
#' @export

###################################################################################
plot_Results <- function(inPath, color = NULL) {
    ##3.a.1##
    setwd(inPath)
    files <- grep(list.files()[grep(list.files(), pattern = ".tif$")],
                  pattern = "step",
                  value = T)
    numberHabitats <- length(files)

    classNames <- vector("character", length = length(files))
    for (i in 1:length(files)) {
        classNames[i] <- substr(files[i], 9, nchar(files[i]) - 4)
    }

    if (numberHabitats < 10) {
        ni <- paste("0", i, sep = "")
    } else{
        ni <- numberHabitats
    }

    load(paste("threshold_step_", ni, sep = ""))
    thres <- threshold
    class <- raster::stack(files[1:length(files)], files[1])

    col <- colorRampPalette(
        c(
            "red",
            "sienna1",
            "yellow",
            "limegreen",
            "forestgreen",
            "blue",
            "darkviolet",
            "lightgrey"
        )
    )

    ###Classification
    for (i in 1:(length(files) + 1)) {
        if (i == (length(files) + 1)) {
            dummy <- raster::raster(files[(i - 1)])
            dummy[dummy < thres[(i - 1)]] <- i
            dummy[dummy >= thres[(i - 1)]] <- NA
            class[[i]] <- dummy
        } else {
            dummy <- raster::raster(files[i])
            dummy[dummy < thres[i]] <- NA
            dummy[dummy >= thres[i]] <- i
            class[[i]] <- dummy
        }
    }
    modelHS <- raster::merge(class[[1:(numberHabitats + 1)]])

    ##3.b.1##
    brk = seq(0.5, numberHabitats + 1.5, 1)

    if (.Platform$OS.type == "unix") {
        x11()
    } else {
        windows()
    }

    if (length(color) == 0) {
        plot(
            modelHS,
            col = col(numberHabitats + 1),
            breaks = brk,
            legend.shrink = 1
        )
    } else{
        plot(
            modelHS,
            col = color,
            breaks = brk,
            legend.shrink = 1
        )
    }
    raster::writeRaster(
        modelHS,
        filename = "HabitatMap_final.tif",
        format = "GTiff",
        overwrite = T
    )

    ##3.b.2##
    stats <- vector("numeric", length = length(files))
    for (i in 1:length(files)) {
        dummy <- raster::raster(files[i])
        dummy[dummy < thres[i]] <- NA
        dummy[dummy >= thres[i]] <- 1
        stats[i] <- raster::freq(dummy, value = 1, useNA = "no")
    }

    dummy <- raster::Which(!is.na(raster(files[1])))
    ref <- raster::freq(dummy, value = 1, useNA = "no")
    percent <- round((stats / ref) * 100, 2)
    rest <- round(100 - sum(percent), 2)
    percent <- append(percent, rest)

    if (.Platform$OS.type == "unix") {
        x11()
    } else {
        windows()
    }

    par(oma = c(0, 4, 0, 0))
    if (length(color) == 0) {
        pie(
            percent,
            labels = percent,
            col = col(numberHabitats + 1),
            main = "",
            cex = 1.5,
            lwd = 2,
            border = "white",
            init.angle = 45
        )
        legend(
            x = -1.8,
            y = 1.5,
            legend = append(classNames, "other"),
            fill = col(numberHabitats + 1),
            cex = 1.55,
            xpd = NA,
            bty = "n"
        )
    } else{
        pie(
            percent,
            labels = percent,
            col = color,
            main = "",
            cex = 1.5,
            lwd = 2,
            border = "white",
            init.angle = 45
        )
        legend(
            x = -1.8,
            y = 1.5,
            legend = append(classNames, "other"),
            fill = color,
            cex = 1.55,
            xpd = NA,
            bty = "n"
        )
    }
}
