
integrate_data <- function(){

library(plyr)
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
library(stringr)

# Run function to build DES tables and controlled vocabulary tables from MetadataDict to make sure everything is up to date 
  source(paste0(getwd(), "/R/CreateDataTablesMetadataDict.R"))
  build_vocab_tables()
  
# Load function to search data mapping 
  source(paste0(getwd(), "/DataIntegrationExample/R/dataMappedField.R")) 

# Read the Metadata dictionary to define field headers for the combined dataset
MetadataDict <- read.csv("Data/MetadataDictionary.csv")


# List of programs to integrate data from
program <- c("NRSA","AIM", "PIBO", "AREMP") 


# Projection for the combined dataset 
CRS<-  "+proj=longlat +datum=WGS84 +no_defs"


# Create a list of fields from the data exchange standards
des_names <-MetadataDict %>% 
        filter(str_detect(entity, c("Record|Location|Event")))%>% 
        drop_na(attribute)%>%  
        dplyr::select(attribute)%>% 
        unlist(use.names = F) %>% 
        unique()
       
# Remove any blanks in character
des_names <- des_names[des_names!= '']

# A vector of metrics names to include in the dataset 
metricControlledVocabulary <- read.csv("DataExchangeStandardTables/metricControlledVocabulary.csv")%>% 
                          dplyr::select("measurementType") %>% 
                          unlist(use.names=F) %>%  
                          unique()



#create an empty dataframe in flat file format to build the analysis ready dataset 
flat_data_names     <- c(des_names, metricControlledVocabulary) %>%  trimws()
flat_data           <- data.frame(matrix(ncol=length(flat_data_names), nrow=1))
colnames(flat_data)  <- flat_data_names

# Read the the data mapping and trim out the white space in the strings
DataMapping <- read.csv("DataExchangeStandardTables/DataMappingDES.csv") %>% 
                    mutate(across(where(is.character), str_trim))

#### Loop to download, and pull information from the original datasets into one file. Add record level information. ####
for(p in program) {
 
  if (p=="NRSA"){

  source(paste0(getwd(), "/DataIntegrationExample/R/DownloadAndCleanEPANRSA.R"))
  data <- download_EPA_NRSA()
  
  # Filter for only the wadeable streams
    field <- dataMapVariable("samplingProtocol", p)
    data <- data %>% 
      filter(!!as.name(field) == "WADEABLE")
  
# From the datamapping find the field name that contains the percent dry program # ed: not sure I understand what "percent dry program" means.
  field <- dataMapVariable("fieldNotes", p)

  # Change variable percent dry to a category
    dry <- data[[field]]
    dry <- as.character(dry) 
    dry[(dry == 0) & !is.na(dry)] <- "Flow (Whole Reach)"
    dry[(dry == 100)& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Flow") & !is.na(dry)] <- "Partial Flow/Stagnant Pools"
    data[[field]] <- dry
    
    # Update SiteSelectionType to Random or Targeted 
    # from the datamapping find the field name that contains the siteSelectionType for NRSA  
    field <- dataMapVariable("siteSelectionType", p)
    siteSelectionType <- data[[field]]
    siteSelectionType <- str_replace_all(siteSelectionType, c("EASTPROB"= "Random", "WESTPROB"= "Random", "PROB" = "Random"))
    siteSelectionType <- str_replace_all(siteSelectionType, c("EASTHAND"= "Targeted", "WESTHAND"= "Targeted", 
                                                                  "HAND" = "Targeted"))
    data[[field]]     <- siteSelectionType

    
  } else if (p=="AIM") { 
    
    print("Processing BLM AIM data")
   source(paste0(getwd(), "/DataIntegrationExample/R/DownloadAndCleanBLMAIMData.R"))
   data <- download_AIM()

    
#### Format data to Data Exchange Standard ####
    # Remove data for ProtocolType = BOATABLE, so only wadeable data is included
    data <- data %>% 
      filter(ProtocolType == "Wadeable")
    
  # from the datamapping find the field name that contains the percent dry 
    field <- dataMapVariable("fieldNotes", p)
    
  # Change variable percent dry to a category 
    dry <- data[[field]]
    dry <- as.character(dry) 
    dry[(dry == 0) & !is.na(dry)] <- "Flow (Whole Reach)"
    dry[(dry == 100)& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Flow") & !is.na(dry)] <- "Partial Flow/Stagnant Pools"
    data[[field]] <- dry
    
    
  #from the datamapping find the field name that contains the percent dry for AIM 
    field <- dataMapVariable("beaverPresence", p)
  
   #change BVR_FLW_MD to YES, NO
    beaverPresence  <- data[[field]]
    beaverPresence  <- as.character(beaverPresence) 
    beaverPresence  <- str_replace(beaverPresence,c("Absent"),"Absent")
    beaverPresence  <- str_replace(beaverPresence, c("Common"),"Present")
    beaverPresence  <- str_replace(beaverPresence, c("Rare"),"Present")
    data[[field]]     <- beaverPresence
    
    
    # Update SiteSelectionType to Random or Targeted 
    # from the datamapping find the field name that contains the siteSelectionType for AIM 
    field               <- dataMapVariable("siteSelectionType", p)
    siteSelectionType   <- data[[field]]
    siteSelectionType   <- str_replace_all(siteSelectionType, c("RandomGRTS"= "Random", 
                                                                "RandomSystematic"= "Random", 
                                                                "SystematicRandom"= "Random"))
    data[[field]]       <- siteSelectionType
  
  } else if (p=="PIBO"){ 
    
    print("Processing USFS PIBO data")  
    data <- as_tibble(read_xlsx("DataIntegrationExample/Data/DataSources/2020_Seasonal_Sum_PIBO.xlsx", 2))
    
  # based on Project feedback when data was requested the coordinates system is WGS 84
    PIBO_coordinate <-  "+proj=longlat +datum=WGS84 +no_defs" 
    
    if(compareCRS(CRS, PIBO_coordinate)==TRUE){
      print(paste( p, "coordinate reference system matches the coordinate system of the data exchange standards for the integrated dataset."))
    } else{ 
      print(paste(p, "coordinate reference system does not match the coordinate system of the data exchange standards for the integrated dataset.")) 
      #Write code to reproject if needed 
    }
    
 # Remove PIBO type Prairie sites and project type Pilot, based on PIBO feedback 
   data<-  data %>% 
      filter(Type !="P") %>% 
      filter(Project != "PILOT")
    
 # From the datamapping find the field name that contains the percent dry for PIBO 
    field <- dataMapVariable("fieldNotes", p)
      
  #Update Stream Flow values to the data exchange standard 
    dry <- data[[field]]
    dry[str_detect(dry, "Other") & !is.na(dry)] <- "Partial Flow/Stagnant Pools"
    dry[str_detect(dry, "No")& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Other") & !is.na(dry)& !str_detect(dry, "No Flow")] <- "Flow (Whole Reach)"
    data[[field]] <- dry
    

  # Classify siteSelectionType for PIBO to Random and Rargeted. To do this we need to use two fields from PIBO dataset Project and Type. 
   siteSelectionType <- data %>% 
                      dplyr::select(c("Project", "Type")) %>% 
                      unite('ProjectType', Project:Type, remove=TRUE)

   # This must be done in this order 
   # All Project SPCK, OTHER, CNTRCT are Targeted
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "SPCL") ] <- "Targeted"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "OTHER") ] <- "Targeted"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "CNTRCT") ] <- "Targeted"
   unique(siteSelectionType)
   #I don't know about PILOT, FWNF? # ed: is this still up-to-date or did we resolve this and assign FWNF to Random? update the comment if so.
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "FWNF") ] <- "Random"
   unique(siteSelectionType)
   
   #Project types CRB & MRB have both Random and Targeted sites, for siteSelectionType use the PIBO Type  
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "I") ] <- "Random"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "S") ] <- "Random"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "K") ] <- "Targeted"
   data$Project <- siteSelectionType$ProjectType
   
   #Update protocol to a description, would be better to update to a link at to a PDF or MR.org document 
   data$Type[data$Type== "I" ] <- "PIBO Inegrator Protocol."
   data$Type[data$Type== "K" ] <- "PIBO Designated livestock grazing monitoirng area protocol(DMA)." 
   data$Type[data$Type== "IS" ] <- "PIBO Sentinel and Inegrator Protocol."
   data$Type[data$Type== "R" ] <- "PIBO Inegrator Protocol."
   data$Type[data$Type== "IKS" ] <- "PIBO Sentinels Protocol. "
   data$Type[data$Type== "IK" ] <- "PIBO Inegrator site and desiginated livestock grazing monitoirng area (DMA) protocol."
   
   

  } else if (p== "AREMP") {
    print("Processing USFS AREMP data")
    source(paste0(getwd(), "/DataIntegrationExample/R/DownloadAndCleanUSFSAREMPData.R"))
    data <- download_AREMP()
    
    # Create a field Protocol field with WADEABLE based on project feedback that all data is collected in wadeable stream 
    data$survey_type ="WADEABLE"
    # Calculate the AREMP bankful width to depth ratio 
    data$ave_widthDepth_ratio    <- data$average_bfwidth / data$average_bfdepth

  }
  

#### Rename the SubSetData from the original fields to the terms (field names) from the data exchange standard ####
  
  term <- DataMapping %>% 
    filter(projectCode == p) %>% 
    filter(originalField %in% names(data)) 
  
  SubSetData <- data %>% 
    dplyr::select(all_of(term$originalField)) 
  
 # build a vector of the field names from the crosswalk. Metric index equals the fields that are part of the metric controlled vocabulary, while the inverse are the fields in the DES. 
   metric_index <- term$term == "term"
   new_names <- character(length(metric_index))
   new_names[metric_index] <- term$measurementType[metric_index]
   new_names[!metric_index] <- term$term[!metric_index]
 
   names(SubSetData) = new_names
   print(new_names)
   rm(new_names)
   
   #Add a column a program with the metadata 
   SubSetData$projectCode   <- p
  
  
  #### Convert date to datatype date #### 
  # ed: in the line above you have convert date to datatype date which applies to the first and third lines below. so maybe add something else that says convert the other data types below to whatever?
  if(any(names(SubSetData) =="eventDate")) {SubSetData$eventDate <- as.Date(SubSetData$eventDate, tryFormats = c("%m/%d/%Y", "%Y-%m-%d")) } 
  if(any(names(SubSetData) =="verbatimLocationID")) {SubSetData$verbatimLocationID <- as.character(SubSetData$verbatimLocationID)} 
  if(any(names(SubSetData) =="verbatimEventID")) {SubSetData$verbatimEventID <- as.character(SubSetData$verbatimEventID)} 
  if(any(names(SubSetData) =="MeanThalwegDepth")) {SubSetData$MeanThalwegDepth <- as.double(SubSetData$MeanThalwegDepth)}
  if(any(names(SubSetData) =="BankAngle")) {SubSetData$BankAngle <- as.double(SubSetData$BankAngle)}
  if(any(names(SubSetData) =="TotalNitrogen")) {SubSetData$TotalNitrogen <- as.double(SubSetData$TotalNitrogen)}
  if(any(names(SubSetData) =="TotalPhosphorous")) {SubSetData$TotalPhosphorous <- as.double(SubSetData$TotalPhosphorous)}
  if(any(names(SubSetData) =="PoolTailFines2")) {SubSetData$PoolTailFines2 <- as.double(SubSetData$PoolTailFines2)}
  if(any(names(SubSetData) =="PoolTailFines6")) {SubSetData$PoolTailFines6 <- as.double(SubSetData$PoolTailFines6)}
   
   
   if(any(names(SubSetData) =="StreamOrder")){
      if(typeof(SubSetData$StreamOrder) == "character") {
            SubSetData$StreamOrder <- parse_number(SubSetData$StreamOrder) 
                } else if (typeof(SubSetData$StreamOrder)=="integer") {
            SubSetData$StreamOrder <- as.numeric(SubSetData$StreamOrder)
                }
      }
  
#### Add fields to the SubSetData that define the specific dataset being combined. ####
    
if (p=="NRSA"){

     SubSetData$datasetID               <- "4"
     SubSetData$projectCode             <- "NRSA"
     SubSetData$institutionCode         <- "EPA"
     SubSetData$datasetName             <- "Rivers and Streams"
     SubSetData$projectName             <- "National Aquatic Resource Surveys; National Rivers and Streams Assessmet"
     SubSetData$datasetLink             <- "https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys"
     SubSetData$bibilographicCitation   <- paste("U.S. Environmental Protection Agency; 2016; National Aquatic Resource Surveys; National Rivers and Streams Assessment 2008 to 2009 data and metadata files Date accessed:", Sys.Date()) # ed: also confused where this comes from b/c it should change depending on the subset data...
     SubSetData$metadataID              <- "https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/DataIntegrationExample/R/ownloadAndCleanEPANRSA.R" # ed: update link from Specifications to Standards if this changes in future
     SubSetData$locationRemarks         <- "Bottom of Reach"
     
     
    } else if (p=="AIM") { 
    
     SubSetData$datasetID               <- "2"
     SubSetData$projectCode             <- "AIM"
     SubSetData$institutionCode         <- "BLM"
     SubSetData$datasetName             <- "I_Indicators"
     SubSetData$projectName             <- "Asssessment Inventory and Monitoring"
     SubSetData$datasetLink             <- "https://gbp-blm-egis.hub.arcgis.com/datasets/BLM-EGIS::blm-natl-aim-lotic-indicators-hub/about"
     SubSetData$bibilographicCitation   <- paste("Bureau of Land Management; 2021; I_Indicators vector digital data; BLM National AIM Lotic Indicators ArcGIS Hub; accessed", Sys.Date())
     SubSetData$metadataID              <- "https://www.arcgis.com/sharing/rest/content/items/97e9d82469194fab88e4193ba591fb72/info/metadata/metadata.xml?format=default&output=html"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/DataIntegrationExample/R/DownloadAndCleanBLMAIMData.R" # ed: update link from specifications to Standards if changing name in future
     SubSetData$locationRemarks         <- "Middle of Reach"
     
     
   } else if (p=="PIBO"){ 
     SubSetData$datasetID               <- "1"
     SubSetData$projectCode             <- "PIBO"
     SubSetData$institutionCode         <- "USFS"
     SubSetData$datasetName             <- "2020_Seasonal_Sum_PIBO"
     SubSetData$projectName             <- "PacFishInFish Biological Opinion Monitoring Program"
     SubSetData$datasetLink             <- "https://www.fs.usda.gov/detail/r4/landmanagement/resourcemanagement/?cid=stelprd3845865"
     SubSetData$bibilographicCitation   <- "U.S. Forest Service PacFishInFish Biological Monitoring Program; 2021; Habitat data and Metadata_Hab Microsoft Excel spreadsheet data request"
     SubSetData$metadataID              <- "Available by data request"
     SubSetData$preProcessingCode       <- ""
     SubSetData$locationRemarks         <- "Bottom of Reach"

     
   } else if (p== "AREMP") {
   
     SubSetData$datasetID               <- "3"
     SubSetData$projectCode             <- "AREMP"
     SubSetData$institutionCode         <- "USFS"
     SubSetData$datasetName             <- "NwfpWatershedConditions20yrReport" 
     SubSetData$projectName             <- "Aquatic and Riparian Effectiveness Monitoring Plan"
     SubSetData$datasetLink             <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.zip"
     SubSetData$bibilographicCitation   <- paste("Northwest Forest Plan the First 20 Years 1994–2013 Watershed Condition Status and Trend; 2015; ArcGIS geodatabase accessed", Sys.Date())
     SubSetData$metadataID              <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.htm"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/blob/master/DataIntegrationExample/R/DownloadAndCleanUSFSAREMPData.R"  #  ed: update link from specifications to Standards if changing
     SubSetData$locationRemarks         <- "Bottom of Reach"
    
   
     
     #AREMP all data collection locations are Random 
     SubSetData$siteSelectionType     <- "Random"
  
   }
   
   
#### Add the SubSetData representing the specific program data into the flat_data, combining information from the sources ####
  flat_data <- bind_rows(flat_data, SubSetData)
  
 
  rm(SubSetData)

}

#### Clean up the data ####

# Remove any locations with blank latitude and longitude 
all_data2 = flat_data %>%
  filter(!is.na(longitude) & !is.na(latitude)) 

# Check if there are blanks in the year
blank_year                  <- is.na(all_data2$year)
all_data2$year[blank_year]  <- substr(all_data2$eventDate[blank_year],1, 4) 
all_data2$year              <- as.integer(all_data2$year)

# Replace N/A and blanks from dataset with the no value 
  # ed: here I think it is important to differentiate between String data blanks being converted to NA
  # and numeric data being converted to a numeric NA value (e.g., -9999 or another outrageous value) to maintain data types within a column 
  # AND IF we use a numeric NA value, then we need to be sure the code does not remove it later (there is a line below removing all -99.9999 values)
#all_data2[all_data2$waterBody == "N/A"] <- NA
all_data2[all_data2 == ''] <- NA 

# Remove any rows (events) that have no metric data in the integrated dataset 
measurement_names <- metricControlledVocabulary

only_metrics <- all_data2 %>% 
  dplyr::select(all_of(measurement_names))

ind <- rowSums(is.na(only_metrics)) != (ncol(only_metrics)) 

all_data2 <-all_data2[ind,]

#EH - replacing commas in waterBody column with | - commas were causing an extra column to show up when unique_locations was exported to csv
all_data2$waterBody = str_replace_all(all_data2$waterBody, ",", "|")

#UID location integrated dataset, need to create a temp locationID concatenating program and LocationID in case across programs location ID is repeated
# ed: this is a little confusing, can you rephrase this comment slightly?
all_data2 <- all_data2 %>% 
            mutate(temp_locaitonID = paste0(verbatimLocationID,projectCode)) %>% 
            transform(locationID=as.numeric((factor(temp_locaitonID)))) %>% 
            dplyr::select(-temp_locaitonID)

all_data2$verbatimLocationID
str(all_data2)
all_data2[,c(11,12)]
all_data2$temp_locationID #####maybe remove this an the above 3 lines!!!!!!!!!*****************

#Remove rows that are exact duplicate from the combined dataset 
all_data2 <-  all_data2 %>% 
              distinct()

#Remove starting and trailing white space in strings 
all_data2 <- all_data2 %>%
  mutate_if(is.character, str_trim)

# Create a list of unique locations for the combined dataset 
u_locations <- dplyr::select(all_data2, (c("locationID", "latitude", "longitude",
                                           "waterBody", "projectCode")))
unique_locations = u_locations %>% distinct(locationID, projectCode,.keep_all = TRUE) #EH edited this line on 30Jan2023 - set distinct to only be for location ID and project code, but keep all columns. This fixed the duplicate locationID issue here.. but not for the location table

unique_path <- paste0(getwd(), "/DataIntegrationExample/data/UniqueLocationsforStreamHabitatMetric.csv")
#file.remove(unique_path)
write.csv(unique_locations, file=unique_path, row.names=FALSE)

#EH added this code to replace the sampling protocol in alldata2 
all_data2 <- all_data2 %>%
  mutate(samplingProtocol = replace(samplingProtocol, projectCode=='NRSA', 'https://www.monitoringresources.org/Document/Protocol/Details/3339')) %>%
  mutate(samplingProtocol = replace(samplingProtocol, projectCode=='AIM', 'AIM https://www.monitoringresources.org/Document/Protocol/Details/3555')) %>%
  mutate(samplingProtocol = replace(samplingProtocol, projectCode=='PIBO', 'https://www.monitoringresources.org/Document/Protocol/Details/3552')) %>%
  mutate(samplingProtocol = replace(samplingProtocol, projectCode=='AREMP', 'https://www.monitoringresources.org/Document/Protocol/Details/3542'))

#Converting PIBO D50 data from m to mm - EH added
all_data2 <- all_data2 %>% 
  mutate(D50 = as.integer(ifelse(projectCode =="PIBO", D50*1000, D50)))

#Converting NRSA MeanThalwegDepth data from cm to m - EH added
all_data2 <- all_data2 %>%
  mutate(MeanThalwegDepth = ifelse(projectCode == "NRSA", MeanThalwegDepth/100, MeanThalwegDepth))

#### Subset the data set to match the data exchange standards documented on https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications ##### # ed: update URL later if this changes. ####
#Record level table 
#Subset the sampling features/locations 
RecordLevel<- MetadataDict %>% 
  filter(str_detect(entity, "Record")) %>% 
  drop_na(attribute)%>%  
  dplyr::select(attribute)%>% 
  unlist(use.names = F) %>% 
  unique() %>% trimws()

RecordLevel <- RecordLevel[RecordLevel!= ""]

RecordLevel_table <- all_data2 %>% 
  dplyr::select(one_of(c("datasetID",RecordLevel))) %>% 
  distinct()

#location table 

location <- MetadataDict %>%  
    filter(str_detect(entity, "Location"))%>% 
    drop_na(attribute)%>%  
    dplyr::select(attribute)%>% 
    unlist(use.names = F) %>% 
    unique() %>% trimws()

location <- location[location!= ""]

#Subset the sampling features/locations 
#EH updated the below code - distinct() changed to what it is now. It now specifies that we only want the locationID and datasetID to be distinct and to keep all table attributes
location_table <- all_data2 %>% 
  dplyr::select(one_of(c("datasetID", location))) %>% 
  distinct(datasetID, locationID, .keep_all = TRUE) %>% 
  relocate(c("datasetID","locationID", "verbatimLocationID","latitude", "longitude"))  

#Build the event table
event<- MetadataDict %>% 
  filter(str_detect(entity, "Event")) %>% 
  drop_na(attribute)%>%  
  dplyr::select(attribute)%>% 
  unlist(use.names = F) %>% 
  unique() %>% trimws()

event <- event[event != ""]

event_table <- all_data2 %>% 
  dplyr::select(one_of(c("locationID",  event)))



# Create the measurement or fact table 

#measurement_names <- metricControlledVocabulary

#measurement <- all_data2 %>% 
 # dplyr::select(eventID) 

measurement <- all_data2 %>% 
            dplyr::select(measurement_names, eventID)

Results <- measurement %>% 
  pivot_longer(cols = names(dplyr::select(measurement, -eventID)), 
               names_to ="measurementType", values_to="measurementValue") %>% 
  drop_na(measurementValue) %>% 
  add_column(measurementTypeID = as.integer(NA)) %>% 
  rowid_to_column("measurementID")  


#Add the measurementID to the measurement or fact table
metricControlledVocabularyTable <- read.csv("DataExchangeStandardTables/metricControlledVocabulary.csv")
cv_index <- metricControlledVocabularyTable %>% 
  dplyr::select(contains("measurementType")) 

# add the MeasurementTypeID to the MeasurementOrFact table 
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

#### Save files ####
#Write the analysis ready stream monitoring dataset data (all_data2) to a .csv 
file_path <- paste0(getwd(), "/DataIntegrationExample/data/AnalysisStreamHabitatMonitoringMetricDataset.csv")
#file.remove(file_path)
write.csv(all_data2, file=file_path, row.names=FALSE)


#Save the relational database files and metadata
list_of_datasets <- list("RecordLevel" = RecordLevel_table, "Location"= location_table, "Event"= event_table,
                         "MeasurementOrFact"= Results)

file_name = paste0(getwd(), "/DataIntegrationExample/data/RelationalDataTablesStreamHabitatMetrics.xlsx") 
#file.remove(file_name)
openxlsx::write.xlsx(list_of_datasets, file = file_name) 

# Save .csv files for each of the tables in the relational database 
# Something in this code is change verbatim field name # ed: the verbatimD instead of verbatimEventID being output?
for(i in 1:length(names(list_of_datasets))){ 
  filename = paste0(getwd(),"/DataIntegrationExample/Data/csv/", names(list_of_datasets[i]), ".csv")
  table_name <- names(list_of_datasets[i])
  table <- data.frame(list_of_datasets[i])
  names(table) <- gsub(paste0(table_name,"."), "", names(table))
  write.csv(table, filename, row.names= FALSE, quote = FALSE)
} 


return(list_of_datasets) 

}

