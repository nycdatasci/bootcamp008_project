# global.R

## PACKAGES
# UI
library(shinydashboard)

# Data wrangling
library(dplyr)
library(zoo)

# Date wrangling
library(lubridate)

# Maps
library(leaflet)

# Plots
library(googleVis)
library(ggplot2)
library(RColorBrewer)

source('helpers.R')

stations = readRDS('data/2015_station_data-v2.rds')
trips = readRDS('data/2015_trip_data.rds')
weather = readRDS('data/2015_weather_data.rds')
zip2City = read.csv('data/zip2city.csv', stringsAsFactors = F)

# Clean up data, names
# station_data.csv has loads of empty lines after the final entry
# sum(is.na(stations))
stations = filter(stations, station_id > 0)
# colnames(stations)
#
# sum(is.na(trips))
# colnames(trips)
trips = rename(
  trips,
  Bike.No = Bike..,
  Start.Date.src = Start.Date,
  End.Date.src = End.Date
)

# sum(is.na(weather))
# When there's no event, e.g. rain or fog, than that field's NA
# colnames(weather[, colSums(is.na(weather)) > 0])

# There are some missing temperature values that need to be taken care of
weatherZoo = zoo(select(weather, ZIP, Date, Mean.TemperatureF, Mean.TemperatureC, CloudCover))
# sum(is.na(weatherZoo))
weatherZoo=na.locf(weatherZoo)
# sum(is.na(weatherZoo))

weatherZoo =
  mutate(
    as.data.frame(weatherZoo),
    ZIP = as.numeric(as.character(ZIP)),
    Date = as.Date(Date),
    Mean.TemperatureF = as.numeric(as.character(Mean.TemperatureF)),
    Mean.TemperatureC = as.numeric(as.character(Mean.TemperatureC)),
    CloudCover = as.numeric(as.character(CloudCover))
  )

weatherZoo = left_join(
  weatherZoo,
  select(
    weather,
    ZIP,
    Date,
    Day,
    Month,
    Year,
    WDay,
    Week,
    Quarter,
    Events
  ),
  by=c('ZIP', 'Date')
)

# Add landmark ZIPs to stations
stations = left_join(stations, zip2City, by=(c('landmark' = 'city')))

# Create actual timestamps from Start.Date, End.Date for date arithmetics
# Class "POSIXct" represents the (signed) number of seconds since the beginning
# of 1970 (in the UTC time zone) as a numeric vector.
tz = 'America/Los_Angeles'
dtStartFormat = '%Y-%m-%d %H:%M'
dtEndFormat = '%m/%d/%Y %H:%M'

trips = trips %>%
  mutate(
    Start.Date = as.POSIXct(strptime(Start.Date.src, tz = tz, format = dtStartFormat)),

    Start.Date.Day = day(Start.Date),
    Start.Date.Month = month(Start.Date),
    Start.Date.Year = year(Start.Date),

    Start.Date.Date = make_date(Start.Date.Year, Start.Date.Month, Start.Date.Day),

    Start.Date.WDay = substr(wday(Start.Date, label = T), 1, 3),  # week starts on Sun in the US!
    Start.Date.Week = week(Start.Date),
    Start.Date.Quarter = ceiling(month(Start.Date) / 3),

    Start.Date.Hour = hour(Start.Date),

    End.Date = as.POSIXct(strptime(End.Date.src, tz = tz, format = dtEndFormat)),

    End.Date.Day = day(End.Date),
    End.Date.Month = month(End.Date),
    End.Date.Year = year(End.Date),

    End.Date.Date = make_date(End.Date.Year, End.Date.Month, End.Date.Day),

    End.Date.WDay = substr(wday(End.Date, label = T), 1, 3),      # week starts on Sun in the US!
    End.Date.Week = week(End.Date),
    End.Date.Quarter = ceiling(month(End.Date) / 3),

    End.Date.Hour = hour(End.Date)
  )
trips = select(trips, -Start.Date.src, -End.Date.src)


## TRIPS
# Aggr by route
# Route: A:B != B:A
trips = trips %>%
  mutate(
    route = paste0(Start.Terminal, '-', End.Terminal)
  )

routesABne = trips %>%
  group_by(route, Start.Terminal, End.Terminal) %>%
  summarise(
    n = n(),
    totalDur = sum(Duration),
    minDur = min(Duration),
    maxDur = max(Duration),
    avgDur = mean(Duration),
    medDur = median(Duration),
    diffAvgMedDur = mean(Duration) - median(Duration)
  ) %>%
  arrange(desc(n))

routesABne = routesABne %>%
  left_join(stations, by=c('Start.Terminal' = 'station_id')) %>%
  left_join(stations, by=c('End.Terminal' = 'station_id'), suffix=c('start','end')) %>%
  select(
    route,
    Start.Terminal,
    End.Terminal,
    nameStart = namestart,
    nameEnd = nameend,
    latStart = latstart,
    longStart = longstart,
    latEnd = latend,
    longEnd = longend,
    n,
    totalDur,
    minDur,
    maxDur,
    avgDur,
    medDur,
    diffAvgMedDur
  )

# Route: A:B == B:A
normRoute = trips %>%
  group_by(Trip.ID) %>%
  summarise(
    normRoute = paste0(min(Start.Terminal, End.Terminal), '-', max(Start.Terminal, End.Terminal))
  )
trips = left_join(trips, normRoute, by='Trip.ID')

routesABe = trips %>%
  group_by(normRoute) %>%
  summarise(
    n = n(),
    totalDur = sum(Duration),
    minDur = min(Duration),
    maxDur = max(Duration),
    avgDur = mean(Duration),
    medDur = median(Duration),
    diffAvgMedDur = mean(Duration) - median(Duration)
  ) %>%
  arrange(desc(n))


for (i in 1:nrow(routesABe)) {
  routesABe[i, 'Start.Terminal'] = as.integer(unlist(strsplit(as.character(routesABe[i, 'normRoute']), '-'))[1])
  routesABe[i, 'End.Terminal'] = as.integer(unlist(strsplit(as.character(routesABe[i, 'normRoute']), '-'))[2])
}

routesABe = routesABe %>%
  left_join(stations, by=c('Start.Terminal' = 'station_id')) %>%
  left_join(stations, by=c('End.Terminal' = 'station_id'), suffix=c('start','end')) %>%
  select(
    normRoute,
    Start.Terminal,
    End.Terminal,
    latStart = latstart,
    longStart = longstart,
    nameStart = namestart,
    nameEnd = nameend,
    latEnd = latend,
    longEnd = longend,
    n,
    totalDur,
    minDur,
    maxDur,
    avgDur,
    medDur,
    diffAvgMedDur
  )

## BIKES
# Aggr by bike
# Bike usage per bike
# Bike usage in minutes
bikes = trips %>%
  mutate(Bike.No = as.character(Bike.No)) %>%
  group_by(Bike.No) %>%
  summarise(
    n = n(),
    dur = sum(Duration),
    medDur = median(Duration),
    minDate = min(Start.Date.Date),
    maxDate = max(End.Date.Date),
    daysInUse = maxDate - minDate
  ) %>% arrange(daysInUse)

# Bike usage per bike, route A:B != B:A
# bikesABe = trips %>%
#   group_by(Bike.No, route) %>%
#   summarise(
#     n = n(),
#     dur = sum(Duration),
#     medDur = median(Duration)
#   )

# # Bike usage per bike, route A:B == B:A
# bikesABne = trips %>%
#   group_by(Bike.No, normRoute) %>%
#   summarise(
#     n = n(),
#     dur = sum(Duration),
#     medDur = median(Duration)
#   )

# Bike usage per bike, start station
# bikesStatFrom = trips %>%
#   group_by(Bike.No, Start.Terminal) %>%
#   summarise(
#     n = n(),
#     dur = sum(Duration),
#     medDur = median(Duration)
#   )

# Bike usage per bike, end station
# bikesStatTo = trips %>%
#   group_by(Bike.No, End.Terminal) %>%
#   summarise(
#     n = n(),
#     dur = sum(Duration),
#     medDur = median(Duration)
#   )

## STATIONS
docks = stations %>%
  group_by(landmark) %>%
  summarise(
    Stations = n(),
    Docks = sum(dockcount),
    avgDockCount = Docks / Stations
  )

staStartByHour = trips %>%
  group_by(Start.Terminal, Start.Date.Hour) %>%
  summarise(
    n = n()
  )

staEndByHour = trips %>%
  group_by(End.Terminal, End.Date.Hour) %>%
  summarise(
    n = n()
  )

staStartByDate = trips %>%
  group_by(Start.Terminal, Start.Date.Date) %>%
  summarise(
    n = n()
  )

# Add ZIP to trips
tripsZIP = trips %>%
  left_join(stations, by=c('Start.Terminal' = 'station_id'))  %>%
  select(
    -name,
    -lat,
    -long,
    -dockcount,
    -landmark,
    -installation
  )

# Get n of trips by ZIP x Start.Date
zipStartByDate = tripsZIP %>%
  group_by(ZIP, Start.Date.Date) %>%
  summarise(
    n = n()
  )

weatherTrips = left_join(weatherZoo, zipStartByDate, by=(c('ZIP', 'Date' = 'Start.Date.Date')))

# weatherEvents = weatherTrips %>%
#   group_by(ZIP, Events) %>%
#   summarise(
#     nEvts = n(),
#     avgTrips = round(mean(n, na.rm = T), 0)
#   )

routesABneSankey = as.data.frame(routesABne) %>%
  transmute(
    nameStart = paste0(as.character(nameStart), 'f'),
    nameEnd = paste0(as.character(nameEnd), 't'),
    n = n
  ) %>% arrange(desc(n))

routesABeSankey = as.data.frame(routesABe) %>%
  transmute(
    nameStart = paste0(as.character(nameStart), 'f'),
    nameEnd = paste0(as.character(nameEnd), 't'),
    n = n
  ) %>% arrange(desc(n))

## Customers
cust = trips %>%
  group_by(Subscriber.Type) %>%
  summarise(
    n = n(),
    dur = sum(Duration),
    medDur = median(Duration)
  )
