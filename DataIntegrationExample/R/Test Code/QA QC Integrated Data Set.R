#####QA of integrated data set 

library(xlsx)
library(openxlsx)
library(httr)
library(tidyverse)
library(data.table)

#Packages to format table
library(knitr)
library(kableExtra)

# packages for downloading and formatting shapefiles & other GIS Data 
library(downloader)
library(rgdal)
library(RCurl)
library(sf)

#Mapping, graphing and visualizations packages 
library(shiny)
library(leaflet)
library(dplyr)
library(leaflet.extras)
library(DT)
library(ggplot2)
library(cowplot)

#to make half violinplots
source("https://raw.githubusercontent.com/datavizpyr/data/master/half_flat_violinplot.R")

path<-paste0(getwd(), "/data/Integrated Data Set.xlsx")
sheets <- openxlsx::getSheetNames(path)
data_set <- read.xlsx(paste0(getwd(), "/data/Integrated Data Set.xlsx"))
data <- lapply(sheets, openxlsx::read.xlsx, xlsxFile=path)
names(data) <- sheets

for (n in names(data)) { 
  assign(n, data[[n]])
  }

boat <- Event%>% 
      filter(invert_match(str_detect(samplingProtocol,("WADEABLE"))))

wade_ID <- Event %>% 
        filter(str_detect(samplingProtocol,("WADEABLE"))) 
        
  #select("eventID") %>% 
   #     pull( eventID)

wade_results <- Results %>% 
                filter(wade_ID$eventID%in%eventID)

metrics <-  unique(Results$measurementTerm)

library(cowplot)

for (m in metrics) {
   
   to_plot <- Results %>% 
        filter(Results$eventID %in%  wade_ID$eventID ) %>% 
        filter(str_detect(measurementTerm, m)) 
   
   
   
      
                        
    to_plot$measurementDeterminedBy <- as.factor(to_plot$measurementDeterminedBy)
   
   box <- ggplot(to_plot, 
                  aes(x=measurementDeterminedBy, y= DataValue, color= measurementDeterminedBy))+
                  geom_boxplot()+
                  ggtitle(m) +
                  theme(legend.position="none")
     
      scatter <- ggplot(to_plot, 
                        aes(x=measurementDeterminedBy, y= DataValue, color= measurementDeterminedBy))+
                        geom_point()+
                        ggtitle(m) 
      
      histogram <- ggplot(to_plot, 
                          aes(DataValue, color= measurementDeterminedBy))+
                          geom_histogram()+
                          ggtitle(m) +  facet_wrap(~measurementDeterminedBy)
      
      
       theme_set(theme_bw(16))
       violin <- ggplot(to_plot, 
                    aes(measurementDeterminedBy,DataValue, fill=measurementDeterminedBy)) +
                    geom_flat_violin() +
                    theme(legend.position="none")+ggtitle(m) 
       
       
       
       v <- ggplot(to_plot, aes(measurementDeterminedBy,DataValue, fill=measurementDeterminedBy)) +
         geom_flat_violin(position = position_nudge(x = .2, y = 0)) +
         coord_flip()+
         geom_jitter(aes(color = measurementDeterminedBy),
                     width=0.15, alpha = 0.6)+
         theme(legend.position="none")+ ggtitle(m) 
      
       
       v1 <- ggplot(to_plot, aes(measurementDeterminedBy,DataValue, fill=measurementDeterminedBy)) +
         geom_flat_violin(position = position_nudge(x = .2, y = 0)) +
         coord_flip()+
         geom_jitter(aes(color = measurementDeterminedBy),
                     width=0.15, alpha = 0.6)+
         geom_boxplot(aes(x = as.numeric(measurementDeterminedBy)+0.25, y = DataValue),outlier.shape = NA, alpha = 0.3, width = .1, colour = "BLACK") +
         theme(legend.position="none")+ ggtitle(m) 
       
    
        
  # Open a pdf file
     
     filename <- paste0(getwd(), "/plots/",m,".jpeg")
     jpeg(filename)
     print(v1)
     #par(mfrow = c(1,2))
    # print(box)
     #print(scatter)
     #print(histogram)
     #print(violin) 
   
     
   #  print(scatter, position = c(0, 0, 0.5, 1), more = TRUE)
    # print(violin, position = c(0.5, 0, 1, 1))
     
    
     #plot_grid(box, violin)
     # Close the file
     dev.off() 
  
  } 
 

p <- ggplot(measurements, 
            aes(x=DataValue, y= measuremetTerm, color= measurementDeterminedBy))+
              geom_boxplot()+
              facet_grid(~measurmentTerm)
p 


p <- ggplot(measurements, 
            aes(x=measuremetTerm, y=measurementValue , color= measurementDeterminedBy))+
  geom_boxplot()+
  facet_grid(.~measurmentTerm)
p 







metric <- data %>% 
          select("Grad", "Program") 
#ggplot(nvcs_h, aes(nvcs_h[1]))+geom_histogram()+facet_wrap(~Program)
#ggplot(nvcs_h, aes(input$metric))+ geom_point()+facet_wrap(~Program)
qplot(nvcs_h[,1], geom='histogram')+ xlab(names(nvcs_h[1]))

qplot(nvcs_h[,1], geom='histogram')+ xlab(names(nvcs_h[1]))

ggplot(nvcs_h, aes(nvcs_h[1]))+geom_histogram()+facet_wrap(~Program)
