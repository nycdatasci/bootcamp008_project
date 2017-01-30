library(dplyr)
library(RColorBrewer)
library(tidyr)
library(DT)
library(googleVis)
library(ggmap)
library(ggplot2)
library(shinydashboard)
library(shiny)
library(leaflet)
library(shinythemes)



#data for map data
new_df<- read.csv("data/crimeData1.csv")

#data for plots
table_df<-read.csv("data/graph.csv")
table_df<-head(table_df,100000)
df<-head(new_df,100)
df$occ_date <- as.Date(df$occ_date, format = "%m-%d-%Y")

lab<-read.csv("data/graph1.csv")
la<-lab
la$occ_date<- as.Date(la$occ_date, format= "%d-%m-%Y")
