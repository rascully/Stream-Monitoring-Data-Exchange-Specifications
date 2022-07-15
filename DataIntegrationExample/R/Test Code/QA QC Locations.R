##############################################################################
# Libraries
##############################################################################
library(shiny)
library(shinythemes)
library(ggplot2)
library(plotly)
library(leaflet)
library(DT)
library(tidyverse)
##############################################################################
# Data
##############################################################################
wd <- "C:/Users/rscully/Documents/Projects/Habitat Data Sharing/2019_2020/Code/Stream-Monitoring-Data-Exchange-Specifications"

loc <- read.csv(paste0(wd, "/Data Intergration Example/data/csv/Location.csv")) 

pal <- colorFactor(palette=c("green","red","blue", "yellow"), domain=c(1, 2, 3, 4))
x <-duplicated(loc$verbatimD)       


dup <- loc %>% group_by(locationID) %>% filter(n()>1) %>% summarize(n=n())

dup_loc <- loc %>% 
  filter(locationID %in% dup$locationID)  %>%  
  arrange(locationID)

dup_loc$id <- seq.int(nrow(dup_loc))
data <- dup_loc
#str(qDat)
##############################################################################
# UI Side
##############################################################################
library(shiny)
library(leaflet)
library(DT)

ui <- fluidPage(
  mainPanel(
    leafletOutput("Map"),
    dataTableOutput("Table")
  )
)
##############################################################################
# Server Side
library(shiny)
library(leaflet)
library(DT)
library(htmltools)

server<- function(input, output) {
  
  observeEvent(input$Map_marker_click, {
    clickId <- input$Map_marker_click$id
    dataTableProxy("Table") %>%
      selectRows(which(data$ref == clickId)) %>%
      selectPage(which(input$Table_rows_all == clickId) %/% 10 + 1)
  })
  
  output$Table <- renderDataTable({
    DT::datatable(data, selection = "single",options=list(stateSave = TRUE))
  })
  
  observeEvent(input$Map_marker_click, {
    clickId <- input$Map_marker_click$id
    dataTableProxy("Table") %>%
      selectRows(which(data$ref == clickId)) %>%
      selectPage(which(input$Table_rows_all == clickId) %/% input$Table_state$length + 1)
  })
  
  TableProxy <-  dataTableProxy("Table")
  
  output$Map <- renderLeaflet({
    data_map <- leaflet(data) %>%
      addProviderTiles(providers$Thunderforest.Outdoors,
                       options = tileOptions(apikey = 'a9d0362ca8e5483a98c4653356dd7661'),
                       group = "Topography") %>%
      addCircleMarkers(
        lng=~longitude,
        lat=~latitude,
        layerId = ~id,
        radius = 4,
        color = "purple",
        stroke = FALSE,
        fillOpacity = 0.5, 
        label = ~htmlEscape(verbatimD)
      )
    data_map
  })
  
  observeEvent(input$Map_marker_click, {
    clickId <- input$Map_marker_click$id
    dataId <- which(data$ref == clickId)
    TableProxy %>%
      selectRows(dataId) %>%
      selectPage(dataId %/% 10 + 1)
  })
}

##############################################################################
shinyApp(ui = ui, server = server)
##############################################################################