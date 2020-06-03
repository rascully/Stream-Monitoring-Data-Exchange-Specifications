This repository documents the data exchange specification for metric-level habitat data based on the Simple Darwin Core principles with location, event, and measurement or fact extensions (ADD CITATION?https://dwc.tdwg.org/terms/#measurementorfact).  We propose data exchange specification architecture based on data userís needs and data from the four monitoring programs involved in this effort: Environmental Protection Agency (EPA) National Rivers & Streams Assessment (NRSA), Bureau of Land Management (BLM) Aquatic Assessment, Inventory, and Monitoring (AIM), the Forest Service Aquatic and Riparian Effective Monitoring Program and PACFISH/INFISH Biological Opinion Effectiveness Monitoring. Each of these programs has unique objectives and, therefore, unique spatial, temporal, response, and inference designs. Collectively these four programs produce over 300 metrics. Included is a controlled vocabulary for a sub-set of metrics because more than two programs calculate them.  

We cross-walked each programís metadata to the standard vocabulary, but that does not indicate the metric is compatible across programs. Detail of the metric combability between programs based on literature and input from the programsí staff is shared here.  The burden is on the data user to decide if the methods are comparable enough to answer their specific management questions based on the robust metadata provided with each metric. 

We built a standard set of metrics for exchange based on the datasets from the four habitat monitoring programs, BLM AIM, EPA NARS, USFS PIBO, and USFS ARMEP. The controlled vocabulary contains a subset of the metrics calculated among the three programs. 

Robust machine and human-readable documentation of the step by step process used to collect and analyzed data is required to assess the comparison of metrics from multiple stream habitat monitoring programs.  We document data collection methods and analysis in MonitoringResources.org. 

Using these data exchange specifications, MonitoringResources.org, and ScienceBase, we can make instream habitat data findable, accessible, interoperable, and reusable (FAIR). We are efficiently delivering stream habitat metrics across jurisdictional boundaries to decision-makers. The code to incorporate the data is accessible in the Git Repository: <a href = "https: //github.com/rascully/Stream-Monitoring-Data-Intergrating-Data-From-Multiple-Programs">https: //github.com/rascully/Stream-Monitoring-Data-Intergrating-Data-From-Multiple-Programs</a>. Using the combined data set, we built a biological analysis package and tools for downloading and visualizing the dataset and can be found here:  <a href="https://github.com/rascully/stream-habitat-bap">https://github.com/rascully/stream-habitat-bap</a>. 

If partners wish to exchange additional metrics, the controlled vocabulary needs to be updated  with the name, description, short machine-readable name, data type, and unit.  We use GitHub to manage version control of the habitat metric vocabulary.  To use the controlled vocabulary, a new program must cross-walk the fields in their datasets fields to the dictionary and document their data collection and analysis methods in MonitoringResources.org. The pilot programís field cross-walk and MonitoringResources.org metrics IDs are shared in the cross-walk.csv file. 
