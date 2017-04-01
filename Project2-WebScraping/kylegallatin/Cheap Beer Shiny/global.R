#global.R
library(dplyr)
library(tidyr)
library(ggplot2)


coors <- read.csv("data/coors.csv")
coorsLight <- read.csv("data/coorsLight.csv")
bud = read.csv("data/bud.csv")
budLight = read.csv("data/budLight.csv")
busch = read.csv("data/busch.csv")
buschLight = read.csv("data/buschLight.csv")
nattyIce = read.csv("data/nattyIce.csv")
nattyLight = read.csv("data/nattyLight.csv")
highLife = read.csv("data/miller_highlife.csv")

classic = rbind(coors, coorsLight, bud,
                budLight, busch, buschLight, 
                highLife, nattyIce, nattyLight)

#separate the attributes column into each respective column 
classic = separate(classic, name, into = c("name", "brewery"), sep = "\\|")
classic = separate(classic, attributes, into = c('attributes', 'overall'), sep = "overall:")
classic = separate(classic, attributes, into = c('attributes', 'feel'), sep = "feel:")
classic = separate(classic, attributes, into = c('attributes', 'taste'), sep = "taste:")
classic = separate(classic, attributes, into = c('attributes', 'smell'), sep = "smell:")
classic = separate(classic, attributes, into = c('attributes', 'look'), sep = "look:")
classic$attributes <- NULL

#remove extra characters and covert the ratings to numeric 
classic$overall = as.numeric(classic$overall)
classic$look = as.numeric(sub('\\|', '', classic$look))
classic$smell = as.numeric(sub('\\|', '', classic$smell))
classic$taste = as.numeric(sub('\\|', '', classic$taste))
classic$feel = as.numeric(sub('\\|', '', classic$feel))

#turn the dates into the correct format
classic$date = as.POSIXct(classic$date, format = "%b %d,%Y")
classic$year = format(classic$date, '%Y')
classic <- na.omit(classic)

# ggplot(data = classic, aes(x = year, y = look)) +
#   geom_boxplot() +
#   facet_grid(~name, scales = "free_x") +
#   coord_flip() +
#   geom_smooth(aes(group = 1))

#include analysis component 
# summary(aov(classic$overall ~ classic$name))
# x = TukeyHSD(aov(classic$overall ~ classic$name))
# y = data.frame(rownames(x$`classic$name`))
# colnames(y) <- 'names'
# z = separate(y, names, c('one', 'two'), sep = '-')
# z[z$one == 'Natural Light ',]
