
metric_information <-function(metric_name) {
  
  #install.packages("jsonlite")
  #install.package("openxlsx")
  library(jsonlite)
  #library(openxlsx)
  #library(tidyverse)
  
  wd <-getwd()
    #"C:/Users/rscully/Documents/Projects/Habitat Data Sharing/2019_2020/Code/tributary-habitat-data-sharing-/"
  file<- paste0(wd,"/Data/Metadata.xlsx")
  metadata <-as_tibble(read.xlsx(file, 3)) #read in the metadata 
 
  metric_index<- filter(metadata, Field==metric_name)
  mr_index <- data.frame(select(metric_index, contains('ShortName')), select(metric_index, contains('CollectionMethod')))

  # add a row to put the text into 
  mr_index <- add_row(mr_index)
  mr_index <- add_row(mr_index)
  

  i =0 #reset the index 
  for(i in 1:length(mr_index)){
          id= mr_index[1,i]
          if(!is.na(id)){ 
               print(id)
                mr_method    <- paste0("https://www.monitoringresources.org/api/v1/methods/", id) 
                mr_method    <- URLencode(mr_method)
                method_text  <- fromJSON(mr_method) 
                instruction  <-  method_text$instructions
                if (!is.null(instruction)){
                  mr_index[2,i]   <- method_text$citation$title
                  mr_index[3,i]   <-  method_text$instructions
                } 
          }
  }
  
return(mr_index)
} 


