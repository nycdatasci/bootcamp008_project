##############LIBRARIES & SETTINGS###################
library(dplyr)
library(data.table)
library(ggplot2)
library(devtools)
library(tidyverse)

<<<<<<< HEAD

=======
# setwd('~/Dropbox/learning/NYCDSA/projects/NYCDSA_project_1/')
>>>>>>> a20c39d271323a07d1aadb5ae34f15c3c524c318
options(digits.secs = 6) #to include fractions of a second for timestamps
options(max.print = 100)


#REMOTE FILES -- WARNING: Files are large (df_311data > 1gb), may take a while to download depending on connection 
url_stub <- 'https://dl.dropboxusercontent.com'
df_hs16 <- fread(paste0(url_stub, '/s/ksxhrdn1hgj0btl/Heat%20Seek%20NYC%20data%206-15%20to%206-16.csv?dl=0'), stringsAsFactors = TRUE, data.table = FALSE)
df_hs17 <- fread(paste0(url_stub, '/s/q03pq9qw0oi152b/Heat%20Seek%20NYC%20data%206-16%20to%206-17.csv?dl=0'), stringsAsFactors = TRUE, data.table = FALSE)
sensor_mapping <- fread(paste0(url_stub, '/s/doy90pumwhgygdl/sensor_mapping.csv?dl=0'), stringsAsFactors = FALSE, data.table = FALSE)
df_311data <- fread(paste0(url_stub, '/s/qwrc8shn8dtvy2a/311_Service_Requests_from_2010_to_Present.csv?dl=0'), stringsAsFactors = TRUE, data.table = FALSE)

#LOCAL STORAGE
# setwd('~/Dropbox/learning/NYCDSA/projects/NYCDSA_project_1/')
# df_hs16 <- fread('data/Heat Seek NYC data 6-15 to 6-16.csv', stringsAsFactors = TRUE, data.table = FALSE)
# df_hs17 <- fread('data/Heat Seek NYC data 6-16 to 6-17.csv', stringsAsFactors = TRUE, data.table = FALSE)
# sensor_mapping <- fread('data/sensor_mapping.csv', stringsAsFactors=FALSE, data.table = FALSE)
# df_311data <- fread('data/311_Service_Requests_from_2010_to_Present.csv', stringsAsFactors = TRUE, data.table = FALSE) 

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

remove_outliers <- function(x, na.rm = TRUE, ...) {
  qnt <- quantile(x, probs=c(.25, .75), na.rm = na.rm, ...)
  H <- 1.5 * IQR(x, na.rm = na.rm)
  y <- x
  y[x < (qnt[1] - H)] <- NA
  y[x > (qnt[2] + H)] <- NA
  y
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
df_hs$full_address <- paste0(df_hs$clean_address, ', NY ', df_hs$zip_code)

# merging lat/long data into main hs df
df_hs <- left_join(df_hs, sensor_mapping, by=c('full_address'='unique_address'))

# moved this to external CSV for convenience
# sensor_mapping <- data.frame(unique_address=unique(df_hs$full_address[!df_hs$full_address %in% c(", NY NA")]))
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

df_311subset <- tbl_df(df_311subset) %>% arrange(`Created Date`)

