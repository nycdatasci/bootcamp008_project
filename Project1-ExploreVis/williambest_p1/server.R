library(dygraphs)
library(dplyr)
library(googleVis)
library(reshape2)
library(geosphere)

source("helpers.r")

##load data
tornadoes.since.1996 <- readRDS("tornadoes_since_1996.rds")
tornadoes.since.1996 <- tornadoes.since.1996 %>% arrange(st)
tornadoes.since.1996 <- tornadoes.since.1996 %>% mutate(mag = paste0("F", mag))
## Preprocessing data
# for map
storm.paths.pp <- tornadoes.since.1996 %>% select(storm.id = X1, state = st, year = yr, slat, slon, elat, elon, loss, mag, len)
# storms with starts or ends at 0.00 are bad data
storm.paths.pp <- storm.paths.pp %>% filter((60 > slat & slat > 10))
storm.paths.pp <- storm.paths.pp %>% filter((60 > elat & elat > 10))
storm.paths.pp <- storm.paths.pp %>% filter((-130 < slon & slon < -50))
storm.paths.pp <- storm.paths.pp %>% filter((-130 < elon & elon < -50))


# storm lengths
storm.size.pp <- tornadoes.since.1996 %>% filter(!is.na(len) & !is.na(wid))
storm.size.pp <- storm.size.pp %>% group_by(st, mag) %>% summarise(average.length = mean(len), average.width = mean(wid))
storm.size.pp <- storm.size.pp %>% arrange(mag)

# for loss graphs
loss.by.state.pp <- tornadoes.since.1996
loss.by.state.pp <- loss.by.state.pp %>% filter(!is.na(loss))
# for casualty graphs
casualties.by.state.pp <- tornadoes.since.1996
casualties.by.state.pp <- casualties.by.state.pp %>% filter(!is.na(inj) & !is.na(fat))
casualties.by.state.pp <- casualties.by.state.pp %>% mutate(casualties = inj + fat)


function(input, output, session) {
  
  get.path.ids.state <- reactive({
    storm.paths.pp %>% filter(state == input$state) %>% select(storm.id)
  })
  
  get.path.ids.mag <- reactive({
    storm.paths.pp %>% filter(mag %in% input$map.mag) %>% select(storm.id)
  })
  
  get.path.ids.year <- reactive({
    storm.paths.pp %>% filter(year >= input$map.year[1] & year <= input$map.year[2]) %>% select(storm.id)
  })
  
  output$map <- renderLeaflet({
    # get only storms given user filter options
    
    storm.paths <- storm.paths.pp %>% filter(state == input$state) 
    storm.paths <- storm.paths %>% filter(mag %in% input$map.mag)
    storm.paths <- storm.paths %>% filter(year >= input$map.year[1] & year <= input$map.year[2])
    
    storm.paths <- storm.paths %>% filter(length.check(slat, slon, elat, elon, len))
    
    storm.map <- leaflet() %>% addTiles() 
    
    for (i in 1:nrow(storm.paths)) {
      lat1 <- storm.paths[i, "slat"]
      lat2 <- storm.paths[i, "elat"]
      lon1 <- storm.paths[i, "slon"]
      lon2 <- storm.paths[i, "elon"]
      
      storm.map <- addPolylines(storm.map, lat = c(lat1, lat2), lng = c(lon1, lon2))
    }
    
    storm.map
  })
  
  output$length.by.severity <- renderGvis({
    storm.size <- storm.size.pp %>% filter(st == input$state)
    storm.size <- storm.size %>% ungroup() %>% select(mag, average.length)
    gvisColumnChart(storm.size,
                    options = list(title = paste("Average Length of Storm by Severity"),
                                   legend = "none",
                                   hAxis = "{title:'Severity'}",
                                   vAxis = "{title:'Length in Miles'}")
    )
  })
  
  get.loss.by.state <- reactive({
    loss.by.state <- loss.by.state.pp
    if (input$group.by == "Year") {
      loss.by.state <- loss.by.state %>% group_by(yr, st) %>% summarise(loss = sum(loss))
    }
    if (!input$include.zero.values) {
      loss.by.state <- loss.by.state %>% filter(loss > 0)
    }
    loss.by.state <- loss.by.state %>% group_by(st) %>% summarise(damage = mean(loss)) %>% arrange(damage)
  })
  
  output$loss.chart <- renderGvis({
    
    loss.by.state <- get.loss.by.state()
    
    loss.by.state <- windowed.bar.chart(loss.by.state, "st", input$state, 4, 4)
    
    loss.by.state <- loss.by.state %>% mutate(Loss.in.USD = damage * 10e6, Loss.in.USD.style = damage.style)
    
    gvisColumnChart(loss.by.state,
                    xvar = "st",
                    yvar = c("Loss.in.USD", "Loss.in.USD.style"),
                    options = list(title = paste("Average Financial Loss per",input$group.by,"per State"),
                                   legend = "none",
                                   hAxis = "{title:'State'}",
                                   vAxis = "{title:'Financial Loss (USD)', format:'short'}"))
  })
  
  
  get.casualties.by.state <- reactive({
    casualties.by.state <- casualties.by.state.pp
    if (input$group.by == "Year") {
      casualties.by.state <- casualties.by.state %>% group_by(yr, st) %>% summarise(casualties = sum(casualties))
    }
    if (!input$include.zero.values) {
      casualties.by.state <- casualties.by.state %>% filter(casualties > 0)
    }
    casualties.by.state <- casualties.by.state %>% group_by(st) %>% summarise(damage = mean(casualties)) %>% arrange(damage)
    
  })
  
  output$casualty.chart <- renderGvis({
    
    casualties.by.state <- get.casualties.by.state()
    
    casualties.by.state <- windowed.bar.chart(casualties.by.state, "st", input$state, 4, 4)
    
    casualties.by.state <- casualties.by.state %>% mutate(Casualties = damage, Casualties.style = damage.style)
    
    gvisColumnChart(casualties.by.state,
                    xvar = "st",
                    yvar = c("Casualties", "Casualties.style"),
                    options = list(title = paste("Average Casualties (Injuries + Fatalities) per",input$group.by,"per State"),
                                   legend = "none",
                                   hAxis = "{title:'State'}",
                                   vAxis = "{title:'Number of Casualties'}")
    )
  })
  
  
  output$state.comparison <- renderGvis({
    loss.by.state <- get.loss.by.state()
    casualties.by.state <- get.casualties.by.state()
    
    loss.by.state <- loss.by.state %>% select(st) %>% mutate(Loss.Position = as.numeric(row.names(loss.by.state)))
    casualties.by.state <- casualties.by.state %>% select(st) %>% mutate(Casualty.Position = as.numeric(row.names(casualties.by.state)))
    
    compare <- inner_join(loss.by.state, casualties.by.state, by = 'st')
    compare <- compare %>% mutate(x3 = NA)
    names(compare) <- c("st", "x1", "Other States", input$state)
    compare[compare$st == input$state, input$state] <- compare[compare$st == input$state, "Other States"]
    compare[compare$st == input$state, "Other States"] <- NA
    
    gvisScatterChart(compare[, c(-1)], options = list(colors = "['blue', 'gold']",
                                                      legend = "none",
                                                      title = "Position Comparison with All Other States",
                                                      hAxis = "{title:'National Loss Position'}",
                                                      vAxis = "{title:'National Casualty Position'}",
                                                      trendlines = "0"))
    
  })
  
  
  output$state.severity.bubble.chart <- renderGvis({
    
    storms.with.valid.data <- tornadoes.since.1996 %>% filter(st == input$state) %>% filter(!is.na(loss)) %>% filter(!is.na(inj) & !is.na(fat))
    storms.with.valid.data <- storms.with.valid.data %>% mutate(casualties = inj  + fat)
    if (!input$include.zero.values) {
      storms.with.valid.data <- storms.with.valid.data %>% filter(loss > 0) %>% filter(casualties > 0)
    }
    c.and.l.by.severity <- storms.with.valid.data %>% group_by(yr, mag) %>% summarise(loss = sum(loss), casualties = sum(casualties), count = n())

    c.and.l.by.severity <- c.and.l.by.severity %>% group_by(mag) %>% summarise(loss = mean(loss), casualties = mean(casualties), count = mean(count))
    
    # rename columns to look better on graph
    c.and.l.by.severity <- c.and.l.by.severity %>% rename(Loss = loss, Casualties = casualties, `Average Storms per Year` = count, Severity = mag)
    
    c.and.l.by.severity <- c.and.l.by.severity %>% mutate(Loss.in.USD = Loss *10e6)
    
    
    gvisBubbleChart(c.and.l.by.severity, idvar = "", xvar = "Loss.in.USD", yvar = "Casualties", sizevar = "Average Storms per Year", colorvar = "Severity",
                    options = list(title = "Average Financial Loss and Casualties per Year by Magnitude",
                                   vAxis = paste0("{title: 'Casualties (Injuries + Fatalities)', logScale: ", tolower(input$state.log.scale), "}"),
                                   hAxis = paste0("{title: 'Financial Loss (USD)', logScale: ", tolower(input$state.log.scale), ", format: 'short'}"),
                                   width = '100%', height = 300
                                   )
                    )
  })
  
  ####### Info Boxes ######
  
  output$average.storms.per.year <- renderInfoBox({
    
    storms.per.year <- tornadoes.since.1996 %>% filter(st == input$state) %>% group_by(yr) %>% summarise(count = n())
    
    infoBox("Average Storms Per Year", round(mean(storms.per.year$count)), icon = icon("bolt"), color = "black", fill = TRUE)
  })
  
  output$casualties.per.storm <- renderInfoBox({
    
    casualties.per.state <- tornadoes.since.1996 %>% filter(st == input$state) %>% filter(!is.na(inj) & !is.na(fat))
    casualties.per.state <- casualties.per.state %>% mutate(casualties = inj + fat)
    if (!input$include.zero.values) {
      casualties.per.state <- casualties.per.state %>% filter(casualties > 0)
    }
    if (input$group.by == "Storm") {
      casualties <- round(mean(casualties.per.state$casualties))
    } else {
      casualties <- casualties.per.state %>% group_by(yr) %>% summarise(c = sum(casualties)) %>% summarise(mean(c))
    }
    infoBox(paste("Average Casualties Per", input$group.by), casualties, icon = icon("frown-o"), color = "red", fill = TRUE)
  })
  
  output$loss.per.storm <- renderInfoBox({
    loss.per.state <- tornadoes.since.1996 %>% filter(st == input$state) %>% filter(!is.na(loss))
    if (!input$include.zero.values) {
      loss.per.state <- loss.per.state %>% filter(loss > 0)
    }
    if (input$group.by == "Storm") {
      loss <- round(mean(loss.per.state$loss))
    } else {
      loss <- loss.per.state %>% group_by(yr) %>% summarise(l = sum(loss)) %>% summarise(mean(l))
    }

    infoBox(paste("Average Financial Loss Per", input$group.by), paste(format(loss, digits = 2, nsmall = 2), "Million"), icon = icon("usd"), color = "green", fill = TRUE)
  })
  
}