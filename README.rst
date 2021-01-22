.. figure:: GitDocs/Logo.png
    :target: https://github.com/carstennh/HabitatSampler/tree/master/HabitatSampler_v2.0
    :align: center

==================================================================================================
Procedure on Autonomous Sampling and Reductive Learning in Imagery
==================================================================================================

How to use
----------------
1. Stepwise Procedure
----------------------------------
* You need R to run the master script: **HabitatSampler_v02.r**
* Within the master script a step by step procedure is executed: **HabitatSampler_Usage.txt** 
* This is the routine: `HabitatSampler_v2.0 <https://github.com/carstennh/HabitatSampler/tree/master/HabitatSampler_v2.0>`__

2. R package
--------------------
* You need R to install the **package HaSa** that includes all functions and test data
* devtools::install_github("carstennh/HabitatSampler", subdir="R-package", build_vignettes = TRUE)
* Sometimes there are problems, then do **1.** devtools:: install_version("velox", version = "0.2.0", repos = "https://cran.uni-muenster.de/") 
* For Windows operating systems the `Rtools <https://cran.r-project.org/bin/windows/Rtools/>`__ are needed

* library(HaSa) and list datasets: data(package="HaSa") and functions: lsf.str("package:HaSa") or use library(help="HaSa")
* there are information available about programm execution and function behavior in Rmarkdown: `HabitatSampler_Usage <https://github.com/carstennh/HabitatSampler/tree/master/R-package/vignettes>`__

Input
----------------
* **Image File as Raster Layer Stack** (e.g. Satellite Time Series, RGB Drone, Orthophoto)
* **Reference File** (e.g. spectral-temporal profiles or point shape; one profile or point per category)
* **Class Names** (the categories that are defined to be delineated in imagery)

Output
----------------
* **Interactive Maps** of habitat type probailities

.. image:: GitDocs/figure_1.png
           
* **Classified Image** of chosen categories
* **Sample Distribution** of sampled categories
* **Spatial Statistics** of categories distribution
* the categories are refferred to as habitat types


.. image:: GitDocs/figure_2.png

Key Features
----------------
* the algorithm provides a set of **reference samples** for each habitat type
* the algorithm provides an ensemble of calibrated **machine learning classifiers** for each habitat type
* the algorithm provides a map of **habitat type probabilities** 
* the algorithm is optimzed for broad-scale **satellite image** time series (pixel size > 10m)
* the alogrthm can be applied on **variable image categories** in complex scenes
* the algorithm is tranferable to **variable input imagery** 

Citation
----------------
Neumann, C. (2020): Habitat sampler—A sampling algorithm for habitat type delineation in remote sensing imagery. - Diversity and Distributions, 26 (12), 1752-1766. `<https://doi.org/10.1111/ddi.13165>`__.

Credits
----------------

HaSa was developed by Carsten Neumann (Helmholtz Centre Potsdam GFZ German Research Centre for Geosciences) within the context of the
`NaTec - KRH <http://www.heather-conservation-technology.com/>`__ project funded by the German Federal Ministry of Education and Research (BMBF) (grant number: 01 LC 1602A).

The test data represent pre-processed Copernicus Sentinel-2 satellite imagery (ESA 2018). Pre-processing was done using `GTS2 <https://www.gfz-potsdam.de/en/section/remote-sensing-and-geoinformatics/projects/closed-projects/gts2/>`__ and `AROSICS <https://github.com/GFZ/arosics>`__. 

Community version and commercial support
----------------------------------------

HaSa will be further developed under a community version located at [GitLab's habitat-sampler group.](https://git.gfz-potsdam.de/habitat-sampler/HabitatSampler). For commercial support the users should contact the Helmholtz innovation lab [FernLab](https://fernlab.gfz-potsdam.de/fern-lab.html) will manage.
