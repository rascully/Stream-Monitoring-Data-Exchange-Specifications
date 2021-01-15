#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)

#Open the metadata file 
metadata <- readxl::read_excel("Metadata.xlsx", sheet = 3)

#Create the data exchange specifications tables 
DES_tables <- c("RecordLevel", "Location","Event", "MeasurementOrFact")
for (i in 1:length(DES_tables)){ 
     x<- metadata %>% 
            select(CategoryID, TermID, Category, InDES, Term,Description,Examples, DataType ) %>% 
            filter(Category== DES_tables[i], InDES=="x") %>% 
            select(-InDES)
      
      print(DES_tables[i]) 
      file_name <- paste0(DES_tables[i], "_table") # create a file name 
      write.csv(x, file=paste0("Tables/",file_name,".csv" ), row.names = F)
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
                  select(CategoryID, Category, TermID, MeasurementID, VocabularyCatagory, SubsetOfMetrics, InDES, 
                         Term, LongName, Description, Examples ,DataType, Unit, 
                         AREMPField, NRSA2004Field, NRSA2008Field, AIMField, PIBOField) %>% 
                  filter(SubsetOfMetrics=="x")  %>% 
                  select(-SubsetOfMetrics, -InDES)

write.csv(crosswalk, file=paste0("Tables/Crosswalk.csv" ), row.names=F)


#Create a list of metrics from the programs not in the controlled vocabulary 
notInVocab<- metadata %>% 
  select(CategoryI, Category, TermID, MeasurementID, VocabularyCatagory, SubsetOfMetrics, InDES, 
         Term, LongName, Description, Examples ,DataType, Unit, 
         AREMPField, NRSA2004Field, NRSA2008Field, AIMField, PIBOField) %>% 
  filter(is.na(SubsetOfMetrics)& is.na(InDES))  %>% 
  select(-SubsetOfMetrics, -InDES)

write.csv(crosswalk, file=paste0("Tables/NotInControlledVocabularyOrDES.csv" ), row.names=F)
