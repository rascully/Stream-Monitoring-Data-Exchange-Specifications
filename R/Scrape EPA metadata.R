#####Scraping EPA National Aquatic Resources data 

#This script is to pull meta data from the EPA data web page. 

download_EPA_NRSA <- function(SBUserName, SBPassword, CRS) {
library(tidyverse)
library(rvest)
library(stringr)
library(httr)
library(sbtools)

#####Sign into ScienceBase to find the link to the EPA data site 
#SBUserName  <- readline(prompt="ScienceBase User Name: ")
#SBPassword  <- readline(prompt="ScienceBase Password: ")
  
SBUserName  <- "rscully@usgs.gov"
SBPassword  <- "pnampUSGS79!"
  

authenticate_sb(SBUserName, SBPassword)
sb_id<- "5ea9d6a082cefae35a21ba5a"

######Download all the data links from the EPA web site#####
web_links<- item_get_fields(sb_id, "webLinks")
content <- read_html(web_links[[1]]$uri)

tables <- content %>% 
  html_table(fill = TRUE) 

EPA_table <- tables[[1]]

## Data links
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

#####Sort out the NARS data#####
NARS <- EPA_table %>% 
          filter(str_detect(Survey, "Streams"))

#####Join the location tables to create one data set of all the stream data#####
l_data_sets <- c("WSA Verification - Data",  "External Data: Site Information - Data", "NRSA 1314 Site Information - Data")
location_data <- NARS %>% 
                filter(str_detect(Indicator, "Site"))

location_data <- NARS %>% 
  filter(str_detect(web1, "siteinfo")) %>% 
  filter(!str_detect(web1,"ext"))


for(i in 1:length(location_data$web1)) { 
 # print(location_data$Survey[i])
  url_link <- paste0("https://www.epa.gov", location_data$web2[i])
  temp_file <- tempfile(fileext = ".csv")
  download.file(url_link, temp_file)
  if (i ==1) { 
    data1       <- read.csv(temp_file, sep="\t")
    # 2004 data location column header don't match the other two data sets, need to check with the EPA to see if this data is compadable 
    data1 <- data1 %>% rename(LON_DD83 = LON_DD, 
                              LAT_DD83= LAT_DD) 
    #Convert HUC  data to characters not integers 
    data1[str_detect(names(data1), "HUC")] <- data1 %>% 
                                                dplyr::select(contains("HUC")) %>% 
                                                mutate_each(as.character) 
    
    } else { 
    data2     <- read.csv(temp_file)
    #convert data type to characters 
    data2[str_detect(names(data2), "HUC")] <- data2 %>% 
                                              dplyr::select(contains("HUC")) %>% 
                                              mutate_each(as.character)
  if(any(str_detect(names(data2),"EPA_REG"))==T) {
       data2$EPA_REG <- as.character(data2$EPA_REG)
      } 
    data1     <- bind_rows(list(data1, data2))
  }
  unlink(temp_file)
} 

##### Convert string dates to dates #####
data1$DATE_COL <- as.Date.character(data1$DATE_COL, format="%m/%d/%Y" )
#data1$PUBLICATION_DATE <- as.Date.character(data1$PUBLICATION_DATE, format="%m/%d/%Y" )

blank_year             <- is.na(data1$YEAR)
data1$YEAR[blank_year] <- format(data1$DATE_COL[blank_year],format="%Y")
data1$YEAR<- as.integer(data1$YEAR)

# Check the longitude to make sure all are negative because this data set is all collected west of the prime meridian 
if(any(data1$XLON_DD>0, na.rm=TRUE)== T) {
  postive_index <- data1$XLON_DD >0 & !is.na(data1$XLON_DD)
  data1$XLON_DD[postive_index] <- data1$XLON_DD[postive_index]*(-1)
}

#####Join the data tables to the location tables 
# Identify the data tables of metrics we want to join
macroinvertebrates <-NARS %>% 
  filter(str_detect(Indicator, "Benthic Macroinvertebrates")) %>%  
  filter(str_detect(Data, "Metric"))

water_chem <-NARS %>% 
  filter(str_detect(Indicator, "Water Chemistry")) %>%  
  filter(str_detect(Data, "Indicator"))

phys_hab <-NARS %>% 
  filter(str_detect(Indicator, "Physical Habitat")) %>%  
  filter(str_detect(web1, paste(c("phabmet", "phabmed"), collapse = "|"))) 

metric_list <- rbind(macroinvertebrates, water_chem)
metric_list <- rbind(metric_list, phys_hab)


for(link in metric_list$web1){ 
  url_link <- paste0("https://www.epa.gov", link)
  temp_file <- tempfile(fileext = ".csv")
  download.file(url_link, temp_file)
  data_set<- read.csv(temp_file)
  if (any(str_detect(names(data_set), "YEAR"))==F) {
    data_set$DATE_COL <- as.Date.character(data_set$DATE_COL, format="%m/%d/%Y")  
    data_set <- mutate(data_set, YEAR = as.integer(format(data_set$DATE_COL,format="%Y")))
    }
  data1 <- left_join(data1, data_set, by=c("SITE_ID","YEAR", "VISIT_NO"))
  unlink(temp_file)
} 

data1<- data1 %>% 
        mutate(DATE_COMBIND = Sys.Date()) %>% 
        mutate(PROGRAM = "NRSA")

#####Remove duplicate fields#### 

#remove columns with .y indicating duplicate columns 
data1<- data1 %>% 
      dplyr::select(-contains(c(".y", "x,x", "y.y")))

#Rename columns with .x, so that field names match the original fields in the metadata 
names(data1) <- str_remove(names(data1), ".x")


#Delete the old EPA data file 
files <- list.files(paste0(getwd(), "/data"))
files_remove <- paste0(getwd(), "/data/", files[str_detect(files, "NRSA")])
file.remove(files_remove)


#####Save the Tidy Data set to Sciencebase#####
short_name = paste0("Tidy_NRSA_Data_Set.csv")
file_name <- paste0("data/", short_name)

write.csv(data1, file=file_name)


if(any(str_detect(item_list_files(sb_id)$fname, short_name))){
    item_replace_files(sb_id, file_name, title="")
  } else {
    item_append_files(sb_id, file_name)
}

##### Update the last Processed date to indicate the last time the code was run. 
sb_dates <- item_get_fields(sb_id, c('dates'))
sb_dates[[1]][["dateString"]] <- as.character(Sys.Date())

# This does not work? No error messsage? Don't understand the issue? 
items_update(sb_id, info = list(dates = sb_dates)) 

return(data1)
} 