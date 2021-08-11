#Access Vocabularies from AIP 

#Require the package so you can use it
require("httr")
require("jsonlite")
require("XML")
require("tidyverse")
require("xml2")
require("devtools")

CV_list <- c("datasettype", "organizationtype","samplingfeaturetype", "sitetype")
metadata <- "Created and maintained at the Observation Data Model 2 (ODM2) (https://github.com/ODM2/ODM2ControlledVocabularies) . ODM2 is an information model and supporting software ecosystem for feature-based earth observations, designed for interoperability among disciplines."

#####Pull data from the API, but I am not good at this. 
for(cv in CV_list){
  print(cv)
URL <- paste0("http://vocabulary.odm2.org/api/v1/",cv,"/?format=skos")
assign(cv, xmlToDataFrame(URL, homogeneous=FALSE) %>% 
        filter(!is.na(definition)) %>% 
        select("prefLabel", "definition" , "type","inScheme")) 
} 

CV_metadata <- data.frame(CV_list, metadata)

##### Pull data from downloaded CV tables 

for(cv in CV_list){
  print(cv)
  filename <- paste0("Tables/",cv,".csv")
  assign(cv, read.csv(filename)) 
} 

##### Units controlled vocabulary suggested by !!! 
units<- read.csv("Tables/CV_Units.csv")
CV_list<- "units"
metadata<-"Units are not treated as a CV in ODM2.However they do provided a list of Units for those who may want to adopt and use them."

CV_metadata <- bind_rows(CV_metadata, data.frame(CV_list, metadata))

####Controlled vocabularies created for by the Stream
stream_variables <- read.csv("Tables/Controlledvocabulary.csv")

CV_list<- "Stream_Variables"
metadata<-"Controlled vocabullary described by the Stream Habitat Metric Intergration project, facilited by PNAMP, see information here:https://www.pnamp.org/project/habitat-metric-data-integration."

CV_metadata <- bind_rows(CV_metadata, data.frame(CV_list, metadata))

list_of_datasets <- list("metadata"= CV_metadata, "dataset" = datasettype, "organization"= organizationtype, "site"= sitetype, 
                         "sampleingfeature"=samplingfeaturetype,  "units"= units, 
                         "streamVariables"= stream_variables)

openxlsx::write.xlsx(list_of_datasets, file = "Tables/ControlledVocabularies.xlsx", overwrite = TRUE) 

