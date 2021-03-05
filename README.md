
# Stream Monitoring Habitat Data Exchange Specifications 
Data exchange specifications are a set of guidelines and rules for using and combining information. Rigorous data exchange specifications support reuse, promote interoperability, and reduce data integration costs (Morris and Frechette 2008, Hamm 2019). The Stream Monitoring Habitat Data Exchange Specifications are a standard for exchanging metric-level habitat data based on the Darwin Core principles outlined by Wieczorek et al. in 2012. The Darwin Core standard is maintained at the GitHub repository https://github.com/tdwg/dwc. The Stream Habitat Metric Data Integration working group facilitated by the Pacific Northwest Aquatic Monitoring Partnership (PNAMP) (https://www.pnamp.org/project/habitat-metric-data-integration) and the USGS adopted the Darwin Core standard for stream habitat metrics, and as a use case, integrate stream habitat metrics from three federal stream habitat monitoring programs in a separate Git Hub Repository: https://github.com/rascully/Integrating-Stream-Monitoring-Data-From-Multiple-Programs..

# Structure 


We utilize the Darwin Core classes: Record-level, Location, Event, and Measurement or Fact Data Structure [Figure 1](Figures/StructureOfDarwinCoreForHabitatMetrics.png).Class in Darwin Core is the title for a group of terms (Wieczorek et al. 2012). The Record-level Class documents information about each data set and links to locations using the DatasetID. Location Class documents the locations and metadata about a specific location; locations are associated with a sampling event using the LocationID. Multiple events can be related to a single location. The Event Class documents the data collection event and metadata about the sampling event. Events are linked to the specific metric values using the EventID. The Measurement or Fact Class documents the metric values and metadata about each metric. At each event, programs collect multiple measurements, producing numerous metrics. To promote transparent and consistent metadata, PNAMP facilitated a process to describe a controlled vocabulary, defining the metrics that can be shared using these data exchange specifications. This type of data are suited to a star data schema, with one record table references multiple dimensional tables. Stream habitat data are structured such that there are one-to-many relationships between data sets and locations, locations and events, and events and metrics. We adapted the star schema described by Darwin Core to the stream habitat metric data sets [Figure 2](Figures/HabiatDataSharingSchema.png).  


## Record Level Class 
The Record Level Class documents the core elements of a data set, including information about the origin of the data set, who collected the data, and how to cite the data set. See details in the [Record Level table](Tables/RecordLevel_table.csv). A data set is a collection of locations. Each location there are a group of events, at each event a collection of metrics; for example, a program releases a data set every five years containing all the data collection locations, events, and metrics from the previous five years. We recommend storing metadata about the data sets in a trusted online data repository ensuring we have sufficient information about data sets’ origins. If a program does not have the resources to build a repository, we recommend using USGS ScienceBase, which is available to all. Find more information about ScienceBase here https://www.sciencebase.gov/about/.

## Location Class
Understanding where data are collected is critical to interpreting biological monitoring data.  The Location class describes where information are collected, see the list of terms in the [Location table](Tables/Location_table.csv). There are multiple locations in each data set. The locationID is the key to link locations to events. To view and analysis data from various sources, latitudes and longitude information must be consistent across data sets; therefore, for this data, all latitude and longitudes are converted to WGS1984.

## Event Class
The Event class describes an action that occurs at a specific time frame see the [Event table](Tables/Event_table.csv) To assess the status and trend of a resource as a response to management actions, stream habitat monitoring programs revists sites, meaning that the project returns to a single location multiple times during the study duration. Therefore, a data set will contain numerous locations, and each location includes numerous events.

## Measurement Or Fact (Metrics) Class
A metric is a value resulting from the reduction or processing of measurements taken at an event based on the procedures defined by the response design. Programs derive a variety of metrics from a single measurement. For stream habitat data at each event, programs take multiple types of measurements and produce various metrics from one measurement; for example, the measurement for pools produces both percent pools and pool frequency. Events are associated with measurements by the eventID, see the [Measurement Or Fact Table](Tables/MeasurementOrFact_table.csv) for the full definitions of terms. 

### Controlled Vocabulary  
We defined a controlled vocabulary of metrics to select from for the MeasurmetID and populate the MeasurmentUnit in the Measurement or Fact Class. The standard language enables the integration of multiple habitat monitoring program metrics into one data set.

We built the controlled vocabulary using metadata and metrics from four large scale, long-running federal stream habitat monitoring programs: Environmental Protection Agency (EPA), National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM), the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP) and PACFISH/INFISH Biological Opinion (PIBO) Effectiveness Monitoring. Each program has unique objectives, spatial, temporal, response, and inference designs; yet, they produce similar metrics. These four programs collectively produce over 300 metrics but have only a subset of common metrics across programs. Program leads, and data managers from the four programs agreed on a subset of the metrics that can be shared across the programs; these can be found in the first draft of the controlled vocabulary [controlled vocabulary](Tables/StandardVocabulary.csv).

The working group cross walked each of their program’s field names to the controlled vocabulary (Table 6) .  The working group agreed all metrics in the Temperature category will be pulled from the NorWeST temperature database. We documented details of the metric compatibility discussions between the four programs in Appendix A. 

If partners wish to exchange additional metrics, the controlled vocabulary and the cross walk must be updated on GitHub, and the integration code re-run.  The list of metrics from the four programs not included in the first draft of the standard vocabulary or data exchange specifications is documented in this repository. [View the list of metrics not in the controlled vocabulary ](Tables/NotInControlledVocabularyOrDES.csv) 

# Use Case 

As a use case for these date exchange specifications we wrote code based on these data exchange specifications to intergrate habitat metrics from three federal habitat monitoring programs: Environmental Protection Agency (EPA), National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM),and the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP). The [work flow](Figures/WorkFlow.png) pulls program information from ScienceBase, the exchange specifications and the field crosswalk from this repository, and data collection metrics documented from MonitoringResources.org. Find the R code to integrate data sets at the [Integrating Stream Monitoring Data From Multiple Programs](https://github.com/rascully/Integrating-Stream-Monitoring-Data-From-Multiple-Programs) Git Hub repository and the finaly data set is documentation and shared in ScienceBase at ADD SCIENCEBAES LINK WHEN I CAN

# Conclusion
The data exchange specifications contain the details of what will be share and the format to be shared. We recognize preparing data to be shared requires an investment of time, resources, expertise, and careful documentation of the data collection process and the results. A recent opinion piece in Nature by Barend Mons (2020), the director of a Global Open FAIR office, recommends that ‘5% of research funds be invested in making data reusable’. Projects producing this type of data are already working beyond their capacity. To integrate data between habitat programs, there needs to be support in project budgets or for a centralized data manager to help implement and update the necessary documentation and code to share data.

# References 
Mons, B. (2020). Invest 5% of research funds in ensuring data are reusable. Nature, 578(7796), 491.

Kulvatunyou, B., Morris, K. C., Ivezic, N., & Frechette, S. (2008). Development life cycle for semantically coherent data exchange specification. Concurrent Engineering, 16(4), 279-290.

Wieczorek J, Bloom D, Guralnick R, Blum S, Döring M, et al. (2012) Darwin Core: An Evolving Community-Developed Biodiversity Data Standard. PLoS ONE 7(1): e29715. https://doi.org/10.1371/journal.pone.0029715

Wikipedia contributors. 'Machine-readable data.' Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, 6 Aug. 2013. Web. 21 Aug. 2014.




