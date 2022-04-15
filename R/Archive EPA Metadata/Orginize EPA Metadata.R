# Code to pull the EPA metadata from https://www.epa.gov/national-aquatic-resource-surveys/data-national-aquatic-resource-surveys and put it in a spreadsheet 


install.packages("xlsx")

# Store base url (note the secure -- https:// -- url)
# URL for the rivers and streams https://www.epa.gov/sites/production/files/2015-09/phabmed.txt
# URL for the benthic macroinvertebrate data  https://www.epa.gov/sites/production/files/2015-09/bentcond.txt
# URL for benthic taxa https://www.epa.gov/sites/production/files/2016-06/nrsa_0809_benttaxa.txt
# URL for extbenthicref https://www.epa.gov/sites/production/files/2015-09/extbenthicrefcond.txt
# URL for extnrsabentcts https://www.epa.gov/sites/production/files/2015-09/extnrsabentcts.txt
# URL for https://www.epa.gov/sites/production/files/2016-11/nrsa0809bentctsmet.txt



file_url <-  "https://www.epa.gov/sites/production/files/2016-11/nrsa0809bentctsmet.txt"

# import the data!
EPA_Metadata <-  read.csv(file_url, sep="\t")
head(EPA_Metadata)

#write the data to a .csv file C:\Users\rscully\Documents\Projects\Habitat Data Sharing\2019 Work\Data\EPA
write.csv(EPA_Metadata, file = "C:/Users/rscully/Documents/Projects/Habitat Data Sharing/2019 Work/Data/EPA/nrsa0809bentctsmet.csv", col.names = TRUE)
