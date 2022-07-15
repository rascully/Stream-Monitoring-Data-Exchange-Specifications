##### Create map of 

#library(leaflet)
library(tidyverse)
library(dplyr)
library(spData)
library(sf)

getwd()
source(paste0(getwd(), "/Data Intergration Example/R/Combine Data.R")) 
data <-integrate_data()

Locations <- data$Location


 
point  <- Locations %>% 
  filter(datasetID == 1) %>%  
  dplyr::select(any_of(c("longitude", "latitude")))

library(usmap)
library(ggplot2)

plot_usmap(data = point, values = "pop_2015", color = "red") + 
  scale_fill_continuous(
    low = "white", high = "red", name = "Population (2015)", label = scales::comma
  ) + theme(legend.position = "right")
