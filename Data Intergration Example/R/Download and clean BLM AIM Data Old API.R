
download_AIM<- function(){
  
  library(dplyr)
  library(readr)
  library(tidyverse)
  library(sf)
  library(data.table)
  library(raster)

  
  #create a URL to access the BLM Data
  url <- list(hostname = "gis.blm.gov/arcgis/rest/services",
              scheme = "https",
              path = "hydrography/BLM_Natl_AIM_AquADat/MapServer/0/query",
              query = list(
                where = "1=1",
                outFields = "*",
                returnGeometry = "true",
                f = "geojson")) %>% 
                setattr("class", "url")
  
  request <- build_url(url)
  BLM <- st_read(request, stringsAsFactors = TRUE) #Load the file from the Data file 
  data <- as_tibble(BLM)
  data <- data %>% 
    filter(PRTCL == "WADEABLE")
  
  #Check the projection 
  st_crs(BLM)
  
  if(compareCRS(CRS, BLM)==TRUE){
   print("AIM coordinate reference system matches the coordinate system of the data exchange standards for the integrated dataset.")
  } else{ 
  print("AIM coordinate reference system does not match the coordinate system of the data exchange standards for the integrated dataset.")
      #code to reproject 
        #st_transform(data, crs="+proj=longlat +datum=WGS84 +no_defs")
   }
  
  #Fix the date 
  data$DT <- as.POSIXct(data$DT/1000, origin="1970-01-01")
  data$DT <- str_remove(data$DT, " 17:00:00 PDT")
  data$DT <- as.Date.character(str_remove(data$DT, "17:00:00"))
  
  
  
  file_name <- paste0(getwd(), "/data/DataSources/AIM_Processed_Dataset.csv")
  write.csv(data, file=file_name, row.names=FALSE)
  
  return(data)
}