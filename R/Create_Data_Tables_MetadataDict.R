#Script to create tables for the the data exchange specifications and the publications

library(tidyverse)
library(stringr)
library(openxlsx)

metadataDict <- readxl::read_excel("Data/MetadataDictionary.xlsx", sheet = 1)
metadataDict <- metadataDict %>%
                rename("term"="label") %>% 
                filter(!is.na(term))

#Create the Data Exchange Standard Tables 
tables_des <- c("Record", "Location", "Event", "MeasurementOrFact")
tables <- pull(unique(metadataDict %>% 
                   select(tblname)))
DES <-metadataDict %>% 
  filter(str_detect(tblname, paste(tables_des, collapse = "|"))) %>%
  drop_na(term)


#Open the metadata file 
metadata <- readxl::read_excel("Data/Metadata.xlsx", sheet = 3)

#metadataT<- metadata %>%  
            #filter(str_detect(term, paste(DES$term, collapse = "|"))) %>% 
            #select(termID, term, table) 

metadataDict <- right_join(DES, metadataT,  by = c("term"))

for (i in 1:length(tables_des)){ 
  assign(tables[i], metadataDict %>% 
                     select(tblname,term, termID, definition, rdommin, rdommax, dataType, examples, standard) %>% 
                     filter(str_detect(tblname, tables[i])))
          
}

#####Create a controlled vocabulary table 
EmunDict <- readxl::read_excel("Data/MetadataDictionary.xlsx", sheet = 2)

cv <- EmunDict %>% 
    filter(entity == "MetricControlledVocabulary")

measurementType <- cv %>% 
  filter(attribute == "measurementType")

measurementTypeID <- cv %>% 
  filter(attribute == "measurementTypeID")

measurementTypeID <- measurementTypeID %>% 
        mutate(attribute, measurementType = str_remove(enumerateddefinition, "A unique numeric identifier assigned to the measurementType")) 

measurementTypeID
        
measurementTypeID$measurementType <- measurementTypeID$measurementType %>% 
                    str_replace_all(fixed("."), "") %>% 
                    trimws() %>% 
                    rename(measurementID = enumerateddomain)

measurementTypeID

x <- full_join(measurementType, measurementTypeID, by.x = 'enumerateddomain',  by.y = 'measurementType')


str_replace_all(x$measurementType, fixed("."), "")



xstr_remove(x$measurementType[2], ".")

x <-str_remove(measurementTypeID$enumerateddefinition[2], "A unique numeric identifier assigned to the measurementType") 
y <- str_remove(x, ".")



#create a vocabulary table 
vocabulary<- metadata %>% 
  select(c(termID,  categoryID, table,measurementType,subsetOfMetrics,
           term, longName , description, examples, dataType, measurementUnit, minimumPossibleValue, maximumPossibleValue)) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-subsetOfMetrics, -categoryID, -table) 
  


#create a vocabulary table 
vocabulary<- metadata %>% 
  select(c(categoryID, table,subsetOfMetrics, termID, 
         term, longName , description, examples, dataType, measurementUnit, minimumPossibleValue, maximumPossibleValue)) %>% 
  filter(table== "ControlledVocabulary", subsetOfMetrics=="x") %>% 
  select(-"subsetOfMetrics", -"categoryID", -"table") %>%
  rename("measurementType"="term", "measurementTypeID"="termID", "unit"="measurementUnit") 
  

vocabulary$term = "term"
vocabulary$termID = 401
vocabulary$table = "ControlledVocabulary"
vocabulary$edomvds = "Producer Defined"
vocabulary$table = "MeasuremeorFact"


#table	attrlabl	category	definition	edomvds	unit	comment

  vocabulary <- vocabulary %>% 
            relocate("table","termID", "term", "measurementTypeID", "measurementType", "description", "edomvds", "unit","dataType")

#  write.csv(vocabulary, file=paste0("Tables/ControlledVocabulary_table.csv" ), row.names=F)
  
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

cw_long <- cw_long %>%
  relocate("program", "termID", "term", "dataType", "originalField", "originalUnit", "originalDataType", "methodCollection", "methodAnalysis")

vocab_cw <- cw_long %>% 
          filter(termID >= 500) %>% 
          rename("measurmentTypeID" ="termID", "measurementType"="term")

vocab_cw$term = "term"
vocab_cw$termID = 401
  
des_long <- cw_long %>% 
            filter(termID <500)# %>% 
            #select("term")

  
des_long$measurementType = ""
des_long$measurmentTypeID = NA

cw_long2 <- bind_rows(vocab_cw,des_long )


cw_long2 <- cw_long2   %>%
              relocate("termID", "term","measurmentTypeID", "measurementType", "dataType", "program", "originalField",  "originalUnit") %>% 
              arrange("measurementTypeID")
  


for(i in 1:length(names(list_of_datasets))){ 
  filename = paste0(getwd(),"/Data Exchange Standard Tables/", names(list_of_datasets[i]), ".csv")
  table_name <- names(list_of_datasets[i])
  table <- data.frame(list_of_datasets[i])
  names(table) <- gsub(paste0(table_name,"."), "", names(table))
  write.csv(table, filename, row.names= FALSE)
} 

#Short crosswalk for the project team

short_crosswalk <- metadata %>% 
  select(c("measurementType", "subsetOfMetrics", "inDES", 
           "term", "longName", "description", "examples", "dataType", "measurementUnit")|contains("CW")) %>% 
  filter(subsetOfMetrics=="x"| inDES=="x"  ) %>% 
  select(-subsetOfMetrics, -inDES, -contains("Method")) %>% 
  filter(measurementType != "Temperature")

#names(short_crosswalk) <- str_remove_all(names(short_crosswalk), "CW")
#write.csv(short_crosswalk, file=paste0("Tables/CrosswalkForReview.csv" ), row.names=F)


#Create a list of metrics from the programs not in the controlled vocabulary 

notInVocab<- metadata %>% 
  select(c(categoryID,table,measurementType, termID, measurementID, subsetOfMetrics,
           term,longName, description,examples, dataType, measurementUnit, inDES) | contains("FieldCW")) %>% 
  filter(is.na(subsetOfMetrics)& is.na(inDES))  %>% 
  select(-subsetOfMetrics, -inDES)

names(notInVocab) <- str_remove_all(names(notInVocab), "CW")
write.csv(notInVocab, file=paste0("Other Tables/NotInControlledVocabularyOrDES.csv" ), row.names=F)


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

list_of_datasets <- list("RecordLevel" = Record, "Location"= Location, "Event"= Event,
                         "MeasurementorFact"= MeasurementOrFact, "VariableCV"= vocabulary,  "DataMapping"= crosswalk, 
                         "BLM"= BLM, "AREMP"= AREMP, "PIBO" = PIBO) 


list_of_datasets <- append(list_of_datasets, EPA)

file.remove("Other Tables/PropertyRegistry.xlsx")
openxlsx::write.xlsx(list_of_datasets, file = "Other Tables/PropertyRegistry.xlsx") 

