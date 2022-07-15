#####Example for GIS
library(tidyverse)
library(stringr)
library(leaflet)
library(ggplot2)
library(knitr)

filenames <- list.files(paste0(getwd(), "/Data Intergration Example/data/csv/"),pattern = ".csv", all.files=TRUE, full.names=TRUE)

for (fName in filenames) {
  x <- str_remove(fName, 
             pattern = ("C:/Users/rscully/Documents/Projects/Habitat Data Sharing/2019_2020/Code/Stream-Monitoring-Data-Exchange-Specifications/Data Intergration Example/data/csv/"))
  y <- str_remove(x, pattern = ".csv")
  
  assign(y,read.csv(fName) )
 
}

t <- count(GISVariables, Value)

state <- "Oregon"

stateFilter <- GISVariables %>% 
      filter(Value == state) %>% 
      dplyr::select(locationID)

stateFilter <- GISVariables %>% 
  filter(Value == state) %>% 
  dplyr::select(locationID, Value)

colnames(stateFilter)[2] <- 'StateName'


GISindex <- GISVariables %>%  
              filter(locationID %in% stateFilter$locationID) %>% 
              filter(Variable == "Wildland Fire") 
               

pal = colorFactor(c("green","yellow","red", "blue", "orange"), domain = (unique(GISindex$Value)))

m <- leaflet(GISindex) %>% 
  addTiles() %>% 
  addCircleMarkers(color = pal(GISindex$Value)) %>% 
  addLegend("topright", pal=pal, values= ~Value, opacity =1)

m  

m <- leaflet(GISindex) %>% 
  addTiles() %>% 
  addCircleMarkers(color = pal(GISindex$projectCode)) %>% 
  addLegend("topright", pal=pal, values= ~projectCode, opacity =1)

m  



#filter(Variable == "Wildland Fire") 


GISindex <- GISVariables %>%  
  filter(locationID %in% stateFilter$locationID) %>% 
  filter(Variable == "Wildland Fire") %>% 
  dplyr::select(c(locationID, Value))

w <- left_join(stateFilter, GISindex)





GISlocations<- Location %>% 
              filter(locationID %in% GISindex$locationID)


GISDataset <- RecordLevel %>% 
              filter(datasetID %in% unique(GISlocations$datasetID))


GISEvents <- Event %>% 
            filter(locationID %in% GISindex$locationID)

GISmeasurementsOrFact <- MeasurmentOrFact %>% 
                      filter(eventID %in% GISEvents$eventID)

wideMetrics <- GISmeasurementsOrFact %>% 
          dplyr:: select(-c(measurementTypeID, measurementID)) %>% 
          pivot_wider(names_from = measurementType, values_from = measurementValue )


dataWide <- right_join(GISDataset, GISlocations, join_by = datasetID)

dataWide = dataWide %>% 
          dplyr::select(-verbatimD)

dataWide <- left_join(dataWide, GISEvents, join_by = locationID )

dataWide <- left_join(dataWide, wideMetrics, join_by = eventID)

dataWide = dataWide %>% 
  dplyr::select(-verbatimD)

dataWide <- left_join(dataWide, GISindex, join_by =locaitonID)

write.csv(dataWide, paste0(getwd(), "/Data Intergration Example/R/Test Code/test.csv"))

count(dataWide$projectCode)

plot(dataWide$RPD, dataWide$Grad)

ggplot(GISindex, aes(x= Value)) + geom_bar()+ ggtitle(state)+theme_bw()

kable(
  dataWide %>% 
    group_by(Value) %>% 
    summarize(
      mean = mean(PctFines6),
      count = n())
)




ggplot(dataWide, aes(x=Value, y=PctFines6)) + 
                geom_boxplot(color = "black")+
                theme_bw()+ggtitle(paste (state, "PctFines6 by Fire Catagory"))+
                stat_summary()
  
pal = colorFactor(c("green","yellow","red", "blue"), domain = (unique(dataWide$projectCode)))

m <- leaflet(dataWide) %>% 
  addTiles() %>% 
  addCircleMarkers(color = pal(dataWide$projectCode)) %>% 
  addLegend("topright", pal=pal, values= ~projectCode, opacity =1)

m  

