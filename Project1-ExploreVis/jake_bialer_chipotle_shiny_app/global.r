library(ggplot2)
library(rgdal)
library(RColorBrewer)
library(noncensus)
library(shiny)
library(tidyr)
library(maps)
library(noncensus)
library(dplyr)
library(shiny)

carnitas_map = read.csv("https://dl.dropboxusercontent.com/u/9526991/carnitas_map1.csv")
map_df <-readRDS(gzcon(url("https://dl.dropboxusercontent.com/u/9526991/Map_df2.rds")))
joined.steak <-readRDS(gzcon(url("https://dl.dropboxusercontent.com/u/9526991/Steak_Regression.rds")))
reg_vars <- readRDS(gzcon(url("https://dl.dropboxusercontent.com/u/9526991/allthedata.rds")))
steak_burrito <- readRDS(gzcon(url("https://dl.dropboxusercontent.com/u/9526991/steak_burrito.rds")))
names(reg_vars)[50] = "Minimum_Wage"
names(reg_vars)[49] = "Living_Wage"
names(reg_vars)[40] = "Annual_taxes"
names(reg_vars)[46] = "Required_annual_income_before_taxes"
super_burrito =  readRDS(gzcon(url("https://dl.dropboxusercontent.com/u/9526991/superburrito.rds")))

names(map_df)[1] = "long"
names(map_df)[2] = "lat"
# speed up
# map_df = head(map_df,10000)

library(RColorBrewer)
library(maps)
my.cols2 <-brewer.pal(8, "Reds")

states_map <- map_data("state")
#pal <- leaflet::colorFactor(my.cols2, domain = as.factor(c(super_burrito$`Steak Burrito`,super_burrito$`Steak Burrito_aftertax`)))


menu_items = c("Steak Burrito","Barbacoa Burrito","Chicken Burrito","Chorizo Burrito","Sofritas Burrito","Veggie Burrito")
global_items = c("Transportation","Living_Wage" ,"POP_ESTIMATE_2015",
                 "Births_2015","Minimum_Wage","R_NET_MIG_2015",
"rate","rating","review_count","Housing","Annual_taxes",
"Required_annual_income_before_taxes",
"Other","Food","Medical")