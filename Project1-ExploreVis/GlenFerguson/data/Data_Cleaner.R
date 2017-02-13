library(dplyr)
library(tidyr)
setwd("~/Desktop/Wine_trade_datasets/Final_Data")
# Write a function to tidy the first set of data tables.
file_names = c('Vina_area.csv', 
               'Vol_exports.csv', 
               'Vol_production.csv', 
               'Vol_Consumption.csv',
               'Vol_Consumption_per_capita.csv',
               'Vol_imports.csv', 
               'Vol_net_imports.csv',
               'Value_exports.csv', 
               'Value_imports.csv', 
               'Alcohol_consumption_per_capita.csv',
               'Adult_pop.csv', 
               'GDP_per_capita.csv', 
               'GDP.csv')

col_names = c('Total grapevine area, 000 ha', 
              'Volume of wine exports, ML', 
              'Volume of wine production, ML', 
              'Volume of wine consumption, ML', 
              'Volume of wine consumption per capita, litres', 
              'Volume of wine imports, ML', 
              'Volume of wine net imports, ML', 
              'Value of wine exports, US$ million',
              'Value of wine imports, US$ million', 
              'Total alcohol consumption per capita (litres of alcohol)',
              'Adult population (millions)', 
              'GDP per capita, US$ current', 
              'GDP, US$ current')

# 
cols <- c('X1960.1964','X1965.1969','X1970.1974','X1975.1979','X1980.1984',
          'X1985.1989','X1990.1994','X1995.1999','X2000.2004','X2005.2009')

tidy_growth_data <- function(name, column_names) {
    df <- read.csv(name, na.strings = c('', 'na'), header=TRUE)
    df[cols] <- lapply(df[cols], as.numeric)
    df <- gather(df ,key='FiveYearRange', value = value_string, 3:12)
    return(df)
}
df1 <- tidy_growth_data('Vina_area.csv', cols) %>%
                 rename('Total_grapevine_area' = value_string)
df2 <- tidy_growth_data('Vol_exports.csv', cols) %>%
                 rename('Volume_wine_exports' = value_string)
df3 <- tidy_growth_data('Vol_production.csv', cols) %>%
                 rename('Vol_wine_production' = value_string)
df4 <- tidy_growth_data('Vol_Consumption.csv', cols) %>%
                 rename('Vol_wine_consumption' = value_string)
df5 <- tidy_growth_data('Vol_Consumption_per_capita.csv', cols) %>%
                 rename('Volume_wine_consumption_per_capita' = value_string)
df6 <- tidy_growth_data('Vol_imports.csv', cols) %>%
                 rename('Vol_wine_imports' = value_string)
df7 <- tidy_growth_data('Vol_net_imports.csv', cols) %>%
                 rename('Vol_net_imports' = value_string)
df8 <- tidy_growth_data('Value_exports.csv', cols) %>%
                 rename('Value_wine_exports' = value_string)
df9 <- tidy_growth_data('Value_imports.csv', cols) %>%
                 rename('Value_wine_imports' = value_string)
df10  <- tidy_growth_data('Adult_pop.csv', cols) %>%
                   rename('Adult_population' = value_string)
df11 <- tidy_growth_data('GDP_per_capita.csv', cols) %>%
                  rename('GDP_per_capita' = value_string)
df12  <- tidy_growth_data('Alcohol_consumption_per_capita.csv', cols) %>%
                   rename('Tot_alcohol_consumption_per_capita' = value_string)
df13<- tidy_growth_data('GDP.csv', cols) %>%
                  rename('GDP'= value_string)
# Merge the outputs into a data frame
df_list = list(df1, df2, df3, df4, df5, df6, df7, df8, df9, df10, df11, df12, df13)
df14 <- Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2), df_list) %>%
# remove some extra characters and convert the character columns to factors.
        mutate(FiveYearRange = gsub('X','' ,FiveYearRange)) %>%
        mutate(FiveYearRange = gsub('\\.','-' ,FiveYearRange))
fac_cols <- c('Region', 'Country', 'FiveYearRange')
df14[fac_cols] <- lapply(df14[fac_cols], factor)
saveRDS(df14, '1960-2009_data.rds')
#####################################################
# Now tidy the data from the data for bilateral trade
cols_bilat <- c('WEX', 'WEM', 'ECA', 'ANZ', 'USC', 'LAC', 'AME', 'APA')

tidy_bilat_trade_data <- function(name, column_name) {
  df <- read.csv(name, na.strings = c('', 'na'), header=TRUE)
  df[cols_bilat] <- lapply(df[cols_bilat], as.numeric)
  df <- gather(df ,key='Import_Region', value = value_string, 4:ncol(df))
  return(df)
}

bt_col_names = c("Volume of wine exports to each region, '000 litres" ,
                 "Volume of wine imports from each region, '000 litres" ,
                 "Value of wine imports to each region, US$ '000",
                "Value of wine exports from each region, US$ '000",
                "Index of volume-based regional wine trade intensity",
                "Index of value-based regional wine trade intensity")


dfbt1 <- tidy_bilat_trade_data('Vol_exports_regions.csv', cols_bilat) %>%
                        rename("Vol_wine_exports_region" = value_string)
dfbt2 <- tidy_bilat_trade_data("Vol_imports_regions.csv", cols_bilat) %>%
                        rename("Vol_wine_imports_region" = value_string)
dfbt3 <- tidy_bilat_trade_data("Value_imports_regions.csv", cols_bilat) %>%
                        rename("Value_wine_imports_region" = value_string)
dfbt4 <- tidy_bilat_trade_data("Value_exports_regions.csv", cols_bilat) %>%
                        rename("Value_wine_exports_region" = value_string)
dfbt5 <- tidy_bilat_trade_data("Vol_Trade_Intensity.csv", cols_bilat) %>%
                        rename("Index_volume_trade_intensity" = value_string)
dfbt6 <- tidy_bilat_trade_data("Value_Trade_Intensity.csv", cols_bilat) %>%
                        rename("Index_value_trade_intensity" = value_string)
# Merge the outputs into a data frame
dfbt_list = list(dfbt1, dfbt2, dfbt3, dfbt4, dfbt5, dfbt6)
dfbt7 <- Reduce(function(dtf1,dtf2) full_join(dtf1,dtf2), dfbt_list) %>%
  # remove some extra characters and convert the character columns to factors.
  rename("Export_Country" = Export.Country)

World$Group[World$region %in% c('South Africa','Turkey')] = 'AME'

fac_bt_cols <- c('Region', 'Year', 'Export_Country', 'Import_Region')
dfbt7[fac_bt_cols] <- lapply(dfbt7[fac_bt_cols], as.factor)
saveRDS(dfbt7,'Bilateral_trade_by_Region.rds')



