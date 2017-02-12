library(dplyr)
library(DT)

setwd('/Users/mu/Dropbox/learning/NYCDSA/bootcamp008_project/Project2-WebScraping/TomHunter/amazon/')
df_top100 <- fread('data/products.csv', stringsAsFactors = FALSE, data.table = FALSE)


