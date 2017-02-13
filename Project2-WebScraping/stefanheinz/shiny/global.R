# Shiny
library(shiny)
library(shinydashboard)
library(shinyjs)

# Charts
library(googleVis)
library(ggplot2)
library(RColorBrewer)
library(wordcloud2)

# Data wrangling
library(dplyr)

# Date wrangling
library(lubridate)

# Nicer data tables
library(DT)

# %like%
library(data.table)

source('helpers.R')

songs = readRDS('data/clean/swr3-songs-2016-v3.rds')
shows = readRDS('data/clean/shows.rds')
wordCloudFilter = readLines('data/wordcloudfilter.txt')

tz = 'Europe/Berlin'
tsFormat = '%F %T'
dtFormat = '%d.%m.%Y'
songs = mutate(
  songs,
  ts = as.POSIXct(strptime(ts, tz=tz, format=tsFormat)),
  date = as.POSIXct(strptime(date, tz=tz, format=dtFormat)),

  title = as.character(title),
  artist = as.character(artist),
  wdayLbl = as.character(wdayLbl)
)

# Grouped by artist, title
distSongs = songs %>%
  group_by(artist, title) %>%
  summarise(
    playCount = n()
  )

abWordCloudVal = -1
