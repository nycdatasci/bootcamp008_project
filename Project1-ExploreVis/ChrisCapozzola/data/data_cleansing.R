library(dplyr)
library(tidyr)
#GeoNames r package
#leaflet
#cardoDB
zika_data = read.csv("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/cdc_zika.csv")
zika_dates = transmute(zika_data,r_date = sapply(as.character(report_date),gsub,pattern="[_-]",replacement=""))
uniqueDates = unique(zika_dates)
zika_locations = unique(zika_data$location)
zika_locations2 = strsplit(as.character(zika_locations),"-")
# municipality is largest location type ~88k
# following data fields are most popular 
# zika_confirmed_clinic, zika_confirmed_laboratory, zika_suspected_clinic, zika_suspected

zika_clean = zika_data
# reformate date field
zika_clean$report_date = as.Date(zika_clean$report_date, format = "%Y-%m-%d")
# break out location 
zika_clean = separate(zika_clean, location, into = c("Country","State","Municipality"), sep = "-")
# break out data by country

argentina_data = zika_clean[zika_clean$Country == "Argentina",]
brazil_data = zika_clean[zika_clean$Country == "Brazil",]
colombia_data = zika_clean[zika_clean$Country == "Colombia",]
dominican_republic_data = zika_clean[zika_clean$Country == "Dominican_Republic",]
ecuador_data = zika_clean[zika_clean$Country == "Ecuador",]
el_salvador_data = zika_clean[zika_clean$Country == "El_Salvador",]
guatemala_data = zika_clean[zika_clean$Country == "Guatemala",]
haiti_data = zika_clean[zika_clean$Country == "Haiti",]
mexico_data = zika_clean[zika_clean$Country == "Mexico",]
nicaragua_data = zika_clean[zika_clean$Country == "Nicaragua",]
panama_data = zika_clean[zika_clean$Country == "Panama",]
puerto_rico_data = zika_clean[zika_clean$Country == "Puerto_Rico",]
united_states_data = zika_clean[zika_clean$Country == "United_States",]
usvi_data = zika_clean[zika_clean$Country == "United_States_Virgin_Islands",]

# mutate to probable and confirmed cases only
argentina_data = argentina_data %>% mutate_if(is.factor,as.character)
argentina_data = argentina_data[grepl("probable|confirmed|study",argentina_data$data_field),]
argentina_data = argentina_data %>% mutate(conf_prob = ifelse(grepl("confirmed",argentina_data$data_field),"confirmed","probable"))
argentina_data$value = as.numeric(argentina_data$value)

brazil_data = brazil_data %>% mutate_if(is.factor,as.character)
brazil_data = brazil_data[grepl("confirmed|zika",brazil_data$data_field),]
brazil_data = brazil_data %>% mutate(conf_prob = ifelse(grepl("zika",brazil_data$data_field),"confirmed","probable"))
brazil_data$value = as.numeric(brazil_data$value)
brazil_data = brazil_data[is.na(brazil_data$value) == FALSE,]
brazil_data = brazil_data[is.na(brazil_data$State) == FALSE,]

colombia_data = colombia_data %>% mutate_if(is.factor,as.character)
colombia_data = colombia_data %>% mutate(conf_prob = ifelse(grepl("confirmed",colombia_data$data_field),"confirmed","probable"))
colombia_data$value = as.numeric(colombia_data$value)

dominican_republic_data = dominican_republic_data %>% mutate_if(is.factor,as.character)
dominican_republic_data$value = as.numeric(dominican_republic_data$value)
dominican_republic_data = dominican_republic_data[dominican_republic_data$value>0,]
dominican_republic_data = dominican_republic_data[!grepl("gbs|efe|weeks", dominican_republic_data$data_field),]
dominican_republic_data = dominican_republic_data[dominican_republic_data$location_type != "country",]
dominican_republic_data = dominican_republic_data[grepl("cumulative",dominican_republic_data$data_field),]
dominican_republic_data = dominican_republic_data %>% mutate(conf_prob = ifelse(grepl("confirmed",dominican_republic_data$data_field),"confirmed","probable"))

ecuador_data = ecuador_data %>% mutate_if(is.factor,as.character)
ecuador_data$value = as.numeric(ecuador_data$value)
ecuador_data = ecuador_data[!grepl("ages|Not",ecuador_data$data_field),]
ecuador_data = ecuador_data %>% mutate(conf_prob = ifelse(grepl("confirmed",ecuador_data$data_field),"confirmed","probable"))

el_salvador_data = el_salvador_data %>% mutate_if(is.factor,as.character)
el_salvador_data$value = as.numeric(el_salvador_data$value)
el_salvador_data = el_salvador_data[!grepl("weekly|age|pregnant",el_salvador_data$data_field),]
el_salvador_data = el_salvador_data[el_salvador_data$location_type != "country",]
el_salvador_data = el_salvador_data %>% mutate(conf_prob = ifelse(grepl("suspected",el_salvador_data$data_field),"probable","confirmed"))

guatemala_data = guatemala_data %>% mutate_if(is.factor,as.character)
guatemala_data$value = as.numeric(guatemala_data$value)
guatemala_data = guatemala_data[guatemala_data$location_type != "country",]
guatemala_data = guatemala_data %>% mutate(conf_prob = ifelse(grepl("confirmed", guatemala_data$data_field),"confirmed","probable"))

haiti_data = haiti_data %>% mutate_if(is.factor,as.character)
haiti_data$value = as.numeric(haiti_data$value)
haiti_data = haiti_data %>% mutate(conf_prob = ifelse(grepl("suspected", haiti_data$value), "probable","confirmed"))

mexico_data = mexico_data %>% mutate_if(is.factor,as.character)
mexico_data$value = as.numeric(mexico_data$value)
mexico_data = mexico_data[!grepl("yearly",mexico_data$data_field),]
mexico_data = mexico_data %>% mutate(conf_prob = ifelse(grepl("confirmed",mexico_data$data_field),"confirmed","probable"))

nicaragua_data = nicaragua_data %>% mutate_if(is.factor,as.character)
nicaragua_data$value = as.numeric(nicaragua_data$value)
nicaragua_data = nicaragua_data[!grepl("normal",nicaragua_data$data_field),]
nicaragua_data = nicaragua_data %>% mutate(conf_prob = ifelse(grepl("confirmed",nicaragua_data$data_field),"confirmed","probable"))

panama_data = panama_data %>% mutate_if(is.factor,as.character)
panama_data$value = as.numeric(panama_data$value)
panama_data = panama_data[!grepl("negative|age|weekly", panama_data$data_field),]
panama_data = panama_data[panama_data$location_type != "country",]
panama_data = panama_data %>% mutate(conf_prob = ifelse(grepl("Zika",panama_data$data_field),"confirmed","probable"))

# not enough data available for puerto rico
# puerto_rico_data = puerto_rico_data %>% mutate_if(is.factor,as.character)
# puerto_rico_data$value = as.numeric(puerto_rico_data$value)
# puerto_rico_data = puerto_rico_data[!is.na(puerto_rico_data$report_date),]

united_states_data = united_states_data %>% mutate_if(is.factor,as.character)
united_states_data$value = as.numeric(united_states_data$value)
united_states_data = united_states_data[!grepl("yearly",united_states_data$data_field),]
united_states_data = united_states_data %>% mutate(conf_prob = ifelse(grepl("reported",united_states_data$data_field),"confirmed","probable"))

# create a vector with all countries names

countries = c("Argentina","Brazil","Colombia","Dominican_Republic","Ecuador","El_Salvador","Guatemala","Haiti","Mexico","Nicaragua","Panama", "United_States")

# call libraries for maps

library(ggmap)
library(mapproj)
library(ggplot2)
library(maptools)
library(rgdal)
library(rgeos)
# load all shape files for mapping and convert into dataframes
colombia_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/COL_adm2.rds")
colombia_adm.df = fortify(colombia_adm, region = "NAME_1")

argentina_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/ARG_adm2.rds")
argentina_adm.df = fortify(argentina_adm, region = "NAME_1")

brazil_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/BRA_adm2.rds")
brazil_adm.df = fortify(brazil_adm, region = "NAME_1")

dominican_republic_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/DOM_adm2.rds")
dominican_republic_adm.df = fortify(dominican_republic_adm, region = "NAME_1")

ecuador_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/ECU_adm2.rds")
ecuador_adm.df = fortify(ecuador_adm, region = "NAME_1")

el_salvador_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/SLV_adm2.rds")
el_salvador_adm.df = fortify(el_salvador_adm, region = "NAME_1")

guatemala_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/GTM_adm2.rds")
guatemala_adm.df = fortify(guatemala_adm, region = "NAME_1")

haiti_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/HTI_adm2.rds")
haiti_adm.df = fortify(haiti_adm, region = "NAME_1")

mexico_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/MEX_adm2.rds")
mexico_adm.df = fortify(mexico_adm, region = "NAME_1")

nicaragua_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/NIC_adm2.rds")
nicaragua_adm.df = fortify(nicaragua_adm, region = "NAME_1")

panama_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/PAN_adm2.rds")
panama_adm.df = fortify(panama_adm, region = "NAME_1")

united_states_adm <- readRDS("/Users/arianiherrera/Desktop/NYCDataScience/Data Visualization Project/USA_adm2.rds")
united_states_adm.df = fortify(united_states_adm, region = "NAME_1")


#######
# select specific data TURN INTO FUNCTION
col_dates = unique(colombia_data$report_date)
col_select = colombia_data[,c("report_date", "Country", "State","conf_prob","value")]
col_select = col_select[col_select$report_date == col_dates[1],]
col_select$State = gsub("_"," ",col_select$State)
col_select = col_select %>% group_by(report_date, Country, State,conf_prob) %>% summarise(infected = sum(value))
col_select = spread(col_select, key = conf_prob, value = infected)

# merge with shape file dataframes
colombia_adm.df = merge(colombia_adm.df, col_select, by.x = 'id',by.y = 'State', all = TRUE)
colombia_adm.df = arrange(colombia_adm.df, order)
colombia_adm.df = colombia_adm.df[colombia_adm.df$order %% 20 == 0,]

# make plot
c <- ggplot(data = colombia_adm.df, aes(x = long, y = lat, group = group)) + geom_polygon(aes(fill = cut(confirmed,6)), alpha = .75) + geom_path(colour = 'grey', linestyle = 1)
c = c + labs(x=" ", y=" ") + 
  theme_bw() + scale_fill_brewer('Zika Virus Infections', palette  = 'YlOrRd') + 
  coord_map() +
  theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + 
  theme(axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank()) + 
  theme(panel.border = element_blank())
######

cleanMapPlot <- function(country_data, country_adm.df, date_input){
  # Clean Data
  country_select = country_data[,c("report_date", "Country", "State","conf_prob","value")]
  country_select = country_select[country_select$report_date == date_input,]
  country_select$State = gsub("_"," ",country_select$State)
  country_select = country_select %>% group_by(report_date, Country, State,conf_prob) %>% summarise(infected = sum(value))
  country_select = spread(country_select, key = conf_prob, value = infected)
  # Merge Data to shape dataframe
  country_adm.df = country_adm.df[!grepl("Alaska|Hawaii",country_adm.df$id),]
  country_adm.df = country_adm.df[country_adm.df$order %% 10 == 0,]
  country_adm.df = merge(country_adm.df, country_select, by.x = 'id',by.y = 'State', all = TRUE)
  country_adm.df = arrange(country_adm.df, order)
  
  # Create plot with clean data
  g <- ggplot(data = country_adm.df, aes(x = long, y = lat, group = group)) + geom_polygon(aes(fill = cut(confirmed,6)), alpha = .75) + geom_path(colour = 'grey')
  g = g + labs(x=" ", y=" ") + 
    theme_bw() + scale_fill_brewer('Zika Virus Infections', palette  = 'YlOrRd') + 
    coord_map() +
    theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + 
    theme(axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank()) + 
    theme(panel.border = element_blank())
  return(g)
}

arg_dates = unique(argentina_data$report_date)
brz_dates = unique(brazil_data$report_date) # not splitting columns into conf_prob
dr_dates = unique(dominican_republic_data$report_date)
ecu_dates = unique(ecuador_data$report_date)
salv_dates = unique(el_salvador_data$report_date) # same as brazil
guat_dates = unique(guatemala_data$report_date)
haiti_dates = unique(haiti_data$report_date)
mex_dates = unique(mexico_data$report_date)
nic_dates = unique(nicaragua_data$report_date)
pan_dates = unique(panama_data$report_date)
us_dates = unique(united_states_data$report_date)





brz_select = brazil_data[,c("report_date", "Country", "State","conf_prob","value")]
brz_select = brz_select[brz_select$report_date == brz_dates[1],]
brz_select$State = gsub("_"," ",brz_select$State)
brz_select = brz_select %>% group_by(report_date, Country, State,conf_prob) %>% summarise(infected = sum(value))
brz_select = spread(brz_select, key = conf_prob, value = infected)

brazil_adm.df = brazil_adm.df[!grepl("Alaska|Hawaii",brazil_adm.df$id),]
brazil_adm.df = brazil_adm.df[brazil_adm.df$order %% 10 == 0,]
brazil_adm.df = merge(brazil_adm.df, brz_select, by.x = 'id',by.y = 'State', all = TRUE)
brazil_adm.df = arrange(brazil_adm.df, order)

b <- ggplot(data = brazil_adm.df, aes(x = long, y = lat, group = group)) + geom_polygon(aes(fill = cut(probable,6)), alpha = .75) + geom_path(colour = 'grey')
b = b + labs(x=" ", y=" ") + 
  theme_bw() + scale_fill_brewer('Zika Virus Infections', palette  = 'YlOrRd') + 
  coord_map() +
  theme(panel.grid.minor=element_blank(), panel.grid.major=element_blank()) + 
  theme(axis.ticks = element_blank(), axis.text.x = element_blank(), axis.text.y = element_blank()) + 
  theme(panel.border = element_blank())











