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
│   │   ├── Test Code\
│   │   ├── CombineData.R
│   │   ├── DownloadAndCleanBLMAIMData.R
│   │   ├── DownloadAndCleanEPANRSA.R
│   │   ├── DownloadAndCleanUSFSAREMPData.R
│   │   ├── Maps for report.R
│   │   └── dataMappedField.R
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
│   │   │   ├── GISVariables.csv
│   │   │   ├── Location.csv
│   │   │   ├── MeasurmentOrFact.csv
│   │   │   └── RecordLevel.csv
│   │   │
│   │   ├── AnalysisStreamHabitatMonitoringMetricDataset.csv
│   │   ├── Integrated Data Set.accdb
│   │   ├── RelationalDataTablesStreamHabitatMetrics.xlsx
│   │   └── UniqueLocationsforStreamHabitatMetric.csv
│   │
│   └── README.md
├── R\
│   │
│   ├── Archive EPA Metadata\
│   │
│   └── CreateDataTablesMetadataDict.R
</pre>
Repository file directory created using RP Tree in Python (https://github.com/realpython/rptree)

# Database Schema
![database schema](/Figures/databaseERD3_ms.png "database schema") 


# Disclaimer
This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

Although these data have been processed successfully on a computer system at the U.S. Geological Survey (USGS), no warranty expressed or implied is made regarding the display or utility of the data for other purposes, nor on all computer systems, nor shall the act of distribution constitute any such warranty. The USGS or the U.S. Government shall not be held liable for improper or incorrect use of the data described and/or contained herein.

# Getting Started
To run the integration code, download or clone the repository, install the necessary R packages and run the following: 

`source(paste0(getwd(), "/Data Integration Example/R/Combine Data.R"))`  
`data <- integrate_data()`

# How to Contribute
<i>pending</i>

# License
<i>License will be public domain</i>

# Funding and Acknowledgements
<i>pending</i>
Funding for the development of the Stream Monitoring Data Exchange Standards was provided by the U.S. Geological Survey, U.S. Bureau of Land Management and USDA Forest Service. The use of trade, product, or firm names in this repository does not imply endorsement by the US government.

# Recommended Citation
Scully, R. and Heaston, E. 2022. Stream Monitoring Data Exchange Standards, GitHub repository, https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications

<i>update to GitLab pending</i>
