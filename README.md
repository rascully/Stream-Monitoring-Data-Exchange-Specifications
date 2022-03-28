---
title: "Data Exchange Specifications"
contact: "Becca Scully"
contact information: rscully@usgs.gov 
---

## R Markdown
# USGS Disclaimer for Draft Software and Data Exchange Specifications 
This software is preliminary or provisional and is subject to revision. It is being provided to meet the need for timely best science. The software has not received final approval by the U.S. Geological Survey (USGS). No warranty, expressed or implied, is made by the USGS or the U.S. Government as to the functionality of the software and related material nor shall the fact of release constitute any such warranty. The software is provided on the condition that neither the USGS nor the U.S. Government shall be held liable for any damages resulting from the authorized or unauthorized use of the software.

Although these data have been processed successfully on a computer system at the U.S. Geological Survey (USGS), no warranty expressed or implied is made regarding the display or utility of the data for other purposes, nor on all computer systems, nor shall the act of distribution constitute any such warranty. The USGS or the U.S. Government shall not be held liable for improper or incorrect use of the data described and/or contained herein.

# About
Below is the first version of the Stream Habitat Metric Data Exchange Standard. The standard is maintained as a GitLab repository Stream Monitoring Data Exchange Standard based on recommendations from Ornelas et al. 2021 for using Git repositories to document and version data standards.

## Mission and Goal of Standard 
The Stream Habitat Data exchange standard provides content and structure for integrating stream habitat monitoring metrics and metadata from multiple programs. When we refer to stream habitat data, we refer to the instream physical characteristics. Values are measured within a linear reach defined by a starting and endpoint, but locations are represented as a point in datasets. Metrics are values resulting from reducing measurements taken one or more times during the study period according to procedures defined by the response design (Stevens & Urquhart 2000).  

## Relationship to Existing Standards 
A PNAMP working group of experts developed the stream habitat metric exchange standard from four federally funded stream habitat monitoring programs. We based the fields on the data sources, the Darwin Core, ODM2, and WQX standards. The structure is a relational database model such as ODM2 employees and a tall data format described by Darwin Core. 

## Description of Standard 
The stream habitat metric exchange standard includes the fields, data structure, and metric-controlled vocabulary necessary to describe, exchange, and use stream habitat data across four specific federally-funded stream habitat monitoring programs (Table 1). The standard focuses on the core set of metadata fields, including locations, protocols, dataset information necessary to represent the sampling efforts accurately, and a subset of metrics produced by each program. 

## Application and Intended Use of Standard 
The stream habitat metric standard is applicable for sharing and integrating metrics and metadata for stream habitat physical characteristics. This standard addresses differences in response designs between the source datasets but do not account for different spatial designs. Additionally, data users need to be aware variability in training and crews can be impact measurement and data collection consistency and resulting metrics. Therefore, users analyzing datasets resulting from this standard should pay care and attention to these limitations.

## Standard Development Procedures 
A working group led by PNAMP developed the standard, the details are in the XXX chapter of this document.  

## Maintenance of Standard 
This standard is published and maintained in GitLab. GitLab is a version control system used for collaborative software development and suited for the joint development of data standards (Ornelas et al. 2021). As the standard is updated, the GitLab software is designed to track changes, and collaborators can use the GitLab tools to submit suggestions and changes.
Editor's note for review: the standard is currently on GitHub (Scully, 2022d) but this text refers to GitLab, which is where it will eventually be released.


## Data Mapping  
The source datasets need to be mapped to the standard to combine datasets from multiple sources. Data mapping is the assignment of fields from the source datasets to the fields and metrics described in the data exchange standard (DAMA 2009). Some mapping from the sources to the data exchange standard are simple, while others require a transformation to be combined information into a single dataset.

## Data Structure 
The data is structured as a relational database model. Primary keys are unique values for each record or row in the table, and foreign keys are included in the child tables to define the relationship between tables (DAMA 2009). The primary and foreign keys in the integrated dataset are as follows (also see Figure 3 {entity relationship diagram}):
*	Record Level table primary key is datasetID, foreign key in the Location table 
*	Location Table primary key is locationID, foreign key in Event table 
*	Event Table primary key is EventID, foreign key in Measurement or Fact table 
*	Metric Controlled Vocabulary primary key is measurementTypeID, foreign key in Measurement or Fact table 
This resulted in six tables (RecordLevel, Location, Event, MeasurementorFact, Metric Controlled Vocabulary, and DataMapping) linked together in a relational data   ![Figure 1](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Figures/HabiatDataSharingSchema.png)
  *Figure 1* 
  

## Record Level Table
The Record Level table documents the core elements of a dataset, including information about the origin of the dataset, who collected the data, and how to cite the source dataset (Table # {RecordLevel}). datasetID is the primary key. 

[Record Level Table](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data%20Exchange%20Specifications%20Tables/RecordLevel.csv). 

### Record Level Data Mapping Notes 
#### datasetID
datasetID is a unique identifiers integer generated when the datasets are combined into the single datasets. 

## Location  
Location Class describes where information was collected in the field (Table # {Location}). datasetID is the foreign key linking Location table to Record Level table. locationID is the primary key Each Record Level dataset contained multiple locations linked from the Location Table to the Record Level Table by the datasetID field. LocationID was the primary key for the Location table and was used to associate locations with events in the Event table, allowing for multiple events to be tied to a single location. Unique, consistent locationID numbers were generated for each unique location in the integrated dataset. Source data program-specific locationIDs were non-standardized across programs and could not be used when integrating due to the inherent risk of UID duplication. However, program locationIDs were preserved in the integrated data in the verbatimLocationID column to trace back to the original datasets. 


#### [Location table](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data%20Exchange%20Specifications%20Tables/Location.csv)

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

#### [Event table](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data%20Exchange%20Specifications%20Tables/Event.csv)

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

[Measurement or Fact Table](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data%20Exchange%20Specifications%20Tables/MeasurementorFact.csv) for the full definitions of terms.

### Measurement or Fact Mapping Notes 
#### measurementID 
measurementID is a unique identifiers integer generated when the datasets are combined into the single datasets.

#### measurementMethod  
measurementMethod is filled in with the link to the data collection and analysis methodology documented in MonitoringResources.org. This supports reuse and trust by the end-users. The methods were published on MonitoringResources.org, an online, publicly accessible suite of information and tools for natural resource monitoring programs and professionals to document the who, what, where, when, and how of data collection and analysis (Bayer et al. 2018). MonitoringResources.org provides a standard structure for documenting data collection and analysis methods and APIs to access the method's documentation via a UID assigned to each method and allows for version control. For example, AREMP and PIBO MP collect substrate information using different field methods, but working group experts and past data agreed that the methodology used in the field produces comparable results, allowing the two program's metrics to be integrated.  

### Metric Controlled Vocabualry VariableID  Controlled Vocabularies for Results Table 

The metric-controlled vocabulary defines the metrics included in the MeasurementOrFact table. The controlled vocabulary was formatted as a flat .csv table containing term names, definitions, data type (.e.g, numeric), measurement units (e.g., meters) and acceptable values (e.g., a percent must fall between 0 and 100) for all metrics in the dataset ({Table # MetricCV}). A metric is a term in the controlled vocabulary and the measurementType was linked to the Measurement or Fact table's termID (fig # {stream monitoring data exchange spec schematic}).  

[controlled vocabulary](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data%20Exchange%20Specifications%20Tables/metricControlledVocabulary.csv).

# Data Mapping 
Mapping
We map the field names in the source datasets to the fields in the data exchange standard. Sources metrics are mapped to the metric-controlled vocabulary. The program reviewed and approved the mapping. The working group agreed that all metrics included in the data mapping and integrated dataset were compatible across the programs.

[Data Mapping](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data%20Exchange%20Specifications%20Tables/DataMapping.csv) 

# Data Inergration Examples 
[Data Integration Example](Data Intergration Example) details and example of using this data exchange standard. To share habitat metrics from four federal habitat monitoring programs: Environmental Protection Agency (EPA) National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM), and the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP) and PacFish/InFish Biological Monitoring Opinion Monitoring Program (PIBO MP). 

# Conclusion
The data exchange specifications contain the details of what will be share and the format to be shared. We recognize preparing data to be shared requires an investment of time, resources, expertise, and careful documentation of the data collection process and the results.  An opinion piece in Nature by Barend Mons (2020), the director of a Global Open FAIR office, recommends that '5% of research funds be invested in making data reusable'. 

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











