##############################################
###  Data Science Bootcamp 8               ###
###  Project 1 - Exploratory Visualization ###
###  Yvonne Lau  / January 29, 2017        ###
###     Restaurant Closures from Health    ###
###           Inspections in NYC           ###
##############################################

# load data
load('data/grade_only.RData')
load('data/closure_shiny.RData')
load('data/health_processed.RData')
load('data/unique_health.RData')

closure <- closure_shiny
health_processed <- data

# clean grade_only data with unique restaurants for ggplot2
# Unique  grades plit
grade_only_plot <- unique(grade_only[c("camis","date","borough","year","grade","cuisine","score")])
grade_only_plot <- filter(grade_only_plot,year!=2011, year!=2012) #clean only datapoint from 2011, small sample of 2012
grade_only_plot$year <- as.factor(grade_only_plot$year)

# tab 2
unique_score <- unique(data[c("camis","date","borough","year","score","cuisine")])
unique_score <- filter(unique_score, year!='2011',year!='2012')

