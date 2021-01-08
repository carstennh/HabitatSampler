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
plot_results <- function(inPath, color = NULL) {
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
    class <- stack(files[1:length(files)], files[1])

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
            dummy <- raster(files[(i - 1)])
            dummy[dummy < thres[(i - 1)]] <- i
            dummy[dummy >= thres[(i - 1)]] <- NA
            class[[i]] <- dummy
        } else {
            dummy <- raster(files[i])
            dummy[dummy < thres[i]] <- NA
            dummy[dummy >= thres[i]] <- i
            class[[i]] <- dummy
        }
    }
    modelHS <- merge(class[[1:(numberHabitats + 1)]])

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
    } else {
        plot(
            modelHS,
            col = color,
            breaks = brk,
            legend.shrink = 1
        )
    }
    writeRaster(
        modelHS,
        filename = "HabitatMap_final.tif",
        format = "GTiff",
        overwrite = T
    )
    ##3.b.2##
    stats <- vector("numeric", length = length(files))

    for (i in 1:length(files)) {
        dummy <- raster(files[i])
        dummy[dummy < thres[i]] <- NA
        dummy[dummy >= thres[i]] <- 1
        stats[i] <- freq(dummy, value = 1, useNA = "no")
    }

    dummy <- Which(!is.na(raster(files[1])))
    ref <- freq(dummy, value = 1, useNA = "no")
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
