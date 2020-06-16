#Need to design a workflow to link the master metadata file to the individual files or figure out a way to update each file. 
install.packages('tidyverse')
library(tidyverse)
library(downloader) 
library(xlsx)

wd <- getwd()
metadata    <- as_tibble(read.xlsx(paste0(wd,"/Metadata.xlsx") , 3), col_names= TRUE)

definitions    <- as_tibble(read.xlsx(paste0(wd,"/Metadata.xlsx") , 4), col_names= TRUE)


cross_walk  <- select(metadata, c(CategoryID, FieldID, Category, InDES, SubsetOfMetrics, LongName, Field, Definition, DataType, NotesCodesConventions, DataType,
                                  AREMPField, AREMPDescriptionIfDifferentFromDefinition, AREMPUnits, AREMPCollectionMethodID, AREMPAnalysisMethodID, 
                                  BLMFieldFromMetadata, BLMField, BLMDescriptionIfDifferentFromDefinition, BLMUnits, BLMCollectionMethodID, BLMAnalysisMethodID,
                                  EPA2008Field, EPA2004Field, EPADescriptionIfDifferentFromDefinition, EPAUnits, EPACollectionMethodID, EPAAnalysisMethodID,
                                  PIBOField, PIBODescriptionIfDifferentFromDescription, PIBOUnits, PIBOCollectionMethodID, PIBOAnalysisMethodID))
                                  
                          

# Extract the subset of metrics that are inclued in the initial controlled vocubilary, not in the inital crontrolled vocab or the data exchange specifications, and in the data exhcnage specifications 
metrics <- cross_walk%>% 
  filter(SubsetOfMetrics== "x" | InDES == 'x')

metrics <- cross_walk %>% 
          filter(SubsetOfMetrics =="x")

not_in_cross_walk <- cross_walk %>% 
  filter(SubsetOfMetrics !="x" | InDES == 'x')
    
des <- cross_walk %>%
    filter(InDES =='x')

#Extract the definitions of the columns included in the subseted metadata. If a name is added to the "cross-walk" variable update the metadata file definitions sheet. 
subset_definition <- definitions %>%
  filter(IncludeInCrosswalk =="x")

#Save the spreadsheets with the definitions 
install.packages("writexl")
library(writexl)
sheets <- list("CrossWalk and Vocab" = metrics, "Column Definitions" = subset_definitions) #assume sheet1 and sheet2 are data frames
write_xlsx(sheets, "SubSetOfToCheck.xlsx")

sheets <- list("Data Exchange Specifications" = des, "Column Definitions"= subset_definitions)
write_xlsx(sheets, "ElementsOfDataExchangeSpecifications.xlsx")

sheets <- list("Metrics Not In CrossWalk" = not_in_cross_walk, "Column Definitions"= subset_definitions) 
write_xlsx(sheets, "MetricsNotInVocab.xlsx")
