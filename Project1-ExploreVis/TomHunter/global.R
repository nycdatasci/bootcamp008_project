##############LIBRARIES & SETTINGS###################
library(dplyr)
library(data.table)
library(tidyr)
library(ggplot2)
library(ggmap)
library(mapproj)
library(devtools)
library(tidyverse)

# devtools::install_github('dkahle/ggmap')
# devtools::install_github('hadley/ggplot2')
# install.packages("ggthemes", type = "source")
# install.packages("tidyverse")
# install_version("ggplot2", version = "2.1.0", repos = "http://cran.us.r-project.org")


setwd('~/Dropbox/learning/NYCDSA/projects/NYCDSA_project_1/')
options(digits.secs = 6) #to include fractions of a second for timestamps
options(max.print = 100)

df_hs16 <- fread('Heat Seek NYC data 6-15 to 6-16.csv', stringsAsFactors = TRUE, data.table = FALSE)
df_hs17 <- fread('Heat Seek NYC data 6-16 to 6-17.csv', stringsAsFactors = TRUE, data.table = FALSE)
sensor_mapping <- fread('sensor_mapping.csv', stringsAsFactors=FALSE, data.table = FALSE)
df_311data <- fread('311_Service_Requests_from_2010_to_Present.csv', stringsAsFactors = TRUE, data.table = FALSE) 

setwd(paste(getwd(),'/BORO_zip_files_csv/', sep=""))
df_geo_MN <- fread('MN.csv', data.table = FALSE)
df_geo_BK <- fread('BK.csv', data.table = FALSE)
df_geo_BX <- fread('BX.csv', data.table = FALSE)
df_geo_SI <- fread('SI.csv', data.table = FALSE)
df_geo_QN <- fread('QN.csv', data.table = FALSE)

##############HELPER CODE###################
winterize <- function(df, col_name) {
  #winterize (aka translate the continous timestamp to categorical winter ranges)  
  #static values
  winters <- list('Winter 2010'=c('10-01-2009','5-31-2010'),'Winter 2011'=c('10-01-2010','5-31-2011'),'Winter 2012'=c('10-01-2011','5-31-2012'),'Winter 2013'=c('10-01-2012','5-31-2013'),'Winter 2014'=c('10-01-2013','5-31-2014'),'Winter 2015'=c('10-01-2014','5-31-2015'),'Winter 2016'=c('10-01-2015','5-31-2016'),'Winter 2017'=c('10-01-2016','5-31-2017'))
  winters <- sapply(winters, function(x) as.POSIXct(x, tz = 'EST', format = '%m-%d-%Y'))
  new_col_name = 'Winters'
  
  df[new_col_name] <- NA
  
  for (i in 1:(length(winters)/2)) {
    df[(df[col_name] >= winters[1,i] & df[col_name] <= winters[2,i]), new_col_name] = as.character(names(winters[1,i]))
  }
  return(df)
}

##############HEAT SEEK DATA CLEANING###################
df_hs <- full_join(df_hs16, df_hs17)
rm(df_hs16, df_hs17)

df_hs$created_at <- as.POSIXct(df_hs$created_at, format = "%Y-%m-%d %H:%M:%S", tz='EST')
df_hs$address <- as.factor(df_hs$address)
df_hs$clean_address <- sapply(df_hs$address, toupper)

df_hs <- winterize(df_hs, 'created_at')
df_hs$Year <- as.factor(format(df_hs$created_at,'%Y'))
df_hs$Month <- as.factor(format(df_hs$created_at,'%m'))

df_hs <- tbl_df(df_hs) %>% arrange(desc(created_at))

# sensor_mapping <- data.frame(unique_address=unique(df_hs$clean_address[!df_hs$clean_address %in% c("")]))
# sensor_mapping$unique_address <- paste(sensor_mapping$unique_address, ', NY', sep = "")
# sensor_mapping$unique_address <- as.character(sensor_mapping$unique_address)
# sensor_mapping <- sensor_mapping %>% mutate_geocode(., unique_address)
# write_csv(sensor_mapping, path = '~/Dropbox/learning/NYCDSA/projects/NYCDSA_project_1/sensor_mapping.csv')

##############311 DATA CLEANING###################
#create subset of data we care about and sort by creation date
df_311subset <- df_311data[,c('Unique Key','Created Date','Closed Date','Agency','Agency Name','Complaint Type','Descriptor','Location Type','Incident Zip','Incident Address','Street Name','Community Board','Borough','Status')]
rm(df_311data)

#clean up timestamps
df_311subset$`Created Date` <- as.POSIXct(df_311subset$`Created Date`, format = "%m/%d/%Y %I:%M:%S %p", tz="EST")
df_311subset$`Closed Date` <- as.POSIXct(df_311subset$`Closed Date`, format = "%m/%d/%Y %I:%M:%S %p", tz="EST")

df_311subset <- winterize(df_311subset, 'Created Date')
df_311subset$Winters <- as.factor(df_311subset$Winters)
df_311subset$Year <- as.factor(format(df_311subset$`Created Date`,'%Y'))
df_311subset$Month <- as.factor(format(df_311subset$`Created Date`,'%m'))
# sapply(df_311subset, drop(is.na(Winters)))

df_311subset <- tbl_df(df_311subset) %>% arrange(`Created Date`)

# zipcode_mapping <- data.frame(unq_zip=unique(df_311subset$`Incident Zip`))
# zipcode_mapping$unq_zip <- as.character(zipcode_mapping$unq_zip)
# zipcode_mapping <- zipcode_mapping %>% mutate_geocode(., unq_zip)

##############GEO DATA CLEANING###################
#subset of only columns interested in
sub_cols <- c("Borough","Block","Lot","ZipCode","Address","AssessTot")
df_geo_MN <- df_geo_MN[,sub_cols]
df_geo_BK <- df_geo_BK[,sub_cols]
df_geo_BX <- df_geo_BX[,sub_cols]
df_geo_SI <- df_geo_SI[,sub_cols]
df_geo_QN <- df_geo_QN[,sub_cols]

df_geo <- full_join(df_geo_MN, df_geo_BK)
df_geo <- full_join(df_geo, df_geo_BX)
df_geo <- full_join(df_geo, df_geo_QN)
df_geo <- full_join(df_geo, df_geo_SI)

rm(sub_cols, df_geo_MN, df_geo_BK, df_geo_QN, df_geo_SI, df_geo_BX)

df_geo$Borough <- as.factor(df_geo$Borough)



##############UI SELECTION CRITERIA###################
cols_311 <- c("Borough" = "Borough",
              "Year" = "Year", 
              "Winter" = "Winters")
cols_hs <- c( "Year" = "Year",
              "Winter" = "Winters")

hs_addresses <- sensor_mapping[,1]

hs_sensor_ids <- unique(df_hs$sensor_short_code[!df_hs$sensor_short_code %in% c("")])

##############SUMMARIES AND GRAPHS###################

# get_googlemap("156 5TH AVENUE, NY", zoom = 12) %>% ggmap()

# qmplot(lon, lat, data = sensor_mapping, maptype = "toner-lite", color = I("red"))
# qmplot(lon, lat, data = sensor_mapping, geom = "blank", zoom = 15, maptype = "toner-background", darken = .7, legend = "topleft") +
#   stat_density_2d(aes(fill = ..level..), geom = "polygon", alpha = .3, color = NA) +
#   scale_fill_gradient2("Sensor\nLocations", low = "white", mid = "yellow", high = "red", midpoint = median())



