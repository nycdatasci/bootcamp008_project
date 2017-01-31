library(dplyr)
library(lubridate)
library(tidyr)
library(shiny)
library(shinydashboard)
library(leaflet)
library(leaflet.extras)
library(readr)
library(xts)
library(dygraphs)

#import data
drilling_activity <- read.csv("./www/drilling_activity.csv")
drilling_activity$Date <- mdy(factor(drilling_activity$Date))
drilling_activity <- drilling_activity %>%
  mutate(YearMonth = format(Date, "%y-%m-01")) %>%
  filter(Date > ymd("2012-01-01"))

well_licences <- read.csv(file = "./www/well_licences.csv")
well_licences$Date <- ymd(well_licences$Date)
well_licences <- well_licences %>%
  mutate(YearMonth = format(Date, "%y-%m-01")) %>%
  filter(Date > ymd("2012-01-01"))

pipelinesConst <- read.csv(file = "./www/pipelinesConst.csv")
pipelinesConst$Date <- dmy(factor(pipelinesConst$ActivityStartDate))
pipelinesConst <- pipelinesConst %>%
  filter(!is.na(pipelinesConst$Date)) %>%
  filter(Date > ymd("2012-01-01")) %>%
  mutate(YearMonth = format(Date, "%y-%m-01"))

abandoned_wells <- read.csv(file = "./www/abandoned_wells.csv")

prices <- read_csv("./www/prices.csv")
production <- read_csv("./www/production.csv")

abMap <- leaflet() %>%
  addProviderTiles("Thunderforest.Landscape", options = providerTileOptions(opacity = .9),
                   group = "Map") %>%
  addProviderTiles("CartoDB.DarkMatter",
                   group = "Lights Off")  %>%
  setMaxBounds(-135,45,-90,62) %>%
  setView(lng = -125.45, lat = 55, zoom = 5)



############################ Drilling Activity #######################Thunderforest.TransportDark################################
#1Number of wells by month
drillsByMonth <- drilling_activity %>%
  group_by(YearMonth) %>%
  summarise(Number = n()) %>%
  arrange(desc(YearMonth))

YearMonth1 <- as.Date(drillsByMonth$YearMonth, "%y-%m-%d")
drillsByMonthxts <- xts(drillsByMonth, order.by = YearMonth1)
drillsByMonthG <- dygraph(drillsByMonthxts, main = "Number of New Wells Drilled"
) %>%
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)



#2no of drillers active by month
drillersByMonth <- drilling_activity %>%
  group_by(Drilling.Contractor,YearMonth) %>%
  distinct() %>%
  ungroup() %>%
  group_by(YearMonth) %>%
  summarise(Active = n()) %>%
  arrange(desc(YearMonth))

YearMonth1 <- as.Date(drillersByMonth$YearMonth, "%y-%m-%d")
drillersByMonthxts <- xts(drillersByMonth, order.by = YearMonth1)
drillersByMonthG <- dygraph(drillersByMonthxts, main = "Number of Drilling Contractors Active") %>%
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)

#3Number of licencees active during a month
licenceesByMonthDA <- drilling_activity %>%
  group_by(Licencee,YearMonth) %>%
  distinct() %>%
  ungroup() %>%
  group_by(YearMonth) %>%
  summarise(Active = n()) %>%
  arrange(desc(YearMonth))
YearMonth1 <- as.Date(licenceesByMonthDA$YearMonth, "%y-%m-%d")
licenceesByMonthDAxts <- xts(licenceesByMonthDA, order.by = YearMonth1)
licenceesByMonthDAG <- dygraph(licenceesByMonthDAxts, main = "Number of Licencees Active by Month") %>% 
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)


#4Top five Contractors Over Time
top5Contr <- drilling_activity %>%
  group_by(Drilling.Contractor) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(top5Contr, as.character)
top5Time <- drilling_activity %>%
  filter(Drilling.Contractor == t$Drilling.Contractor[1] | Drilling.Contractor == t$Drilling.Contractor[2] |
           Drilling.Contractor == t$Drilling.Contractor[3] | Drilling.Contractor == t$Drilling.Contractor[4] |
           Drilling.Contractor == t$Drilling.Contractor[5]) %>%
  group_by(Drilling.Contractor, YearMonth) %>%
  count(sort = T) 
ts <- spread(top5Time, Drilling.Contractor, n)

YearMonth1 <- as.Date(ts$YearMonth, "%y-%m-%d")
tsxts <- xts(ts, order.by = YearMonth1)

top5TimeG <- dygraph(tsxts, main = "Top Five Drilling Contractors") %>%
  dyAxis("y", label = "Wells Drilled") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 1) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set1")) %>%
  dyLegend(width = 500)



#5Top five Licencees over time
top5Lic <- drilling_activity %>%
  group_by(Licencee) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(top5Lic, as.character)
top5TimeLic <- drilling_activity %>%
  filter(Licencee == t$Licencee[1] | Licencee == t$Licencee[2] |
           Licencee == t$Licencee[3] | Licencee == t$Licencee[4] |
           Licencee == t$Licencee[5]) %>%
  group_by(Licencee, YearMonth) %>%
  count(sort = T) 
tsLic <- spread(top5TimeLic, Licencee, n)

YearMonth1 <- as.Date(tsLic$YearMonth, "%y-%m-%d")
tsLicxts <- xts(tsLic, order.by = YearMonth1)
top5TimeLicG <- dygraph(tsLicxts, main = "Top Five Permit Holders") %>%
  dyAxis("y", label = "Wells Drilled") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 1) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)



#6 Five most active counties over time
top5LicCountyDA <- drilling_activity %>%
  group_by(County.Name) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(top5LicCountyDA, as.character)
top5TimeLicCountyDA <- drilling_activity %>%
  filter(County.Name == t$County.Name[1] | County.Name == t$County.Name[2] |
           County.Name == t$County.Name[3] | County.Name == t$County.Name[4] |
           County.Name == t$County.Name[5]) %>%
  group_by(County.Name, YearMonth) %>%
  count(sort = T) 
tsLic <- spread(top5TimeLicCountyDA, County.Name, n)

YearMonth1 <- as.Date(tsLic$YearMonth, "%y-%m-%d")
tsLicxts <- xts(tsLic, order.by = YearMonth1)
top5TimeLicCountyDAG <- dygraph(tsLicxts, main = "Top Five Counties") %>%
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 1) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set1")) %>%
  dyLegend(width = 500)


#7 Top reasons for drilling wells
top5LicReasonsDA <- drilling_activity %>%
  group_by(Activity.Type) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(top5LicReasonsDA, as.character)
top5TimeLicReasonsDA <- drilling_activity %>%
  filter(Activity.Type == t$Activity.Type[1] | Activity.Type == t$Activity.Type[2] |
           Activity.Type == t$Activity.Type[3] | Activity.Type == t$Activity.Type[4] |
           Activity.Type == t$Activity.Type[5]) %>%
  group_by(Activity.Type, YearMonth) %>%
  count(sort = T) 
tsLic <- spread(top5TimeLicReasonsDA, Activity.Type, n)

YearMonth1 <- as.Date(tsLic$YearMonth, "%y-%m-%d")
tsLicxts <- xts(tsLic, order.by = YearMonth1)
top5TimeLicReasonDAG <- dygraph(tsLicxts, main = "Top Reasons for Drilling") %>%
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 1) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)


############################ Licences #######################################################

#Licences given out
licencesByMonthLic <- well_licences %>%
  group_by(YearMonth) %>%
  summarise(Number = n()) %>%
  arrange(desc(YearMonth))
YearMonth1 <- as.Date(licencesByMonthLic$YearMonth, "%y-%m-%d")
licencesByMonthLicxts <- xts(licencesByMonthLic, order.by = YearMonth1)
licencesByMonthLicG <- dygraph(licencesByMonthLicxts, main = "Number of Licences Issued") %>% 
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)



#Licencees active by month
licenceesByMonthLic <- well_licences %>%
  group_by(Licencee,YearMonth) %>%
  distinct() %>%
  ungroup() %>%
  group_by(YearMonth) %>%
  summarise(Number = n()) %>%
  arrange(desc(YearMonth))
YearMonth1 <- as.Date(licenceesByMonthLic$YearMonth, "%y-%m-%d")
licenceesByMonthLicxts <- xts(licenceesByMonthLic, order.by = YearMonth1)
licenceesByMonthLicG <- dygraph(licenceesByMonthLicxts, main = "Number of Licencees Active by Month") %>% 
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)


#Types of wells
typesLic <- well_licences %>%
  group_by(YearMonth,Substance) %>%
  count() %>%
  arrange(desc(YearMonth))
tL <- spread(typesLic, Substance, n)

YearMonth1 <- as.Date(tL$YearMonth, "%y-%m-%d")
tLxts <- xts(tL, order.by = YearMonth1)
typesLicG <- dygraph(tLxts, main = "Number of Wells by Product") %>% 
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 1) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(6, "Set1")) %>%
  dyLegend(width = 500)


#Depths by drilling type
depthsTypes <- well_licences %>%
  group_by(YearMonth, Drilling.Type) %>%
  summarise(AverageDepth = mean(Projected.Depth))

dL <- spread(depthsTypes, Drilling.Type, AverageDepth)

YearMonth1 <- as.Date(dL$YearMonth, "%y-%m-%d")
dLxts <- xts(dL, order.by = YearMonth1)
depthsTypesG <- dygraph(dLxts, main = "Average Depth by Well Type") %>% 
  dyAxis("y", label = "Depth (m)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 1) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 3)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)


#Depths by substance
depthsSubstance <- well_licences %>%
  group_by(Substance) %>%
  count(sort = T) %>%
  top_n(5) 

t <- lapply(depthsSubstance, as.character)
depthsSubstanceTime <- well_licences %>%
  filter(Substance == t$Substance[1] | Substance == t$Substance[2] |
           Substance == t$Substance[3] | Substance == t$Substance[4] |
           Substance == t$Substance[5]) %>%
  group_by(Substance, YearMonth) %>%
  summarise(avDepth = mean(Projected.Depth))

dL <- spread(depthsSubstanceTime, Substance, avDepth)

YearMonth1 <- as.Date(dL$YearMonth, "%y-%m-%d")
dLxts <- xts(dL, order.by = YearMonth1)
depthsSubstanceG <- dygraph(dLxts, main = "Average Projected Depth by Substance") %>% 
  dyAxis("y", label = "Depth (m)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(6, "Set2")) %>%
  dyLegend(width = 500)


#Depths by well type
depthsWellTypes <- well_licences %>%
  group_by(Well.Type) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(depthsWellTypes, as.character)
depthsWellTypesTime <- well_licences %>%
  filter(Well.Type == t$Well.Type[1] | Well.Type == t$Well.Type[2] |
           Well.Type == t$Well.Type[3] | Well.Type == t$Well.Type[4] |
           Well.Type == t$Well.Type[5]) %>%
  group_by(Well.Type, YearMonth) %>%
  summarise(avDepth = mean(Projected.Depth))

dL <- spread(depthsWellTypesTime, Well.Type, avDepth)

YearMonth1 <- as.Date(dL$YearMonth, "%y-%m-%d")
dLxts <- xts(dL, order.by = YearMonth1)

depthsWellTypesTimeG <- dygraph(dLxts, main = "Average Projected Depth by Substance") %>% 
  dyAxis("y", label = "Depth (m)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)


#Depths by companies
depthsCompanies <- well_licences %>%
  group_by(Licencee) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(depthsCompanies, as.character)
depthsCompaniesTime <- well_licences %>%
  filter(Licencee == t$Licencee[1] | Licencee == t$Licencee[2] |
           Licencee == t$Licencee[3] | Licencee == t$Licencee[4] |
           Licencee == t$Licencee[5]) %>%
  group_by(Licencee, YearMonth) %>%
  summarise(AvDepth = mean(Projected.Depth))

dL <- spread(depthsCompaniesTime, Licencee, AvDepth)

YearMonth1 <- as.Date(dL$YearMonth, "%y-%m-%d")
dLxts <- xts(dL, order.by = YearMonth1)
depthsCompaniesG <- dygraph(dLxts, main = "Average Depths by Companies") %>% 
  dyAxis("y", label = "Depth (m)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)


########################## Pipelines ########################################
#1 Number of pipeline starts per day
pipesByMonth <- pipelinesConst %>%
  group_by(YearMonth) %>%
  summarise(Number = n()) %>%
  arrange(desc(YearMonth))

YearMonth1 <- as.Date(pipesByMonth$YearMonth, "%y-%m-%d")
pipesByMonthxts <- xts(pipesByMonth, order.by = YearMonth1)
pipesByMonthG <- dygraph(pipesByMonthxts, main = "Pipeline Construction Starts") %>% 
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)


#2 Number of companies starting pipeline construction
permiteesByMonth <- pipelinesConst %>%
  group_by(Licencee,YearMonth) %>%
  distinct() %>%
  ungroup() %>%
  group_by(YearMonth) %>%
  summarise(Number = n())

YearMonth1 <- as.Date(permiteesByMonth$YearMonth, "%y-%m-%d")
permiteesByMonthxts <- xts(permiteesByMonth, order.by = YearMonth1)
permiteesByMonthG <- dygraph(permiteesByMonthxts, main = "Number of Companies Starting Pipeline Construction") %>% 
  dyAxis("y", label = "Number") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)


#3 Length of pipelines on which construction began
lengthByMonth <- pipelinesConst %>%
  group_by(YearMonth) %>%
  summarise(Length = sum(Length)) %>%
  arrange(desc(YearMonth))

YearMonth1 <- as.Date(lengthByMonth$YearMonth, "%y-%m-%d")
lengthByMonthxts <- xts(lengthByMonth, order.by = YearMonth1)
lengthByMonthG <- dygraph(lengthByMonthxts, main = "Projected Length of Pipeline Starts") %>% 
  dyAxis("y", label = "Length (km)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = 2) %>%
  dyHighlight(highlightCircleSize = 5, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T)


#4 County where the pipeline started
countyFromMonth <- pipelinesConst %>%
  group_by(County.From) %>%
  count(sort = T) %>%
  top_n(5)


t <- lapply(countyFromMonth, as.character)
countyFromMonthTime <- pipelinesConst %>%
  filter(County.From == t$County.From[1] | County.From == t$County.From[2] |
           County.From == t$County.From[3] | County.From == t$County.From[4] |
           County.From == t$County.From[5]) %>%
  group_by(County.From, YearMonth) %>%
  summarise(Number = n())

dL <- spread(countyFromMonthTime, County.From, Number)

YearMonth1 <- as.Date(dL$YearMonth, "%y-%m-%d")
dLxts <- xts(dL, order.by = YearMonth1)
countyFromMonthG <- dygraph(dLxts, main = "Projected Length of Pipeline by County") %>% 
  dyAxis("y", label = "Length (km)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)

#5 County where the pipeline ended
countyToMonth <- pipelinesConst %>%
  group_by(County.To) %>%
  count(sort = T) %>%
  top_n(5)

t <- lapply(countyToMonth, as.character)
countyToMonthTime <- pipelinesConst %>%
  filter(County.To == t$County.To[1] | County.To == t$County.To[2] |
           County.To == t$County.To[3] | County.To == t$County.To[4] |
           County.To == t$County.To[5]) %>%
  group_by(County.To, YearMonth) %>%
  summarise(Number = n())


dL <- spread(countyToMonthTime, County.To, Number)

YearMonth1 <- as.Date(dL$YearMonth, "%y-%m-%d")
dLxts <- xts(dL, order.by = YearMonth1)
countyToMonthG <- dygraph(dLxts, main = "Projected Length of Pipeline by County") %>% 
  dyAxis("y", label = "Length (km)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)


########################## Price and volume #######################################

#Prices Chart
YearMonth1 <- mdy(prices$Date)
pricesByMonthxts <- xts(prices, order.by = YearMonth1)
pricesG <- dygraph(pricesByMonthxts, main = "Prices of Light and Heavy WCS in US$") %>% 
  dyAxis("y", label = "Price (US$)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set2")) %>%
  dyLegend(width = 500)


YearMonth1 <- mdy(production$Date)
productionByMonthxts <- xts(production, order.by = YearMonth1)

productionG <- dygraph(productionByMonthxts, main = "Production") %>% 
  dyAxis("y", label = "Volume (10,000 cu m)") %>%
  dyAxis("x", label = "Period") %>%
  dyOptions(drawPoints = TRUE, pointSize = .8) %>%
  dyHighlight(highlightCircleSize = 3, 
              highlightSeriesBackgroundAlpha = 0.2,
              hideOnMouseOut = T, highlightSeriesOpts = list(strokeWidth = 2)) %>%
  dyOptions(colors = RColorBrewer::brewer.pal(5, "Set1")) %>%
  dyLegend(width = 500)




################## ABANDONED WELLS CALCULATIONS #################################
mostAbndWellsFrom <- abandoned_wells %>%
  group_by(Licensee) %>%
  count(sort = T) %>%
  top_n(1)

categoryAbnd <- abandoned_wells %>%
  filter(Fluid == "Not Applicable")
