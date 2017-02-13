library(shiny)
library(leaflet)
library(shinydashboard)
library(dplyr)
library(data.table)
library(sqldf)
library(corrplot)
library(shinythemes)

# setwd('C:/Users/Shyam/Documents/Bootcamp/Homework/1st_Project')
rt2 <- read.csv('rt2.csv')

dataurl = "https://raw.githubusercontent.com/swingley/san-diego-neighborhoods/master/data/sdpd_beats.topojson"
topoData <- readLines(dataurl)

iconSet <- iconList(burrito = makeIcon("burrito.svg", iconWidth = 18, iconHeight = 21))

rt2$Reviewer <- as.factor(rt2$Reviewer)
rt2$Tortilla <- as.numeric(rt2$Tortilla)
num_cols <- c('Tortilla' = 'Tortilla',
              'Meat' = 'Meat',
              'Temp' = 'Temp', 'Fillings' = 'Fillings', 
              'Meat.filling' = 'Meat.filling',
              'Uniformity' = 'Uniformity',
              'Salsa' = 'Salsa',
              'Synergy' = 'Synergy',
              'Wrap' = 'Wrap')
cat_cols <- c('Burrito' = 'Burrito', 'Reviewer' = 'Reviewer')
