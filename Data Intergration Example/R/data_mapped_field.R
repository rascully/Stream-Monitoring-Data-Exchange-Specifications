

dataMapVariable <- function(DES_field, Program) {

library(tidyverse)
  
  
  #Download the data mapping from the data exchange specifications Git page. 
  #github_link <- "https://raw.githubusercontent.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/master/Data%20Exchange%20Standard%20Tables/DataMapping.csv"
  
  #temp_file <- tempfile(fileext = ".csv")
  #req <- GET(github_link, 
             # authenticate using GITHUB_PAT
  #           authenticate(Sys.getenv("GITHUB_PAT"), ""),
             # write result to disk
  #           write_disk(path = temp_file))
  
  #Crosswalk_tall <- read.csv(temp_file)
  #rm(temp_file)
  Crosswalk_tall <-  read.csv("Data Exchange Standard Tables/DataMapping.csv")

  variable <- Crosswalk_tall %>% 
    filter(term == DES_field & projectCode == Program) %>%  
    dplyr::select(originalField)   %>% 
    unlist(use.names = F) %>% 
    unique() %>% trimws()

return(variable)

} 