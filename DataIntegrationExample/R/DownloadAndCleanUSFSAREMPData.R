#Download the AREMP data from the Geodatabase, create a tidy data file and upload the file to ScienceBase. # ed: are you still uploading to ScienceBase?



download_AREMP<- function(){
   
   
   library(rgdal)
   library(downloader) 
   library(sp)
   library(sf)
   library(tidyverse)
   library(geojsonio)
   library(sjmisc)
   library(raster)
   library(utils)
   library(readxl)

# projection described by the DES for stream habit data 
CRS_DES <-  "+proj=longlat +datum=WGS84 +no_defs" 


# AREMP data page link: https://www.fs.usda.gov/r6/reo/monitoring/watersheds.php

# Old link fileURL <- "https://www.fs.fed.us/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.zip"
fileURL <- 'https://www.fs.usda.gov/r6/reo/monitoring/downloads/watershed/NwfpWatershedCondition20yrReport.gdb.zip'



#Download the file to the Data file in the local repository 
df <- paste0(getwd(),"/DataIntegrationExample/data/DataSources/NwfpWatershedCondition20yrReport.gdb.zip")  

download(fileURL, destfile=df)

#Unzip the file into the Data file in the local repository
unzip(paste0(getwd(),"/DataIntegrationExample/data/DataSources/NwfpWatershedCondition20yrReport.gdb.zip") , exdir= paste0(getwd(), "/DataIntegrationExample/Data/DataSources")) 

#Define the file path to the geodata base, if AREMP changes their file structure this will need to be updated # ed: spelling
path <- '/DataIntegrationExample/Data/NwfpWatershedCondition20yrReport.gdb'
fgdb <- paste0(getwd(), path)

#investigate the layers in the AREMP geodatabase 
subset(ogrDrivers(), grepl("GDB", name))
fc_list <- ogrListLayers(fgdb)

#load the locations, stream and habitat data from the AREMP geodatabase file # ed: spelling
locations   <- st_read(dsn=fgdb, layer = fc_list[10])

#st_crs(locations)
data        <- st_read(dsn=fgdb, layer = fc_list[11])

#macro and temp data is a score summarized by watershed not used in this data integration 
macro       <- st_read(dsn=fgdb, layer = fc_list[6])
temp        <- st_read(dsn=fgdb, layer = fc_list[3])

#rename a column in the data file so the locations and the data can be joined on that column 
names(data)[names(data) == "site_id"] <- "SITE_ID"

#Join the location information and the metric data 
AREMP <- right_join(locations, data, by="SITE_ID")

##### Testing adding AREMP data # ed: why is all of this commented out?

   
#locations   <- read_excel(paste0(getwd(),"/DataIntegrationExample/data/DataSources/AREMPqryLocationTable_forPNAMP.xlsx"))
#events      <- read_excel(paste0(getwd(),"/DataIntegrationExample/data/DataSources/AREMPqryEventTable_forPNAMP.xlsx"))
#updatedData <-  left_join(locations, events)
#write.csv(updatedData, paste0(getwd(),"/DataIntegrationExample/data/DataSources/AREMPTest.csv"))


#updatedData <- updatedData %>% dplyr::rename(SITE_ID = verbatimLocationID, 
#                                  site_survey_id = verbatimEventID, 
#                                  lattitude = La)
#write.csv(updatedData, paste0(getwd(),"/DataIntegrationExample/data/DataSources/AREMPTest.csv"))

#AREMP_all <- full_join(updatedData, AREMP)

#write.csv(AREMP_all, paste0(getwd(),"/DataIntegrationExample/data/DataSources/AREMPTest.csv"), row.names = FALSE)


#### 

if(compareCRS(CRS_DES, st_crs(locations))==TRUE){
   print("AREMP coordinate reference system matches the coordinate system of the data exchange standards for the intergrated dataset.")
   
} else {
   print("AREMP coordinate reference system does not match the coordinate system of the data exchange standards for the intergrated dataset.")
   #Transform to a standard system 
   a_WGS84 <- st_transform(AREMP, crs="+proj=longlat +datum=WGS84 +no_defs")
   
   #pull coordinates out of shapefile 
   lat_long <- do.call(rbind, st_geometry(a_WGS84))%>% 
      as_tibble(.name_repair = "unique")%>% 
      setNames(c("longitude","lattitude", "Z", "Z2"))
   
   # create a table of the AREMP data with lat and long 
   table       <- (st_geometry(AREMP)<- NULL)
   AREMP_csv   <- bind_cols(AREMP, lat_long)
   print("Transformed to WGS84 based on the data exchange standard")
}

#Delete the old AREMP data file 
files <- list.files(paste0(getwd(), "/DataIntegrationExample/data/DataSources"))
#files_remove <- paste0(getwd(), "/DataIntegrationExample/data/DataSources/", files[str_detect(files, "AREMP")])
#file.remove(files_remove)

file_name <- paste0(getwd(), "/DataIntegrationExample/data/DataSources/AREMPProcessedDataset.csv")
write.csv(AREMP_csv, file=file_name, row.names=FALSE)

return(AREMP_csv)
} 

