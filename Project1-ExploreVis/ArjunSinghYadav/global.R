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
library(readr)


load('data/data.RData')

#data for map data
# new_df<- read_csv("data/crimeData1.csv")
# df<-new_df
# df$occ_date <- as.Date(df$occ_date, format = "%m-%d-%Y")
# #data for plots
# table_df<-read_csv("data/graph.csv")
# table_df<-head(table_df,100000)
# 
# lab<-read_csv("data/graph1.csv")
# la<-lab
# la$occ_date<- as.Date(la$occ_date, format= "%d-%m-%Y")
