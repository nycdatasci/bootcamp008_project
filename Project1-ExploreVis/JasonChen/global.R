###################DATA MANIPULATION######################
library(data.table)
library(dplyr)
library(tidyr)
library(chron)
library(reshape2)
###################GGPLOT2 LIBRARY########################
library(ggplot2)
library(ggthemes)
library(RColorBrewer)
###################LEAFLET LIBRARY########################
library(leaflet)
library(leaflet.extras)
####################SHINY#################################
library(shinydashboard)
library(shinyTime)
library(DT)


countvehicles <- function(row){return(sum(row != ''))}

nyc.collisions <- fread('https://data.cityofnewyork.us/api/views/h9gi-nx95/rows.csv', 
                        stringsAsFactors = F)%>%tbl_df()
setnames(nyc.collisions, make.names(colnames(nyc.collisions)))

nyc.collisions<- filter(nyc.collisions, 
                        !is.na(LATITUDE + LONGITUDE + ZIP.CODE))
nyc.collisions$DATE <- as.Date(nyc.collisions$DATE, '%m/%d/%Y')
nyc.collisions <- mutate(nyc.collisions, year = year(DATE))
nyc.collisions$year <- as.factor(nyc.collisions$year)
nyc.collisions$ZIP.CODE <- as.character(nyc.collisions$ZIP.CODE)
nyc.collisions <- filter(nyc.collisions, year != 2012 & year !=2017)
nyc.collisions$TIME <- apply(t(nyc.collisions$TIME), 2, function(x){paste0(x, ':00')})

nyc.collisions$TIME <- times(nyc.collisions$TIME)
nyc.collisions$no.of.cars <- apply(select(nyc.collisions, c(25:29)),
                                   1,countvehicles)
nyc.collisions <- nyc.collisions%>%
  mutate(weekday = weekdays(as.Date(DATE, '%m/%d/%y')))

collisions.weekday<-summarise(group_by(nyc.collisions, weekday, year, BOROUGH), count = n())
collisions.weekday$weekday <- factor(collisions.weekday$weekday,
                                     levels = c("Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"))

zip <- fread('zip.csv')
zip <- separate(zip, 'ZIP Codes', into=c('a','b','c','d','e','f','g','h','i'), sep = ',')%>%
  gather(key = 'col', value = 'ZIP.CODE', 3:11)%>%
  na.omit()%>%
  arrange(Neighborhood)%>%select(ZIP.CODE, Neighborhood)

nyc.collisions <- left_join(nyc.collisions, zip, by='ZIP.CODE')

inj.ratio <- group_by(nyc.collisions, VEHICLE.TYPE.CODE.1)%>%
  summarise(total.deaths = sum(NUMBER.OF.PERSONS.KILLED),
            total.injuries = sum(NUMBER.OF.PERSONS.INJURED),
            total.accidents = n())%>%
  mutate(ratio = (total.injuries + total.deaths)/total.accidents)%>%
  arrange(desc(ratio))%>%
  filter(VEHICLE.TYPE.CODE.1 != '', VEHICLE.TYPE.CODE.1 != 'UNKNOWN')



  motorcycles <- filter(nyc.collisions, VEHICLE.TYPE.CODE.1 == 'MOTORCYCLE')
motorcycle.cause <- group_by(motorcycles, CONTRIBUTING.FACTOR.VEHICLE.1)%>%
  summarise(total.deaths = sum(NUMBER.OF.PERSONS.KILLED),
            total.injuries = sum(NUMBER.OF.PERSONS.INJURED),
            total.accidents = n())%>%
  mutate(ratio = (total.injuries + total.deaths)/total.accidents)%>%
  arrange(desc(ratio))%>%
  filter(CONTRIBUTING.FACTOR.VEHICLE.1 != '', CONTRIBUTING.FACTOR.VEHICLE.1 != 'Unspecified')

summary(motorcycle.cause)
  
collisions.hurt <- nyc.collisions%>%
  filter(NUMBER.OF.PERSONS.KILLED != 0 | NUMBER.OF.PERSONS.INJURED !=0)
collisions.safe <- nyc.collisions%>%
  filter(NUMBER.OF.PERSONS.KILLED == 0 | NUMBER.OF.CYCLIST.INJURED ==0)


collisions.killed <- nyc.collisions%>%
  filter(NUMBER.OF.PERSONS.KILLED != 0)%>%
  mutate(color = ifelse(NUMBER.OF.PEDESTRIANS.KILLED != 0, 'red', 
                        ifelse(NUMBER.OF.CYCLIST.KILLED !=0, 'green', 'blue')))

grouped <- group_by(nyc.collisions,year,BOROUGH)%>%
  summarise( 
    injured = sum(NUMBER.OF.PERSONS.INJURED), 
    killed = sum(NUMBER.OF.PERSONS.KILLED),
    none = sum(NUMBER.OF.PERSONS.INJURED ==0 & 
                 NUMBER.OF.PERSONS.KILLED ==0),
    count = n()
  )

grouped1 <- group_by(collisions.hurt,year,BOROUGH)%>%
  summarise(
    injured = sum(NUMBER.OF.PERSONS.INJURED), 
    killed = sum(NUMBER.OF.PERSONS.KILLED),
    none = sum(NUMBER.OF.PERSONS.INJURED ==0 & 
                 NUMBER.OF.PERSONS.KILLED ==0),
    count = n()
  )

#####################################TEST######################################

# 
# grouped2 <- group_by(collisions.safe, year, BOROUGH)%>%
#   summarise(count = n())
# 
# group_by(nyc.collisions, year)%>%summarise(count= n())%>%View()
# 
# group_by(filter(nyc.collisions,CONTRIBUTING.FACTOR.VEHICLE.1 != 'Unspecified'), 
#          year, CONTRIBUTING.FACTOR.VEHICLE.1)%>%
#   summarise(count = n())%>%mutate(ratio = count/n())%>%
#   arrange(desc(ratio))%>%head(n=20)%>%
#   ggplot(aes(x=year, y=ratio)) +
#   geom_line(aes(group = CONTRIBUTING.FACTOR.VEHICLE.1, color = CONTRIBUTING.FACTOR.VEHICLE.1)) +
#   # facet_grid(~ year)+
#   # scale_x_discrete(label=abbreviate) +
#   theme_classic()
# 
# group_by(filter(nyc.collisions, VEHICLE.TYPE.CODE.1 != 'OTHER',
#                 VEHICLE.TYPE.CODE.1 != 'UNKNOWN'), year, VEHICLE.TYPE.CODE.1)%>%
#   summarise(count = n())%>%mutate(ratio = count/n())%>%
#   arrange(desc(ratio))%>%head(n=20)%>%
#   ggplot(aes(x=year, y=ratio)) +
#   geom_line(aes(group = VEHICLE.TYPE.CODE.1, color = VEHICLE.TYPE.CODE.1)) + 
#   #facet_grid(~ VEHICLE.TYPE.CODE.1)+
#   # scale_x_discrete(label=abbreviate) +
#   theme_classic()
