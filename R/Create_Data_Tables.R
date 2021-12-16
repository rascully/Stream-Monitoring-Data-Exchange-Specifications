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
                     dplyr::select(table, termID, inDES, term,  description,examples, dataType, 
                                   primaryKey, foreignKey, controlledVocabulary, controlledVocabularyAPI, 
                                   minimumPossibleValue,maximumPossibleValue,darwinCoreTerm, darwinCoreClass, ODM2Term, ODMTable) %>% 
                     filter(table== tables[i], inDES=="x") %>% 
                     select(-inDES, -table)) , file=paste0("Tables/",file_name,".csv" ), row.names = F )
      }



### Create a tall table of the DES terms an

des_tall <- metadata %>% 
                   dplyr::select(table, termID, inDES, term,  description,examples, dataType,measurementUnit , 
                                 primaryKey, foreignKey, controlledVocabulary, controlledVocabularyAPI, 
                                 minimumPossibleValue,maximumPossibleValue,darwinCoreTerm, darwinCoreClass, ODM2Term, ODMTable) %>% 
                   filter(inDES=="x") %>% 
                   select(-inDES)


des_test <- metadata %>% 
          select(c("table", "termID", "inDES", "term", "dataType")|contains("DataType")|contains("Unit"))  %>% 
          filter(inDES=="x") %>% 
          select(-inDES)

metric_cv <- metadata %>% 
  select(c("table", "termID", "inDES","fullCV",  "term", "dataType")|contains("DataType")|contains("Unit"))  %>% 
  filter(fullCV=="x") %>% 
  select(-fullCV)


#metadata %>% 
 # dplyr::select(CategoryID, TermID, Term, ODMTable, Table,measurementType, InDES, Term,Description,Examples, DataType )%>% 
  #filter(ODMTable== DES_tables[1], InDES=="x")


#create a vocabulary table 
vocabulary<- metadata %>% 
  select(c(categoryID,table,measurementType,subsetOfMetrics, termID, 
         term, longName , description, examples, dataType, measurementUnit, minimumPossibleValue, maximumPossibleValue)) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-subsetOfMetrics, -categoryID, -table)

write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary.csv" ), row.names=F) 

old_crosswalk <- metadata %>% 
          select(c("table","measurementType", "measurementID", "term","termID",  "subsetOfMetrics", "inDES", 
          "longName", "description", "examples", "dataType", "measurementUnit")|contains("CW")) %>% 
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
  select(c("termID", "term", "subsetOfMetrics", "inDES")| contains(c("Unit"))) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -measurementUnit) 

units_long <- units %>%
  pivot_longer(cols=contains("Unit"), names_to= "program", values_to = "originalUnit", values_drop_na = T) %>% 
  mutate(program, program = str_remove_all(program, "Units"))

cw_long <- full_join(cw_long, units_long, by= c("termID", "program", "term")) %>% 
  select(-contains("ProgramMethodType")) 

##### Create a data type table 
dataType <- metadata %>% 
  select(c("termID","term", "subsetOfMetrics", "inDES")|contains("DataType")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -"dataType", -"term") %>% 
  pivot_longer(cols= contains("DataType"), names_to="program", values_to= "originalDataType", values_drop_na = T) %>% 
  mutate(program, program = str_remove_all(program, "DataType"))

cw_long <- full_join(cw_long, dataType, by = c("termID", "program"))
                    

#####Create a method table 
method_type = c("Collection", "Analysis")

for (type in method_type) {
  print(type)

  method <- metadata %>% 
    select(c("termID","term", "subsetOfMetrics", "inDES", contains(type))) %>% 
    filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
    select(-subsetOfMetrics, -inDES, -"term") %>% 
    pivot_longer(cols= contains("Method"), names_to="programMethods", values_to= paste0("method", type), values_drop_na = T) %>% 
    mutate(programMethods, program = str_remove_all(programMethods, paste0(type, "MethodIDCW")))
  
    cw_long <- full_join(cw_long, method, by= c("termID", "program")) %>% 
                select(-contains("programMethods"))
  
}

cw_long <- cw_long %>% arrange("program", "termID", "term", "datatype", "orginalField", "orginalUnit", "originalDataType", "methodCollection", "methodAnalysis")
  
write.csv(crosswalk, file=paste0("Tables/Crosswalk_wide.csv" ), row.names=F)
write.csv(cw_long, file=paste0("Tables/Crosswalk_long.csv" ), row.names=F)

sheets <- openxlsx::getSheetNames("Tables/ControlledVocabularyForFields.xlsx")
CVFields <- lapply(sheets,openxlsx::read.xlsx, xlsxFile="Tables/ControlledVocabularyForFields.xlsx")
names(CVFields) <- sheets

#####Create one file
list_of_datasets <- append(list("RecordLevel" = RecordLevel, "Location"= Location, "Event"= Event,
                         "MeasurementOrFact"= MeasurementOrFact, "metricControlledVocabulary"= vocabulary, 
                         "Crosswalk_tall"=cw_long  ,  "Crosswalk"= old_crosswalk, "Methods"=method, "des_tall"= des_tall), CVFields) 

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
                         "MeasurementOrFact"= MeasurementOrFact, "VariableCV"= vocabulary,  "Crosswalk"= crosswalk, 
                         "BLM"= BLM, "AREMP"= AREMP, "PIBO" = PIBO) 

list_of_datasets <- append(list_of_datasets, EPA)

file.remove("Tables/PropertyRegistry.xlsx")
openxlsx::write.xlsx(list_of_datasets, file = "Tables/PropertyRegistry.xlsx") 

