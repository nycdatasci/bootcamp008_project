library(shiny)
library(dplyr)
library(googleVis)
library(shinydashboard)
library(ggplot2)
library(ggthemes)
library(RColorBrewer)

setwd("~/Desktop/Wine_trade_datasets/Final_Data")
growth_data <- readRDS('1960-2009_data.rds')
bilateral_trade <- readRDS('Bilateral_trade_by_Region.rds')

country_list = list('Turkey' = 'TURK', 'South Africa' = 'SAF', 'Australia' = 'AUS',
                    'New Zealand' = 'NZL','China' = 'CHINA', 'Hong Kong' = 'HK',
                    'India' = 'INDIA', 'Japan' = 'JPN', 'South Korea' = 'KOR', 
                    'Malaysia' = 'MAL', 'Philippines' = 'PHIL','Singapore' = 'SIN',
                    'Thailand' = 'THAI', 'Bulgaria' = 'BUL', 'Croatia' = 'CRO', 
                    'Georgia' = 'GEO', 'Hungary' = 'HUN', 'Moldova' = 'MOLD',
                    'Romania' = 'ROM', 'Russia' = 'RUS', 'Ukraine' = 'UKR',
                    'Argentina' = 'ARG', 'Brazil' = 'BRA', 'Chile' = 'CHILE', 
                    'Mexico' = 'MEX', 'Uruguay' = 'URU', 'USA' = 'USA', 'Canada' = 'CAN',
                    'Austria' = 'AUT','Belgium' = 'BEL', 'Denmark' = 'DEN', 
                    'Finland' = 'FIN', 'Germany' = 'GER', 'Greece' = 'GRE', 
                    'Ireland' = 'IRL', 'Netherlands' = 'NLD', 'Sweden' = 'SWE', 
                    'Switzerland' = 'SWISS', 'UK' = 'UK', 'France' = 'FRA', 
                    'Italy' = 'ITA', 'Portugal' = 'POR', 'Spain' = 'SPN')

list_country = list('TURK' = 'Turkey','SAF' =  'South Africa', 'AUS' = 'Australia',
                    'NZL' = 'New Zealand', 'CHINA' = 'China', 'HK'='Hong Kong',
                    'INDIA' = 'India', 'JPN' = 'Japan', 'KOR' = 'South Korea', 
                    'MAL' = 'Malaysia', 'PHIL' = 'Philippines', 'SIN' = 'Singapore',
                    'THAI' = 'Thailand', 'BUL' = 'Bulgaria', 'CRO' = 'Croatia', 
                    'GEO' = 'Georgia', 'HUN' = 'Hungary', 'MOLD' = 'Moldova',
                    'ROM' = 'Romania', 'RUS' = 'Russia', 'UKR' = 'Ukraine',
                    'ARG' = 'Argentina', 'BRA' = 'Brazil', 'CHILE' = 'Chile', 
                    'MEX' = 'Mexico', 'URU' = 'Uruguay', 'USA' = 'USA', 'CAN' = 'Canada',
                    'AUT' = 'Austria','BEL' = 'Belgium', 'DEN' = 'Denmark', 
                    'FIN' = 'Finland', 'GER' = 'Germany', 'GRE' = 'Greece', 
                    'IRL' = 'Ireland', 'NLD' = 'Netherlands', 'SWE' = 'Sweden', 
                    'SWISS' = 'Switzerland', 'UK' = 'UK', 'FRA' = 'France', 
                    'ITA' = 'Italy', 'POR' = 'Portugal', 'SPN' = 'Spain')

regions = c('AME', 'ANZ', 'APA', 'ECA', 'LAC', 'USC', 'WEM', 'WEX')

col_names = list('Total grapevine area, 000 ha' = 'Total_grapevine_area', 
                 'Volume of wine exports, ML' = 'Volume_wine_exports', 
                 'Volume of wine production, ML' = 'Vol_wine_production', 
                 'Volume of wine consumption, ML' = 'Vol_wine_consumption', 
                 'Volume of wine consumption per capita, litres' = 'Volume_wine_consumption_per_capita', 
                 'Volume of wine imports, ML' = 'Vol_wine_imports', 
                 'Volume of net wine imports, ML' = 'Vol_net_imports', 
                 'Value of wine exports, US$ million' = 'Value_wine_exports',
                 'Value of wine imports, US$ million' = 'Value_wine_imports' , 
                 'Total alcohol consumption per capita (litres of alcohol)' = 'Tot_alcohol_consumption_per_capita',
                 'Adult population (millions)' = 'Adult_population', 
                 'GDP per capita, US$ current'  = 'GDP_per_capita', 
                 'GDP, US$ current' = 'GDP')

names_col = list('Total_grapevine_area' = 'Total grapevine area, 000 ha', 
                 'Volume_wine_exports' = 'Volume of wine exports, ML', 
                 'Vol_wine_production' = 'Volume of wine production, ML', 
                 'Vol_wine_consumption' = 'Volume of wine consumption, ML', 
                 'Volume_wine_consumption_per_capita' = 'Volume of wine consumption per capita, litres', 
                 'Vol_wine_imports' = 'Volume of wine imports, ML', 
                 'Vol_net_imports' = 'Volume of net wine imports, ML', 
                 'Value_wine_exports' = 'Value of wine exports, US$ million',
                 'Value_wine_imports' = 'Value of wine imports, US$ million', 
                 'Tot_alcohol_consumption_per_capita' = 'Total alcohol consumption per capita (litres of alcohol)',
                 'Adult_population' = 'Adult population (millions)', 
                 'GDP_per_capita' = 'GDP per capita, US$ current', 
                 'GDP' = 'GDP, US$ current')

bt_col_names = list("Volume of wine exports to each region, '000 litres" = "Vol_wine_exports_region",
                    "Value of wine exports to each region, US$ '000" = "Value_wine_exports_region",
                    "Volume of wine imports from each region, '000 litres" = "Vol_wine_imports_region",
                    "Value of wine imports from each region, US$ '000" = "Value_wine_imports_region")

names_bt_col = list("Vol_wine_exports_region" = "Volume of wine exports to each region, '000 litres",
                    "Value_wine_exports_region" = "Value of wine exports to each region, US$ '000",
                    "Vol_wine_imports_region" = "Volume of wine imports from each region, '000 litres",
                    "Value_wine_imports_region" = "Value of wine imports from each region, US$ '000")

intensity_col_names = list("Volume-based trade intensity" = "Index_volume_trade_intensity",
                           "Value-based trade intensity" = "Index_value_trade_intensity")

#AME <- c('SAF', 'TURK')
#ANZ <- c('AUS','NZL')
#APA <- c('CHINA', 'HK', 'INDIA', 'JPN', 'KOR', 'MAL', 'PHIL', 'SIN', 'THAI')
#ECA <- c('BUL', 'CRO', 'GEO', 'HUN', 'MOLD', 'ROM', 'RUS', 'UKR')
#LAC <- c('ARG', 'BRA', 'CHILE', 'MEX', 'URU')
#USC <- c('CAN', 'USA')
#WEM <- c('AUT', 'BEL', 'DEN', 'FIN', 'GER', 'GRE', 'IRL', 'NLD', 'SWE', 'SWISS', 'UK')
#WEX <- c('FRA', 'ITA', 'POR', 'SPN')
