#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)

#Open the metadata file 
metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

#Create the data exchange specifications tables 
DES_tables <- c("RecordLevel", "Location","Event", "MeasurementOrFact")
for (i in 1:length(DES_tables)){ 
    
     assign(DES_tables[i], metadata %>% 
            select(CategoryID, TermID, Category, InDES, Term,Description,Examples, DataType ) %>% 
            filter(Category== DES_tables[i], InDES=="x") %>% 
            select(-InDES)) 
      
      print(DES_tables[i]) 
      file_name <- paste0(DES_tables[i], "_table") # create a file name 
      write.csv(DES_tables[i], file=paste0("Tables/",file_name,".csv" ), row.names = F)
  }

#create a vocabulary table 
vocabulary<- metadata %>% 
                  select(CategoryID, Category,TermID, MeasurementID, SubsetOfMetrics,
                         Term,LongName, Description,Examples, DataType, Unit ) %>% 
                  filter(Category== "ControlledVocabulary", SubsetOfMetrics=="x") %>% 
                  select(-SubsetOfMetrics)

write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary.csv" ), row.names=F) 

#Create the crosswalk table 

crosswalk<- metadata %>% 
        select(c("CategoryID", "Category", "TermID", "MeasurementID", "VocabularyCatagory", "SubsetOfMetrics", "InDES", 
           "Term", "LongName", "Description", "Examples", "DataType", "Unit")|contains("CW")) %>% 
        filter(SubsetOfMetrics=="x"| InDES=="x"  ) %>% 
        select(-SubsetOfMetrics, -InDES) 
        
  
names(crosswalk) <- str_remove_all(names(crosswalk), "CW")
write.csv(crosswalk, file=paste0("Tables/Crosswalk.csv" ), row.names=F)

#Short crosswalk for the project team

short_crosswalk <- metadata %>% 
  select(c("VocabularyCatagory", "SubsetOfMetrics", "InDES", 
           "Term", "LongName", "Description", "Examples", "DataType", "Unit")|contains("CW")) %>% 
  filter(SubsetOfMetrics=="x"| InDES=="x"  ) %>% 
  select(-SubsetOfMetrics, -InDES, -contains("Method")) %>% 
  filter(VocabularyCatagory != "Temperature")

names(short_crosswalk) <- str_remove_all(names(short_crosswalk), "CW")
write.csv(short_crosswalk, file=paste0("Tables/CrosswalkForReview.csv" ), row.names=F)


#Create a list of metrics from the programs not in the controlled vocabulary 
notInVocab<- metadata %>% 
  select(c(CategoryID, Category, TermID, MeasurementID, VocabularyCatagory, SubsetOfMetrics, InDES, 
         Term, LongName, Description, Examples ,DataType, Unit) | contains("FieldCW"))  %>% 
  filter(is.na(SubsetOfMetrics)& is.na(InDES))  %>% 
  select(-SubsetOfMetrics, -InDES)

names(notInVocab) <- str_remove_all(names(notInVocab), "CW")
write.csv(notInVocab, file=paste0("Tables/NotInControlledVocabularyOrDES.csv" ), row.names=F)

