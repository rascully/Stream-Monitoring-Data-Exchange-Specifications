

dataMapVariable <- function(DES_field, Program) {

library(tidyverse)
  

  Crosswalk_tall <-  read.csv("DataExchangeStandardTables/DataMappingDES.csv")

  variable <- Crosswalk_tall %>% 
    filter(term == DES_field & projectCode == Program) %>%  
    dplyr::select(originalField)   %>% 
    unlist(use.names = F) %>% 
    unique() %>% trimws()

return(variable)

} 