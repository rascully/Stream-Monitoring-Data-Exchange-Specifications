# Disclaimer
This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

Although these data have been processed successfully on a computer system at the U.S. Geological Survey (USGS), no warranty expressed or implied is made regarding the display or utility of the data for other purposes, nor on all computer systems, nor shall the act of distribution constitute any such warranty. The USGS or the U.S. Government shall not be held liable for improper or incorrect use of the data described and/or contained herein.

# Recommended Citation
Scully, R. and Heaston, E. 2022. Stream Monitoring Data Exchange Standards, GitHub repository, https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications

# Requirements
R (version?) is required to execute this code.

Install the following packages:
 To use this code install packages: 
 
|             |         |         |           |
|-------------|---------|---------|-----------|
| data.table  | hutils  | readlx  | sjmisc    |
| downloader  | openxlsx| rgdal   | sp        |
| dplyr       | plyr    | rvest   | stringer  |
| geojsonio   | raster  | sbtools | tidyverse |
| httr        | readr   | sf      | tmap      |

# Contents
***Input***
* _/R/DownloadAndCleanBLMAIMData.R_: acceses and pre-processes BLM lotic AIM data

* _/R/DownloadAndCleanEPANRSA.R_: acceses and pre-processes EPA NARS NRSA data

* _/R/DownloadAndCleanUSFSAREMPData.R_: acceses and pre-processes USFS AREMP data

* _/R/CombineData.R_: transforms and combines pre-processed data from 4 wadeable stream monitoring programs (BLM lotic AIM, EPA NARS NRSA, USFS AREMP, USFS PIBO MP)

* _/Data/CategoryDictionary.csv_: categorical data dictionary used by R code to fill in metric-controlled vocabulary definitions and Data Exchange Standard tables

* _/Data/MetadataDictionary.csv_: data dictionary used by R code to fill in Data Exchange Standard tables

* _/DataExchangeStandardTables/DataMappingDES.csv_: used by R code to map data between programs and combine data

***Output***
* _DataIntegrationExample/data/csv_: folder containing the 'RecordLevel', 'Location', 'Event', and 'MeasurementOrFact' integrated data tables produced by R code as well as the 'RelationalDataTablesStreamHabitatMetrics.xlsx' file used to create the 'Integrated Data Set.accdb'. To recreate the relationships between tables in Microsoft Access, refer to the Database Schema diagram below.

* _DataExchangeStandardTables_: folder containing the Data Exchange Standards for the 'RecordLevel', 'Location', 'Event' and 'MeasurementOrFact' data tables produced by R code


# Getting Started
To run the data integration code, download the repository and packages as described above and run:

```
    source(paste0(getwd(), "/Data Intergration Example/R/Combine Data.R")) 
    data <- integrate_data() 
```

The integrated_data() function in 'CombineData.R'will run the functions:  
  * Donwnload and clean AREMP Data.R
  * Donwnload and clean BLM AIM Data.R
  * Donwnload and clean EPA NRSA  Data.R

The USFS PIBO data are pre-processed within the 'CombineData.R' code and does not have a separate pre-procesd file. Data are directly pulled into the integrated_data() fuction.

# Database Schema
![database schema](/Figures/databaseERD3_ms.png "database schema") 
The database schema diagram depicts one-to-many joins between primary and foreign keys (listed in the table below) in the ‘RecordLevel’, ‘Location’, ‘Event’, and ‘MeasurementOrFact’ tables.
| Table name        | Primary key       | Foreign key |
|-------------------|-------------------|-------------|
| RecordLevel       | datasetID         | none        | 
| Location          | locationID        | datasetID   | 
| Event             | eventID           | locationID  | 
| MeasurementOrFact | measurementTypeID | eventID     | 

# Maintenance
Updates or maintenance of this software release are not anticipated at this time.

# Funding and Acknowledgements
Funding for the development of the Stream Monitoring Data Exchange Standards was provided by the U.S. Geological Survey, U.S. Bureau of Land Management and USDA Forest Service. The use of trade, product, or firm names in this repository does not imply endorsement by the US government.

# Related Publications
<i>add pubs here</i>

# Source Data Citations
Bureau of Land Management BLM Assessment, Inventory, and Monitoring Project Team, 2021, I_Indicators [vector digital data], BLM Natl AIM Lotic Indicators Hub: https://gbp-blm-egis.hub.arcgis.com/datasets/BLM-EGIS::blm-natl-aim-lotic-indicators-hub/about

Miller, S.A., Gordon, S.N., Eldred, P., Beloin, R.M., Wilcox, S., Raggon, M., Andersen, H., and Muldoon, A., 2017, Northwest Forest Plan—the first 20 years (1994–2013): watershed condition status and trends: U.S. Department of Agriculture, Forest Service, Pacific Northwest Research Station PNW-GTR-932. https://www.fs.usda.gov/treesearch/pubs/55231

Northwest Forest Plan Aquatic and Riparian Effectiveness Monitoring Program [AREMP], 2015, Northwest Forest Plan– the First 20 Years (1994–2013): Watershed Condition Status and Trend [ArcGIS geodatabase] (.gdb): https://www.fs.usda.gov/r6/reo/monitoring/watersheds.php

U.S. Environmental Protection Agency, 2006, National Aquatic Resource Surveys, Wadeable Streams Assessment 2004 [tabular files]: https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys

U.S. Environmental Protection Agency, 2016, National Aquatic Resource Surveys, National Rivers and Streams Assessment 2008–2009 [tabular files]: https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys

U.S. Environmental Protection Agency, 2020, National Aquatic Resource Surveys, National Rivers and Streams Assessment 2013–2014 [tabular files]: https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys

U.S. Environmental Protection Agency, 2021, National Aquatic Resource Surveys, National Rivers and Streams Assessment 2018–2019 [tabular files]: https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys

Please note, data were not publicly available from the U.S. Forest Service PacFish/InFish Biological Opinion Monitoring Program and PIBO MP abitat data obtained via data request (W.C. Saunders, U.S. Forest Service PacFish/InFish Biological Opinion Monitoring Program, unpublished data, 2021) 
