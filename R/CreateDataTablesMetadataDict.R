# Script to create tables for the the data exchange standards # ed changed specifications to standards, removed publications

build_vocab_tables <-function() {
library(tidyverse)
library(stringr)
library(openxlsx)

metadataDict <- read.csv("Data/MetadataDictionary.csv")

metadataDict <- metadataDict %>%
               dplyr::rename(term = attribute) %>% 
                filter(!is.na(term))

#### Create the Data Exchange Standard Tables ####
tables_des <- c("RecordLevel", "Location", "Event", "MeasurementOrFact")

DES <-metadataDict %>% 
  filter(str_detect(entity, paste(tables_des, collapse = "|"))) %>%
  drop_na(term)

for (i in 1:length(tables_des)){ 
  filename = paste0(getwd(),"/DataExchangeStandardTables/",  tables_des[i], "DES.csv")
  write.csv( assign(tables_des[i], metadataDict %>% 
                    dplyr:: select(-c ('sourcedefinition', 'unboundeddefinition', 'enumerateddomain', 'NAorBlankcell', 'NAdefinition'))  %>% 
                     relocate('entity', 'termID', 'term', 'definition', 'dataType') %>% 
                     filter(str_detect(entity, tables_des[i])) %>% 
                     filter(termID != "NA")  %>% 
                     arrange(termID)), filename, row.names = FALSE)


}


#### Create a controlled vocabulary table from the CategoryDict ####
CategoryDict <- read.csv("Data/CategoryDictionary.csv") 

cv <- CategoryDict %>% 
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

#### Save the metricControlledVocabulary ####
write.csv(metricControlledVocabulary, paste0(getwd(),"/DataExchangeStandardTables/metricControlledVocabulary.csv"), row.names= FALSE)


#### Build mapping table for the lessons learned paper and project review ####

dataMapping <- read.csv("DataExchangeStandardTables/DataMappingDES.csv")

wideDataMapping <- dataMapping %>% 
  pivot_wider(names_from = projectCode, values_from = c(originalField,originalUnit, originalDataType, methodCollection, methodAnalysis))

metricControlledVocabulary$measurementTypeID <- as.numeric(metricControlledVocabulary$measurementTypeID)

controlledVocbularyDataMapping <- right_join(wideDataMapping, metricControlledVocabulary) # ed: in the variable name, change Vocbulary to Vocabulary

write.csv(controlledVocbularyDataMapping, paste0(getwd(),"/DataExchangeStandardTables/TablesForManuscripts/controlledVocabularyDataMappingTableForManuscript.csv")) # ed: followup from above, in the write.csv(filename, change the filename Vocbulary to Vocabulary

desDataMapping <- right_join(wideDataMapping, DES)
write.csv(desDataMapping, paste0(getwd(),"/DataExchangeStandardTables/TablesForManuscripts/desDataMappingTableForManuscript.csv"))

} 


