library(maptools)
library(rgdal)
library(leaflet)

#Make available census tract shapes, school test data, and income data for census.

tract.longlat <- spTransform(readOGR("./nyct2010_16d", "nyct2010"), CRS("+proj=longlat +datum=WGS84"))
copy_longlat<-tract.longlat


address.test<-read.csv("address_test.csv", stringsAsFactors=F)
address.test$X<-as.character(address.test$X)
census.vital<-read.csv("census_vital.csv", stringsAsFactors=F)

pal <- colorNumeric(palette = "RdYlGn", domain = address.test$Proficient.ELA)
pal2<- colorNumeric(palette = "Greys", domain = census.vital$Median.Household.Income)
