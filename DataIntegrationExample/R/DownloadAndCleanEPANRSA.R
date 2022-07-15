#####Scraping EPA National Aquatic Resources data 

#This script is to pull data from the EPA data web page. Then we create a tidy data set from the 2004, 2008/09, 
#2013/14 NRSA stream data sets with the Macrioneverterbreate, physical habitat and water chemistry metric and 
#indicator data. The data set is then save to the GitHub page and the ScienceBase Item. 

download_EPA_NRSA <- function() {
  library(tidyverse)
  library(rvest)
  library(stringr)
  library(httr)
  library(sbtools)
  library(plyr)
  library(hutils)
  library(dplyr)
  
  test_ID = "10001"
  
  #Projection for the combined dataset 
  CRS<-  "+proj=longlat +datum=WGS84 +no_defs"
  
  ######Download all the data links from the EPA web site#####
  content <- read_html("https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys")
  
  tables <- content %>% 
    html_table(fill = TRUE) 
  
  EPA_table <- tables[[1]]
  
#### Scrape data links from EPA webpage ####
  web <- content %>%
    html_nodes("table tr")%>%
    html_nodes(xpath="//td[3]") %>%  ## xpath
    html_nodes("a") %>%
    html_attr("href")
  
  EPA_table$web1 <- web  ## add files column
  
  ## metadata links accordingly
  web2 <- content %>%
    html_nodes("table tr") %>%
    html_nodes(xpath="//td[4]") %>%  ## xpath
    html_nodes("a") %>%
    html_attr("href")
  
  
  EPA_table[EPA_table$Metadata %in% "", "Metadata"] <- NA
  EPA_table[!is.na(EPA_table$Metadata), "web2"] <- web2
  
#####Sort out the NARS data from the full list of data sets on the EPA website#####
  NARS <- EPA_table %>% 
    filter(str_detect(Survey, "Streams"))
  

##### Build a data fame of the data sets used to build the data set ####
  location_data <- NARS %>% 
    filter(str_detect(Indicator, "Site Information"))%>% 
    filter(!str_detect(web1,"ext")) %>% 
    filter(!str_detect(web1, "verification"))

  water_chem <-NARS %>% 
    filter(str_detect(Indicator, "Water Chemistry"))%>%  
    filter(str_detect(Data, paste(c("Indicator", "CHLA", "WSA"), collapse = "|"))) %>% 
    filter(!str_detect(Data, "(Field)"))
  
  phys_hab <-NARS %>% 
    filter(str_detect(Indicator, "Physical Habitat")) %>%  
    filter(str_detect(web1, paste(c("phabmet", "physical_habitat","phabmed" , "nrsa1314_phabmed"), collapse = "|"))) 
  
  phys_hab2004 <- phys_hab %>% 
    filter(str_detect(Survey, "2004")) 
  
  dataset_table<- bind_rows(phys_hab, phys_hab2004) %>% 
    bind_rows(water_chem) %>% 
    bind_rows(location_data) 
  

######Join all the 2004 datsets #####
  data_2004 <- dataset_table %>% 
        dplyr::filter(str_detect(Survey,"2004")) %>% 
        unique()
  
#Separate out the two habitat datasets labeled 2004 because processing requires a steps to combined the two 2004 datasets 
  phys_hab2004 <- data_2004 %>% 
    filter(str_detect(Indicator, "Physical Habitat")) 
  
  # Combing the 2004 physical habitat datasets into on dataset, convert data types
  for(ph2004 in 1:length(phys_hab2004$web1)) {
    link = phys_hab2004$web1[ph2004]
    url_link <- paste0("https://www.epa.gov", link)
    temp_file <- tempfile(fileext = ".csv")
    download.file(url_link, temp_file)
    
    if (ph2004 ==1 ) { 
      data_set2004<- read.csv(temp_file)
      
    } else { 
      data_set20042 <- read.csv(temp_file)
      data_phys_hab  <- full_join(data_set2004, data_set20042)
      #data_phys_hab <-data_phys_hab %>% 
      #mutate(UID = paste0(SITE_ID, "-", VISIT_NO))
      
      # convert visit number to string to accommodate "R" in 2021 data release 
      data_phys_hab[str_detect(names(data_phys_hab), "VISIT_NO")] <- data_phys_hab %>% 
        dplyr::select(contains("VISIT_NO")) %>% 
        mutate_all(as.character)
      
      data_phys_hab[str_detect(names(data_phys_hab), "LDCBF_G08")] <- data_phys_hab %>% 
        dplyr::select(contains("LDCBF_G08")) %>% 
        mutate_all(as.character)
      
      data_phys_hab[str_detect(names(data_phys_hab), "L_RRPW3")] <- data_phys_hab %>% 
        dplyr::select(contains("L_RRPW3")) %>% 
        mutate_all(as.character)
      
    }
    
  } 

data_phys_hab2004 <- data_phys_hab
rm(data_phys_hab)
  
# 2004 Location Data download and reformat variables to match data types of other datasets 

link = dataset_table %>% 
      dplyr::filter(Survey == "Streams 2004") %>% 
      filter(str_detect(Indicator, "Site")) %>% 
      dplyr:: select(web1)

url_link <- paste0("https://www.epa.gov", link)
temp_file <- tempfile(fileext = ".csv")
download.file(url_link, temp_file)
locations_2004 <- read.csv(temp_file)
rm(temp_file)

locations_2004$DATE_COL <- as.Date(locations_2004$DATE_COL, format="%m/%d/%Y")

# 2004 data location column header don't match the other two data sets, need to check with the EPA to see if this data is comparable 
locations_2004 <- locations_2004 %>% dplyr::rename(LON_DD83 = LON_DD, 
                                                 LAT_DD83= LAT_DD) 

# Stream 2004 Site Information Data does not contain the field PROTOCOL, based on metadata and information from the programs 
# the field TNT = Site is a target stream (perennial wadeable) or a non-target site. The rows filled in with TRUE are 
# WADABLE streams. We create a new field in the 2004 Location data and update all TNT = TRUE , PROTOCOL = WADABLE 
TNT_TRUE <- locations_2004$TNT == "TRUE"
locations_2004$PROTOCOL[TNT_TRUE] <- "WADEABLE"

#Convert HUC  data to characters not integers 
locations_2004[str_detect(names(locations_2004), "HUC")] <- locations_2004 %>% 
  dplyr::select(contains("HUC")) %>% 
  mutate_all(as.character) 

locations_2004[str_detect(names(locations_2004), "VISIT_NO")] <- locations_2004 %>% 
  dplyr::select(contains("VISIT_NO")) %>% 
  mutate_all(as.character)

all_data_2004 <- left_join(locations_2004, data_phys_hab2004)

#2004 Waterchem Data 
chem_URL <- data_2004 %>% 
                filter(str_detect(Indicator, "Chemistry")) %>% 
                dplyr::select(contains("web1"))

# Download the water chem data, update the 
url_link <- paste0("https://www.epa.gov", chem_URL[1])
temp_file <- tempfile(fileext = ".csv")
download.file(url_link, temp_file)

water_chem_2004 <- read.csv(temp_file)

water_chem_2004[str_detect(names(water_chem_2004), "VISIT_NO")] <- water_chem_2004 %>% 
  dplyr::select(contains("VISIT_NO")) %>% 
  mutate_all(as.character)

water_chem_2004$DATE_COL <- as.Date(water_chem_2004$DATE_COL, format="%m/%d/%Y")


all_data_2004 <- left_join(all_data_2004, water_chem_2004, by= c("SITE_ID", "YEAR", "VISIT_NO", "DATE_COL"))

####Add the dataset names 

all_data_2004$datasetName <- paste(data_2004$Data, collapse=",")
all_data_2004$UID <- paste0(all_data_2004$SITE_ID,"-", all_data_2004$VISIT_NO, "-", all_data_2004$DATE_COL) 

#### build all the datasets not from 2004)####

##### List of dataset excluding the 2004 data #####
dataset_table <- dataset_table %>% 
  filter(!str_detect(Survey, "2004"))

##### Location data (not including the 2004 data) ####
location_data <- dataset_table %>% 
    filter(str_detect(Indicator, "Site Information"))

  
  for(i in 1:length(location_data$web1)) { 
    
      print(location_data$Survey[i])
      url_link              <- paste0("https://www.epa.gov", location_data$web1[i])
      temp_file             <- tempfile(fileext = ".csv")
      download.file(url_link, temp_file)
      data2                 <- read.csv(temp_file)
      data2$datasetNameLocation     <- location_data$Data[i]
      
      #convert the name SITE_CLASS to SITETYPE 
     if(any(names(data2) =="SITE_CLASS")) { 
        data2 <- data2 %>% dplyr::rename(SITETYPE = SITE_CLASS)
        print(names(data2))
     } 
    
      #convert the name GNIS_NAME to LOC_NAME 
      if(any(names(data2) =="LOC_NAME")) { 
        data2 <- data2 %>% dplyr::rename(GNIS_NAME=LOC_NAME)
        print(names(data2))
      }   
      
      
      #Convert the data from a string to a date 
      if (any(names(data2)=="DATE_COL")) { 
        if (grepl("-", data2$DATE_COL[1],  fixed=TRUE)) { 
          data2$DATE_COL <- as.Date(data2$DATE_COL, format= "%d-%B-%y")
        } else if (grepl("/", data2$DATE_COL[1],  fixed=TRUE)) { 
          data2$DATE_COL <- as.Date(data2$DATE_COL, format="%m/%d/%Y") 
        }
      }
      
      #convert data type to characters 
      data2[str_detect(names(data2), "HUC")] <- data2 %>% 
        dplyr::select(contains("HUC")) %>% 
        mutate_all(as.character)
      
      data2[str_detect(names(data2), "REACHCODE")] <- data2 %>% 
        dplyr::select(contains("REACHCODE")) %>% 
        mutate_all(as.character)
      
      data2[str_detect(names(data2), "STATECTY")] <- data2 %>% 
        dplyr::select(contains("STATECTY")) %>% 
        mutate_all(as.character)
      
      data2[str_detect(names(data2), "VISIT_NO")] <- data2 %>% 
        dplyr::select(contains("VISIT_NO")) %>% 
        mutate_all(as.character)
      
      if(any(str_detect(names(data2),"EPA_REG"))==T) {
        data2$EPA_REG <- as.character(data2$EPA_REG)
      } 
      
    # Bind years of location together into one dataset 
  
    if(i == 1){
        all_locations <- data2
      } else {
        all_locations     <- bind_rows(list(all_locations, data2))
       } 
      
      unlink(temp_file)
  } 
  

#####Build a water_chem dataset (not the 2004 data) ####
  water_chem <-dataset_table %>% 
    filter(str_detect(Indicator, "Water Chemistry")) 
  
#Build a table of all water chemistry data 
  for(wc in 1:length(water_chem$web1)){ 
    link                              <-  water_chem$web1[wc]
    url_link                          <- paste0("https://www.epa.gov", link)
    temp_file                         <- tempfile(fileext = ".csv")
    download.file(url_link, temp_file)
    data_set                          <- read.csv(temp_file)
    data_set$datasetNameWaterChem     <- water_chem$Data[wc]
    
    data_set[str_detect(names(data_set), "VISIT_NO")] <- data_set %>% 
      dplyr::select(contains("VISIT_NO")) %>% 
      mutate_all(as.character)
    
    data_set[str_detect(names(data_set), "LDCBF_G08")] <- data_set %>% 
      dplyr::select(contains("LDCBF_G08")) %>% 
      mutate_all(as.double)
    
    data_set[str_detect(names(data_set), "L_RRPW3")] <- data_set %>% 
      dplyr::select(contains("L_RRPW3")) %>% 
      mutate_all(as.double)
    
    if (wc==1) {
      name <- "data_water_chem"
      assign(name, data_set)
      data_water_chem$DATE_COL <- as.Date(data_water_chem$DATE_COL, format= "%d-%B-%y")
    } else {
      data_set$DATE_COL <- as.Date.character(data_set$DATE_COL, format="%m/%d/%Y")
      data_water_chem <- bind_rows(data_water_chem, data_set)
    }
    
    unlink(temp_file)
  } 
  
  
  if (any(is.na(data_water_chem$YEAR))==T) {
    data_water_chem <- mutate(data_water_chem, YEAR = as.integer(format(data_water_chem$DATE_COL,format="%Y")))
  }
  
  #print(data_water_chem %>% 
   #       filter(UID == test_ID) %>% 
    #      dplyr::select(c("SITE_ID",  "YEAR",  "VISIT_NO", "UID"))) 
  
  
#####Build a physical habitat dataset (not the 2004 data) #####
  phys_hab <-dataset_table %>% 
    filter(str_detect(Indicator, "Physical Habitat")) 
  
  for(ph in 1:length(phys_hab$web1)){ 
    
    link                            <- phys_hab$web1[ph]
    url_link                        <- paste0("https://www.epa.gov", link)
    temp_file                       <- tempfile(fileext = ".csv")
    download.file(url_link, temp_file)
    data_set                        <- read.csv(temp_file)
    data_set$datasetNamePhysHab     <- phys_hab$Data[ph]
    
    ##Convert variablestypes to match data types across all datasets ####
    
    data_set[str_detect(names(data_set), "VISIT_NO")] <- data_set %>% 
     dplyr::select(contains("VISIT_NO")) %>% 
    mutate_all(as.character)
    
    data_set[str_detect(names(data_set), "LDCBF_G08")] <- data_set %>% 
      dplyr::select(contains("LDCBF_G08")) %>% 
      mutate_all(as.character)
    
    data_set[str_detect(names(data_set), "L_RRPW3")] <- data_set %>% 
      dplyr::select(contains("L_RRPW3")) %>% 
      mutate_all(as.character)


#   Convert the date from a string to a date data type based
    if (any(names(data_set)=="DATE_COL")) { 
     if (grepl("-", data_set$DATE_COL[1],  fixed=TRUE)) { 
        data_set$DATE_COL <- as.Date(data_set$DATE_COL, format= "%d-%B-%y")
      } else if (grepl("/", data_set$DATE_COL[1],  fixed=TRUE)) { 
        data_set$DATE_COL <- as.Date(data_set$DATE_COL, format="%m/%d/%Y") 
      }
    }
    
    if (ph ==1) {
      data_phys_hab <- data_set
    } else {
    data_phys_hab <- bind_rows(data_phys_hab, data_set)
      } 
    unlink(temp_file)
  }
  

##### Join the locations, water chem and physical habitat data (not 2004)  #####
  dim(all_locations)
  dim(data_water_chem)
  dim(data_phys_hab)
  
data_locations2008 <- merge(all_locations, data_water_chem, by ="UID", all = TRUE)

#####fill blanks and delete duplicate in matching columns 
dup_col <- data_locations2008 %>%
    dplyr::select(contains(c(".x", ".y")))
  
names <- unique(gsub(".x|.y", "", names(dup_col)))
 
for (field in 1:length(names)) {
   # print(names[field])
  
  test<- data_locations2008 %>%  
    dplyr::select(contains(names[field]))  
    
  index.x <- is.na(test[1])
    #print(test[index.x,] )
    test[index.x,1] = test[index.x, 2]
    #print(test[index.x,])
    
    index.y <- is.na(test[2])
  #  print(test[index.y,])
    test[index.y,2] = test[index.y, 1]
  #  print(test[index.y,])
    
    data_locations2008 <- data_locations2008 %>%  
      dplyr::select(-contains(names[field])) %>% 
      bind_cols(test)
  
  }   
 
data_locations2008 <- data_locations2008 %>% 
 dplyr::select(-contains(".y"))

names(data_locations2008) <- str_remove(names(data_locations2008), ".x")
##### merge location/water chem with physical habitat data 
  data_locations2008 <- merge(data_locations2008, data_phys_hab, by = "UID", all= TRUE)
  
#### concatenation the dataset names 
#datasetNamesCol<- data_locations2008 %>%  
#                  dplyr::select(contains("datasetName")) 

#data_locations2008$datasetName <- unite(datasetNamesCol, datasetName, sep=",")

#data_locations2008 <- data_locations2008 %>%  
 #   dplyr::select(-contains("datasetName."))

  ## test 
 t <- (data_locations2008 <- data_locations2008 %>%  
    relocate(contains(c("SITE_ID","UID", "PROTOCOL",  "LAT", "LON", "VISIT_NO", "DATE_COL")))) 
  
#####Duplicate fields across the datasets
  dup_col <- data_locations2008 %>%
    dplyr::select(contains(c(".x", ".y")))
  names <- unique(gsub(".x|.y", "", names(dup_col)))
  
  for (field in 1:length(names)) {
   # print(names[field])
    
    test<- data_locations2008 %>%  
      dplyr::select(contains(names[field]))  
    
    index.x <- is.na(test[1])
    #print(test[index.x,] )
    test[index.x,1] = test[index.x, 2]
#    print(test[index.x,])
    
    index.y <- is.na(test[2])
#    print(test[index.y,])
    test[index.y,2] = test[index.y, 1]
 #   print(test[index.y,])
    
    data_locations2008 <- data_locations2008 %>%  
      dplyr::select(-contains(names[field])) %>% 
      bind_cols(test)
    
  }   
  
  data_locations2008 <- data_locations2008 %>% 
    dplyr::select(-contains(".y"))
  
  names(data_locations2008) <- str_remove(names(data_locations2008), ".x")
  
  #view(data_locations2008 <- data_locations2008 %>%  
  #       relocate(contains(c("SITE_ID","UID", "PROTOCOL",  "LAT", "LON", "VISIT_NO", "DATE_COL")))) 
  
    
#####Join the >2008 datasets will the 2004 dataset  
  all_data_2004$UID <- as.character(all_data_2004$UID)
  data_locations2008$UID <- as.character(data_locations2008$UID)
  
  ##### Stoped here data_locations2008$dtadatasetName is a 
  data_locations <- bind_rows(data_locations2008, all_data_2004)

data_locations <- data_locations %>%  
  relocate(contains(c("SITE_ID","UID", "LAT", "LON", "VISIT_NO", "DATE_COL")))

#### Join the datasetsNames into one column 

subSetDatasetNames <- data_locations %>%  
                        dplyr::select(contains("dataset"))

conDatasetNames <- unite(subSetDatasetNames, datasetName, sep=",", na.rm = TRUE)

data_locations$datasetName <- conDatasetNames[['datasetName']]


#print(data_locations %>% 
#        filter(UID == test_ID) %>% 
#        select(c("SITE_ID",  "YEAR",  "VISIT_NO", "UID")))

#####Fill in blank years & update the positive longitudes to postie based on the assumption all sampling is collected west of the prime meridian ####
 blank_year             <- is.na(data_locations$YEAR)
  data_locations$YEAR[blank_year] <- format(data_locations$DATE_COL[blank_year],format="%Y")
  data_locations$YEAR<- as.integer(data_locations$YEAR)

#Check the longitude to make sure all are negative because this data set is all collected west of the prime meridian 
 if(any(data_locations$XLON_DD>0, na.rm=TRUE)== T) {
    postive_index <- data_locations$XLON_DD >0 & !is.na(data_locations$XLON_DD)
   data_locations$XLON_DD[postive_index] <- data_locations$XLON_DD[postive_index]*(-1)
 }
  
#####Reproject the data based on the standard. NARS data is published in Albers#####

#if(compareCRS(CRS, st_crs(locations))==TRUE){
   # print("AREMP coordinate reference system matches the coordinate system of the data exchange standards for the intergrated dataset.")
#  }else {
 #   print("AREMP coordinate reference system does not match the coordinate system of the data exchange standards for the intergrated dataset.")
    #Transform to a standard system 
#    a_WGS84 <- st_transform(AREMP, crs="+proj=longlat +datum=WGS84 +no_defs")
      #pull coordinates out of shapefile 
 #   lat_long <- do.call(rbind, st_geometry(a_WGS84)) %>% 
  #    as_tibble(.name_repair = "unique") %>% setNames(c("longitude","lattitude", "c3", "c4"))
    
    # create a table of the AREMP data with lat, and long 
   # table       <- (st_geometry(AREMP)<- NULL)
  #  AREMP_csv   <- bind_cols(AREMP, lat_long)
   # print("Transformed to WGS 84 based on the data standard")
  #}
  
  
#####Delete the old EPA data file & save the new file ####


  files <- list.files(paste0(getwd(), "/DataIntegrationExample/data/DataSources"))
  files_remove <- paste0(getwd(), "/DataIntegrationExample/data/DataSources/", files[str_detect(files, "NRSA")])
  file.remove(files_remove)
  
  write.csv(data_locations, paste0(getwd(), "/DataIntegrationExample/data/DataSources/NRSAProcessedDataset.csv"), row.names=FALSE)

# Save a data.table of datafiles and metadata used to build this dataset
  write.csv(dataset_table, paste0(getwd(), "/DataIntegrationExample/data/DataSources/NRSATableOfDataset.csv"), row.names = FALSE)
 
  return(data_locations)
}
