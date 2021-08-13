#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)
library(openxlsx)

#Open the metadata file 
metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

#Create the data exchange specifications tables 
DES_tables <- c("Datasets", "SamplingFeature","Action", "Results")

for (i in 1:length(DES_tables)){ 
  file_name = paste0(DES_tables[i], "_table")
  write.csv(assign(DES_tables[i], metadata %>% 
                     dplyr::select(TermID, ODMTable, InDES, ODM, Description,Examples, DataType, 
                                   PrimaryKey, ForeginKey, ControlledVocabulary, ControlledVocabularyAPI, 
                                   MinimamPossibleValue,MaximamPossibleValue   ) %>% 
                     filter(ODMTable== DES_tables[i], InDES=="x") %>% 
                     rename(Term=ODM) %>% 
                     select(-InDES, -ODMTable)) , file=paste0("Tables/ODM",file_name,".csv" ), row.names = F )
      }


metadata %>% 
  dplyr::select(CategoryID, TermID, ODM, ODMTable, Table,measurementType, InDES, measurementTerm,Description,Examples, DataType )%>% 
  filter(ODMTable== DES_tables[1], InDES=="x")


#create a vocabulary table 
vocabulary<- metadata %>% 
  select(CategoryID,Table,measurementType, measurementID, SubsetOfMetrics,
         measurementTerm,LongName, Description,Examples, DataType, measurementUnit, MaximamPossibleValue, MaximamPossibleValue ) %>% 
  filter(Table== "ControlledVocabulary", SubsetOfMetrics=="x") %>% 
  select(-SubsetOfMetrics)

write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary.csv" ), row.names=F) 

#Create the crosswalk table 

crosswalk<- metadata %>% 
  select(c("Table","measurementType", "measurementID", "measurementTerm", "SubsetOfMetrics", "InDES", 
           "LongName", "Description", "Examples", "DataType", "measurementUnit")|contains("CW")) %>% 
  filter(SubsetOfMetrics=="x"| InDES=="x"  ) %>% 
  select(-SubsetOfMetrics, -InDES) 

crosswalk[str_detect(crosswalk$measurementTerm, c("sampingProtocol")),]

names(crosswalk) <- str_remove_all(names(crosswalk), "CW")
write.csv(crosswalk, file=paste0("Tables/Crosswalk.csv" ), row.names=F)


#####Create one file
list_of_datasets <- list("Datasets" = Datasets, "SamplingFeature"= SamplingFeature, "Action"= Action,
                         "Results"= Results, "VariableCV"= vocabulary,  "Crosswalk"= crosswalk) 

file.remove("Tables/ODM2_DarwinCore_StreamHabitat_ExchangeSpecifications.xlsx")

openxlsx::write.xlsx(list_of_datasets, file = "Tables/ODM2_DarwinCore_StreamHabitat_ExchangeSpecifications.xlsx") 


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
         measurementTerm,LongName, Description,Examples, DataType, measurementUnit, MaximamPossibleValue, MinimamPossibleValue, PickList ) %>% 
  filter(Table== "ControlledVocabulary", SubsetOfMetrics=="x") %>% 
  select(-SubsetOfMetrics)

notInVocab<- metadata %>% 
  select(c(CategoryID,Table,measurementType, TermID, measurementID, SubsetOfMetrics,
           measurementTerm,LongName, Description,Examples, DataType, measurementUnit, InDES) | contains("FieldCW")) %>% 
  filter(is.na(SubsetOfMetrics)& is.na(InDES))  %>% 
  select(-SubsetOfMetrics, -InDES)

names(notInVocab) <- str_remove_all(names(notInVocab), "CW")
write.csv(notInVocab, file=paste0("Tables/NotInControlledVocabularyOrDES.csv" ), row.names=F)


#the original metadata from the programs and the proposed schema cross walk 

read_excel_allsheets <- function(filename, tibble = FALSE) {
  # I prefer straight data.frames
  # but if you like tidyverse tibbles (the default with read_excel)
  # then just pass tibble = TRUE
  sheets <- readxl::excel_sheets(filename)
  x <- lapply(sheets, function(X) readxl::read_excel(filename, sheet = X))
  if(!tibble) x <- lapply(x, as.data.frame)
  names(x) <- sheets
  x
}

all_metadata <- read_excel_allsheets("Data/Metadata.xlsx")
BLM <- all_metadata$BLM
AREMP <- all_metadata$AREMP
PIBO <- all_metadata$PIBO
EPA <- all_metadata[grep("EPA", names(all_metadata))]
EPA_names <- names(EPA)

one= as.df(EPA[1])


list_of_datasets <- list("Record_level" = RecordLevel, "location"= Location, "Event"= Event,
                         "Measurment_or_Fact"= MeasurementOrFact, "Vocabulary"= vocabulary,  "Crosswalk"= crosswalk, "BLM"= BLM, "AREMP"= AREMP, "PIBO" = PIBO)
list_of_datasets <- append(list_of_datasets, EPA)

openxlsx::write.xlsx(list_of_datasets, file = "Tables/PropertyRegistry.xlsx") 
##### Data exhange specifications 

list_of_datasets <- list("Record_level" = RecordLevel, "location"= Location, "Event"= Event,
                         "Measurment_or_Fact"= MeasurementOrFact, "Vocabulary"= vocabulary) 

