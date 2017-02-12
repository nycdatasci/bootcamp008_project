library(dplyr)
library(DT)
library(VIM)
library(Hmisc)


setwd('/Users/mu/Dropbox/learning/NYCDSA/bootcamp008_project/Project2-WebScraping/TomHunter/amazon/')
df_top100 <- fread('data/products.csv', stringsAsFactors = FALSE, data.table = FALSE)
aggr(df_top100)


