library(tidyverse)
library(shiny)
library(shinydashboard)
library(ggthemes)
library(openxlsx)

# setwd("/Users/ethanweber/Desktop/Shiny_Project/Script")
raw <- read_rds("./shinydata")
raw$state <- raw$state %>% tolower

simpleCap <- function(x) {
  s <- strsplit(x, " ")[[1]]
  paste(toupper(substring(s, 1,1)), substring(s, 2),
        sep="", collapse=" ")
}

f <- function(x) {state.region[grep(simpleCap(x), state.name)]}
lfp_adj <- function(x) {
  x <- ifelse(x <= 45, x, 45)
  x <- ifelse(x >= 12, x, 12  )
}
unr_adj <- function(x) {
  x <- ifelse(x <= 16, x, 16)
  x <- ifelse(x >= 2, x, 2  )
}
sr_adj <- function(x){
  x <- ifelse(x <= 35, x, 35)
  x <- ifelse(x >= 5, x, 5  )
}
srate <- scale_fill_gradient2(midpoint = 15, low="darkblue", high="red", limits = c(4, 36))
unemplr <- scale_fill_gradient2(midpoint = 4, low="darkblue", high="red", limits = c(2, 16))
yoys <- scale_fill_gradient2(midpoint = 0, low="darkblue", high="red", limits = c(-2, 2))
wfp <- scale_fill_gradient2(midpoint = 24, low = "darkblue", high = 'red', mid = 'white', limits = c(13, 45))


DF <- mutate(raw, 'nonemployed' = lfp_adj(100*(1-raw$employed/raw$civPop)), 'unemployment_Rate' = 100*(1-raw$employed/raw$laborForce),  "suicide_Rate" = 100000*raw$deaths/raw$s_Pop) %>%
  mutate('yoy_nonemp' = (nonemployed - lag(nonemployed, order_by = year))/lag(nonemployed, order_by = year), 
         'yoy_suicide' = (suicide_Rate - lag(suicide_Rate, order_by = year))/lag(suicide_Rate, order_by = year),
         'yoy_unemp' = (unemployment_Rate - lag(unemployment_Rate, order_by = year))/lag(unemployment_Rate, order_by = year))
DF <- left_join(map_data("state"), DF, by = c('region' = 'state')) %>%
  rename('state' = region)

DD <- group_by(raw, age, year) %>% 
  summarise('employed' = sum(employed), "civPop" = sum(civPop), 'laborForce' = sum(laborForce), 'deaths' = sum(deaths), 's_Pop' = sum(s_Pop)) %>%
  mutate('nonemployed' = (100*(1-employed/civPop)), 'unemployment_Rate' = 100*(1-employed/laborForce),  "suicide_Rate" = 100000*deaths/s_Pop)



prime_age <- filter(raw, age != '15_16-24', age != 'TotalPop', age != '65+') %>%
  group_by(state, year) %>% summarise('civPop' = sum(civPop), 'laborForce' = sum(laborForce),
                                      'employed' = sum(employed), 'unemployed' = sum(unemployed), 
                                      's_Pop' = sum(s_Pop), 'deaths' = sum(deaths)) %>%
  mutate('nonemployed' = 100*(1-employed/civPop), "suicide_Rate" = 100000*deaths/s_Pop, 'unemployment_Rate' = 100*(1-employed/laborForce))
prime_age <- left_join(map_data("state"), prime_age, by = c('region' = 'state')) %>%
  rename('state' = region)

DF$nonemployed <- lfp_adj(DF$nonemployed)
DF$unemployment_Rate <- unr_adj(DF$unemployment_Rate)
DF$suicide_Rate <- sr_adj(DF$suicide_Rate)
prime_age$suicide_Rate <- sr_adj(prime_age$suicide_Rate)
prime_age$unemployment_Rate <- unr_adj(prime_age$unemployment_Rate)
prime_age$nonemployed <- lfp_adj(prime_age$nonemployed)





#Code from another file
male <- read_tsv('./genderM.txt')
fem <- read_tsv('./genderF.txt')
occu<- read.csv('./occup.csv', header = TRUE)

male <- mutate(male, 'gender' = 'Male')
fem <- mutate(fem, 'gender' = 'Female')

switcher2 <- function(x) {
  switch(x,
         "Census Region 1: Northeast" = "Northeast",
         "Census Region 2: Midwest" = "Midwest",
         "Census Region 3: South" = "South",
         "Census Region 4: West" = "West",
         "NA" = NA
  )
}

df3 <- rbind(fem, male)
df3$census_Region <- sapply(df3$`Census Region`, switcher2)
df3$cause_of_Death <- df3$`Injury Mechanism & All Other Leading Causes`
df3$age <- df3$`Ten-Year Age Groups Code`

df3 <- df3[,c(-1, -2, -3, -5, -6, -7, -9, -11)]

dfv1 <- filter(df3, cause_of_Death != "Other specified, classifiable Injury", 
               cause_of_Death !=  "Unspecified Injury", 
               cause_of_Death !=  "Other specified, not elsewhere classified Injury",
               is.na(cause_of_Death) == FALSE,
               is.na(Population) == FALSE)

ggplot(occu, aes(x = Occupation, y = suicide_Rate)) + 
  geom_bar(stat = 'identity') + coord_flip() + 
  theme_tufte() + ggtitle("Suicide by Occupation") + ylab('Suicide Rate')

dfv1g <- group_by(dfv1, Year, census_Region, cause_of_Death) %>% summarise('number_of_Deaths' = 100000*sum(Deaths)/sum(Population))
dfv2g <- group_by(dfv1, Year, cause_of_Death) %>% summarise('number_of_Deaths' = 100000*sum(Deaths)/sum(Population))

mechanism_data <- group_by(dfv1, Year, census_Region, cause_of_Death) %>% 
  summarise('number_of_Deaths' = 100000*sum(Deaths)/sum(Population))

###



shinyServer(function(input, output) {
  
  output$usaMap <- renderPlot({
    ggplot() +  geom_polygon(data=filter(DF, age == 'TotalPop', year == input$yearusa),
      aes(x=long, y=lat, group = group, fill = suicide_Rate), color = 'black') +
      coord_map() + srate +
      theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks.x=element_blank(), axis.ticks.y=element_blank()
    )
  })
  
  output$pasr <- renderPlot({
    ggplot() +  geom_polygon(
      data=filter(prime_age, year == input$yearpasr),
      aes(x=long, y=lat, group = group, fill = suicide_Rate), color = 'black') +
      coord_map() + srate + 
      theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
            axis.text.x=element_blank(), axis.text.y=element_blank(),
            axis.ticks.x=element_blank(), axis.ticks.y=element_blank()
      )
  })
  output$palfp <- renderPlot({
    ggplot() + geom_polygon(
      data = filter(prime_age, year == input$yearpalf),
      aes(x=long, y=lat, group = group, fill = nonemployed), color = 'black') +
      wfp + coord_map() +
      theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
            axis.text.x=element_blank(), axis.text.y=element_blank(),
            axis.ticks.x=element_blank(), axis.ticks.y=element_blank()
      )})
  output$paur <- renderPlot({
    ggplot() + geom_polygon(
      data = filter(prime_age, year == input$yearpaur),
      aes(x=long, y=lat, group = group, fill = unemployment_Rate), color = 'black') +
      unemplr + coord_map() +
      theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
            axis.text.x=element_blank(), axis.text.y=element_blank(),
            axis.ticks.x=element_blank(), axis.ticks.y=element_blank()
      ) })
output$dba <- renderPlot({
    ggplot() + geom_polygon(data = filter(DF, age == input$dbaages, year == input$yeardba),
      aes(x=long, y=lat, group = group, fill = suicide_Rate), colour = 'black') +
      srate + coord_map() + 
      theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks.x=element_blank(), axis.ticks.y=element_blank()
    )})
output$lfpba <- renderPlot({
  ggplot() + geom_polygon(data = filter(DF, age == input$lfpages, year == input$lfpyear),
    aes(x=long, y=lat, group = group, fill = (nonemployed)), colour = 'black') + 
    wfp + coord_map() +
    theme(axis.title.x=element_blank(), axis.title.y=element_blank(),
          axis.text.x=element_blank(), axis.text.y=element_blank(),
          axis.ticks.x=element_blank(), axis.ticks.y=element_blank()
          )
  })

output$mechgraph <- renderPlot({
    ggplot(filter(mechanism_data, Year == input$mechyear),
      aes(x = cause_of_Death, y = number_of_Deaths, fill = cause_of_Death)) + coord_flip() +
    geom_bar(stat = 'identity') + facet_grid(census_Region ~ .) + ylab("Deaths Per ")
})

output$occu <- renderPlot({
  ggplot(occu, aes(x = Occupation, y = suicide_Rate)) + 
    geom_bar(stat = 'identity') + coord_flip() + 
    theme_tufte() + ggtitle("Suicide by Occupation") + ylab('Suicide Rate')
})
output$nonpage <- renderPlot ({ 
  ggplot(DD, aes(x = year, y = nonemployed, color = age )) + geom_line() + theme_tufte() + ylab('Laborforce Nonparticipation Rate')
})
})

#fillcolor <- function(x){ 
#  if (x == 'suicide_Rate') {
#      return(srate)
#  }run
#  if (x == 'nonemployed') {
#    return(wfp)
#  }
#  if (x == 'unemployment_Rate') {
#    return(unemplr)
#  }
#  if (x == 'yoynonemp') {
#    return(yoys)
#  }}
#eval(parse(text = paste(input$usainfo)))
