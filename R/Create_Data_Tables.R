#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)
library(openxlsx)

#Open the metadata file 
metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

#Create the data exchange specifications tables 
DES_tables <- c("Datasets", "SamplingFeature","Action", "Results")
tables <- c("RecordLevel", "Location", "Event", "MeasurementOrFact")



for (i in 1:length(tables)){ 
  
  file_name = paste0(tables[i], "_table")
  print(paste0(tables[i], "_table"))
  write.csv(assign(tables[i], metadata %>% 
                     dplyr::select(table, termID, inDES, term, description,examples, dataType, 
                                   primaryKey, foreginKey, controlledVocabulary, controlledVocabularyAPI, 
                                   minimamPossibleValue,maximamPossibleValue,darwinCoreTerm, darwinCoreClass, ODM2Term, ODMTable) %>% 
                     filter(table== tables[i], inDES=="x") %>% 
                     select(-inDES, -table)) , file=paste0("Tables/",file_name,".csv" ), row.names = F )
      }


#metadata %>% 
 # dplyr::select(CategoryID, TermID, Term, ODMTable, Table,measurementType, InDES, Term,Description,Examples, DataType )%>% 
  #filter(ODMTable== DES_tables[1], InDES=="x")


#create a vocabulary table 
vocabulary<- metadata %>% 
  select(categoryID,table,measurementType, measurementID, subsetOfMetrics,
         term, description, examples, dataType, measurementUnit, maximamPossibleValue, minimamPossibleValue ) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-subsetOfMetrics, -categoryID, -table)

write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary.csv" ), row.names=F) 

#Create the crosswalk table 
crosswalk<- metadata %>% 
  select(c("table","measurementType", "measurementID", "term", "subsetOfMetrics", "inDES", 
           "description", "examples", "dataType", "measurementUnit")|contains("CW")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES) 

crosswalk[str_detect(crosswalk$term, c("sampingProtocol")),]

names(crosswalk) <- str_remove_all(names(crosswalk), "CW")
write.csv(crosswalk, file=paste0("Tables/Crosswalk.csv" ), row.names=F)




#####Create one file
list_of_datasets <- list("RecordLevel" = RecordLevel, "Location"= Location, "Event"= Event,
                         "MeasurementOrFact"= MeasurementOrFact, "VariableCV"= vocabulary,  "Crosswalk"= crosswalk) 

file.remove("Tables/Stream_Habitat_ExchangeSpecifications.xlsx")

openxlsx::write.xlsx(list_of_datasets, file = "Tables/Stream_Habitat_ExchangeSpecifications.xlsx") 


#Short crosswalk for the project team

short_crosswalk <- metadata %>% 
  select(c("measurementType", "subsetOfMetrics", "inDES", 
           "term", "longName", "description", "examples", "dataType", "measurementUnit")|contains("CW")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -contains("Method")) %>% 
  filter(measurementType != "Temperature")

names(short_crosswalk) <- str_remove_all(names(short_crosswalk), "CW")
write.csv(short_crosswalk, file=paste0("Tables/CrosswalkForReview.csv" ), row.names=F)


#Create a list of metrics from the programs not in the controlled vocabulary 
vocabulary<- metadata %>% 
  select(categoryID,table,measurementType, measurementID, subsetOfMetrics,
         term,longName, description,examples, dataType, measurementUnit, maximamPossibleValue, minimamPossibleValue, controlledVocabulary, controlledVocabularyAPI ) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-subsetOfMetrics)

notInVocab<- metadata %>% 
  select(c(categoryID,table,measurementType, termID, measurementID, subsetOfMetrics,
           term,longName, description,examples, dataType, measurementUnit, inDES) | contains("FieldCW")) %>% 
  filter(is.na(subsetOfMetrics)& is.na(inDES))  %>% 
  select(-subsetOfMetrics, -inDES)

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


list_of_datasets <- list("RecordLevel" = RecordLevel, "Location"= Location, "Event"= Event,
                         "MeasurementOrFact"= MeasurementOrFact, "VariableCV"= vocabulary,  "Crosswalk"= crosswalk, 
                         "BLM"= BLM, "AREMP"= AREMP, "PIBO" = PIBO) 

list_of_datasets <- append(list_of_datasets, EPA)

file.remove("Tables/PropertyRegistry.xlsx")
openxlsx::write.xlsx(list_of_datasets, file = "Tables/PropertyRegistry.xlsx") 