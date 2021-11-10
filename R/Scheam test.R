#Create XML of the scheam 


library(tidyverse)
library(stringr)
library(openxlsx)
library(httr)

####Open data exchange specifications#####
es <- paste0(getwd(), "/Tables/Stream_Habitat_ExchangeSpecifications.xlsx") 
sheets <- openxlsx::getSheetNames(es)
data <- lapply(sheets,openxlsx::read.xlsx,xlsxFile=es) 
names(data) <- sheets

for (n in sheets) { 
  assign(n, data[[n]])
}

github_link<- "https://raw.githubusercontent.com/tdwg/dwc/master/build/event_core_list.csv"

temp_file <- tempfile(fileext = ".csv")
req <- GET(github_link, 
           # authenticate using GITHUB_PAT
           authenticate(Sys.getenv("GITHUB_PAT"), ""),
           # write result to disk
           write_disk(path = temp_file))

dwc <- read.csv(temp_file)
unlink(temp_file)

term <-read_html("http://rs.tdwg.org/dwc/terms/year")

t2 <- read.

content(term)
