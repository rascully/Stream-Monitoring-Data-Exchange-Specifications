

integrate_data <- function(){

library(dplyr)
library(readxl)
library(readr)
library(tidyverse)
library(openxlsx)
library(sf)
library(tmap)
library(httr)
library(data.table)
library(sp)
library(sbtools)
library(rgdal)
library(sjmisc)

# Load functions 
  source(paste0(getwd(), "/Data Intergration Example/R/data_mapped_field.R")) 
  
#github_link <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/Data/MetadataDictionary_v1.xlsx?raw=true"

#temp_file <- tempfile(fileext = ".xlsx")

#req <- GET(github_link, 
           # authenticate using GITHUB_PAT
 #          authenticate(Sys.getenv("GITHUB_PAT"), ""),
           # write result to disk
  #         write_disk(path = temp_file))

sheets      <- openxlsx::getSheetNames("Data/MetadataDictionary_v1.xlsx")
data        <- lapply(sheets,openxlsx::read.xlsx, xlsxFile="Data/MetadataDictionary_v1.xlsx")
names(data) <- sheets


for (n in sheets) { 
  assign(n, tibble(data[[n]]))
}

rm(data)
#unlink(temp_file)

#List of programs to integrated data from.
program <- c("NRSA","AIM", 'PIBO', "AREMP")

#Name of the exchange tables 
exchange_tables <- c("RecrordLevel", "Location", "Event", "MeasurementOrFact")

#Projection for the combined dataset 
CRS<-  "+proj=longlat +datum=WGS84 +no_defs"


# create a list of fields from the data exchange specifications 
des_names <-MetadataDict %>% 
filter(str_detect(tblname, c("Record|Location|Event")))%>% 
        drop_na(label)%>%  
        dplyr::select(label)%>% 
        unlist(use.names = F) %>% 
       unique()

# Download and get the controlled vocabulary for the measurement or fact measurementType and measurementTypeID 
#github_link <- "https://raw.githubusercontent.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/master/Data%20Exchange%20Standard%20Tables/metricControlledVocabulary.csv"
#temp_file <- tempfile(fileext = ".csv")
#req <- GET(github_link, 
           # authenticate using GITHUB_PAT
#           authenticate(Sys.getenv("GITHUB_PAT"), ""),
           # write result to disk
#           write_disk(path = temp_file))

metricControlledVocabularyToSave <- read.csv("Data Exchange Standard Tables/metricControlledVocabulary.csv")
# create a list of 
metricControlledVocabulary <- metricControlledVocabularyToSave %>% 
                              dplyr::select("measurementType") %>% 
                              unlist(use.names=F) %>%  
                             unique()


flat_data_names     <- c(des_names, metricControlledVocabulary) %>%  trimws()
flat_data           <- data.frame(matrix(ncol=length(flat_data_names), nrow=1))
colnames(flat_data)  <- flat_data_names


#Download the data mapping from the data exchange specifications Git page. Thi sw 
#github_link <- "https://raw.githubusercontent.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/master/Data%20Exchange%20Standard%20Tables/DataMapping.csv"

#temp_file <- tempfile(fileext = ".csv")
#req <- GET(github_link, 
           # authenticate using GITHUB_PAT
#           authenticate(Sys.getenv("GITHUB_PAT"), ""),
           # write result to disk
#           write_disk(path = temp_file))

Crosswalk_tall <- read.csv("Data Exchange Standard Tables/DataMapping.csv")
#rm(temp_file)

# Loop to download, reformat the data 
for(p in program) {
 
  if (p=="NRSA"){

  source(paste0(getwd(), "/Data Intergration Example/R/Download and clean EPA NRSA.R"))
  data <- download_EPA_NRSA()
  
  # we filter for only the wadeable streams
    field <- dataMapVariable("samplingProtocol", p)
    data <- data %>% 
      filter(!!as.name(field) == "WADEABLE")
    
  # from the datamapping find the field name that contains the percent dry for AIM
  field <- dataMapVariable("fieldNotes", p)

  #Change variable percent dry percent dry to a category
    dry <- data[[field]]
    dry <- as.character(dry) 
    dry[(dry == 0) & !is.na(dry)] <- "Flow (Whole Reach)"
    dry[(dry == 100)& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Flow") & !is.na(dry)] <- "Other"
    data[[field]] <- dry
    
    
  } else if (p=="AIM") { 
    
    print("Processing BLM AIM data")
    source(paste0(getwd(), "/Data Intergration Example/R/Download and clean BLM AIM Data.R"))
    data <- download_AIM()
    
    ##### Format data to Data Exchange Standard ####
    #Filter out the PRTCOl = BOATABLE
    field <- dataMapVariable("samplingProtocol", p)
    
    data <- data %>% 
      filter(!!as.name(field) == "Wadeable")
    
    
  #  data <- data %>% 
   #   filter(ProtocolType == "Wadeable")
    

  # from the datamapping find the field name that contains the percent dry for AIM
    field <- dataMapVariable("fieldNotes", p)
    
  #Change variable percent dry percent dry to a category
    dry <- data[[field]]
    dry <- as.character(dry) 
    dry[(dry == 0) & !is.na(dry)] <- "Flow (Whole Reach)"
    dry[(dry == 100)& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Flow") & !is.na(dry)] <- "Other"
    data[[field]] <- dry
    
    
  #from the datamapping find the field name that contains the percent dry for AIM
    field <- dataMapVariable("beaverImpactFlow", p)
  
   #change BVR_FLW_MD to YES, NO
    beaverImpactFlow  <- data[[field]]
    beaverImpactFlow  <- as.character(beaverImpactFlow) 
    beaverImpactFlow  <- str_replace(beaverImpactFlow,c("NONE"),"NO")
    beaverImpactFlow  <- str_replace(beaverImpactFlow, c("MAJOR"),"YES")
    beaverImpactFlow  <- str_replace(beaverImpactFlow, c("MINOR"),"YES")
    data[[field]]     <- beaverImpactFlow
  
  } else if (p=="PIBO"){ 
    print("Processing USFS PIBO data")  
    data <- as_tibble(read_xlsx("Data Intergration Example/Data/DataSources/2020_Seasonal_Sum_PIBO.xlsx", 2))
    
    #based on Project feedback when data was requested the coordinates system is WGS 84
    PIBO_coordinate <-  "+proj=longlat +datum=WGS84 +no_defs" 
    
    if(compareCRS(CRS, PIBO_coordinate)==TRUE){
      print(paste( p, "coordinate reference system matches the coordinate system of the data exchange standards for the integrated dataset."))
    } else{ 
      print(paste(p, "coordinate reference system does not match the coordinate system of the data exchange standards for the integrated dataset.")) 
      #Write code to reproject if 
    }
    
    
 #from the datamapping find the field name that contains the percent dry for AIM
    field <- dataMapVariable("fieldNotes", p)
      
  #Update Stream Flow values to the data exchange standard 
    dry <- data[[field]]
    dry[str_detect(dry, "Other") & !is.na(dry)] <- "Other"
    dry[str_detect(dry, "No")& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Other") & !is.na(dry)& !str_detect(dry, "No Flow")] <- "Flow (Whole Reach)"
    data[[field]] <- dry
    
  # Create a field Protocol field with WADEABLE based on project feedback that all data is collected in wadeable stream 
    data$Type ="WADEABLE"
   
  #Update the Type to the standard Targeted or Random -> need to confirm with Carl 
  # data$Project <- str_replace(data$Project,c("CRB|MRB"),"Random")
  # data$Project <- str_replace(data$Project, c("PILOT|CNTRCT|SPCL|OTHER|FWNF"),"Targeted")


  } else if (p== "AREMP") {
    print("Processing USFS AREMP data")
    source(paste0(getwd(), "/Data Intergration Example/R/Download and clean AREMP Data.R"))
    data <- download_AREMP()
    
    # Create a field Protocol field with WADEABLE based on project feedback that all data is collected in wadeable streamk 
    data$survey_type ="WADEABLE"

  }
  

##### Rename the SubSetData from the original fields to the terms (field names) from the data exchange standard #####
  term <- Crosswalk_tall %>% 
    filter(program == p) %>% 
    filter(originalField %in% names(data)) 
  

  SubSetData <- data %>% 
    dplyr::select(all_of(term$originalField)) 
  
 # build a vector of the field names from the crosswalk. Metric index equals the fields that are part of the metric controlled vocabularly, while the inverse are the fields in the DES. 
  metric_index <- term$term == "term"
  new_names <- character(length(metric_index))
  new_names[metric_index] <- term$measurementType[metric_index]
  new_names[!metric_index] <- term$term[!metric_index]
 
   names(SubSetData) = new_names
   rm(new_names)
   
   #Add a column a program with the metadata 
   SubSetData$projectCode   <- p
  
  
  ###### Convert date to datatype date #####
  if(any(names(SubSetData) =="eventDate")) {SubSetData$eventDate <- as.Date(SubSetData$eventDate, tryFormats = c("%m/%d/%Y", "%Y-%m-%d")) } 
  if(any(names(SubSetData) =="verbatimLocationID")) {SubSetData$verbatimLocationID <- as.character(SubSetData$verbatimLocationID)} 
  if(any(names(SubSetData) =="verbatimEventID")) {SubSetData$verbatimEventID <- as.character(SubSetData$verbatimEventID)} 
  
   if(any(names(SubSetData) =="StreamOrder")){
      if(typeof(SubSetData$StreamOrder) == "character") {
            SubSetData$StreamOrder <- parse_number(SubSetData$StreamOrder) 
                } else if (typeof(SubSetData$StreamOrder)=="integer") {
            SubSetData$StreamOrder <- as.numeric(SubSetData$StreamOrder)
                }
      }
  
##### Add fields to the SubSetData that define the specific dataset being combind. Most of those fields are part of the Record table from the data exchange standard    
if (p=="NRSA"){

     SubSetData$datasetID               <- 1  
     SubSetData$bibilographicCitation   <- paste("U.S. Environmental Protection Agency. 2016, 2020. National Aquatic Resource Surveys. National Rivers and Streams Assessment 2008-2009, 2013-2014. Available from U.S. EPA web page: https://www.epa.gov/national-aquatic-resource-surveys/SubSetData-national-aquatic-resource-surveys.Date accessed:", Sys.Date())
     SubSetData$datasetOrginization     <- "Environmental Protection Agancy"
     SubSetData$institutionCode         <- "EPA"
     SubSetData$projectName             <- "National Rivers and Streams Assessmet"
     SubSetData$projectCode             <- "NRSA"
     SubSetData$datasetLink             <- "https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys"
     SubSetData$metadataID              <- "https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/tree/master/Data%20Intergration%20Example"
     SubSetData$locationRemarks         <- "Bottom of Reach"
     
    } else if (p=="AIM") { 
     
     # SubSetData$datasetName
      SubSetData$datasetID               <- 2
     SubSetData$bibilographicCitation   <- "BLM AIM Aquatic Data (AquADat) Map Service"
     SubSetData$datasetOrginization     <- "Bureau of Land Management"
     SubSetData$institutionCode         <- "BLM"
     SubSetData$projectName             <- "Asssessment, Inventory, and Monitoring"
     SubSetData$projectCode             <- "AIM"
     SubSetData$datasetLink             <- "https://gis.blm.gov/arcgis/rest/services/hydrography/BLM_Natl_AIM_AquADat/MapServer"
     SubSetData$metadataID              <- "https://landscape.blm.gov/geoportal/rest/document?id=%7B44F011CC-6E1F-4FDA-AFDF-B29BF1732ACF%7D"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/tree/master/Data%20Intergration%20Example"
     SubSetData$locationRemarks         <- "Middle of Reach"
     
   } else if (p=="PIBO"){ 
     SubSetData$datasetID               <- 3
     SubSetData$datasetName             <- "2020_Seasonal_Sum_PIBO"
     SubSetData$bibilographicCitation   <- ''
     SubSetData$datasetOrginization     <- "United States Forest Service"
     SubSetData$institutionCode         <- "USFS"
     SubSetData$projectName             <- "PacFish/InFish Biological Opinion Monitoring Program"
     SubSetData$projectCode             <- "PIBO"
     SubSetData$datasetLink             <- "https://www.fs.usda.gov/detail/r4/landmanagement/resourcemanagement/?cid=stelprd3845865"
     SubSetData$metadataID              <- "Available by data request "
     SubSetData$preProcessingCode       <- ""
     SubSetData$locationRemarks         <- "Bottom of Reach"
     
     
   } else if (p== "AREMP") {
   
     SubSetData$datasetID               <- 4
     SubSetData$datasetName             <- "Northwest Forest Plan-the first 
                                              20 years (1994 to 2008): watershed condition status and trend" 
     
     SubSetData$bibilographicCitation   <- 'Miller, Stephanie A.; Gordon, Sean N.; Eldred, Peter; 
                                            Beloin, Ronald M.; Wilcox, Steve; Raggon, Mark;Andersen, 
                                            Heidi; Muldoon, Ariel. 2017. Northwest Forest Plan the first 
                                            20 years (1994 to 2013): watershed condition status and trends. Gen. Tech. Rep. PNW GTR 932.
                                            Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Research Station. 74 p.'
 
     SubSetData$datasetOrginization     <- "United States Forest Service"
     SubSetData$institutionCode         <- "USFS"
     SubSetData$projectName             <- "Aquatic and Riparian Effectiveness Monitoring Plan"
     SubSetData$projectCode             <- "AREMP"
     SubSetData$datasetLink             <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.zip"
     SubSetData$metadataID              <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.htm"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/tree/master/Data%20Intergration%20Example"  
     SubSetData$locationRemarks         <- "Bottom of Reach"
  
   }
   
   
  #####Add the SupSetData representing the specific program data into the flat_data, combinding information from the sources #####
  flat_data <- bind_rows(flat_data, SubSetData)

   rm(SubSetData)

}

#####Clean up the data #####

# Remove any locations with blank latitude and longitude 
all_data2 = flat_data %>%
  filter(!is.na(longitude) & !is.na(latitude)) 

# Check if there are blanks in the year
blank_year                  <- is.na(all_data2$year)
all_data2$year[blank_year]  <- substr(all_data2$eventDate[blank_year],1, 4) 
all_data2$year              <- as.integer(all_data2$year)


##### Generate UIDs for the integrated dataset 

#test <- all_data2[duplicated(all_data2$verbatimEventID),]

#all_data2 %>% 
#  filter(eventID==19676)

#Enter an eventID for the integrated dataset, based on the structure of this dataset we know that each row is a different data collection event, so therefore we generate a UID in the eventID
all_data2 <- all_data2 %>% 
  mutate(temp_eventID = paste0(verbatimEventID,projectCode)) %>% 
  transform(eventID=as.numeric((factor(temp_eventID)))) %>% 
  dplyr::select(-temp_eventID)

#test2 <- all_data2[duplicated(all_data2$eventID),]

#UID location integrated dataset, need to create a temp locationID concatenating program and LocationID in case across programs location ID is repeated 
all_data2 <- all_data2 %>% 
            mutate(temp_locaitonID = paste0(verbatimLocationID,projectCode)) %>% 
            transform(locationID=as.numeric((factor(temp_locaitonID)))) %>% 
            dplyr::select(-temp_locaitonID)


#Remove rows that are exact duplicate from the combind dataset
all_data2 <-  all_data2 %>% 
              distinct()

# Create a list of unique locations for the combind dataset 
u_locations <- dplyr::select(all_data2, (c(locationID, latitude, longitude,
                                           waterBody, projectCode)))
unique_locations <- distinct(u_locations)


unique_path <- paste0(getwd(), "/Data Intergration Example/data/Unique Locations for Stream Habitat Metric.csv")
#file.remove(unique_path)
write.csv(unique_locations, file=unique_path, row.names=FALSE)


####Subset the data set to match the data exchange specifications documented on https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications#####
#Record level table 
#Subset the sampling features/locations 
RecordLevel<- MetadataDict %>% 
  filter(str_detect(tblname, "Record")) %>% 
  drop_na(label)%>%  
  dplyr::select(label)%>% 
  unlist(use.names = F) %>% 
  unique() %>% trimws()

RecordLevel_table <- all_data2 %>% 
  dplyr::select(one_of(c("datasetID",RecordLevel))) %>% 
  distinct()


location <- MetadataDict %>%  
    filter(str_detect(tblname, "Location"))%>% 
    drop_na(label)%>%  
    dplyr::select(label)%>% 
    unlist(use.names = F) %>% 
    unique() %>% trimws()

#Subset the sampling features/locations 
location_table <- all_data2 %>% 
  dplyr::select(one_of(c("datasetID", location))) %>% 
  distinct() %>% 
  relocate(c("datasetID","locationID", "verbatimLocationID","latitude", "longitude"))  

#Build the event table/action table 
event<- MetadataDict %>% 
  filter(str_detect(tblname, "Event")) %>% 
  drop_na(label)%>%  
  dplyr::select(label)%>% 
  unlist(use.names = F) %>% 
  unique() %>% trimws()

event_table <- all_data2 %>% 
  dplyr::select(one_of(c("locationID",  event)))

#Create the measurement or fact table 

measurement_names <- metricControlledVocabulary

measurement <- all_data2 %>% 
  dplyr::select(eventID) 

measurement <- all_data2 %>% 
            dplyr::select(measurement_names, eventID)

Results <- measurement %>% 
  pivot_longer(cols = names(dplyr::select(measurement, -eventID)), 
               names_to ="measurementType", values_to="measurementValue") %>% 
  drop_na(measurementValue) %>% 
  add_column(measurementTypeID = as.integer(NA)) %>% 
  rowid_to_column("measurementID")  


#Add the measurmentID to the measurement or fact table 
cv_index <- metricControlledVocabularyToSave %>% 
  dplyr::select(contains("measurementType")) 

# add the MeasurmentTypeID to the MeasurementOrFact table
for(t in unique(Results$measurementType)){ 
    m_index                          <-  Results$measurementType==t
    Results$measurementTypeID[m_index]          <-  as.numeric(cv_index %>% 
                                                      filter(measurementType==t) %>% 
                                                      dplyr::select(measurementTypeID)) 
  } 

# Clean up the MeasurementOrFact table based on project feedback 
Results<- Results %>% 
  filter(measurementValue != -99.999 ) %>% 
  filter(measurementValue != Inf) %>% 
  relocate(c("eventID","measurementID", "measurementType", "measurementTypeID","measurementValue")) 

#Write the analysis ready stream monitoring dataset data to a .csv
file_path <- paste0(getwd(), "/Data Intergration Example/data/Analysis Stream Habitat Monitoring Metric Dataset.csv")
file.remove(file_path)
write.csv(all_data2, file=file_path, row.names=FALSE)


#Save the relational relation database files and metadata 
list_of_datasets <- list("RecordLevel" = RecordLevel_table, "Location"= location_table, "Event"= event_table,
                         "MeasurmentOrFact"= Results, 
                         "MetricControlledVocabulary" = metricControlledVocabularyToSave
                         ,"DataMapping"= Crosswalk_tall)

file_name = paste0(getwd(), "/Data Intergration Example/data/Relational Data Tables Stream Habitat Metrics.xlsx") 
file.remove(file_name)
openxlsx::write.xlsx(list_of_datasets, file = file_name) 

# Save .csv files for each of the tables in the relational database 
for(i in 1:length(names(list_of_datasets))){ 
  filename = paste0(getwd(),"/Data Intergration Example/Data/csv/", names(list_of_datasets[i]), ".csv")
  table_name <- names(list_of_datasets[i])
  table <- data.frame(list_of_datasets[i])
  names(table) <- gsub(paste0(table_name,"."), "", names(table))
  write.csv(table, filename, row.names= FALSE)
} 


return(list_of_datasets) 

}
