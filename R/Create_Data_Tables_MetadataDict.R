#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)
library(openxlsx)

metadataDict <- readxl::read_excel("Data/MetadataDictionary_v1.xlsx", sheet = 1)

#Create the data exchange specifications tables 
tables <- c("RecordLevel", "Location", "Event", "MeasurementorFact")

for (i in 1:length(tables)){ 
  
  file_name = paste0(tables[i], "_table")
  print(paste0(tables[i], "_table"))
  
  write.csv(assign(tables[i], metadataDict %>% 
                      select(tblname,label, definition, rdommin, rdommax, dataType, examples, standard) %>% 
                      filter(tblname== tables[i])), file=paste0("Tables/",file_name,".csv" ), row.names = F ) 
      }

#Open the metadata file 
metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

#create a vocabulary table 
vocabulary<- metadata %>% 
  select(c(categoryID,table,measurementType,subsetOfMetrics, termID, 
         term, longName , description, examples, dataType, measurementUnit, minimumPossibleValue, maximumPossibleValue)) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-subsetOfMetrics, -categoryID, -table)


old_crosswalk <- metadata %>% 
  select(c("table","measurementType", "measurementID", "term","termID",  "subsetOfMetrics", "inDES", 
          "examples", "dataType", "measurementUnit")|contains("CW")| contains("Units")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES) 

##### Build a tall crosswalk 
crosswalk<- metadata %>% 
  select(c("termID", "term", "subsetOfMetrics", "inDES", "dataType")|contains(c("FieldCW"))) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES) 

cw_long <- crosswalk %>% 
       pivot_longer(cols=contains("Field"), names_to= "program", values_to = "originalField", values_drop_na = T) %>% 
        mutate(program, program = str_remove_all(program, "FieldCW"))

#Create a table of units
units<- metadata %>% 
  select(c("termID","term","subsetOfMetrics", "inDES")| contains(c("Unit"))) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -measurementUnit) %>% 
  drop_na(termID)
  
units_long <- units %>%
  pivot_longer(cols=contains("Unit"), names_to= "program", values_to = "originalUnit", values_drop_na = T) %>% 
  mutate(program, program = str_remove_all(program, "Units"))

cw_long <- left_join(cw_long, units_long, by= c("termID", "program", "term")) %>% 
  select(-contains("ProgramMethodType")) 

##### Create a data type table 
dataType <- metadata %>% 
  select(c("termID","term", "subsetOfMetrics", "inDES")|contains("DataType")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -"dataType") %>% 
  pivot_longer(cols= contains("DataType"), names_to="program", values_to= "originalDataType", values_drop_na = T) %>% 
  mutate(program, program = str_remove_all(program, "DataType"))

cw_long <- left_join(cw_long, dataType, by = c("termID", "program", "term"))
                    

#####Create a method table 
method_type = c("Collection", "Analysis")

for (type in method_type) {
  print(type)

  method <- metadata %>% 
    select(c("termID","term", "subsetOfMetrics", "inDES", contains(type))) %>% 
    filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
    select(-subsetOfMetrics, -inDES) %>% 
    pivot_longer(cols= contains("Method"), names_to="programMethods", values_to= paste0("method", type), values_drop_na = T) %>% 
    mutate(programMethods, program = str_remove_all(programMethods, paste0(type, "MethodIDCW")))
  
    cw_long <- full_join(cw_long, method, by= c("termID","term",  "program")) %>% 
                select(-contains("programMethods"))
  
}

cw_long <- cw_long %>% arrange("program", "termID", "term", "datatype", "orginalField", "orginalUnit", "originalDataType", "methodCollection", "methodAnalysis")
  
write.csv(crosswalk, file=paste0("Tables/Crosswalk_wide.csv" ), row.names=F)
write.csv(cw_long, file=paste0("Tables/Crosswalk_long.csv" ), row.names=F)

#sheets <- openxlsx::getSheetNames("Tables/ControlledVocabularyForFields.xlsx")
#CVFields <- lapply(sheets,openxlsx::read.xlsx, xlsxFile="Tables/ControlledVocabularyForFields.xlsx")
#names(CVFields) <- sheets

#####Create one file
list_of_datasets <- list("RecordLevel" = RecordLevel, "Location"= Location, "Event"= Event,
                         "MeasurementorFact"= MeasurementorFact, "metricControlledVocabulary"= vocabulary, 
                         "Crosswalk"=cw_long)

file.remove("Tables/StreamHabitatSpecifications.xlsx")
write.xlsx(list_of_datasets, file = "Tables/StreamHabitatSpecifications.xlsx") 

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
                         "MeasurementorFact"= MeasurementorFact, "VariableCV"= vocabulary,  "Crosswalk"= crosswalk, 
                         "BLM"= BLM, "AREMP"= AREMP, "PIBO" = PIBO) 

list_of_datasets <- append(list_of_datasets, EPA)

file.remove("Tables/PropertyRegistry.xlsx")
openxlsx::write.xlsx(list_of_datasets, file = "Tables/PropertyRegistry.xlsx") 

