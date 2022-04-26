#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)
library(openxlsx)

metadataDict <- readxl::read_excel("Data/MetadataDictionary.xlsx", sheet = 1)

metadataDict <- metadataDict %>%
               dplyr::rename(term = attribute) %>% 
                filter(!is.na(term))

#Create the Data Exchange Standard Tables 
tables_des <- c("RecordLevel", "Location", "Event", "MeasurementOrFact")
tables <- pull(unique(metadataDict %>% 
                   select(entity)))

DES <-metadataDict %>% 
  filter(str_detect(entity, paste(tables_des, collapse = "|"))) %>%
  drop_na(term)


for (i in 1:length(tables_des)){ 
  assign(tables[i], metadataDict %>% 
                     relocate('entity', 'termID', 'term', 'definition', 'dataType') %>% 
                     filter(str_detect(entity, tables[i]))) %>% 
                     arrange(termID)
  
  filename = paste0(getwd(),"/Data Exchange Standard Tables/",  tables_des[i], ".csv")
  write.csv(tables[i], filename, row.names = FALSE)
  
}


#####Create a controlled vocabulary table 
EmunDict <- readxl::read_excel("Data/MetadataDictionary.xlsx", sheet = 2)

cv <- EmunDict %>% 
  filter(entity == "MetricControlledVocabulary")

measurementType <- cv %>% 
    filter(attribute == "measurementType") %>% 
    dplyr::rename("description" = "enumerateddefinition") %>% 
    dplyr::rename("measurementType" = "enumerateddomain")


measurementTypeID <- cv %>% 
  filter(attribute == "measurementTypeID")

measurementTypeID

measurementTypeID <- measurementTypeID %>% 
                          mutate(attribute, measurementType = str_remove(enumerateddefinition, "A unique numeric identifier assigned to the measurementType")) 

measurementTypeID

measurementTypeID$measurementType <- measurementTypeID$measurementType %>% 
                                        str_replace_all(fixed("."), "") %>% 
                                        trimws() 
                                        
measurementTypeID <- rename(measurementTypeID, "measurementTypeID" = "enumerateddomain") %>% 
                        dplyr::select("measurementTypeID", "measurementType") 

x <- right_join(measurementType, measurementTypeID, by= "measurementType")

x$dataType  <-  "Numeric"
x$term <- "term"
x$termID    <- "401"
x <- relocate(x,"termID","term", "measurementTypeID", "measurementType","description", "units", "dataType")

write.csv(x, paste0(getwd(),"/Data Exchange Standard Tables/metricControlledVocabulary.csv"), row.names= FALSE)

#####################

