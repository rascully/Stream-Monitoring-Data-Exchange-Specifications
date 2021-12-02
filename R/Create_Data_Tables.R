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
  select(categoryID,table,measurementType,subsetOfMetrics, termID, 
         term, longName , description, examples, dataType, measurementUnit, minimamPossibleValue, maximamPossibleValue ) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-subsetOfMetrics, -categoryID, -table)

write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary.csv" ), row.names=F) 

old_crosswalk <- metadata %>% 
          select(c("table","measurementType", "measurementID", "term","termID",  "subsetOfMetrics", "inDES", 
          "longName", "description", "examples", "dataType", "measurementUnit")|contains("CW")) %>% 
          filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
          select(-subsetOfMetrics, -inDES) 

#Create the crosswalk table (Add back in "measurementID" once create UID for each value)
crosswalk<- metadata %>% 
  select(c("termID", "term", "subsetOfMetrics", "inDES")|contains(c("FieldCW"))) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES) 

cw_long <- crosswalk %>% 
       pivot_longer(cols=contains("Field"), names_to= "program", values_to = "orginalField", values_drop_na = T) %>% 
        mutate(program, program = str_remove_all(program, "FieldCW"))

######Create a table of units

units<- metadata %>% 
  select(c("termID", "term", "subsetOfMetrics", "inDES")| contains(c("Unit"))) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -measurementUnit) 

units_long <- units %>%
  pivot_longer(cols=contains("Unit"), names_to= "program", values_to = "orginalUnit", values_drop_na = T) %>% 
  mutate(program, program = str_remove_all(program, "Units"))

cw_long <- full_join(cw_long, units_long, by= c("termID", "program", "term")) %>% 
  select(-contains("ProgramMethodType")) 

#####Create a methods table 

methods <- crosswalk<- metadata %>% 
  select(c("termID", "subsetOfMetrics", "inDES")|contains("MethodIDCW")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES) %>% 
  pivot_longer(cols= contains("Method"), names_to="ProgramMethodType", values_to= "method", values_drop_na = T)



#%>% 
#  mutate(program, program = str_remove_all(program, "CollectionMethodIDCW")) %>% 
 # mutate(program, program = str_remove_all(program, "AnalysisMethodIDCW"))

method_type = c("Collection", "Analysis")

for (type in method_type) {
  print(type)
  
  method_flat <- methods %>% 
    filter(str_detect(ProgramMethodType,type)) %>% 
    rename(!!paste0(type,"Method") := method) %>% 
    mutate(ProgramMethodType, program = str_remove_all(ProgramMethodType
                                             , paste0(type, "MethodIDCW")))
  
    cw_long <- full_join(cw_long, method_flat, by= c("termID", "program")) %>% 
                select(-contains("ProgramMethodType"))
  
}
  
write.csv(crosswalk, file=paste0("Tables/Crosswalk_wide.csv" ), row.names=F)
write.csv(cw_long, file=paste0("Tables/Crosswalk_long.csv" ), row.names=F)


#####Create one file
list_of_datasets <- list("RecordLevel" = RecordLevel, "Location"= Location, "Event"= Event,
                         "MeasurementOrFact"= MeasurementOrFact, "metricControlledVocabulary"= vocabulary, 
                         "Crosswalk_tall"=cw_long  ,  "Crosswalk"= old_crosswalk, "Methods"=methods) 

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

