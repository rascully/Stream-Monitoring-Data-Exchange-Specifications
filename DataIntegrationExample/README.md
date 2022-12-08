# Disclaimer

This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

Although these data have been processed successfully on a computer system at the U.S. Geological Survey (USGS), no warranty expressed or implied is made regarding the display or utility of the data for other purposes, nor on all computer systems, nor shall the act of distribution constitute any such warranty. The USGS or the U.S. Government shall not be held liable for improper or incorrect use of the data described and/or contained herein.

# Background 
This is the code used to integrated stream habitat data for the Stream Habitat Metrics Integration Project. The following code files are used:

/R/DownloadAndCleanBLMAIMData.R - acceses and pre-processes BLM lotic AIM  data

/R/DownloadAndCleanEPANRSA.R - acceses and pre-processes EPA NARS NRSA data

/R/DownloadAndCleanUSFSAREMPData.R - acceses and pre-processes AREMP data

/R/CombineData.R - integrates pre-processed data from 4 wadeable stream monitoring programs

# Overview 
 
We wrote R code to integrate source data based on the Stream Monitoring Data exchange specifications and the data mapping. The code is published as a GitHub (Lab) Repository Stream-Monitoring-Data-Exchange-Specifications.

To run the integration code, download the repository and packages detailed on the GitHub repository and run:

Download the repository and run: 

```
    source(paste0(getwd(), "/Data Intergration Example/R/Combine Data.R")) 
    data <- integrate_data() 
```

* The integrated_data() function in 'CombineData.R'will run the functions:  
  * Donwnload and clean AREMP Data.R
  * Donwnload and clean BLM AIM Data.R
  * Donwnload and clean EPA NRSA  Data.R

The USFS PIBO data are pre-processed within the 'CombineData.R' code and does not have a separate pre-procesd file. Data are directly pulled into the integrated_data() fuction. 

The function will return a dataset combining the original four source datasets into one dataset based on the [Stream-Monitoring-Data-Exchange-Specifications
](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/tree/master/DataExchangeStandardTables)

The data are formatted as an Access database via a Microsoft Excel file and as four CSV files. The data structure is displayed here at the main repository [ReadMe](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/README.md).

All code was authored by Rebecca Scully and Emily Heaston.

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
_pending_ Funding for the development of the Stream Monitoring Data Exchange Standards was provided by the U.S. Geological Survey, U.S. Bureau of Land Management and USDA Forest Service. The use of trade, product, or firm names in this repository does not imply endorsement by the US government.

# License 
_License will be public domain_

# Citing 
Scully, R. and Heaston, E., 2022. Stream Monitoring Data Exchange Standards, GitHub repository, https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications



