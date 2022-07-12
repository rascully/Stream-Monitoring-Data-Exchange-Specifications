

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

# Run function to build DES and controlled vocabulary tables from MetadataDict to make sure everything is up to date 
  source(paste0(getwd(), "/R/Create_Data_tables_MetadataDict.R"))
  build_vocab_tables()
  
# Load functions 
  source(paste0(getwd(), "/Data Intergration Example/R/data_mapped_field.R")) 
  
MetadataDict <- read.csv("Data/MetadataDictionary.csv")
EmunDict    <- read.csv("Data/EmunDictionary.csv")


#List of programs to integrated data from.
program <- c("NRSA","AIM", 'PIBO', "AREMP")

#Name of the exchange tables 
exchange_tables <- c("RecrordLevel", "Location", "Event", "MeasurementOrFact")

#Projection for the combined dataset 
CRS<-  "+proj=longlat +datum=WGS84 +no_defs"


# create a list of fields from the data exchange specifications 
des_names <-MetadataDict %>% 
        filter(str_detect(entity, c("Record|Location|Event")))%>% 
        drop_na(attribute)%>%  
        dplyr::select(attribute)%>% 
        unlist(use.names = F) %>% 
        unique()
       
#remove any blanks 
des_names <- des_names[des_names!= '']


metricControlledVocabularyToSave <- read.csv("Data Exchange Standard Tables/metricControlledVocabulary.csv")

metricControlledVocabulary <- metricControlledVocabularyToSave %>% 
                              dplyr::select("measurementType") %>% 
                              unlist(use.names=F) %>%  
                              unique()

#create a dataframe 
flat_data_names     <- c(des_names, metricControlledVocabulary) %>%  trimws()
flat_data           <- data.frame(matrix(ncol=length(flat_data_names), nrow=1))
colnames(flat_data)  <- flat_data_names

# Read the the data mapping 
DataMapping <- read.csv("Data Exchange Standard Tables/DataMapping.csv")
DataMapping <- DataMapping %>% 
  mutate(across(where(is.character), str_trim))


# Loop to download, and pull information from the original datasets into one file. Add record level information. 
for(p in program) {
 
  if (p=="NRSA"){

  source(paste0(getwd(), "/Data Intergration Example/R/Download and clean EPA NRSA.R"))
  data <- download_EPA_NRSA()
  
  # we filter for only the wadeable streams
    field <- dataMapVariable("samplingProtocol", p)
    data <- data %>% 
      filter(!!as.name(field) == "WADEABLE")
    
# from the datamapping find the field name that contains the percent dry program
  field <- dataMapVariable("fieldNotes", p)

  #Change variable percent dry percent dry to a category
    dry <- data[[field]]
    dry <- as.character(dry) 
    dry[(dry == 0) & !is.na(dry)] <- "Flow (Whole Reach)"
    dry[(dry == 100)& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Flow") & !is.na(dry)] <- "Other"
    data[[field]] <- dry
    
    #Update SiteSelectionType to Random or Targeted 
    # from the datamapping find the field name that contains the siteSelectionType for AIM 
    field <- dataMapVariable("siteSelectionType", p)
    siteSelectionType <- data[[field]]
    siteSelectionType <- str_replace_all(siteSelectionType, c("EASTPROB"= "Random", "WESTPROB"= "Random", "PROB" = "Random"))
    siteSelectionType <- str_replace_all(siteSelectionType, c("EASTHAND"= "Targeted", "WESTHAND"= "Targeted", 
                                                                  "HAND" = "Targeted"))
    data[[field]]     <- siteSelectionType

    
  } else if (p=="AIM") { 
    
    print("Processing BLM AIM data")
    source(paste0(getwd(), "/Data Intergration Example/R/Download and clean BLM AIM Data.R"))
    data <- download_AIM()
    
    ##### Format data to Data Exchange Standard ####
    #Filter out the PRTCOl = BOATABLE, we agree to only share wadable data 
    field <- dataMapVariable("samplingProtocol", p)
    
    data <- data %>% 
      filter(!!as.name(field) == "Wadeable")
    
  # from the datamapping find the field name that contains the percent dry 
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
    
    
    #Update SiteSelectionType to Random or Targeted 
    # from the datamapping find the field name that contains the siteSelectionType for AIM 
    field               <- dataMapVariable("siteSelectionType", p)
    siteSelectionType   <- data[[field]]
    siteSelectionType   <- str_replace_all(siteSelectionType, c("RandomGRTS"= "Random", 
                                                                "RandomSystematic"= "Random", 
                                                                "SystematicRandom"= "Random"))
    data[[field]]       <- siteSelectionType
  
  } else if (p=="PIBO"){ 
    
    print("Processing USFS PIBO data")  
    data <- as_tibble(read_xlsx("Data Intergration Example/Data/DataSources/2020_Seasonal_Sum_PIBO.xlsx", 2))
    
    #based on Project feedback when data was requested the coordinates system is WGS 84
    PIBO_coordinate <-  "+proj=longlat +datum=WGS84 +no_defs" 
    
    if(compareCRS(CRS, PIBO_coordinate)==TRUE){
      print(paste( p, "coordinate reference system matches the coordinate system of the data exchange standards for the integrated dataset."))
    } else{ 
      print(paste(p, "coordinate reference system does not match the coordinate system of the data exchange standards for the integrated dataset.")) 
      #Write code to reproject if needed 
    }
    
    # Remove PIBO type Praire sites, based on PIBO feedback 
   data<-  data %>% 
      filter(Type !="P")
    
 #from the datamapping find the field name that contains the percent dry for AIM
    field <- dataMapVariable("fieldNotes", p)
      
  #Update Stream Flow values to the data exchange standard 
    dry <- data[[field]]
    dry[str_detect(dry, "Other") & !is.na(dry)] <- "Other"
    dry[str_detect(dry, "No")& !is.na(dry)] <- "No Flow (Dry)"
    dry[!str_detect(dry, "Other") & !is.na(dry)& !str_detect(dry, "No Flow")] <- "Flow (Whole Reach)"
    data[[field]] <- dry
    

  # PIBO to classify Random and targeted we need to use 2 fields 
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
   #I don't know about PILOT, FWNF? 
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "PILOT") ] <- "DO not know"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "FWNF") ] <- "DO not know"
   unique(siteSelectionType)
   
   #Project types CRB & MRB have both Random and Targeted sites, for siteSelectionType use the PIBO Type  
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "I") ] <- "Random"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "S") ] <- "Random"
   unique(siteSelectionType)
   siteSelectionType$ProjectType[str_detect(siteSelectionType$ProjectType, "K") ] <- "Targeted"
   data$Project <- siteSelectionType$ProjectType
  

  } else if (p== "AREMP") {
    print("Processing USFS AREMP data")
    source(paste0(getwd(), "/Data Intergration Example/R/Download and clean AREMP Data.R"))
    data <- download_AREMP()
    
    # Create a field Protocol field with WADEABLE based on project feedback that all data is collected in wadeable streamk 
    data$survey_type ="WADEABLE"

  }
  

##### Rename the SubSetData from the original fields to the terms (field names) from the data exchange standard #####
  term <- DataMapping %>% 
    filter(projectCode == p) %>% 
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
  
##### Add fields to the SubSetData that define the specific dataset being combined. 
    
if (p=="NRSA"){

     SubSetData$datasetID               <- ''  
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
     
     SubSetData$datasetName           <- "I_Indicators"
     SubSetData$datasetID               <- ""
     SubSetData$bibilographicCitation   <- paste("Bureau of Land Management AIM Aquatic Data (AquADat) Map Server, https://landscape.blm.gov/geoportal/rest/document?id=%7B44F011CC-6E1F-4FDA-AFDF-B29BF1732ACF%7D, accessed", Sys.Date()) 
     SubSetData$datasetOrginization     <- "Bureau of Land Management"
     SubSetData$institutionCode         <- "BLM"
     SubSetData$projectName             <- "Asssessment, Inventory, and Monitoring"
     SubSetData$projectCode             <- "AIM"
     SubSetData$datasetLink             <- "https://gis.blm.gov/arcgis/rest/services/hydrography/BLM_Natl_AIM_AquADat/MapServer"
     SubSetData$metadataID              <- "https://landscape.blm.gov/geoportal/rest/document?id=%7B44F011CC-6E1F-4FDA-AFDF-B29BF1732ACF%7D"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/tree/master/Data%20Intergration%20Example"
     SubSetData$locationRemarks         <- "Middle of Reach"
     
   } else if (p=="PIBO"){ 
     SubSetData$datasetID               <- ""
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
     SubSetData$Type                    <- "WADEABLE"
     
     
   } else if (p== "AREMP") {
   
     SubSetData$datasetID               <- ""
     SubSetData$datasetName             <- "Northwest Forest Plan-the first 20 years (1994 to 2008): watershed condition status and trend" 
     
     SubSetData$bibilographicCitation   <- paste('Miller, Stephanie A.; Gordon, Sean N.; Eldred, Peter; 
                                            Beloin, Ronald M.; Wilcox, Steve; Raggon, Mark;Andersen, 
                                            Heidi; Muldoon, Ariel. 2017. Northwest Forest Plan the first 
                                            20 years (1994 to 2013): watershed condition status and trends. Gen. Tech. Rep. PNW GTR 932.
                                            Portland, OR: U.S. Department of Agriculture, Forest Service, Pacific Northwest Research Station. 74 p., accessed', Sys.Date()) 
 
     SubSetData$datasetOrginization     <- "United States Forest Service"
     SubSetData$institutionCode         <- "USFS"
     SubSetData$projectName             <- "Aquatic and Riparian Effectiveness Monitoring Plan"
     SubSetData$projectCode             <- "AREMP"
     SubSetData$datasetLink             <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.zip"
     SubSetData$metadataID              <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.htm"
     SubSetData$preProcessingCode       <- "https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/tree/master/Data%20Intergration%20Example"  
     SubSetData$locationRemarks         <- "Bottom of Reach"
     
     #AREMP all data collection locations are Random 
     SubSetData$siteSelectionType     <- "Random"
  
   }
   
   
  #####Add the SupSetData representing the specific program data into the flat_data, combinding information from the sources #####
  flat_data <- bind_rows(flat_data, SubSetData)
  
   print(names(flat_data)) 
   print(names(SubSetData)) 
   
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

# Replace N/A and blanks from dataset with the no value 

#all_data2[all_data2 == "N/A"] <- NA
all_data2[all_data2 == ''] <- NA 


##### Generate UIDs for the integrated dataset 
#create a datasetID  
all_data2 <- all_data2 %>% 
  transform(datasetID=as.numeric((factor(datasetName)))) 
  

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

#Remove starting and trailing white space in strings 
all_data2 <- all_data2 %>%
  mutate_if(is.character, str_trim)

# Create a list of unique locations for the combind dataset 
u_locations <- dplyr::select(all_data2, (c("locationID", "latitude", "longitude",
                                           "waterBody", "projectCode")))
unique_locations <- distinct(u_locations)


unique_path <- paste0(getwd(), "/Data Intergration Example/data/Unique Locations for Stream Habitat Metric.csv")
#file.remove(unique_path)
write.csv(unique_locations, file=unique_path, row.names=FALSE)


####Subset the data set to match the data exchange specifications documented on https://github.com/rascully/Stream-Monitoring-Data-Exchange-Specifications#####
#Record level table 
#Subset the sampling features/locations 
RecordLevel<- MetadataDict %>% 
  filter(str_detect(entity, "Record")) %>% 
  drop_na(attribute)%>%  
  dplyr::select(attribute)%>% 
  unlist(use.names = F) %>% 
  unique() %>% trimws()

RecordLevel_table <- all_data2 %>% 
  dplyr::select(one_of(c("datasetID",RecordLevel))) %>% 
  distinct()


location <- MetadataDict %>%  
    filter(str_detect(entity, "Location"))%>% 
    drop_na(attribute)%>%  
    dplyr::select(attribute)%>% 
    unlist(use.names = F) %>% 
    unique() %>% trimws()

#Subset the sampling features/locations 
location_table <- all_data2 %>% 
  dplyr::select(one_of(c("datasetID", location))) %>% 
  distinct() %>% 
  relocate(c("datasetID","locationID", "verbatimLocationID","latitude", "longitude"))  

#Build the event table/action table 
event<- MetadataDict %>% 
  filter(str_detect(entity, "Event")) %>% 
  drop_na(attribute)%>%  
  dplyr::select(attribute)%>% 
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
                         ,"DataMapping"= DataMapping)

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

