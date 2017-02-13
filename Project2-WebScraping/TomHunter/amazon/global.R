library(dplyr)
library(DT)
library(VIM)
library(Hmisc)

setwd('/Users/mu/Dropbox/learning/NYCDSA/bootcamp008_project/Project2-WebScraping/TomHunter/amazon/')
df <- fread('./data/products_cleaned.csv', stringsAsFactors = FALSE, data.table = FALSE)


#missingness checks


