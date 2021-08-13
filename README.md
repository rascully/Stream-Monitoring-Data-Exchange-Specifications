---
title: "Data Exchange Specifications"
contact: "Becca Scully"
contact information: rscully@usgs.gov 
---

```{r include= FALSE}
library(tidyverse)
library(knitr)
library(readxl)

metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

```


## R Markdown

# Stream Monitoring Habitat Data Exchange Specifications 
Data exchange specifications are a set of guidelines and rules for using and combining information. Rigorous data exchange specifications support reuse, promote interoperability, and reduce data integration costs (Morris and Frechette 2008, Hamm 2019). 

# Summary 
We use [observation data model 2 (ODM)](https://github.com/ODM2/ODM2) and [Darwin Core](https://www.gbif.org/sampling-event-data) to define data exchange specifications and data model (Figure 1) for stream habitat monitoring data. We use controlled vocabularies from ODM2 and define a controlled vocabulary for stream habitat monitoring variables. As a use case we cross walk four federally funded stream habitat monitoring programs to the exchange specifications and wrote R code to to build a data set, this is documented in a GIT Repository here: https://github.com/rascully/Integrating-Stream-Monitoring-Data-From-Multiple-Programs=
 
 ![Figure 1](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Figures/HabiatDataSharingSchema.png)
  *Figure 1* 
# Introduction 
Streams are critical to fish, aquatic community structure, and overall watershed health. State, Federal and Tribal entities collect in-stream habitat data to assess the resources' status and trends unique to their management questions.  Due to climate change, urbanization, and multi-use land management, there is a need to determine the resources' quality and trends across jurisdictional boundaries by using information from multiple collection efforts (Katz et al. 2012). It is not straightforward to combine data from various monitoring programs due to differences in response and survey (spatial and temporal) designs. Additionally, data produced by these programs are not always findable, accessible, interoperable, and reusable (FAIR) (Wilkinson et al. 2016).  There is no centralized repository, data model or data dictionary for this type of information.  A standard theory in data science states researchers spend 80% of their time organizing, fixing mistakes, and cleaning data, leaving only 20% of their time to analyze data (Mons 2020).   Well established rules for integrating and sharing stream habitat data from multiple sources will decrease the time spent finding and organizing data providing accurate and timely information for building indicators, completing analysis, and making decisions.   
Data integration requires a set of business rules to flow data from sources to a target data set. Data needs to be accessed, extracted, moved, validated and cleansed, standardized, transformed, documented and published.  (DAMA Dictionary, CITE OTHER DATA INTEGRATION EFFOTRS)  Rigorous data exchange specifications support reuse, promote interoperability, and reduce integration data cost (Morris and Frechette 2008, Hamm 2019). 

The biggest challenges to data integration are heterogeneity issues (Beran & Piasecki 2009). Stream habitat monitoring data is not immune to these challenges, the data has both semantic heterogeny, disagreement about the meaning of the same or related term (Sheth & Larson 1990) and structural heterogeneity, information system storing their day in different formats and layouts (Ouskel and Sheth 1999). To overcome these issues we undertook a facilitated effort to agree on a controlled vocabulary, fields and definitions, and data model, format of the data to be integrated, from a set of pilot programs.  We then mapped the data from the individual programs to the data model and controlled vocabulary and wrote code to build an integrated data set. The integrated data set is published on USGS ScienceBase, so SAY SOMETHING ABOUT API ACCESS.  We modeled the data exchange specification for stream habitat data based on the observation data model (ODM), but added a table to capture data collection events. Building on existing standards and past research will allow this data to be integrated existing into other tools. 


# Methods 
To integrate data, we need to establish business rules to flow data from the sources to a target data sets. Data must be accessed, extricated, moved, validated, cleaned, standardized, transformed, and loaded (DAMA Dictionary). At the start of this project there is no target data set or rules to integrate stream habitat data. Therefore, to build an integrated data set we define the structure and fields to include in the target data set and define business rules to flow data from sources. 

Before starting the integration work, we need to understand what data and metadata from the desperate data sets needs to be integrated. There are two approaches:
1.	Look for a specific regulatory management question that needs to be answered in order to inform a decision and provide the data to answer those specific questions. (CITE EXAMPLE CAX) 
2.	Let the data guide the integration, identify a subset of like data that provide value and could be use together to answer a variety of management or research question

For stream habitat monitoring data we took the second approach and used the data, metadata and program experts to guide the structure and fields of the target data set. Fields refer to the column headers in the data set.   

We invited four large scale, long term, well documented stream habitat monitoring programs to collaborate in defining a method for integrating data from there stream habitat monitoring programs that can be adapted to similar Federal, State and Tribal programs as needed. 

#### Coordinated with:
* The Assessment, Inventory, and Monitoring (AIM) Strategy provides a framework for the Bureau of Land Management (BLM) to inventory and quantitatively assess the condition and trend of natural resources on the nation's public lands.  This program gathers information to determine ecosystem conditions and how they are changing over time. Such information is actively used by the BLM to guide and justify land uses, policy actions, and adaptive management decisions. (AIM Strategy website) LINK TO THE SCIENCEBASE ITEM 

* The USFS Aquatic and Riparian Effectiveness Monitoring Program (AREMP) was developed to track changes that occurred as a result of active and passive management on the landscape. The Aquatic and Riparian Effectiveness Monitoring Program focuses on assessing the degree to which federal land management under the aquatic conservation strategy (ACS) of the Northwest Forest Plan (NWFP) has been effective in maintaining and improving watershed conditions. (USFS AREMP website)  LINK TO THE SCIENCEBASE ITEM 

*	The USFS PacFish/InFish Biological Opinion Monitoring Program (PIBO MP) is to monitor stream and riparian habitats within the PIBO MP study area, in order to determine if the PacFish (Pacific Anadromous Fish) and InFish (Inland Fish) aquatic conservation strategies can effectively maintain or restore the structure and function of riparian and aquatic systems. (USFS PIBO website)  LINK TO THE SCIENCEBASE ITEM 

*	EPA The National Aquatic Resource Surveys (NARS) are collaborative programs between EPA, states, and tribes designed to assess the quality of the nation's coastal waters, lakes and reservoirs, rivers and streams, and wetlands using a statistical survey design. The NARS provide critical, groundbreaking, and nationally consistent data on the nation's waters. (EPA website)  LINK TO THE SCIENCEBASE ITEM 

These four monitoring programs have structured implementation, core indicators collected with a consistent methodology, statistically valid designs, and effective data management. In addition, based on past work we know there is a subset of consistent metrics and indicators produced across these programs, creating an opportunity to combine data from multiple programs (CITE ). 


# Data Model  
The general structure for this type of monitoring is a dataset contains multiple locations, some locations are sampled multiple times, those sampling efforts we refer to as events, at each event, programs collect multiple measurements, producing numerous metrics (Figure 1)[]. This type of information lends itself to a relational database model so information is not repeated, this will optimize data retrieval for integrated analysis (CITE). Therefore a location will be stored once and linked to multiple events.  

We did not want to build a new data model from scratch so in the future an integrated dataset can be link into exiting data models, repository and resources. We started with the Observation Data Model 2 (ODM2).  ODM2 takes features from the Open Geospatial Consortium (OGC) Observations & Measurements (O&M) standard (Cox, 2007a; Cox 2007b; Cox 2011a; Cox 2011b) and the Horsburgh et al, 2008 observation Data Model (ODM) desciring a data model for hydrologic data and the CUAHSI Hydrologic Information System. ODM2 is a generic model for observations and designed for interoperability among disciplines (http://www.odm2.org/). ODM2 has a “core” and multiple “extension” and established controlled vocabularies.  An observation is defined as an act associated with a descript time or instant, through which a number, term or other symbol is ascribed to an event (Horsburgh et al. 2008). Observations require contextual information, location where the observation was made, date and time, the type of variable and other metadata method used for observation. This OBM2 (https://github.com/ODM2) is highly flexible and provides a good starting point for integrating these data sets. Based on the needs for bringing data sets together and these examples we collapsed ODM2 tables, limited the fields to one important for stream habitat monitoring data and added a few fields from the Darwin Core principles as outlined by Wieczorek et al. in 2012. The Darwin Core standard is maintained at the GitHub repository https://github.com/tdwg/dwc. 

#### Definitions: 
  * Primary Key 
  * Feature Key 
  * Controlled Vocabulary 

# Structure 
To streamline the data storing and data retaliate we selected a relational data model based on ODM2, we simplified some relationships, removed fields that are not approperate for this datatype and added a few fields from the DarwinCore. See our version of the data schema here: ADD LINK 

#### The original data schemas are documented in the ODM2 Git Repository here: 
* Core schema: http://odm2.github.io/ODM2/schemas/ODM2_Current/diagrams/ODM2Core.html
* Results Extension: http://odm2.github.io/ODM2/schemas/ODM2_Current/diagrams/ODM2Results.html
* Sampling Feature Extension: http://odm2.github.io/ODM2/schemas/ODM2_Current/diagrams/ODM2SamplingFeatures.html

# Details of the Data Model 

## ODM Core.Datasets Level Class 
The Record Level Class documents the core elements of a data set, including information about the origin of the data set, who collected the data, and how to cite the data set. See details in the [Dataset table](Tables/ODMDataset_table.csv). A data set is a collection of locations, at each location a collection events, at each event a collection of metrics; for example, a program releases a data set every five years containing all the data collection locations, events and metrics occurring in the previous five years. We recommend storing metadata about the data sets in a trusted online data repository ensuring we have sufficient information about data sets’ origins. If a program does not have the resources to build a repository, we recommend using USGS ScienceBase, which is available to all. Find more information about ScienceBase here https://www.sciencebase.gov/about/. 

### Details of the ODM2  implementation of the Dataset table : https://github.com/ODM2/ODM2/blob/master/doc/ODM2Docs/core_datasets.md 

### The Stream Habitat Monitoring Implentation 
#### To the Datasets table from ODME2 Metadata table we added:
  * MetadataLink 

#### From DarwinCore we added to the Record Level table:
  * DatasetOrginization
  * Modified 

#### The primary key is: 
  * DatasetID 
  
#### Controlled Vocabularies:  
  *  DatasetType
      * http://vocabulary.odm2.org/datasettype/
      * SKOS API: http://vocabulary.odm2.org/api/v1/datasettype/?format=skos 

```{r echo=FALSE, results= 'asis'}

datasets <- read.csv("Tables/ODMDatasets_table.csv")

kable(datasets, caption = "Datasets Table")

```

## Provance extention 
https://github.com/ODM2/ODM2/blob/master/doc/ODM2Docs/ext_provenance.md

## Sampling Feature 
Understanding where data are collected is critical to interpreting biological monitoring data.  The Sampling Feature class describes where information are collected, see the list of terms in the [Sampling Feature table](Tables/ODMSamplingFeature_table.csv). In this data type often this is refered to as the sampling location, but to be compadable with the ODM2 we now refer to this as the Sampling Feature. Each data set contains mutiple sample features (locations). The actionID is the key to link locations to events. To view and analysis data from various sources, latitudes and longitude information must be consistent among data sets; therefore, for this data all latitude and longitudes are converted to WGS1984.

#### To the Sample Feature Table from ODME2 SampleFeature.Site we added:  
  * Latitude 
  * Longitude 
  * SpatialReferenceID 
  
For the integrated data sets all locations Latitude, Longitude are transformed into WGS1984 in Decimal Degrees but in the original data sets the locations are in a variety of spatial references based on each program's needs, therefor we added the verbatim fields to track the data before transformation. 

#### From DarwinCore we added to the Sample Feature table:  
  * VerbatimLatitude 
  * VerbatimLongitude 
  * VerbatimSpatialReferenceID


#### The primary key is: 
  * SamplingFeatureID 
  
#### Added a foreign key: 
  * datasetID to link the Dataset table to the Sample Features table
  
#### Controlled Vocabularies: 
  *  SamplingFeatureType
      * http://vocabulary.odm2.org/samplingfeaturetype/
      * SKOS API http://vocabulary.odm2.org/api/v1/samplingfeaturetype/?format=skos
  * SamplingFeatureGeotype
      * http://vocabulary.odm2.org/samplingfeaturegeotype/
      * SKOS API http://vocabulary.odm2.org/api/v1/samplingfeaturegeotype/?format=skos
  * SpatialReferenceID 
  




```{r echo=FALSE}

 
sampling_feature <- read.csv("Tables/ODMSamplingFeature_table.csv")
kable(sampling_feature)
```
## Core Action 
The Action describes an action that occurs at a specific time frame see the [Core Action table](Tables/ODMAction_table.csv) for the terms.  In this data type often this is refered to as the sampling event, but to make our data comparable with the ODM2 we adopoted the term action.  To assess the status and trend of a resource as a response to management actions, stream habitat monitoring programs often implement a rotating panel design, meaning that the project returns to a single location multiple times during the study duration.  Therefore, a data set will contain numerous locations, and each location can include numerous events.

### This implementation 

#### To the Core Action table from ODME2 Core Feature Action we added:
  * SampleFeatureID 
  

#### From DarwinCore we added to the Record Level table:
  * Added VerbatimActionID based on the DarwinCore, because when implementing these data exchange specification we found that there are duplicate ActionIDs between two or more of the source data sets. 

#### The primary key is: 
  * ActionID

#### Controlled Vocabularies: 
  *  ActionTypeCV 
      * http://vocabulary.odm2.org/actiontype/
      * SKOS API: http://vocabulary.odm2.org/api/v1/actiontype/?format=skos
  
```{r echo= FALSE}

actions <- read.csv("Tables/ODMAction_table.csv")
kable(actions)
```
## Core Results 
A metric is a value resulting from the reduction or processing of measurements taken at an event based on the procedures defined by the response design. Programs derive a variety of metrics from a single measurement. For stream habitat data at each event, programs take multiple types of measurements and produce various metrics from one measurement; for example, the measurement for pools produces both percent pools and pool frequency. Events are associated with measurements by the eventID, see the [Results Table](Tables/ODMResults_table.csv) for the full definitions of terms. 


### This implementation 

#### To the Core Results from Results. MeasurementsResultsValues to Core Resoutls added:
  * MethodID 
  * MeasurementRemark 
  * DataValue 
  

#### The primary key is: 
  * ResultsID 

#### Added foregin key:
  * ActionID 

#### Controlled Vocabularies: 
  * VariableID 
      *  see below 
  * ResultsType: 
      * http://vocabulary.odm2.org/resulttype/
      SKOS API: http://vocabulary.odm2.org/api/v1/resulttype/?format=skos 
  * UnitID: 
      * http://vocabulary.odm2.org/units/
    


```{r echo=FALSE}
results <- read.csv("Tables/ODMResults_table.csv")

kable(results)
```
### VariableID  Controlled Vocabularies for Results Table 

Critical to implementing the observation data model (ODM) for stream habitat monitoring, is solving semantic heterogeneity, or the differences in languages used to describe observations between datasets (CITE). There needs to be a controlled vocabularies for each data type integrated. The standard language enables the integration of multiple habitat monitoring program metrics into one data set. 

We built the variable controlled vocabulary  using metadata and metrics from four large scale, long-running federal stream habitat monitoring programs: Environmental Protection Agency (EPA) National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM), the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP) and PACFISH/INFISH Biological Opinion (PIBO) Effectiveness Monitoring. Each program has unique objectives, spatial, temporal, response, and inference designs; yet, they produce similar metrics.  These four programs collectively produce over 300 metrics but have only a subset of metrics in common across programs. The program leads and data managers from the four programs agreed on a subset of the metrics that can be shared across the programs; these can be found in the first draft of the [controlled vocabulary](Tables/StandardVocabulary.csv).

We focused on defining a set of metric we would integrate.  Previous work has been completed compare some of these data sets and field collection procedures. (CITE) For our initial assessment of metric compadability There have been efforts in the past to comparei field processes for these programs, but we wanted to confirm with the project lead that fields were comparable. PNAMP lead an effort to facilitate conversations with data experts from the four programs to define the metrics that can be shared across the programs. The conversations are documented in Appendix A. We agreed that data in the same colume is compadable, even with this agreement we want to provide documentation of the field methods for each of the metrics included in the controlled vocabulary. To make this effective each individual data collection method needs to be documented in a stand alone, machine readable way. This means when the data set is reused the data collection methology can be accessed via APIs. Simplifying the creation of data portals, web maps and other user interfaces. We used MonitoringResources.org an online tool for documenting field data collection or analysis methods to so for each metric and program we document the field protocols (ADD TABLE OF CONTROLLED VOCABULARY AND METRIC IDs). 

Using the metadata from each program we build a comprehensive list of the metrics produced across the programs and then facilitated discussion with experts from each program to define where metrics are comparable across programs (SEE METHOD REPORT). Use this approach we defined a controlled vocabulary of metrics to be integrated. Additional we defined a subset of metadata for data sets, locations, and events to include in the integrated data sets. Using all this information we build a data schema defining a relation data base observation and measurement model based on Darwin core and CAUSI data models. We then created a schema cross walk from the original data sets to the integrate data schema, and wrote code to pull the data from the orgial locations to be intergrated in the final data sets. 



```{r echo=FALSE}
#create a vocabulary table 
vocabulary<- metadata %>% 
                  select(Table, SubsetOfMetrics,
                         measurementTerm,LongName, Description,Examples, DataType,measurementUnit) %>% 
                  filter(Table== "ControlledVocabulary", SubsetOfMetrics=="x") %>% 
                  select(-SubsetOfMetrics, -Table)

kable(vocabulary)

```

The working group crosswalked each of their program's field names to the controlled vocabulary. We documented details of the metric compatibility discussions between the four programs in Appendix A of the [Data Exchange Specification](MetricLevelExchangeSpecifications.docx) document. 

```{r echo=FALSE}
crosswalk<- metadata %>% 
        select(c("SubsetOfMetrics", "InDES", 
           "measurementTerm", "LongName", "Description", "Examples", "DataType", "measurementUnit")|contains("CW")) %>% 
        filter(SubsetOfMetrics=="x"| InDES=="x"  ) %>% 
        select(-SubsetOfMetrics, -InDES)  
```

If partners wish to exchange additional metrics, the controlled vocabulary must be updated and cross-walk. The list of metrics from the four programs not included in the first draft of the standard vocabulary or data exchange specifications is here: [list of metrics not in the controlled vocabulary ](Tables/NotInControlledVocabularyOrDES.csv) 

# Use Case 
We wrote code based on these data exchange specifications to share habitat metrics from three federal habitat monitoring programs: Environmental Protection Agency (EPA) National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM),and the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP). The work flow pulls program information from ScienceBase, the exchange specifications and the field crosswalk from this repository, and data collection metrics documented from MonitoringResources.org [work flow diagram](https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Figures/WorkFlow.png). The R code to integrate data sets can be found at https://github.com/rascully/Integrating-Stream-Monitoring-Data-From-Multiple-Programs and the data set documentation in ScinceBase at ADD SCIENCEBAES LINK WHEN I CAN 

# Conclusion
The data exchange specifications contain the details of what will be share and the format to be shared. We recognize preparing data to be shared requires an investment of time, resources, expertise, and careful documentation of the data collection process and the results.  A recent opinion piece in Nature by Barend Mons (2020), the director of a Global Open FAIR office, recommends that '5% of research funds be invested in making data reusable'. Projects producing this type of data are already working beyond their capacity, so to integrate data between habitat programs, there needs to be support in project budgets or for a centralized data manager to help implement and updated the necessary documentation and code to share data. 

# References 
Mons, B. (2020). Invest 5% of research funds in ensuring data are reusable. Nature, 578(7796), 491.

Kulvatunyou, B., Morris, K. C., Ivezic, N., & Frechette, S. (2008). Development life cycle for semantically coherent data exchange specification. Concurrent Engineering, 16(4), 279-290.

Wieczorek J, Bloom D, Guralnick R, Blum S, Döring M, et al. (2012) Darwin Core: An Evolving Community-Developed Biodiversity Data Standard. PLoS ONE 7(1): e29715. https://doi.org/10.1371/journal.pone.0029715

Wikipedia contributors. 'Machine-readable data.' Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, 6 Aug. 2013. Web. 21 Aug. 2014.











