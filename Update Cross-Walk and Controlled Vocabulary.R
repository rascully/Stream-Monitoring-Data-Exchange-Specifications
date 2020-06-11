#Need to design a workflow to link the master metadata file to the individual files or figure out a way to update each file. 
install.packages('tidyverse')
library(tidyverse)

install.packages("readr")
library(readr)

#load the metadata file from the GitRepository library
urlfile= "https://raw.githubusercontent.com/rascully/Stream-Monitoring-Data-Exchange-Specifications/master/Metadata_test.csv"


metadata <- read_csv(url(urlfile))