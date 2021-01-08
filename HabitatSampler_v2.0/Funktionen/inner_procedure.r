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

################################################################################
sample_nb <- function(raster,
                      nb_samples,
                      sample_type,
                      nb_mean,
                      nb_it,
                      buffer,
                      reference,
                      model,
                      area,
                      mtry,
                      last,
                      seed,
                      init.seed) {
  ### 1. Maske start=30 optimal = 100
  ### 2.Maske start=40 optimal=110
  ### 3. Maske start=40 optimal=70
  ### 4. Maske start=40 optimal=140
  ### 5. opt=70
  require(spatialEco)
  require(randomForest)
  require(e1071)
  n_channel <- length(names(raster))
  ###velox
  rID = raster[[1]]
  rID[] = 1:(nrow(rID) * ncol(rID))
  r = stack(rID, raster)
  ras.vx <- velox(r)
  ###
  l <- 1        ###6. opt=260
  model1 <- 1
  pbtn1 <- matrix(1, nrow = 1, ncol = 1)
  pbtn2 <- matrix(2, nrow = 1, ncol = 1)
  m <- vector("numeric", length = length(nb_samples))
  layer <- list()
  for (r in nb_samples) {
    ############################################################################
    if (last == T) {
      reference <- rbind(reference, rep(3000, ncol(reference)))
    }
    n <- nb_it
    sample_size <- r
    max_samples_per_class <- sample_size * 5
    if (init.seed == "sample") {
      seed2 <-
        sample(c(1:1000000), size = nb_mean, replace = F)
    } else {
      seed2 <- init.seed
    }
    oobe <- matrix(NA, nrow = n, ncol = nb_mean)
    models <- list()
    points <- list()
    dif <- matrix(NA, nrow = nb_mean, ncol = nrow(reference))
    channel <- matrix(NA, nrow = nb_mean, ncol = nrow(reference))
    switch <- matrix(NA, nrow = nb_mean, ncol = nrow(reference))
    pb <- txtProgressBar(min = 1,
                         max = nb_mean,
                         style = 3)

    for (k in 1:nb_mean) {
      for (j in 1:n) {
        ###Vorbereitung Klassifizierung
        if (j == 1) {
          classes <- as.factor(c(1, 1))
          if (sample_type == "random") {
            set.seed(seed2[k])
            pbt <- sampleRandom(raster, size = sample_size, sp = T)
          }
          if (sample_type == "regular") {
            pbt <- sampleRegular(raster, size = sample_size, sp = T)
          }
          pbt <- point.in.poly(pbt, area)[, 1:n_channel]

          f <- which(is.na(pbt@data[1]))
          if (length(f) != 0) {
            pbt <- pbt[-f,]
          }

          set.seed(seed2[k])
          classes <- as.factor(sample(c(1:2), size = nrow(pbt), replace = T))
          if (length(levels(classes)) < 2) {
            break
          }

          data <- as.data.frame(cbind(classes, pbt@data))
        }
        ########################################################################
        if (model == "rf") {
          model1 <- randomForest(as.factor(classes) ~ .,
                                 data = data,
                                 mtry = mtry)
          if (is.na(mean(model1$err.rate[, 1])) == TRUE) {
            break
          }
          oobe[j, k] <- mean(model1$err.rate[, 1])
        }
        ###
        if (model == "svm") {
          model1 <- svm(as.factor(classes) ~ ., data = data)
          co <-
            length(which(
              as.numeric(as.character(model1$fitted)) - as.numeric(as.character(classes)) == 0
            ))
          if (co == 0) {
            break
          }
          oobe[j, k] <- 1 - (co / length(classes))
        }

        #if ( j > 1) {if (oobe[j,k] < 0.02 || abs(oobe[(j-1),k]-oobe[j,k]) <= 0.011 )
        if (j > 1) {
          if (oobe[j, k] < 0.02)
          {
            models[[k]] <- model1
            points[[k]] <- rbind(pbtn1, pbtn2)
            break
          }

          if (oobe[(j - 1), k] <= oobe[j, k]) {
            models[[k]] <- model_pre
            points[[k]] <- rbind(pbtn1_pre, pbtn2_pre)
            break
          }

          if (j == n &
              oobe[j, k] >= 0.02) {
            models[[k]] <- "NULL"
            points[[k]] <- "NULL"
            break
          }
        }
        model_pre <- model1
        pbtn1_pre <- pbtn1
        pbtn2_pre <- pbtn2
        oobe <<- oobe
        ########################################################################
        if (model == "rf") {
          correct <-
            which(as.numeric(as.character(classes)) - as.numeric(as.character(model1$predicted)) == 0)
        }
        if (model == "svm") {
          correct <-
            which(as.numeric(as.character(model1$fitted)) - as.numeric(as.character(classes)) == 0)
        }
        ########################################################################
        if (length(which(classes[correct] == 1)) == 0) {
          if (j == 1) {
            break
          } else{
            pbtn1 <- pbtn1
          }
        } else {
          d1 <- correct[which(classes[correct] == 1)]

          ###neue Samples aus richtig klassifizierten
          p1 <- pbt@coords[d1,]
          ##coordinaten
          pbtn1 <- as.data.frame(cbind(classes[d1], matrix(p1, ncol = 2)))
          coordinates(pbtn1) <- c("V2", "V3")
          proj4string(pbtn1) <- proj4string(pbt)

          poly <- gBuffer(spgeom = pbtn1,
                          width = buffer,
                          byid = TRUE)
          test <- ras.vx$extract(sp = poly)

          for (i in 1:length(test)) {
            s1 <- dim(test[[i]])[1]
            if (s1 <= 5) {
              test[[i]] <- test[[i]]
            } else {
              set.seed(seed)
              test[[i]] <- test[[i]][sample(c(1:s1), 5, replace = F),]
            }
          }

          for (i in 1:length(test)) {
            if (i == 1) {
              co <- xyFromCell(raster, test[[i]][, 1])
            } else {
              co <- rbind(co, xyFromCell(raster, test[[i]][, 1]))
            }
          }
          pbtn1 <- as.data.frame(cbind(rep(1, nrow(co)), co))
          coordinates(pbtn1) <- c("x", "y")

          test1 <- as.matrix(do.call(rbind, test)[,-1])
          if (ncol(test1) == 1) {
            test1 <- t(test1)
          }
          colnames(test1) <- names(raster)
          if (length(which(is.na(test1))) > 0) {
            pbtn1 <- pbtn1[complete.cases(test1),]
            test1 <- test1[complete.cases(test1),]
          }
        }
        if (class(test1)[1] == "numeric") {
          test1 <- t(matrix(test1))
        }
        if (nrow(test1) == 0) {
          break
        }
        ##############################
        ##############################
        if (length(which(classes[correct] == 2)) == 0) {
          if (j == 1) {
            break
          } else{
            pbtn2 <- pbtn2
          }
        } else {
          d2 <- correct[which(classes[correct] == 2)]

          ###neue Samples aus richtig klassifizierten
          p2 <- pbt@coords[d2,]
          pbtn2 <- as.data.frame(cbind(classes[d2], matrix(p2, ncol = 2)))
          coordinates(pbtn2) <- c("V2", "V3")
          proj4string(pbtn2) <- proj4string(pbt)

          poly <- gBuffer(spgeom = pbtn2,
                          width = buffer,
                          byid = TRUE)
          test <- ras.vx$extract(sp = poly)

          for (i in 1:length(test)) {
            s1 <- dim(test[[i]])[1]
            if (s1 <= 5) {
              test[[i]] <- test[[i]]
            } else {
              set.seed(seed)
              test[[i]] <- test[[i]][sample(c(1:s1), 5, replace = F),]
            }
          }

          for (i in 1:length(test)) {
            if (i == 1) {
              co <- xyFromCell(raster, test[[i]][, 1])
            } else {
              co <- rbind(co, xyFromCell(raster, test[[i]][, 1]))
            }
          }
          pbtn2 <- as.data.frame(cbind(rep(2, nrow(co)), co))
          coordinates(pbtn2) <- c("x", "y")

          test2 <-
            as.matrix(do.call(rbind, test)[,-1])
          if (ncol(test2) == 1) {
            test2 <- t(test2)
          }
          colnames(test2) <- names(raster)
          if (length(which(is.na(test2))) > 0) {
            pbtn2 <- pbtn2[complete.cases(test2),]
            test2 <- test2[complete.cases(test2),]
          }
        }
        if (class(test2)[1] == "numeric") {
          test2 <- t(matrix(test2))
        }
        if (nrow(test2) == 0) {
          break
        }
        ######################################
        ###Gleichverteilung samples in Klassen
        di <- c(nrow(pbtn1), nrow(pbtn2))
        if (abs(nrow(pbtn1) - nrow(pbtn2)) > min(di) * 0.3) {
          if (which.min(di) == 2) {
            set.seed(seed)
            d3 <- sample(1:nrow(pbtn1), nrow(pbtn2), replace = F)
            pbtn1 <- pbtn1[d3,]
            test1 <- test1[d3,]
          } else {
            set.seed(seed)
            d4 <- sample(1:nrow(pbtn2), nrow(pbtn1), replace = F)
            pbtn2 <- pbtn2[d4,]
            test2 <- test2[d4,]
          }
        }
        #####################################
        ###max Klassenbelegungswert
        if (nrow(pbtn1) > max_samples_per_class) {
          set.seed(seed)
          dr <- sample(1:nrow(pbtn1), max_samples_per_class, replace = F)
          pbtn1 <- pbtn1[dr,]
          test1 <- test1[dr,]
        }
        if (nrow(pbtn2) > max_samples_per_class) {
          set.seed(seed)
          dr <- sample(1:nrow(pbtn2), max_samples_per_class, replace = F)
          pbtn2 <- pbtn2[dr,]
          test2 <- test2[dr,]
        }
        ########################################################################
        data <- as.data.frame(cbind(append(pbtn1@data$V1, pbtn2@data$V1),
                                    rbind(test1, test2))) ##data
        names(data)[1] <- "classes"
        classes <- data$classes
        pbt <- rbind(pbtn1, pbtn2)
      }
      setTxtProgressBar(pb, k)
    }

    if (length(models) == 0 |
        length(which(models == "NULL")) == length(models)) {
      stop("No Models - would you be so kind to increase init.samples, please")
    }
    if (length(which(models == "NULL")) > 0) {
      models <- models[-which(models == "NULL")]
    }
    for (jj in 1:nrow(reference)) {
      ref <- jj
      rr = 3
      for (i in 1:length(models)) {
        if (i == 1) {
          dummy <-
            as.numeric(as.character(predict(models[[i]], newdata = reference)))
          if (dummy[ref] != 2) {
            dummy[dummy == 1] <-
              3
            dummy[dummy == 2] <- 1
            dummy[dummy == 3] <- 2
            switch[i, jj] <- i
          }
        } else {
          dummy2 <-
            as.numeric(as.character(predict(models[[i]], newdata = reference)))

          if (dummy2[ref] != 2) {
            dummy2[dummy2 == 1] <- 3
            dummy2[dummy2 == 2] <- 1
            dummy2[dummy2 == 3] <- 2
            switch[i, jj] <- i
          }

          dummy_set <- dummy
          dummy <- dummy + dummy2

          dummy3 <- dummy / dummy[ref]
          dif[i, jj] <- dummy3[ref] - max(dummy3[-ref])

          if (i > 2) {
            if (dummy3[ref] - max(dummy3[-ref]) > dif[(rr - 1), jj]) {
              dummy <- dummy
              channel[i, jj] <- i
              dif[(rr - 1), jj] <- dif[i, jj]
            } else {
              dummy <- dummy_set
            }
          }
        }
      }
      m[l] <- max(dif[2,], na.rm = T)
    }
    index <<- which.max(dif[2,])
    ch <- as.numeric(na.omit(channel[, index]))
    if (length(ch) == 0) {
      stop(
        "No optimal classifier - would you be so kind to adjust init.samples & nb_models, please"
      )
    }
    acc <<- (round(m[l] ^ 2, 2) / 0.25)

    print(paste("class=", index, "  difference=",
                (round(m[l] ^ 2, 2) / 0.25),
                sep = ""))

    l <- l + 1
  }
  close(pb)

  mod_all <- models
  models <- models[ch]
  print(paste("n_models =", length(models)))
  switch <- switch[ch, index]
  points <- points[ch]
  dif <- dif[2,]
  ##############################################################################
  ###Vohersage
  ch <- c(1:length(models))
  switch <- switch

  j <- 1
  for (i in ch) {
    if (j == 1) {
      result1 <- predict(object = raster, model = models[[i]])

      if (is.na(switch[i]) == F) {
        result1 <-
          reclassify(result1, rbind(c(0.5, 1.5, 2), c(1.6, 2.5, 1)))
      }
    } else {
      result1 <- stack(result1, predict(object = raster, model = models[[i]]))

      if (is.na(switch[i]) == F) {
        result1[[j]] <-
          reclassify(result1[[j]], rbind(c(0.5, 1.5, 2), c(1.6, 2.5, 1)))
      }
    }
    print(j)
    j <- j + 1
  }
  ###
  dummy <- brick(result1)
  dummy <- calc(dummy, fun = sum)
  layer[[1]] <- dummy

  setClass(
    "Habitat",
    representation(
      models = "list",
      ref_samples = "list",
      switch = "vector",
      layer = "list",
      mod_all = "list",
      class_ind = "numeric",
      seeds = "numeric"
    )
  )
  new(
    "Habitat",
    models = models,
    ref_samples = points,
    switch = switch,
    layer = layer,
    mod_all = mod_all,
    class_ind = dif,
    seeds = seed2
  )
}
