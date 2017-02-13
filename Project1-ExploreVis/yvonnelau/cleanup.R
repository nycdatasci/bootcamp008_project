##############################################
###  Data Science Bootcamp 8               ###
###  Project 1 - Exploratory Visualization ###
###  Yvonne Lau  / January 29, 2017        ###
###     Restaurant Closures from Health    ###
###           Inspections in NYC           ###
##############################################

# This file contains the code used for clearning the dataset for this shiny appp
library(ggplot2)
library(dplyr)
library(scales)
library(lubridate)
library(RColorBrewer) 
library(ggmap)
library(reshape)

# NA Columns:
nacols <- function(x){
  y <- sapply(x, function(xx)any(is.na(xx)))
  names(y[y])
}  
nacols(data)

# Load raw dataset
raw <- read.csv("health_inspection.csv")
data <- raw

# Convert column names to lower case
names(data) <- tolower(names(data))

# Remove rows with negative and NA scores
data <- data[!(is.na(data$score)),]
data <- data %>% filter(score >= 0)

# Change column names to faciliate analysis
data <- data %>%
  rename(restaurant = dba)%>%
  rename(borough = boro)%>%
  rename(cuisine = cuisine.description)%>%
  #Change format of date
  mutate(date = as.Date(inspection.date,"%m/%d/%Y"))%>%
  # Shorten Cuisine Type 
  mutate(cuisine = gsub(pattern = 'Latin \\(Cuban, Dominican, Puerto Rican, South \\& Central American\\)', replacement = 'Latin', x = cuisine, ignore.case = F)) %>%
  mutate(cuisine = gsub(pattern = 'CafÃ©/Coffee/Tea', replacement = 'Cafe/Coffee/Tea', x = cuisine, ignore.case = F))

# Shorten Level names for "action" column
data$action <- factor(data$action)
levels(data$action) = c("closed","reclosed","reopened","no violations","violations")

# Get Letter grade from Score 
data$grade_converted =  cut(data$score, c(0,13,27,131),
                  labels = c('A','B','C'),
                  include.lowest = TRUE)

# Change Borugh information
levels(data$borough) = c("Bronx","Brooklyn","Manhattan","Manhattan","Queens", "Staten Island")

# select columns that will be used for further analysis
data <- data %>%
  select(-dba,-phone,-inspection.date,-grade.date,
         -record.date,-violation.code)

#Add year, month and day
data$year = year(data$date)
data$month = month(data$date)
data$day = day(data$date)

# Save into a RData file
save(data,file = "health_processed.RData")

#------------closure dataset
closure <- data %>%
  filter(action == 'closed' | action == 'reclosed')

closure_n_infractions <- closure %>%
  group_by(camis,date) %>%
  summarise(n_infractions = n())%>%
  arrange(desc(n_infractions))

# Total #number of closures/reclosures over the years
closure_n_closures <- closure_n_infractions %>%
  group_by(camis)%>%
  summarise(n_closures = n())%>%
  arrange(desc(n_closures))

# Join n of infractions
closure_shiny_nogeo = left_join(closure,closure_n_infractions,
                                by= c("camis","date"))
# Join n of closures
closure_shiny_nogeo = left_join(closure_shiny_nogeo,
                                closure_n_closures,by = "camis")

closure_shiny <- closure_shiny_nogeo %>%
  mutate(address = paste(building,street,'NY', zipcode))

#get geocode from DT toolkit
closure_shiny$geo <- geocode(closure_shiny$address, source = "dsk")

# fix address,add geocode 
closure_shiny[719,]$address = "106 STREET & 5 AVENUE NY 10029"
closure_shiny[719,]$geo = geocode(closure_shiny[719,]$address)

# get lon and lat into different columns
closure_shiny$lon <- closure_shiny[[21]][[1]]
closure_shiny$lat <- closure_shiny[[21]][[2]]
closure_shiny <- closure_shiny[-21]

closure_shiny <- closure_shiny %>%
  mutate(address = paste(building,street,'NY', zipcode))

#save closure_shiny object
save(closure_shiny, file = "closure_shiny.RData")

#-------------Overall dataset for tab1(General View)
grade_only <- health %>%
  filter(grade=='A'|grade=='B'|grade=='C')
grade_only$grade <- factor(grade_only$grade)
save(grade_only,file = "grade_only.RData")

#-------------------number of days closed 
#  days stayed closed
# filter data by reopened
# join 
# if closed, still closed
# reopened, compute # days closed

overall_unique <- unique(data[c("camis","date","borough","cuisine","action")])
reopened_unique <- overall_unique %>%
  filter(action == 'reopened')

reopened_unique %>%
  group_by(camis)%>%
  summarise(n=n())%>%
  arrange(desc(n)) %>%
  filter(n==4)

closure_unique%>%
  group_by(camis)%>%
  summarise(n=n())%>%
  arrange(desc(n)) %>%
  filter(n>3) 

# Compute the number of days
overall_unique

# overall_unique ordered by camis and then by restaurant 
test <- overall_unique[order(overall_unique[,1],overall_unique[,2]),]

# find out a list of restaurants that had closure by id
closed_restaurants <- unique(closure_unique$camis)

# filter restaurants that were closed only
overall_unique_closed <- filter(test, camis %in% closed_restaurants)
#excluded reclosed flag
overall_unique_closed_noreclose <- filter(overall_unique_closed, (action == 'closed'|action == 'reopened'))

dates_diff <- overall_unique_closed_noreclose %>%
  group_by(camis)%>%
  mutate(days_diff = date[action=='closed'][1] - date[action=='reopened'][1])

dates_diff$days_diff = dates_diff$days_diff *-1
dates_diff = filter(dates_diff, action == 'closed')
dates_diff <- dates_diff[!(is.na(dates_diff$days_diff)),]
dates_diff <- select(dates_diff,-borough, -cuisine,-action)

#join number of days closed with closure_shiny dataframe
closure_shiny <- left_join(closure_shiny, dates_diff, by=c("camis","date"))
closure_shiny$dates_diff <- as.numeric(as.character(closure_shiny$dates_diff))
closure_shiny <- select(closure_shiny,-days_diff)
closure_shiny <- closure_shiny %>% rename(days_diff = diff)

# select columns needed for shiny 
closure_shiny <- select(closure_shiny,-building,-street,-zipcode,-grade,-inspection.date,-month,-day)

#update closure_shiny
save(closure_shiny, file = "closure_shiny.RData")

# By violation aggregated data
by_violation = closure_shiny %>% group_by(violation.code, violation.description)%>%summarise(n=n())%>%arrange(desc(n))
by_violation$perc = percent(by_violation$n/sum(by_violation$n))

#unique health_processed entries
unique_health <- unique(health_processed[c("camis","date","action","year","borough","cuisine")])
save(unique_health, file='unique_health.RData')

by_borough = unique_health %>%
  group_by(borough)%>%
  summarize(n=n())

by_borou






