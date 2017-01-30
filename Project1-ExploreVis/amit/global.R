library(plyr)
library(dplyr)

library(tidyr)
library(data.table)
######LOAD GDP Data

gdp <- read.csv("data/gdp_per_capita.csv",header= TRUE,skip=4,check.names = F, stringsAsFactors = F)
gdp  <- as.data.frame(gdp)
gdp <- gdp[-62]
gdp <- gdp %>%
  gather(year,gdp,5:61)
gdp <- gdp[c(-3,-4)]


###LOAD POPULATION DATA 

population <- read.csv("data/total_population.csv",header= TRUE,skip=4,check.names = F, stringsAsFactors = F)
population  <- as.data.frame(population)
population <- population[-62]
population <- population %>%
  gather(year,population,5:61)
population <- population[c(-3,-4)]


###LOAD EMPLOYMENT DATA 

empl <- read.csv("data/employment to population ratio.csv",header= TRUE,skip=4,check.names = F, stringsAsFactors = F)
empl  <- as.data.frame(empl)
empl <- empl[-62]
empl <- empl %>%
  gather(year,empl,5:61)
empl <- empl[c(-3,-4)]
empl <- empl[complete.cases(empl),]


####JOIN THE TABLES TO CREATE ONE TABLE

empl <- join(empl,gdp,by=c('Country Name','Country Code','year'))
empl <- join(empl,population, by=c('Country Name','Country Code','year'))

###Rename Col Names

colnames(empl)[1] <- "country"
colnames(empl)[2] <- "code"

### Load country and region file

country_region<- read.csv("data/country_region.csv",header= TRUE,check.names = F, stringsAsFactors = F)
empl <- join(empl,country_region, by='country')
empl$year<- as.numeric(empl$year)
empl <- empl[complete.cases(empl[,"region"]),]


### Load temperature data from Keggle

temp_raw<- fread('data/GlobalLandTemperaturesByCountry.csv')
temp_raw$dt <-substr(temp_raw$dt,1,4)
names(temp_raw)[names(temp_raw) == 'dt'] <- 'year'
names(temp_raw)[names(temp_raw) == 'Country'] <- 'country'
temp_raw$year <- factor(temp_raw$year)
temp_raw$country <- factor(temp_raw$country)
temp_agg <- temp_raw %>%
  group_by(country,year)%>%
  summarise(avg_temp=mean(AverageTemperature))
temp_agg$country = as.character(temp_agg$country)
temp_agg$year = as.numeric(as.character(temp_agg$year))
empl<-left_join(empl, temp_agg, by=c('country','year'))


###Load CO2 emissions data 


?fread
co2 <- fread('data/co2_emissions.csv',header= TRUE,check.names = F, stringsAsFactors = F, na.string=c("","NA"))
colnames(co2)[1] <- "country"
colnames(co2)[2] <- "code"
co2 <- co2[co2$`Indicator Name`=='CO2 emissions (kt)',]
co2  <- as.data.frame(co2)
co2 <- co2[-62]
co2 <- co2 %>%
  gather(year,co2,5:61)
co2 <- co2[c(-3,-4)]
co2$year <- as.numeric(co2$year)
empl<-left_join(empl, co2, by=c('country','year'))
empl <- empl[-9]
names(empl)[2]<- 'code'
names(empl)[2]
empl$co2 <- as.numeric(empl$co2)
str(empl)

##empl <- empl[-4]

empl.regions <- unique(empl$region)
empl.country <- unique(empl$country)

cor.options <- c("pie","circle","ellipse","number")