# Habitat Sampler

The demo shows how to classify 7 classes using a Sentinel 2 image.

## Setup

0) Install and load all required packages and functions \
    0.1 set working directories (use: '/') \
    0.2 set data input/output paths (use: '/') \
    0.3 install HaSa library and its dependencies
 
1) Prepare Input Data \
    1.a.1) Satellite time series stack clipped to study area (specify file name) \
    1.a.2) Satellite time series stack -> clip via R routine
        
    1.b.1) Reference Spectra as table (rows=habitats, columns=spectral wavebands)  \
    1.b.2) Reference Point Shape -> extract spectral wavebands from Satellite time series stack via R routine (change projection if neccessary)
    
    1.c.1) create SpatialPolygonsDataFrame from satellite time series stack extent  for setting sampling boundaries  \
    1.c.2) define RGB channels for image plot \
    1.c.3) define color Palette for habitat type probability plot \
    1.c.4) create vector with class names in the order of reference spectra (rows = habitats)


## Parametrization

2) Habitat sampling\
    2.a.1) Execute R function `multi_Class_Sampling`.
    ```R
    multi_Class_Sampling <- 
            function(
                in.raster,      #clipped satellite time series stack [raster brick]
                init.samples,   #starting number of spatial samples (suggest: 30)
                sample_type     # distribution of spatial samples ("random" or "regular"; suggest: "regular")   
                nb_models       # number of models to collect (suggest: 200)  
                nb_it           # number of iterations for model accuracy (suggest:10) 
                buffer          # distance (in m) for new sample collection around initial samples (depends on pixel size)
                reference       # table of reference spectra [data.frame]
                model           # which machine learning algorithm to use ("rf" random forest or "svm" support vector machine; suggest: rf)
                area            # SpatialPolygonsDataFrame from satellite time series stack extent
                mtry            # number of predictor used at random forest splitting nodes (suggest: mtry << n predictors)
                last            # only true for one class classifier ("TRUE" or "FALSE"; suggest: "F")
                seed            # set seed for reproducable results (suggest: 3)
                init.seed       # "sample" for new or use Run@seeds to reproduce previous steps
                outPath         # output path for saving results
                step            # at which step should the procedure start (see 2.b.1) (suggest: 1 at the beginning)
                classNames      # vector with class names in the order of reference spectra
                n_classes       # total number of classes (habitat types) to be separated
                multiTest       # number of test runs to compare different probability output
                RGB             # pallet colors for the interactive plots
                overwrite       # overwrite the KML and raster files from previous runs
           )
    ```
    
    
### Remarks 
**remark 1)** 
The results from previous steps are reproducable when using the same seed value and int.seed=Run@seeds (e.g. Run02@seeds) in consequence, init.sample for regular sampling determines an invariant sample distribution, use random sampling or vary init.sample to get varying sample distributions.

**remark 2)** 
Regular sampling is faster.

**remark 3)** 
The argument `last = T` can be set when only one class should be separated from the background pixels.

**remark 4)** 
The R object Run holds slots of: 
```R
                models          # selected classifiers
                ref_samples     # spatial points of selected samples (see WriteOutSamples.r)
                switch          # the target class is [2] if switch is not NA then the target class must be changed from [1] to [2] (see WriteOutSamples.r)
                layer           # raster layer of habitat type probability
                mod_all         # all classifiers from nb_models
                class_ind       # predictive distance metric for all classes
                seeds           # seeds to reproduce respecitve step/habitat type sampling
```

**remark 5)** 
With the clause `if multiTest > 1` the user will get multiple maps and will be ask to enter the number of the probability distribution that is apropriate.                                                                    


## Executing


### Step 1
1) An interactive map is plotted in a web browser (e.g. firefox for linux), containing:
    * background map
    * RGB image
    * selected habitat type map
    * probaility threshold on mouse hover
    * predictive distance

2) The user has to decide to extract this habitat type on the basis of a threshold (**2.1**) or to sample again (**2.2**) \
    2.1 Enter threshold in R console, the outcome are 6 files saved to disk for the selected habitat type and we move **Step 2..N**. 
    The files are:
    
    * HabitatSampler object (Run) - R Binary
    * probability map - *.kml, *.png, geocoded *.tif
    * threshold list - R Binary
    * leaflet interactive web interface - *.html
     After habitat extraction is done the user have to decide to adjust starting number of samples and number of models or proceed automaticlay to next step enter sample/model adjsutement (../..) or auto (0) in R console.
        
    2.2 Enter 0 in R console, the user have to decide to adjust starting number of samples and number of models or proceed automaticlay to new sampling enter
    sample/model adjustement (../..) or auto (0) in R console. Proceed with **1** until decision (**2.1**) has made.
    
### Step 2...N

Repeat **Step 1** for a new habitat type until **N** habitat types.
    
**Note**: In case it is not possible to converge, i.e., convergence fails, due to the fact either no `models` can be selected or `init.samples` are not enough or another error occurs, it is possible to restart by re-running again the `multi_Class_Sampling` function with the following new argument's values:

    ```R
        in.raster       # out.raster
        init.samples    # printed in console
        nb_models       # printed in console
        reference       # out.reference
        step            # specify next step number
        classNames      # out.names
    ```                                           

## Output Plot

3) generate habitat type map and summary statistics \
    3.1) Call function `plot_results` with the following arguments:
    
    ```R
        inPath         # input files (*.tif), equals outPath 
        color          # vector of plot colors, one for each habitat type
    ```
    
**remark 1)**
If color is not specified an internal color table will be called.
