library(tidyverse)

data <- read.csv(paste0(getwd(), "/Data Intergration Example/data/Analysis Stream Habitat Monitoring Metric Dataset.csv")) 

count <- data %>% count(projectCode)

x <- data %>%
  group_by(projectCode) %>% 
  select(LWDVol) %>%  # replace to your needs
  summarise_all(funs(sum(is.na(.)))) 
x$projectCount <- count$n

print(x)
