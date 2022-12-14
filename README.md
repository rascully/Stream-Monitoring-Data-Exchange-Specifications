# Repository Directory
<pre>
├── Data\
│   ├── CategoryDictionary.csv
│   └── MetadataDictionary.csv
|
├── DataExchangeStandardTables\
│   ├── DataMappingDES.csv
│   ├── EventDES.csv
│   ├── LocationDES.csv
│   ├── MeasurementOrFactDES.csv
│   ├── RecordLevelDES.csv
│   └── metricControlledVocabulary.csv
│
├── DataIntegrationExample\
│   │
│   ├── R\
│   │   │
│   │   ├── CombineData.R
│   │   ├── DownloadAndCleanBLMAIMData.R
│   │   ├── DownloadAndCleanEPANRSA.R
│   │   ├── DownloadAndCleanUSFSAREMPData.R
│   │
│   ├── data\
│   │   │
│   │   ├── DataSources\
│   │   │   │
│   │   │   ├── NwfpWatershedCondition20yrReport.gdb\
│   │   │   │
│   │   │   ├── wsamarch2_2009\
│   │   │   │
│   │   │   ├── 2020_Seasonal_Sum_PIBO.xlsx
│   │   │   ├── AIMProcessedDataset.csv
│   │   │   ├── AIM_Dataset.csv
│   │   │   ├── AREMPProcessedDataset.csv
│   │   │   ├── AREMPTest.csv
│   │   │   ├── AREMPqryEventTable_forPNAMP.xlsx
│   │   │   ├── NRSAProcessedDataset.csv
│   │   │   ├── NRSATableOfDataset.csv
│   │   │   ├── NwfpWatershedCondition20yrReport.gdb.zip
│   │   │   └── ~$2020_Seasonal_Sum_PIBO.xlsx
│   │   │
│   │   ├── csv\
│   │   │   ├── Event.csv
│   │   │   ├── Location.csv
│   │   │   ├── MeasurmentOrFact.csv
│   │   │   └── RecordLevel.csv
│   │   │
│   │   ├── AnalysisStreamHabitatMonitoringMetricDataset.csv
│   │   ├── Integrated Data Set.accdb
│   │   ├── RelationalDataTablesStreamHabitatMetrics.xlsx
│   │
│   └── README.md

</pre>
Repository file directory created using [RP Tree](https://github.com/realpython/rptree) in Python

# Database Schema
![database schema](/Figures/databaseERD3_ms.png "database schema") 


# Disclaimer
This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

Although these data have been processed successfully on a computer system at the U.S. Geological Survey (USGS), no warranty expressed or implied is made regarding the display or utility of the data for other purposes, nor on all computer systems, nor shall the act of distribution constitute any such warranty. The USGS or the U.S. Government shall not be held liable for improper or incorrect use of the data described and/or contained herein.

# Getting Started
To run the integration code, download or clone the repository, install the necessary R packages and run the following: 

`source(paste0(getwd(), "/Data Integration Example/R/Combine Data.R"))`  
`data <- integrate_data()`

Additional information on installation and running code can be found in the [DataIntegrationExample ReadMe](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/DataIntegrationExample/README.md)

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

# How to Contribute
<i>pending</i>

# License
<i>pending, License will be public domain</i>

# Funding and Acknowledgements
<i>pending</i>
Funding for the development of the Stream Monitoring Data Exchange Standards was provided by the U.S. Geological Survey, U.S. Bureau of Land Management and USDA Forest Service. The use of trade, product, or firm names in this repository does not imply endorsement by the US government.

# Recommended Citation
Scully, R. and Heaston, E. 2022. Stream Monitoring Data Exchange Standards, GitHub repository, https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications

<i>update to GitLab pending</i>
