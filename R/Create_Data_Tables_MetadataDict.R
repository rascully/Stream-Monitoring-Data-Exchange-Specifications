#Script to create tables for the the data exchange specifications and the publications

build_vocab_tables {
library(tidyverse)
library(stringr)
library(openxlsx)

metadataDict <- readxl::read_excel("Data/MetadataDictionary.xlsx", sheet = 1)
write.csv(metadataDict, "Data/MetadataDictionary.csv")

metadataDict <- metadataDict %>%
               dplyr::rename(term = attribute) %>% 
                filter(!is.na(term))

#Create the Data Exchange Standard Tables 
tables_des <- c("RecordLevel", "Location", "Event", "MeasurementOrFact")

DES <-metadataDict %>% 
  filter(str_detect(entity, paste(tables_des, collapse = "|"))) %>%
  drop_na(term)

for (i in 1:length(tables_des)){ 
  filename = paste0(getwd(),"/Data Exchange Standard Tables/",  tables_des[i], "DES.csv")
  write.csv( assign(tables_des[i], metadataDict %>% 
                     relocate('entity', 'termID', 'term', 'definition', 'dataType') %>% 
                     filter(str_detect(entity, tables_des[i])) %>% 
                     arrange(termID)), filename, row.names = FALSE)


}


#####Create a controlled vocabulary table from the EmunDict 
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
                                        
measurementTypeID <- measurementTypeID %>% 
                        dplyr::rename("measurementTypeID" = "enumerateddomain") %>% 
                        dplyr::select("measurementTypeID", "measurementType") 

# Join the measurementType to the ID numbers 
metricControlledVocabulary  <- right_join(measurementType, measurementTypeID, by= "measurementType")

metricControlledVocabulary$dataType  <-  "Numeric"
metricControlledVocabulary$term <- "term"
metricControlledVocabulary$termID    <-  401
metricControlledVocabulary <- relocate(metricControlledVocabulary,"termID","term", "measurementTypeID", "measurementType","description", "units", "dataType")

#Save the metricControlledVocabulary 
write.csv(metricControlledVocabulary, paste0(getwd(),"/Data Exchange Standard Tables/metricControlledVocabulary.csv"), row.names= FALSE)

#####Build mapping table for the lessons learned paper and project review 

dataMapping <- read.csv("Data Exchange Standard Tables/DataMapping.csv")

wideDataMapping <- dataMapping %>% 
  pivot_wider(names_from = program, values_from = c(originalField,originalUnit, originalDataType, methodCollection, methodAnalysis))

controlledVocbularyDataMapping <- right_join(wideDataMapping, metricControlledVocabulary)

write.csv(controlledVocbularyDataMapping, paste0(getwd(),"/Data Exchange Standard Tables/controlledVocabularyDataMappingTableForManuscript.csv")) 

desDataMapping <- right_join(wideDataMapping, DES)
write.csv(desDataMapping, paste0(getwd(),"/Data Exchange Standard Tables/desDataMappingTableForManuscript.csv"))

} 
#####################

