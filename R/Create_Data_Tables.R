#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)

#Open the metadata file 
metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

#Create the data exchange specifications tables 
DES_tables <- c("RecordLevel", "Location","Event", "MeasurementOrFact")
for (i in 1:length(DES_tables)){ 
  file_name =paste0(DES_tables[i], "_table")
   write.csv(assign(DES_tables[i], metadata %>% 
                           select(CategoryID, TermID, Table,measurementType, InDES, measurementTerm,Description,Examples, DataType ) %>% 
                           filter(Table== DES_tables[i], InDES=="x") %>% 
                           select(-InDES)), file=paste0("Tables/",file_name,".csv" ), row.names = F )
     }

#create a vocabulary table 
vocabulary<- metadata %>% 
                  select(CategoryID,Table,measurementType, measurementID, SubsetOfMetrics,
                         measurementTerm,LongName, Description,Examples, DataType, measurementUnit ) %>% 
                  filter(Table== "ControlledVocabulary", SubsetOfMetrics=="x") %>% 
                  select(-SubsetOfMetrics)

write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary.csv" ), row.names=F) 

#Create the crosswalk table 

crosswalk<- metadata %>% 
        select(c("measurementType", "measurementID", "measurementTerm", "SubsetOfMetrics", "InDES", 
          "LongName", "Description", "Examples", "DataType", "measurementUnit")|contains("CW")) %>% 
        filter(SubsetOfMetrics=="x"| InDES=="x"  ) %>% 
        select(-SubsetOfMetrics, -InDES) 
        
  
names(crosswalk) <- str_remove_all(names(crosswalk), "CW")
write.csv(crosswalk, file=paste0("Tables/Crosswalk.csv" ), row.names=F)

#Short crosswalk for the project team

short_crosswalk <- metadata %>% 
  select(c("measurementType", "SubsetOfMetrics", "InDES", 
           "measurementTerm", "LongName", "Description", "Examples", "DataType", "measurementUnit")|contains("CW")) %>% 
  filter(SubsetOfMetrics=="x"| InDES=="x"  ) %>% 
  select(-SubsetOfMetrics, -InDES, -contains("Method")) %>% 
  filter(measurementType != "Temperature")

names(short_crosswalk) <- str_remove_all(names(short_crosswalk), "CW")
write.csv(short_crosswalk, file=paste0("Tables/CrosswalkForReview.csv" ), row.names=F)


#Create a list of metrics from the programs not in the controlled vocabulary 
vocabulary<- metadata %>% 
  select(CategoryID,Table,measurementType, measurementID, SubsetOfMetrics,
         measurementTerm,LongName, Description,Examples, DataType, measurementUnit ) %>% 
  filter(Table== "ControlledVocabulary", SubsetOfMetrics=="x") %>% 
  select(-SubsetOfMetrics)

notInVocab<- metadata %>% 
  select(c(CategoryID,Table,measurementType, TermID, measurementID, SubsetOfMetrics,
           measurementTerm,LongName, Description,Examples, DataType, measurementUnit, InDES) | contains("FieldCW")) %>% 
  filter(is.na(SubsetOfMetrics)& is.na(InDES))  %>% 
  select(-SubsetOfMetrics, -InDES)

names(notInVocab) <- str_remove_all(names(notInVocab), "CW")
write.csv(notInVocab, file=paste0("Tables/NotInControlledVocabularyOrDES.csv" ), row.names=F)

