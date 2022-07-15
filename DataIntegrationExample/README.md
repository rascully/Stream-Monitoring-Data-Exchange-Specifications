# USGS Disclaimer for Draft Software and Data Exchange Specifications 

This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

# Background 
This repository contains the code to integrate stream habitat metrics from four stream habitat monitoring programs based on the data exchange specifications describe in the  and Scully et. al 2022 *Methods for Building and Applying a Data Exchange Standard for Integrating Stream Habitat Data from Multiple* Monitoring Programs

# Overview 
 
We wrote R code to integrate source data based on the Stream Monitoring Data exchange specifications and the data mapping. The code is published as a GitHub (Lab) Repository Integrating Stream Monitoring Data From Multiple Programs. To run the integration code, download the repository and packages detailed on the GitHub repository and run:

Download the repository and run: 

```
    source(paste0(getwd(), "/Data Intergration Example/R/Combine Data.R")) 
    data <- integrate_data() 
```

* The integrated_data() function in 'Combine Data.R'will run the functions:  
  * Donwnload and clean AREMP Data.R
  * Donwnload and clean BLM AIM Data.R
  * Donwnload and clean EPA NRSA  Data.R

The USFS PIBO data is not reformatted it is directly pulled into the integrated_data() fuction. 

The function will return a dataset combined the original data into one dataset based on [Stream Monitoring Data Exchange Specifications repository](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications). 

The products are accessible to the public via the USGS ScienceBase data repository (Scully, 2022a). We produce as Microsoft Access Database, an Excel file with each data table as a worksheet tab, and .csv files. Additionally, we share an  Analysis Stream Habitat Metric Dataset.csv, a flat version of the relational database. Analysis-ready data are scientific data available in optimized formats suited to be easily incorporated into any workflow or visualization without additional formatting. Each dataset on ScienceBase have human and machine readable metadata. 

All code was authored by Rebecca Scully and reviewed by !!!!) 

# Installation 
 To use this code install packages: 
 
 | Packages    |
|-------------|
| data.table  |
| downloader  |
| dplyr       |
| geojsonio   |
| httr        |
| hutils      |
| openxlsx    |
| plyr        |
| raster      |
| readr       |
| readxl      |
| rgdal       |
| rvest       |
| sbtools     |
| sf          |
| sjmisc      |
| sp          |
| stringr     |
| tidyverse   |
| tmap        |


# Funding 
This work was funded by the U.S. Geological Survey, U.S. Forest Service and the U.S. Bureau of Land Management. 

# License 
# Citing 
Scully, R., 2022. Integrating Stream Monitoring Data From Multiple Programs, GitHub repository. https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications



