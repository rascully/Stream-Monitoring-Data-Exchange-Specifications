---
title: "Data Exchange Specifications"
contact: "Becca Scully"
contact information: rscully@usgs.gov 
---

## R Markdown
# About

## Mission and Goal of Standard 
The Stream Habitat Data exchange standard provides content and structure for integrating stream habitat monitoring metrics and metadata from multiple programs. When we refer to stream habitat data, we are referring to the instream physical characteristics. These values are measured at a linear reach defined by a starting and end point, but in datasets are represented as a point. Metrics are values resulting from reducing measurements taken one or more times during the study period according to procedures defined by the response design (Stevens & Urquhart 2000). 

## Relationship to Existing Standards 
The stream habitat metric exchange standard was developed by a PNAMP working group composed of experts from four federally funded stream habitat monitoring programs. The fields are based on the data sources, the Darwin Core, ODM2, and WQX standards. The structure is based on a relational database model as employed by ODM2. 

## Description of Standard 
The stream habitat metric exchange standard includes the fields, data structure, and metric controlled vocabulary necessary to describe, exchange, and use stream habitat data across four specific federally-funded stream habitat monitoring programs (Table 1). The standard focuses on the core set of metadata fields, including locations, protocols, dataset information necessary to represent the sampling efforts accurately, and a subset of metrics produced by each program. 

## Application and Intended Use of Standard 
The stream habitat metric standard is applicable for sharing and integrating metrics and metadata for stream habitat physical characteristics. This standard addresses differences in response designs between the source datasets but do not account for different spatial designs. Additionally, data users need to be aware variability in training and crews can be impact measurement and data collection consistency and resulting metrics. Therefore, users analyzing datasets resulting from this standard should pay care and attention to these limitations.

## Standard Development Procedures 
The standard was developed by a working group led by PNAMP, the details are in Methods for Building and Applying a Data Exchange Standard for Stream Habitat Data From Multiple Monitoring Programs (Scully et al 2022a; in preparation) 

## Maintenance of Standard 
This standard is published and maintained in GitLab. GitLab is a version control system used for collaborative software development and suited for collaborative development of data standards (Ornelas et al. 2021) If the standard is updated, the GitLab software is designed to track changes, and collaborators can use the GitLab tools to submit suggestions and changes. 

## Data Mapping  
The original datasets need to be mapped to the standard to combine datasets from multiple sources. Data mapping is the assignment of fields from the original datasets to the fields and metrics described in the data exchange specifications (DAMA 2009). Some mapping from the sources to the data exchange standard are simple, while others require a transformation to be combined information into a single dataset.

## Data Structure 
The data is structured as a relational database model. Primary keys area unique value for each record or row in the table are identified and foreign keys are included in the child tables to define the relationship between tables (DAMA 2009), including the following:
*Record Level table primary key is datasetID, foreign key in the Location table 
*Location Table primary key is locationID, foreign key in Event table 
*Event Table primary key is Event, foreign key in Measurement or Fact table 
*Metric Controlled Vocabulary primary key is TermID, foreign key in Measurement or Fact table 
This resulted in a series of five tables (RecordLevel, Location, Event, MeasurementorFact, Metric Controlled Vocabulary) linked together in a relational data model, stored and shared as an MS Access Database.  ![Figure 1](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Figures/HabiatDataSharingSchema.png)
  *Figure 1* 
  

## Record Level Table
The Record Level table documents the core elements of a dataset, including information about the origin of the dataset, who collected the data, and how to cite the source dataset (Table # {RecordLevel}). datasetID is the primary key. 

[Data set table](Tables/RecordLevel_table.csv). 

### Record Level Data Mapping Notes 
#### datasetID
datasetID is a unique identifiers integer generated when the datasets are combined into the single datasets. 

## Location  
Location Class describes where information was collected in the field (Table # {Location}). datasetID is the foreign key linking Location table to Record Level table. locationID is the primary key Each Record Level dataset contained multiple locations linked from the Location Table to the Record Level Table by the datasetID field. LocationID was the primary key for the Location table and was used to associate locations with events in the Event table, allowing for multiple events to be tied to a single location. Unique, consistent locationID numbers were generated for each unique location in the integrated dataset. Source data program-specific locationIDs were non-standardized across programs and could not be used when integrating due to the inherent risk of UID duplication. However, program locationIDs were preserved in the integrated data in the verbatimLocationID column to trace back to the original datasets. 


#### [Location table](Tables/Location_table.csv)

### Location Data Mapping Notes 
#### locationID 
locationID is a unique identifiers integer generated when the datasets are combined into the single dataset.

#### verbatimLocationID 
verbatimLocaitonID are the unique identifiers from the original datasets all convert to data type string. By maintaining the link to location and event identifiers from the original datasets the data user can trace information back to the source. 

#### latitude and longitude 
All latitude and longitudes need to be in the coordinate reference system is World Geodetic System 1984 (WGS84), not projected. 

#### siteSelectionType
Discussion with project team 

## Event  
Event Class describes an action that occurs at some location during some time (Darwin Core, ).  Table # {Event}).}). locationID is the foreign key linking Location table to Event table. eventID is the primary key assigned to each row in the Event table and will be used to link an event to multiple measurements. 
To maintain provenance to the original data sources, we retained UID for each event from the source data in the column verbatimEventID. We did not use the sources eventIDs as the primary key due to the variety of formats, mixes of data type, and potential for repeated value between two programs. 

#### [Event table](Tables/Event_table.csv)

### Event Data Mapping Notes 
#### eventID 
eventID is a unique identifiers integer generated when the datasets are combined into the single dataset.

#### verbatimEventID 
verbatimEventID are the unique identifiers from the original datasets all convert to data type string. By maintaining the link to location and event identifiers from the original datasets the data user can trace information back to the source. 

#### fieldNotes 
fieldNotes is a string field that we will in with the stream flow at the time of sampling. Each example dataset stories flow in a different format. Some share percent dry, an integer, while others share stream flow as a string. For the integrated dataset all stream flows are transformed to a string, category “No Flow (Dry)”, “Flow (Whole Reach)”, “Other”. For programs reporting stream flow  as percent dry, we transform the data such that: 
* 0 = Flow (Whole Reach)  
* 100= No Flow (Dry) 
*All other values are reported as “Other” 

For programs that report percent of the reach with flow, we transform the data in inverse.

#### samplingProtocol 
Discussion with project team 

#### beaverImpact 
Discussion with project team 


## Measurment or Facts  
The Measurement or Fact Darwin Core class/extension stores the results of a measurement at an event Table # { Measurement or Fact}). }). eventID is the foreign key linking Event table to MeasurementOrFact table. measurementID is the primary key and numeric UIDs were generated for each row. Data values were stored in the dataValue field and the measurementType field defined the "nature of the measure, fact, characteristic or assertion" and filled in from the metric controlled vocabulary (Darwin Core Maintenance Group 2021). 

[Measurement or Fact Table](Tables/MeasurementORFact_table.csv) for the full definitions of terms.

### Measurement or Fact Mapping Notes 
#### measurementID 
measurementID is a unique identifiers integer generated when the datasets are combined into the single datasets.

#### measurementMethod  
measurementMethod is filled in with the link to the data collection and analysis methodology documented in MonitoringResources.org. This supports reuse and trust by the end-users. The methods were published on MonitoringResources.org, an online, publicly accessible suite of information and tools for natural resource monitoring programs and professionals to document the who, what, where, when, and how of data collection and analysis (Bayer et al. 2018). MonitoringResources.org provides a standard structure for documenting data collection and analysis methods and APIs to access the method's documentation via a UID assigned to each method and allows for version control. For example, AREMP and PIBO MP collect substrate information using different field methods, but working group experts and past data agreed that the methodology used in the field produces comparable results, allowing the two program's metrics to be integrated.  

### Metric Controlled Vocabualry VariableID  Controlled Vocabularies for Results Table 

The metric-controlled vocabulary defines the metrics included in the MeasurementOrFact table. The controlled vocabulary was formatted as a flat .csv table containing term names, definitions, data type (.e.g, numeric), measurement units (e.g., meters) and acceptable values (e.g., a percent must fall between 0 and 100) for all metrics in the dataset ({Table # MetricCV}). A metric is a term in the controlled vocabulary and the measurementType was linked to the Measurement or Fact table's termID (fig # {stream monitoring data exchange spec schematic}).  

[controlled vocabulary](Tables/StandardVocabulary.csv).


# Use Case Guide 
We wrote code based on these data exchange specifications to share habitat metrics from three federal habitat monitoring programs: Environmental Protection Agency (EPA) National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM),and the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP). The work flow pulls program information from ScienceBase, the exchange specifications and the field crosswalk from this repository, and data collection metrics documented from MonitoringResources.org [work flow diagram](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Figures/WorkFlow.png). The R code to integrate data sets can be found at https://github.com/rascully/Integrating-Stream-Monitoring-Data-From-Multiple-Programs and the data set documentation in ScinceBase at ADD SCIENCEBAES LINK WHEN I CAN 

# Conclusion
The data exchange specifications contain the details of what will be share and the format to be shared. We recognize preparing data to be shared requires an investment of time, resources, expertise, and careful documentation of the data collection process and the results.  An opinion piece in Nature by Barend Mons (2020), the director of a Global Open FAIR office, recommends that '5% of research funds be invested in making data reusable'. Projects producing this type of data are already working beyond their capacity, so to integrate data between habitat programs, there needs to be support in project budgets or for a centralized data manager to help implement and updated the necessary documentation and code to share data. 

# Funding 

# License

# Cititation 
Scully, R., 2022b. Stream Monitoring Data Exchange Standards, GitHub repository. https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications 

# Reference Resourecs 

Scully, R., et al., 2022a. Methods for Building and Applying a Data Exchange Standard for Integrating Stream Habitat Data from Multiple Monitoring Programs (working title). U.S. Geological Survey Techniques and Methods, manuscript in preparation. 

Scully, R., et al 2022b. Physical Stream Habitat Data Integrated from Mutiple Monitoring Programs for the U.S. from, 2000-2020 (working title). U.S. Geological Survey data release, data release in preparation. 

Scully, R., 2022a. Integrating Stream Habitat Monitoring Data From Multiple Monitoring Programs, GitHub repository. https://github.com/rascully/Integrating-Stream-Monitoring-Data-From-Multiple-Programs 

Scully, R., 2022b. Stream Monitoring Data Exchange Standards, GitHub repository. https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications 



# References 
Mons, B. (2020). Invest 5% of research funds in ensuring data are reusable. Nature, 578(7796), 491.

Kulvatunyou, B., Morris, K. C., Ivezic, N., & Frechette, S. (2008). Development life cycle for semantically coherent data exchange specification. Concurrent Engineering, 16(4), 279-290.

Wieczorek J, Bloom D, Guralnick R, Blum S, Döring M, et al. (2012) Darwin Core: An Evolving Community-Developed Biodiversity Data Standard. PLoS ONE 7(1): e29715. https://doi.org/10.1371/journal.pone.0029715

Wikipedia contributors. 'Machine-readable data.' Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, 6 Aug. 2013. Web. 21 Aug. 2014.











