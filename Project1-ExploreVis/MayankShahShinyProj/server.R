library(dplyr)
library(rgdal) 
library(ggplot2)
library(readxl)
library(tidyr)
library(maps)
library(mapproj)
library(scales)
library(raster)
library(ggmap)
library(ggthemes)
library(rgeos)
library(maptools)
library(RgoogleMaps)
library(foreign)
library(readxl)
library(shiny)


MyShape <- readOGR(dsn = "./data", layer = "geo_export_64e1323f-442d-4e29-9483-f2a66ac6c867")
MyShapeMapData <- map_data(MyShape)
MajorKey <- read_excel("MajorKey.xlsx")
MyShapeMapData <- merge(MyShapeMapData, MajorKey, by.x= 'region', by.y = 'Region', all = TRUE)


CrimeData <- read_excel("byPrecinct.xls", col_names = TRUE)
CrimeData <- CrimeData %>% gather(Year, Occurrences, `2000.000000`:`2015.000000`)
CrimeData <- na.omit(CrimeData)
trim.trailing <- function (x) sub("\\s+$", "", x)
CrimeData$CRIME <- trim.trailing(CrimeData$CRIME)
CrimeData[,3] <- sapply(CrimeData[, 3], as.numeric)


#Assault
CrimeDataA00 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2000")
CrimeDataA00 <- inner_join(MyShapeMapData, CrimeDataA00, by = 'Precinct')
A00 <- ggplot(CrimeDataA00, aes(x = long, y = lat))
A00 <- A00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA01 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2001")
CrimeDataA01 <- inner_join(MyShapeMapData, CrimeDataA01, by = 'Precinct')
A01 <- ggplot(CrimeDataA01, aes(x = long, y = lat))
A01 <- A01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA02 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2002")
CrimeDataA02 <- inner_join(MyShapeMapData, CrimeDataA02, by = 'Precinct')
A02 <- ggplot(CrimeDataA02, aes(x = long, y = lat))
A02 <- A02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA03 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2003")
CrimeDataA03 <- inner_join(MyShapeMapData, CrimeDataA03, by = 'Precinct')
A03 <- ggplot(CrimeDataA03, aes(x = long, y = lat))
A03 <- A03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA04 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2004")
CrimeDataA04 <- inner_join(MyShapeMapData, CrimeDataA04, by = 'Precinct')
A04 <- ggplot(CrimeDataA04, aes(x = long, y = lat))
A04 <- A04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA05 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2005")
CrimeDataA05 <- inner_join(MyShapeMapData, CrimeDataA05, by = 'Precinct')
A05 <- ggplot(CrimeDataA05, aes(x = long, y = lat))
A05 <- A05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA06 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2006")
CrimeDataA06 <- inner_join(MyShapeMapData, CrimeDataA06, by = 'Precinct')
A06 <- ggplot(CrimeDataA06, aes(x = long, y = lat))
A06 <- A06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA07 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2007")
CrimeDataA07 <- inner_join(MyShapeMapData, CrimeDataA07, by = 'Precinct')
A07 <- ggplot(CrimeDataA07, aes(x = long, y = lat))
A07 <- A07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA08 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2008")
CrimeDataA08 <- inner_join(MyShapeMapData, CrimeDataA08, by = 'Precinct')
A08 <- ggplot(CrimeDataA08, aes(x = long, y = lat))
A08 <- A08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA09 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2009")
CrimeDataA09 <- inner_join(MyShapeMapData, CrimeDataA09, by = 'Precinct')
A09 <- ggplot(CrimeDataA09, aes(x = long, y = lat))
A09 <- A09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA10 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2010")
CrimeDataA10 <- inner_join(MyShapeMapData, CrimeDataA10, by = 'Precinct')
A10 <- ggplot(CrimeDataA10, aes(x = long, y = lat))
A10 <- A10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA11 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2011")
CrimeDataA11 <- inner_join(MyShapeMapData, CrimeDataA11, by = 'Precinct')
A11 <- ggplot(CrimeDataA11, aes(x = long, y = lat))
A11 <- A11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA12 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2012")
CrimeDataA12 <- inner_join(MyShapeMapData, CrimeDataA12, by = 'Precinct')
A12 <- ggplot(CrimeDataA12, aes(x = long, y = lat))
A12 <- A12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA13 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2013")
CrimeDataA13 <- inner_join(MyShapeMapData, CrimeDataA13, by = 'Precinct')
A13 <- ggplot(CrimeDataA13, aes(x = long, y = lat))
A13 <- A13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA14 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2014")
CrimeDataA14 <- inner_join(MyShapeMapData, CrimeDataA14, by = 'Precinct')
A14 <- ggplot(CrimeDataA14, aes(x = long, y = lat))
A14 <- A14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

CrimeDataA15 <- CrimeData %>% filter(CRIME == "FELONY ASSAULT" & Year == "2015")
CrimeDataA15 <- inner_join(MyShapeMapData, CrimeDataA15, by = 'Precinct')
A15 <- ggplot(CrimeDataA15, aes(x = long, y = lat))
A15 <- A15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 800), low="darkgreen",high="red")

#Burglary
CrimeDataB00 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2000")
CrimeDataB00 <- inner_join(MyShapeMapData, CrimeDataB00, by = 'Precinct')
B00 <- ggplot(CrimeDataB00, aes(x = long, y = lat))
B001 <- B00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(low="darkgreen",high="red")

CrimeDataB01 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2001")
CrimeDataB01 <- inner_join(MyShapeMapData, CrimeDataB01, by = 'Precinct')
B01 <- ggplot(CrimeDataB01, aes(x = long, y = lat))
B02 <- B01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB02 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2002")
CrimeDataB02 <- inner_join(MyShapeMapData, CrimeDataB02, by = 'Precinct')
B02 <- ggplot(CrimeDataB02, aes(x = long, y = lat))
B02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB03 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2003")
CrimeDataB03 <- inner_join(MyShapeMapData, CrimeDataB03, by = 'Precinct')
B03 <- ggplot(CrimeDataB03, aes(x = long, y = lat))
B03 <- B03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB04 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2004")
CrimeDataB04 <- inner_join(MyShapeMapData, CrimeDataB04, by = 'Precinct')
B04 <- ggplot(CrimeDataB04, aes(x = long, y = lat))
B04 <- B04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB05 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2005")
CrimeDataB05 <- inner_join(MyShapeMapData, CrimeDataB05, by = 'Precinct')
B05 <- ggplot(CrimeDataB05, aes(x = long, y = lat))
B05 <- B05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB06 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2006")
CrimeDataB06 <- inner_join(MyShapeMapData, CrimeDataB06, by = 'Precinct')
B06 <- ggplot(CrimeDataB06, aes(x = long, y = lat))
B06 <- B06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB07 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2007")
CrimeDataB07 <- inner_join(MyShapeMapData, CrimeDataB07, by = 'Precinct')
B07 <- ggplot(CrimeDataB07, aes(x = long, y = lat))
B07 <- B07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB08 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2008")
CrimeDataB08 <- inner_join(MyShapeMapData, CrimeDataB08, by = 'Precinct')
B08 <- ggplot(CrimeDataB08, aes(x = long, y = lat))
B08 <- B08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB09 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2009")
CrimeDataB09 <- inner_join(MyShapeMapData, CrimeDataB09, by = 'Precinct')
B09 <- ggplot(CrimeDataB09, aes(x = long, y = lat))
B09 <- B09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB10 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2010")
CrimeDataB10 <- inner_join(MyShapeMapData, CrimeDataB10, by = 'Precinct')
B10 <- ggplot(CrimeDataB10, aes(x = long, y = lat))
B010 <- B10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB11 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2011")
CrimeDataB11 <- inner_join(MyShapeMapData, CrimeDataB11, by = 'Precinct')
B11 <- ggplot(CrimeDataB11, aes(x = long, y = lat))
B011 <- B11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB12 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2012")
CrimeDataB12 <- inner_join(MyShapeMapData, CrimeDataB12, by = 'Precinct')
B12 <- ggplot(CrimeDataB12, aes(x = long, y = lat))
B012 <- B12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB13 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2013")
CrimeDataB13 <- inner_join(MyShapeMapData, CrimeDataB13, by = 'Precinct')
B13 <- ggplot(CrimeDataB13, aes(x = long, y = lat))
B013 <- B13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataB14 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2014")
CrimeDataB14 <- inner_join(MyShapeMapData, CrimeDataB14, by = 'Precinct')
B14 <- ggplot(CrimeDataB14, aes(x = long, y = lat))
B014 <- B14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")


CrimeDataB15 <- CrimeData %>% filter(CRIME == "BURGLARY" & Year == "2015")
CrimeDataB15 <- inner_join(MyShapeMapData, CrimeDataB15, by = 'Precinct')
B15 <- ggplot(CrimeDataB15, aes(x = long, y = lat))
B015 <- B15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 1100), low="darkgreen",high="red")

#Rape
CrimeDataR00 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2000")
CrimeDataR00 <- inner_join(MyShapeMapData, CrimeDataR00, by = 'Precinct')
R00 <- ggplot(CrimeDataR00, aes(x = long, y = lat))
R00 <- R00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(low="darkgreen",high="red")

CrimeDataR01 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2001")
CrimeDataR01 <- inner_join(MyShapeMapData, CrimeDataR01, by = 'Precinct')
R01 <- ggplot(CrimeDataR01, aes(x = long, y = lat))
R01 <- R01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR02 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2002")
CrimeDataR02 <- inner_join(MyShapeMapData, CrimeDataR02, by = 'Precinct')
R02 <- ggplot(CrimeDataR02, aes(x = long, y = lat))
R02 <- R02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR03 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2003")
CrimeDataR03 <- inner_join(MyShapeMapData, CrimeDataR03, by = 'Precinct')
R03 <- ggplot(CrimeDataR03, aes(x = long, y = lat))
R03 <- R03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR04 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2004")
CrimeDataR04 <- inner_join(MyShapeMapData, CrimeDataR04, by = 'Precinct')
R04 <- ggplot(CrimeDataR04, aes(x = long, y = lat))
R04 <- R04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR05 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2005")
CrimeDataR05 <- inner_join(MyShapeMapData, CrimeDataR05, by = 'Precinct')
R05 <- ggplot(CrimeDataR05, aes(x = long, y = lat))
R05 <- R05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR06 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2006")
CrimeDataR06 <- inner_join(MyShapeMapData, CrimeDataR06, by = 'Precinct')
R06 <- ggplot(CrimeDataR06, aes(x = long, y = lat))
R06 <- R06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR07 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2007")
CrimeDataR07 <- inner_join(MyShapeMapData, CrimeDataR07, by = 'Precinct')
R07 <- ggplot(CrimeDataR07, aes(x = long, y = lat))
R07 <- R07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR08 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2008")
CrimeDataR08 <- inner_join(MyShapeMapData, CrimeDataR08, by = 'Precinct')
R08 <- ggplot(CrimeDataR08, aes(x = long, y = lat))
R08 <- R08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR09 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2009")
CrimeDataR09 <- inner_join(MyShapeMapData, CrimeDataR09, by = 'Precinct')
R09 <- ggplot(CrimeDataR09, aes(x = long, y = lat))
R09 <- R09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")


CrimeDataR10 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2010")
CrimeDataR10 <- inner_join(MyShapeMapData, CrimeDataR10, by = 'Precinct')
R10 <- ggplot(CrimeDataR10, aes(x = long, y = lat))
R10 <- R10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR11 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2011")
CrimeDataR11 <- inner_join(MyShapeMapData, CrimeDataR11, by = 'Precinct')
R11 <- ggplot(CrimeDataR11, aes(x = long, y = lat))
R11 <- R11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")


CrimeDataR12 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2012")
CrimeDataR12 <- inner_join(MyShapeMapData, CrimeDataR12, by = 'Precinct')
R12 <- ggplot(CrimeDataR12, aes(x = long, y = lat))
R12 <- R12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR13 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2013")
CrimeDataR13 <- inner_join(MyShapeMapData, CrimeDataR13, by = 'Precinct')
R13 <- ggplot(CrimeDataR13, aes(x = long, y = lat))
R13 <- R13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")


CrimeDataR14 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2014")
CrimeDataR14 <- inner_join(MyShapeMapData, CrimeDataR14, by = 'Precinct')
R14 <- ggplot(CrimeDataR14, aes(x = long, y = lat))
R14 <- R14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")

CrimeDataR15 <- CrimeData %>% filter(CRIME == "RAPE" & Year == "2015")
CrimeDataR15 <- inner_join(MyShapeMapData, CrimeDataR15, by = 'Precinct')
R15 <- ggplot(CrimeDataR15, aes(x = long, y = lat))
R15 <- R15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(limits = c(0, 110), low="darkgreen",high="red")



#Grand Larceny
CrimeDataG00 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2000")
CrimeDataG00 <- inner_join(MyShapeMapData, CrimeDataG00, by = 'Precinct')
G00 <- ggplot(CrimeDataG00, aes(x = long, y = lat))
G00 <- G00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")


CrimeDataG01 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2001")
CrimeDataG01 <- inner_join(MyShapeMapData, CrimeDataG01, by = 'Precinct')
G01 <- ggplot(CrimeDataG01, aes(x = long, y = lat))
G01 <- G01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")                                                              

CrimeDataG02 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2002")
CrimeDataG02 <- inner_join(MyShapeMapData, CrimeDataG02, by = 'Precinct')
G02 <- ggplot(CrimeDataG02, aes(x = long, y = lat))
G02 <- G02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")                                           

CrimeDataG03 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2003")
CrimeDataG03 <- inner_join(MyShapeMapData, CrimeDataG03, by = 'Precinct')
G03 <- ggplot(CrimeDataG03, aes(x = long, y = lat))
G03 <- G03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG04 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2004")
CrimeDataG04 <- inner_join(MyShapeMapData, CrimeDataG04, by = 'Precinct')
G04 <- ggplot(CrimeDataG04, aes(x = long, y = lat))
G04 <- G04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG05 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2005")
CrimeDataG05 <- inner_join(MyShapeMapData, CrimeDataG05, by = 'Precinct')
G05 <- ggplot(CrimeDataG05, aes(x = long, y = lat))
G05 <- G05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG06 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2006")
CrimeDataG06 <- inner_join(MyShapeMapData, CrimeDataG06, by = 'Precinct')
G06 <- ggplot(CrimeDataG06, aes(x = long, y = lat))
G06 <- G06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG07 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2007")
CrimeDataG07 <- inner_join(MyShapeMapData, CrimeDataG07, by = 'Precinct')
G07 <- ggplot(CrimeDataG07, aes(x = long, y = lat))
G07 <- G07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG08 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2008")
CrimeDataG08 <- inner_join(MyShapeMapData, CrimeDataG08, by = 'Precinct')
G08 <- ggplot(CrimeDataG08, aes(x = long, y = lat))
G08 <- G08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG09 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2009")
CrimeDataG09 <- inner_join(MyShapeMapData, CrimeDataG09, by = 'Precinct')
G09 <- ggplot(CrimeDataG09, aes(x = long, y = lat))
G09 <- G09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG10 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2010")
CrimeDataG10 <- inner_join(MyShapeMapData, CrimeDataG10, by = 'Precinct')
G10 <- ggplot(CrimeDataG10, aes(x = long, y = lat))
G10 <- G10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG11 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2011")
CrimeDataG11 <- inner_join(MyShapeMapData, CrimeDataG11, by = 'Precinct')
G11 <- ggplot(CrimeDataG11, aes(x = long, y = lat))
G11 <- G11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG12 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2012")
CrimeDataG12 <- inner_join(MyShapeMapData, CrimeDataG12, by = 'Precinct')
G12 <- ggplot(CrimeDataG12, aes(x = long, y = lat))
G12 <- G12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG13 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2013")
CrimeDataG13 <- inner_join(MyShapeMapData, CrimeDataG13, by = 'Precinct')
G13 <- ggplot(CrimeDataG13, aes(x = long, y = lat))
G13 <- G13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG14 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2014")
CrimeDataG14 <- inner_join(MyShapeMapData, CrimeDataG14, by = 'Precinct')
G14 <- ggplot(CrimeDataG14, aes(x = long, y = lat))
G14 <- G14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

CrimeDataG15 <- CrimeData %>% filter(CRIME == "GRAND LARCENY" & Year == "2015")
CrimeDataG15 <- inner_join(MyShapeMapData, CrimeDataG15, by = 'Precinct')
G15 <- ggplot(CrimeDataG15, aes(x = long, y = lat))
G15 <- G15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 3000), low="darkgreen",high="red")  

#Robbery
CrimeDataRO00 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2000")
CrimeDataRO00 <- inner_join(MyShapeMapData, CrimeDataRO00, by = 'Precinct')
RO00 <- ggplot(CrimeDataRO00, aes(x = long, y = lat))
RO00 <- RO00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")


CrimeDataRO01 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2001")
CrimeDataRO01 <- inner_join(MyShapeMapData, CrimeDataRO01, by = 'Precinct')
RO01 <- ggplot(CrimeDataRO01, aes(x = long, y = lat))
RO01 <- RO01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO02 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2002")
CrimeDataRO02 <- inner_join(MyShapeMapData, CrimeDataRO02, by = 'Precinct')
RO02 <- ggplot(CrimeDataRO02, aes(x = long, y = lat))
RO02 <- RO02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO03 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2003")
CrimeDataRO03 <- inner_join(MyShapeMapData, CrimeDataRO03, by = 'Precinct')
RO03 <- ggplot(CrimeDataRO03, aes(x = long, y = lat))
RO03 <- RO03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO04 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2004")
CrimeDataRO04 <- inner_join(MyShapeMapData, CrimeDataRO04, by = 'Precinct')
RO04 <- ggplot(CrimeDataRO04, aes(x = long, y = lat))
RO04 <- RO04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO05 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2005")
CrimeDataRO05 <- inner_join(MyShapeMapData, CrimeDataRO05, by = 'Precinct')
RO05 <- ggplot(CrimeDataRO05, aes(x = long, y = lat))
RO05 <- RO05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO06 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2006")
CrimeDataRO06 <- inner_join(MyShapeMapData, CrimeDataRO06, by = 'Precinct')
RO06 <- ggplot(CrimeDataRO06, aes(x = long, y = lat))
RO06 <- RO06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO07 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2007")
CrimeDataRO07 <- inner_join(MyShapeMapData, CrimeDataRO07, by = 'Precinct')
RO07 <- ggplot(CrimeDataRO07, aes(x = long, y = lat))
RO07 <- RO07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO08 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2008")
CrimeDataRO08 <- inner_join(MyShapeMapData, CrimeDataRO08, by = 'Precinct')
RO08 <- ggplot(CrimeDataRO08, aes(x = long, y = lat))
RO08 <- RO08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO09 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2009")
CrimeDataRO09 <- inner_join(MyShapeMapData, CrimeDataRO09, by = 'Precinct')
RO09 <- ggplot(CrimeDataRO09, aes(x = long, y = lat))
RO09 <- RO09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO10 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2010")
CrimeDataRO10 <- inner_join(MyShapeMapData, CrimeDataRO10, by = 'Precinct')
RO10 <- ggplot(CrimeDataRO10, aes(x = long, y = lat))
RO10 <- RO10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO11 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2011")
CrimeDataRO11 <- inner_join(MyShapeMapData, CrimeDataRO11, by = 'Precinct')
RO11 <- ggplot(CrimeDataRO11, aes(x = long, y = lat))
RO11 <- RO11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO12 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2012")
CrimeDataRO12 <- inner_join(MyShapeMapData, CrimeDataRO12, by = 'Precinct')
RO12 <- ggplot(CrimeDataRO12, aes(x = long, y = lat))
RO12 <- RO12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO13 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2013")
CrimeDataRO13 <- inner_join(MyShapeMapData, CrimeDataRO13, by = 'Precinct')
RO13 <- ggplot(CrimeDataRO13, aes(x = long, y = lat))
RO13 <- RO13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO14 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2014")
CrimeDataRO14 <- inner_join(MyShapeMapData, CrimeDataRO14, by = 'Precinct')
RO14 <- ggplot(CrimeDataRO14, aes(x = long, y = lat))
RO14 <- RO14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

CrimeDataRO15 <- CrimeData %>% filter(CRIME == "ROBBERY" & Year == "2015")
CrimeDataRO15 <- inner_join(MyShapeMapData, CrimeDataRO15, by = 'Precinct')
RO15 <- ggplot(CrimeDataRO15, aes(x = long, y = lat))
RO15 <- RO15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1000), low="darkgreen",high="red")

#Murder

CrimeDataM00 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2000")
CrimeDataM00 <- inner_join(MyShapeMapData, CrimeDataM00, by = 'Precinct')
M00 <- ggplot(CrimeDataM00, aes(x = long, y = lat))
M00 <- M00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM01 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2001")
CrimeDataM01 <- inner_join(MyShapeMapData, CrimeDataM01, by = 'Precinct')
M01 <- ggplot(CrimeDataM01, aes(x = long, y = lat))
M01 <- M01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM02 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2002")
CrimeDataM02 <- inner_join(MyShapeMapData, CrimeDataM02, by = 'Precinct')
M02 <- ggplot(CrimeDataM02, aes(x = long, y = lat))
M02 <- M02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM03 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2003")
CrimeDataM03 <- inner_join(MyShapeMapData, CrimeDataM03, by = 'Precinct')
M03 <- ggplot(CrimeDataM03, aes(x = long, y = lat))
M03 <- M03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM04 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2004")
CrimeDataM04 <- inner_join(MyShapeMapData, CrimeDataM04, by = 'Precinct')
M04 <- ggplot(CrimeDataM04, aes(x = long, y = lat))
M04 <- M04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM05 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2005")
CrimeDataM05 <- inner_join(MyShapeMapData, CrimeDataM05, by = 'Precinct')
M05 <- ggplot(CrimeDataM05, aes(x = long, y = lat))
M05 <- M05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM06 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2006")
CrimeDataM06 <- inner_join(MyShapeMapData, CrimeDataM06, by = 'Precinct')
M06 <- ggplot(CrimeDataM06, aes(x = long, y = lat))
M06 <- M06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM07 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2007")
CrimeDataM07 <- inner_join(MyShapeMapData, CrimeDataM07, by = 'Precinct')
M07 <- ggplot(CrimeDataM07, aes(x = long, y = lat))
M07 <- M07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM08 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2008")
CrimeDataM08 <- inner_join(MyShapeMapData, CrimeDataM08, by = 'Precinct')
M08 <- ggplot(CrimeDataM08, aes(x = long, y = lat))
M08 <- M08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM09 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2009")
CrimeDataM09 <- inner_join(MyShapeMapData, CrimeDataM09, by = 'Precinct')
M09 <- ggplot(CrimeDataM09, aes(x = long, y = lat))
M09 <- M09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM10 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2010")
CrimeDataM10 <- inner_join(MyShapeMapData, CrimeDataM10, by = 'Precinct')
M10 <- ggplot(CrimeDataM10, aes(x = long, y = lat))
M10 <- M10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")


CrimeDataM11 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2011")
CrimeDataM11 <- inner_join(MyShapeMapData, CrimeDataM11, by = 'Precinct')
M11 <- ggplot(CrimeDataM11, aes(x = long, y = lat))
M11 <- M11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM12 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2012")
CrimeDataM12 <- inner_join(MyShapeMapData, CrimeDataM12, by = 'Precinct')
M12 <- ggplot(CrimeDataM12, aes(x = long, y = lat))
M12 <- M12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM13 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2013")
CrimeDataM13 <- inner_join(MyShapeMapData, CrimeDataM13, by = 'Precinct')
M13 <- ggplot(CrimeDataM13, aes(x = long, y = lat))
M13 <- M13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM14 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2014")
CrimeDataM14 <- inner_join(MyShapeMapData, CrimeDataM14, by = 'Precinct')
M14 <- ggplot(CrimeDataM14, aes(x = long, y = lat))
M14 <- M14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

CrimeDataM15 <- CrimeData %>% filter(CRIME == "MURDER & NON NEGL. MANSLAUGHTER" & Year == "2015")
CrimeDataM15 <- inner_join(MyShapeMapData, CrimeDataM15, by = 'Precinct')
M15 <- ggplot(CrimeDataM15, aes(x = long, y = lat))
M15 <- M15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 30), low="darkgreen",high="red")

#Motor Theft

CrimeDataMT00 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2000")
CrimeDataMT00 <- inner_join(MyShapeMapData, CrimeDataMT00, by = 'Precinct')
MT00 <- ggplot(CrimeDataMT00, aes(x = long, y = lat))
MT00 <- MT00 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT01 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2001")
CrimeDataMT01 <- inner_join(MyShapeMapData, CrimeDataMT01, by = 'Precinct')
MT01 <- ggplot(CrimeDataMT01, aes(x = long, y = lat))
MT01 <- MT01 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT02 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2002")
CrimeDataMT02 <- inner_join(MyShapeMapData, CrimeDataMT02, by = 'Precinct')
MT02 <- ggplot(CrimeDataMT02, aes(x = long, y = lat))
MT02 <- MT02 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT03 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2003")
CrimeDataMT03 <- inner_join(MyShapeMapData, CrimeDataMT03, by = 'Precinct')
MT03 <- ggplot(CrimeDataMT03, aes(x = long, y = lat))
MT03 <- MT03 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT04 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2004")
CrimeDataMT04 <- inner_join(MyShapeMapData, CrimeDataMT04, by = 'Precinct')
MT04 <- ggplot(CrimeDataMT04, aes(x = long, y = lat))
MT04 <- MT04 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT05 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2005")
CrimeDataMT05 <- inner_join(MyShapeMapData, CrimeDataMT05, by = 'Precinct')
MT05 <- ggplot(CrimeDataMT05, aes(x = long, y = lat))
MT05 <- MT05 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT06 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2006")
CrimeDataMT06 <- inner_join(MyShapeMapData, CrimeDataMT06, by = 'Precinct')
MT06 <- ggplot(CrimeDataMT06, aes(x = long, y = lat))
MT06 <- MT06 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT07 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2007")
CrimeDataMT07 <- inner_join(MyShapeMapData, CrimeDataMT07, by = 'Precinct')
MT07 <- ggplot(CrimeDataMT07, aes(x = long, y = lat))
MT07 <- MT07 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT08 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2008")
CrimeDataMT08 <- inner_join(MyShapeMapData, CrimeDataMT08, by = 'Precinct')
MT08 <- ggplot(CrimeDataMT08, aes(x = long, y = lat))
MT08 <- MT08 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT09 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2009")
CrimeDataMT09 <- inner_join(MyShapeMapData, CrimeDataMT09, by = 'Precinct')
MT09 <- ggplot(CrimeDataMT09, aes(x = long, y = lat))
MT09 <- MT09 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT10 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2010")
CrimeDataMT10 <- inner_join(MyShapeMapData, CrimeDataMT10, by = 'Precinct')
MT10 <- ggplot(CrimeDataMT10, aes(x = long, y = lat))
MT10 <- MT10 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT11 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2011")
CrimeDataMT11 <- inner_join(MyShapeMapData, CrimeDataMT11, by = 'Precinct')
MT11 <- ggplot(CrimeDataMT11, aes(x = long, y = lat))
MT11 <- MT11 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT12 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2012")
CrimeDataMT12 <- inner_join(MyShapeMapData, CrimeDataMT12, by = 'Precinct')
MT12 <- ggplot(CrimeDataMT12, aes(x = long, y = lat))
MT12 <- MT12 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT13 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2013")
CrimeDataMT13 <- inner_join(MyShapeMapData, CrimeDataMT13, by = 'Precinct')
MT13 <- ggplot(CrimeDataMT13, aes(x = long, y = lat))
MT13 <- MT13 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT14 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2014")
CrimeDataMT14 <- inner_join(MyShapeMapData, CrimeDataMT14, by = 'Precinct')
MT14 <- ggplot(CrimeDataMT14, aes(x = long, y = lat))
MT14 <- MT14 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")

CrimeDataMT15 <- CrimeData %>% filter(CRIME == "GRAND LARCENY OF MOTOR VEHICLE" & Year == "2015")
CrimeDataMT15 <- inner_join(MyShapeMapData, CrimeDataMT15, by = 'Precinct')
MT15 <- ggplot(CrimeDataMT15, aes(x = long, y = lat))
MT15 <- MT15 + geom_polygon(aes(group = group, fill = Occurrences)) + scale_fill_gradient(oob = squish, limits = c(0, 1100), low="darkgreen",high="red")


CrimeDataA00 <- recordPlot()


shinyServer(function(input, output){
  crime2 <- reactive({
    switch(input$select,
           "Assault" = "A",
           "Burglary" = "B",
           "Car Theft" = "MT",
           "Grand Larceny" = "G",
           "Murder" = "M",
           "Rape" = "R",
           "Robbery" = "RO")  
  })
  
  year2 <- reactive({
    switch(as.character(input$Slider),
           "2000" = "00",
           "2001" = "01",
           "2002" = "02",
           "2003" = "03",
           "2004" = "04",
           "2005" = "05",
           "2006" = "06",
           "2007" = "07",
           "2008" = "08",
           "2009" = "09",
           "2010" = "10",
           "2011" = "11",
           "2012" = "12",
           "2013" = "13",
           "2014" = "14",
           "2015" = "15")  
  })
  
  output$plot <- renderPlot({
    get(paste0(crime2(), year2()))
  })
  
  
})