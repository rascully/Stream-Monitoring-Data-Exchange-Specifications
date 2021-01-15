#Need to design a workflow to link the master metadata file to the individual files or figure out a way to update each file. 
install.packages('tidyverse')
library(tidyverse)
library(downloader) 
library(xlsx)
install.packages("writexl")
library(writexl)

wd <- getwd()
metadata    <- as_tibble(read.xlsx(paste0(wd,"/Metadata.xlsx") , 3), col_names= TRUE)

definitions    <- as_tibble(read.xlsx(paste0(wd,"/Metadata.xlsx") , 4), col_names= TRUE)



#Subset of columns that are shared as part of work to confirm the controlled vocab 
SubsetColumns  <- select(metadata, c(CategoryID, FieldID, Category, InDES, SubsetOfMetrics, LongName, Field, Definition, DataType, NotesCodesConventions, DataType,
                                  AREMPDescriptionIfDifferentFromDefinition, AREMPField, AREMPFieldCorrection, AREMPUnits, AREMPCollectionMethodID, AREMPAnalysisMethodID, 
                                  BLMDescriptionIfDifferentFromDefinition, BLMFieldFromMetadata, BLMField, BLMFieldCorrection,  BLMUnits, BLMCollectionMethodID, BLMAnalysisMethodID,
                                  EPADescriptionIfDifferentFromDefinition, EPA2008Field, EPA2008FieldCorrection, EPA2004Field, EPA2004FieldCorrection, EPAUnits, EPACollectionMethodID, EPAAnalysisMethodID,
                                  PIBODescriptionIfDifferentFromDescription, PIBOField, PIBOFieldCorrection,  PIBOUnits, PIBOCollectionMethodID, PIBOAnalysisMethodID))
                           
# Extract the subset of metrics that are included in the initial controlled vocabulary, not in the initial controlled vocab or the data exchange specifications, and in the data exhcnage specifications 
metrics <- SubsetColumns%>% 
  filter(SubsetOfMetrics== "x" | InDES == 'x')

metrics <- SubsetColumns %>% 
          filter(SubsetOfMetrics =="x")

NotInControlledVocab <- SubsetColumns %>%
        filter(is.na(InDES)) %>%
        filter(is.na(SubsetOfMetrics))


des <- SubsetColumns %>%
    filter(InDES =='x')

#Extract the definitions of the columns included in the subsets metadata. If a name is added to the "cross-walk" variable update the metadata file definitions sheet. 
subsetDefinitions <- definitions %>%
  filter(IncludeInCrosswalk =="x")

#Save the spreadsheets with the definitions 

sheets <- list("ControlledVocabularyAndCrossWalk" = metrics, "Column Definitions" = subsetDefinitions) #assume sheet1 and sheet2 are data frames
write_xlsx(sheets, paste0(wd, "/ControlledVocabularyAndCrossWalk.xlsx"))

sheets <- list("DataExchangeSpecifications" = des, "Column Definitions"= subsetDefinitions)
write_xlsx(sheets, paste0(wd, "/ElementsOfDataExchangeSpecifications.xlsx"))

sheets <- list("MetricsNotInControlledVocabulary" = NotInControlledVocab, "Column Definitions"= subsetDefinitions) 
write_xlsx(sheets, paste0(wd, "/MetricsNotInControlledVocabulary.xlsx"))
