# Stream Monitoring Habiata Data Exchange Specifications 
Stream Monitoring Habitat Data Exchange Specifications is a standard for exchanging metric-level habitat data based on the Darwin Core principles. 

The stream habitat data exchange specifications are structured based on the simple Darwin Core standard. Using data from four federal stream habitat monitoring programs as a model, we outline the elements needed to share or integrate metrics from stream habitat data sets. We included core dataset information, location information, data collection event information, and individual metrics data. We follow the recommend Darwin Core star database schema due to how one location relates to multiple events, and programs produce numerous metrics at a single event [Figure 1](Figures/StructureofStreamHabitatData.png). The approach is flexible enough to be adapted later to support the transfer of other data types such as macroinvertebrate counts or riparian vegetation.

We utilize the Darwin Core classes Record-level, Location, Occurrence, and Measurement or Fact [Figure 2](Figures/StructureOfDarwinCoreForHabitatMetrics.png). Class in Darwin Core is the title for a group of terms. Record-level class documents information about each dataset and is linked to Location using the DatasetID. Location class document the location and metadata about that location; it is associated with a sampling event using the LocationID. Multiple events can be related to one location—the Event class documents the data collection event and metadata about the sampling event. The event is linked to the specific metric using the EventID. The Measurement Or Fact class documents the metrics and metadata about each metric. At each event, programs collet multiple measurements, producing numerous metrics. To promote transparent and consistent metadata, we facilitated a process to describe a standard vocabulary defining the metrics that can be shared using these data exchange specifications. 

## Record Level Class 
The Record Level class documents the core elements of a data set, including information about the origin of the dataset, who collected the data, and how to cite the dataset [Table 1](Tables/RecordLevel.xlsx).  A data set is a collection of data collection events; for example, a program releases a data set every five years containing all the data collection events occurring in the previous five years. We recommend storing metadata in a trusted online data repository to ensure we have sufficient information about data sets’ origins. If a program does not have the resources to build a repository, we recommend using USGS ScienceBase, which is available to all. To can find more information about ScienceBase, go to https://www.sciencebase.gov/about/.  

## Location
Understanding where data are collected is critical to interpreting biological monitoring data.  The Location class describes where information is collected [Table 2](Tables/Location.xlsx).  There will be multiple locations in each dataset.  To join data from various sources to one dataset, latitudes and longitude information must be constant amongst datasets; therefore, all latitude and longitudes are converted to WGS1984. The locationID is the key to link locations to events. 

## Event
The Event class describes an action that occurs at a specific time frame [Table 3](Tables/Event.xlsx). To assess the resource trend as a response to management actions, stream habitat monitoring programs often implement rotating panel design, meaning that the project returns to a single location multiple times during the study duration.  Therefore a dataset will contain numerous locations, and each location can include numerous events.

## Measurment Or Fact (Metrics)
A metric is a value resulting from the reduction or processing of measures taken at an event based on the procedures defined by the response design. Programs derive a variety of metrics from a single measurement. For stream habitat data at each Event, programs take multiple types of measures and produce various metrics from one measure; for example, the metrics percent pools and pool frequency are calculated from pool measurements.  Events are associated with measurement by the eventID[Table 4](Tables/MeasurementOrFact.xlsx). 

We defined a standard vocabulary of metrics to select from for the MeasurmetID and populate the MeasurmentUnit. The standard language enables the integration of multiple habitat monitoring program metrics. 

We built the standard vocabulary using metadata and metrics from four large scale, long-running federal stream habitat monitoring programs: Environmental Protection Agency (EPA) National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM), the Forest Service Aquatic and Riparian Effective Monitoring Program (AREMP) and PACFISH/INFISH Biological Opinion (PIBO) Effectiveness Monitoring. Each program has unique objectives, spatial, temporal, response, and inference designs, yet; they produce similar metrics. Metrics are a value resulting from the reduction or processing of measurements taken at a site at a specific temporal unit one or more times during the study period based on the procedures defined by the response design. You can derive a variety of metrics from the original measurements.  These four programs collectively produce over 300 metrics, but have only a subset of metrics across programs. The program leads, and data managers from the four programs agreed on a sub-set of the metrics that can to share across the programs.  This subset is the first draft of the controlled vocabulary [Table 5](/2020_12_01%20Controlled%20Vocabulary%20and%20Crosswalk.xlsx).   

The working group cross-walked each of their program's field names to the standard vocabulary.  We also documented detail of the metric combability discussions between the four programs in Appendix A.  The burden is on the data users to ultimately decide if the methods are comparable enough to answer their specific management questions based on metadata in MonitoringResources.org.

If partners wish to exchange additional metrics, they must update the controlled vocabulary on GitHub.  

# Providing Data to Users 
We model this data schema on the Darwin Core star schema[Figure 3](Figures/HabiatDataSharingSchema.png). The star schema is an efficient format for updating and storing data, but not for quick and efficient data analysis. Therefore we will build tools for managers and analysts to download the data in an analysis-ready format based on the Tidy Data principles of each observation is a row; each variable is a column (Wickham 2014).  We chose this structure to simplify loading the data into R and Python for analysis. Each data collect event is a row, and the multiple reach level metrics produced and metadata from an event are fields in the data set. Fields refer to the column headers in the data set, and fields are defined by these data exchange specifications.  

To simplify this data's reuse, we will also link the data to other data sets to provide environmental context to each data collection location, such as elevation, land ownership, management unit, percent forested, etc. 

# Conclusion
The data exchange specifications contain the details of what will be share and the format to be shared.  We recognize preparing data to be shared requires an investment of time, resources, expertise, and careful documentation of the data collection process and the results.  A recent opinion piece in Nature by Barend Mons (2020), the director of a Global Open FAIR office, recommends that "5% of research funds be invested in making data reusable". Projects producing this type of data are already working beyond their capacity, so to integrate data between habitat programs, there needs to be supported in project budgets or for a centralized data manager to help implement and updated the necessary documentation and code to share data. 

Outlining a data exchange specification is only the first step towards delivering timely stream habitat data across jurisdictional boundaries.  We need additional statistical support to answer the question of how to integrate sites selected using different site selection methods. 

# References 
Al-Chokhachy, R., & Roper, B. B. (2010). Different approaches to habitat surveys can impact fisheries management and conservation decisions. Fisheries, 35(10), 476-488.

Chase, K. J., Bock, A. R., & Sando, R. (2016). Sharing our data—An overview of current (2016) USGS policies and practices for publishing data on ScienceBase and an example interactive mapping application (No. 2016-1202, pp. 1-10). US Geological Survey.
"How the Exchange Network works:" EPA. Environmental Protection Agency, 14 Feb. 2013. Web. 23 July 2014. <http://www.epa.gov/exchangenetwork/info/>.

Mons, B. (2020). Invest 5% of research funds in ensuring data are reusable. Nature, 578(7796), 491.

Puls, A., Dunn, A., Hudson, G. (2014). Evaluation and Prioritization of Stream Habitat Monitoring in the Lower Columbia Salmon and Steelhead Recovery Domain as related to the Habitat Monitoring Needs of ESA Recovery Plans. PNAMP Series 2014-003. URL. http://www.pnamp.org/document/4769

Wieczorek, J., Bloom, D., Guralnick, R., Blum, S., Döring, M., Giovanni, R., ... & Vieglais, D. (2012). Darwin Core: an evolving community-developed biodiversity data standard. PloS one, 7(1).

Wikipedia contributors. "Machine-readable data." Wikipedia, The Free Encyclopedia. Wikipedia, The Free Encyclopedia, 6 Aug. 2013. Web. 21 Aug. 2014.




