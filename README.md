# Support material for "A Cellular Platform for the Development of Synthetic Living Machines" [![DOI](https://zenodo.org/badge/328650593.svg)](https://zenodo.org/badge/latestdoi/328650593)

*by Douglas Blackiston, Emma Lederer, Sam Kriegman, Simon Garnier, Josh Bongard, and Michael Levin*

---

This repository contains code and data for reproducing the behavioral analysis described in the manuscript. 

In order to run the included code, you will need to install the following software:
+ `R` (https://cran.r-project.org/)
+ `RStudio` (https://rstudio.com/)
+ The following `R` packages: 
  + `readr`
  + `readxl`
  + `dplyr`
  + `stringr`
  + `lubridate`
  + `ggplot2`
  + `rebmix`
  + `circular`
  + `patchwork`
  + `CEC`
  + `cluster`
  + `ggforce`
  + `RColorBrewer`
  + `tidyr`
  + `msm`
  + `tidygraph`
  + `ggraph`
  + `scales`
  
All other dependencies will be installed for you during the execution of the scripts and notebooks. 

---

In order to reproduce the analysis, you will need to perform the following steps:
1. Download (or clone) the content of the repository to your local computer. 
2. Open `data_prep.R` and `final.Rmd` with `RStudio`.
3. Run the content of `data_prep.R` to prepare the raw data for analysis. 
4. Run the content of `final.Rmd` to obtain the results presented in the manuscript. 
