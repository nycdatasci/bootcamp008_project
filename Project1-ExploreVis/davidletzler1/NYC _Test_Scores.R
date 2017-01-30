#Step 1--Produce dataframe of NYC official census tracts and median income data

#Downloaded csv of Median Income for all NYS urban census tracts from census.gov
#Deleted redundant top row of initial .csv in Excel.
setwd("C:/users/david/documents/nycdsa/Project 1")
census.nys<-read.csv("census/NYS_urban_2010.csv")
#Select only NYC counties from the table and select only relevant data
boroughs<-c("Bronx County", "Queens County", "New York County", "Kings County", "Richmond County")
borough.census<-unlist(sapply(boroughs, grep, census.nys$Geography))
census.nyc<-census.nys[borough.census,c(2,3,4,6)]
names(census.nyc)[c(3,4)]<-c("Total.Households", "Median.Household.Income")


#Step 2--Produce dataframe of school addresses
library(foreign)
library(ggmap)
getGeoDetails <- function(address){   
  #H/T Shane Lynn, "Batch Coding with R and Google Maps", for providing a function to call and import long/lat coordinates from
  #the Google Maps API, adapted for my own needs here.
  geo_reply = geocode(address, output='all', messaging=TRUE, override_limit=TRUE)
  answer <- data.frame(lat=NA, long=NA, formatted_address=NA)
  answer$lat <- geo_reply$results[[1]]$geometry$location$lat
  answer$long <- geo_reply$results[[1]]$geometry$location$lng   
  answer$formatted_address <- geo_reply$results[[1]]$formatted_address
  
  return(answer)
}

#Import database file of school addreses.
school.address<-read.dbf("Public_Schools.dbf", as.is=T)
#Convert addresses to Boolean-search format to submit to GoogleMaps
address.url<-rep(0, times=nrow(school.address))
street<-rep(0, times=nrow(school.address))
for (i in 1:nrow(school.address)){
  street<-(paste0(unlist(strsplit(school.address$ADDRESS[i], split=" ")), collapse="+"))
  address.url[i]<-paste(street, school.address$City[i], "NY", school.address$ZIP[i], sep="+")
}
#Mass request of 1709 address coordinates: ~30 minutes
address.longlat<-lapply(address.url, getGeoDetails)
#Combine results into school addresses and winnow down to relevant data.
address.longlat<-do.call(rbind, address.longlat)
address.df<-cbind(address.longlat, school.address[,c(1,5,6)])
names(address.df)[c(5,6)]<-c("School.Name", "School.Type")

#Step 3--Get shape files for NYC census tracts 
library(ggplot2)
library(maptools)
library(rgdal)
setwd("C:/users/david/documents/nycdsa/Project 1/nyct2010_16d")
#Read ARCGIS file into R and convert coordinates from ARCGIS to standard long/lat.
census.arc<-readOGR(".", "nyct2010")
tract.longlat <- spTransform(census.arc, CRS("+proj=longlat +datum=WGS84"))


#Step 4--Unite US Census and geographic data
library(dplyr)
#Take shapefile's inner dataframe and add census tract column to match census-income file, then merge.
nyc.coord<-as.data.frame(tract.longlat)
levels(nyc.coord$BoroName)<-c("Bronx County", "Kings County", "New York County", "Queens County", "Richmond County")
nyc.coord$Geography<-paste0("Census Tract ", nyc.coord$CTLabel, ", ", nyc.coord$BoroName, ", New York")
census.united<-left_join(nyc.coord, census.nyc, by="Geography")
#Insert new dataframe back into shapefile
tract.longlat@data<-census.united

#Step 5--Link schools to census tracts
#Convert dataframe to sp-compatible object and align coordinate systems
coordinates(address.df) <- ~ long + lat
proj4string(address.df) <- proj4string(tract.longlat)
#Determine which census tract each school lies within: ~10 minutes
for (i in 1:nrow(address.df)){
  address.df$Geography[i]<-over(address.df[i,], tract.longlat)[[12]]
}
#Convert back to dataframe from sp object
address.df<-as.data.frame(address.df)
#Clean census income data and create income buckets
census.united$Median.Household.Income[is.na(census.united$Median.Household.Income)]<-0
census.united$Median.Household.Income<-as.numeric(census.united$Median.Household.Income)
quintile<-quantile(census.united$Median.Household.Income, na.rm=T, probs=seq(0,1,0.2))
census.united$Income.Bucket<-cut(census.united$Median.Household.Income, include.lowest=T, quintile, label=c("Lowest Quintile", "Second-Lowest Quintile", "Middle Quintile", "Second-Highest Quintile", "Highest Quintile"))
#Narrow to relevant data and create Shiny-callable file
census.vital<-census.united[,c(12,15, 16)]
write.csv(census.vital, "census_vital.csv")


#Step 6--Import test data
ela.total<-read.csv("ELA_Total.csv", stringsAsFactors = F)
math.total<-read.csv("Math_Total.csv", stringsAsFactors=F)
#Change column name for future merge
names(ela.total)[1]<-"ATS_CODE"
names(math.total)[1]<-"ATS_CODE"
#Merge test data, narrow to relevant data, and clean
test.total<-full_join(ela.total, math.total, by= c(names(ela.total)[1], "Grade", "Year"))
test.total<-test.total[,c(1:4, 17, 31)]
test.total$Proficient.Percent[test.total$Proficient.Percent=='s']<-NA
test.total$Percent.Proficient[test.total$Percent.Proficient=='s']<-NA
test.total[,5]<-as.numeric(test.total[,5])
test.total[,6]<-as.numeric(test.total[,6])
#Prepare merger of test data and school address data
address.df$ATS_CODE<-gsub("[[:space:]]", "", address.df$ATS_CODE)
address.test<-inner_join(address.df, test.total, by="ATS_CODE")
address.test<-address.test[,-c(3,4,8)]
names(address.test)[c(8,9)]<-c("Proficient.ELA", "Proficient.Math")
school.complete<-left_join(address.test, census.vital, by="Geography")
#Add color data, to save Shiny from having to do it every time
library(leaflet)
pal <- colorNumeric(palette = "RdYlGn", domain = address.test$Proficient.ELA)
school.complete$MathColor<-pal(address.test$Proficient.Math)
school.complete$ELAColor<-pal(address.test$Proficient.ELA)
#Prepare final, Shiny-callable file
write.csv(school.complete, "address_test.csv")


#Step 7--Create map
#This is a base map to chart math scores in all schools/tracts.
library(leaflet)
nyc <- leaflet() %>%  addTiles() %>% setView(lng=-74, lat=40.7, zoom=11)
copy_longlat<-tract.longlat
copy_longlat@polygons<-tract.longlat@polygons
nyc.census<- nyc %>% addPolygons(data=copy_longlat, weight=1, layerId=1:length(copy_longlat@polygons))
nyc.test<- nyc.census %>% 
  addCircleMarkers(lng=address.test$long, lat=address.test$lat, opacity=1, color = address.test$MathColor, radius= 3, popup=paste(sep="<br/>", address.test$School.Name, paste(address.test$Proficient.Math, "% Proficient"))) %>%
  addLegend("bottomright", pal = pal, values = address.test$Proficient.ELA, title = "Percent Proficient (2016)")

#Step 8--Additional analysis

#Perform correlation test between test scores/income
address.cor<-filter(address.test, Grade=="All Grades")
cor.test(address.cor$Proficient.Math, address.cor$Median.Household.Income) #0.473
cor.test(address.cor$Proficient.ELA, address.cor$Median.Household.Income) #0.514

#Examine year-to-year test proficiency level
math.total$X..8[math.total$X..8=="s"]<-NA
math.total$X..8<-as.numeric(math.total$X..8)
math.year<-filter(math.total, Grade=="All Grades")
math.year %>% group_by(Year) %>% summarize(Total.Proficient=sum(X..8, na.rm=T)/sum(Number.Tested, na.rm=T)) 
# 1  2013        0.3099477
#2  2014        0.3558831
#3  2015        0.3642421
#4  2016        0.3764723

ela.total$Proficiet.Total[ela.total$Proficiet.Total=="s"]<-NA
ela.total$Proficiet.Total<-as.numeric(ela.total$Proficiet.Total)
ela.year<-filter(ela.total, Grade=="All Grades")
ela.year %>% group_by(Year) %>% summarize(Total.Proficient=sum(Proficiet.Total, na.rm=T)/sum(Number.Tested, na.rm=T))

#1  2013        0.2763665
#2  2014        0.2958861
#3  2015        0.3149984
#4  2016        0.3933296

#Examine grade-by-grade proficiency
math.total %>% group_by(Grade) %>% summarize(Total.Proficient=sum(X..8, na.rm=T)/sum(Number.Tested, na.rm=T))
#3        0.3863118
#4        0.4005786
#5        0.3791962
#6        0.3493421
#7        0.3159851
#8        0.2561857
#All Grades        0.3511844

ela.total %>% group_by(Grade) %>% summarize(Total.Proficient=sum(Proficiet.Total, na.rm=T)/sum(Number.Tested, na.rm=T))
#         3        0.3307813
#         4        0.3375183
#         5        0.3139323
#         6        0.2942713
#         7        0.3039613
#         8        0.3363706
# All Grades        0.3198468

#Examine year/grade proficiency for longitudinal analysis
math.mix<-filter(math.total, Grade!="All Grades")
ela.mix<-filter(ela.total, Grade!="All Grades")
math.year.grade<-math.mix %>% group_by(Grade, Year) %>% summarize(Total.Proficient=sum(X..8, na.rm=T)/sum(Number.Tested, na.rm=T))
ela.year.grade<-ela.mix %>% group_by(Grade, Year) %>% summarize(Total.Proficient=sum(Proficiet.Total, na.rm=T)/sum(Number.Tested, na.rm=T))