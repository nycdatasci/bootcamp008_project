##############################################
###  Data Science Bootcamp 8               ###
###  Project 1 - Exploratory Visualization ###
###  Yvonne Lau  / January 29, 2017        ###
###     Restaurant Closures from Health    ###
###           Inspections in NYC           ###
##############################################


library(DT)
library(shiny)
library(googleVis)
library(ggplot2)
library(dplyr)
library(scales)
library(lubridate)
library(RColorBrewer)
library(ggmap)
library(leaflet)
library(maps)
library(plotly)
library(reshape)


function(input, output,session){
  #----------------General Information tab: 
  #Make data reactive according to user Input
  
  grade_data <- reactive({
    if(input$general_boro == 1){
      grade_only_plot
    }else{
      filter(grade_only_plot, borough %in% input$general_boro)      
    }
  })
  
  output$grade_plot <- renderGvis({
    # transform data for GoogleVis
    #group by year and grade
    grade_only_grouped <- grade_data()%>%
      group_by(year,grade)%>%
      summarise(n=n())
    
    #melt and cast data into the format for stacked googlevis 
    mgrade_only <- reshape::melt(grade_only_grouped, id = c("grade","year"))
    grade_dist <- reshape::cast(mgrade_only, year~grade,sum)
    
    gvisColumnChart(grade_dist, options = list(
      isStacked="percent", colors="['#A6D0BD','#565656','red']"))
    })
  
  # How scores are distributed across Boroughs
  output$score_plot <- renderPlot({
    ggplot(data = grade_data(),aes(x=score, color=borough)) +
      stat_density(aes(color=borough), geom ="line", position ="identity")+
      coord_cartesian(xlim=c(0,40))+
      labs(x = 'Score', y = 'Restaurant Density')+
      scale_y_continuous(breaks=seq(0,0.14,0.02),
                         labels = scales::percent) +
      scale_colour_brewer(name="Borough", palette='Set3') +
      theme_bw() +
      theme(legend.key=element_blank()) +
      geom_vline(xintercept = c(14,28), colour='grey') +
      annotate("text", x = c(6,20,35), y = 0.11, label = c('A','B','C'), size=6) +
      annotate("rect", xmin = 0, xmax = 14, ymin = 0, ymax = 0.20, alpha = .2, fill='darkgreen') +
      annotate("rect", xmin = 14, xmax = 28, ymin = 0, ymax = 0.20, alpha = .2, fill='darkblue') +
      annotate("rect", xmin = 28, xmax = 60, ymin = 0, ymax = 0.20, alpha = .2, fill='darkred')
      
  })
  
  grade_data2 <- reactive({
    if(input$general_boro==1){
      grade_only
    }else{
      filter(grade_only, borough %in% input$general_boro)
    }
  })
  # show statistics using infoBox
  output$totalBox <- renderInfoBox({
    total <- dim(grade_data())[1]
    infoBox("Total Restaurants Inspected", total, icon = icon("pencil"),color="olive")
  })
  output$criticalBox <- renderInfoBox({
    critical <- dim(filter(grade_data2(), critical.flag == 'Critical'))[1]
    total <- dim(grade_data2())[1]
    perc <- percent(critical/total)
    infoBox("% of Critical Infractions", perc ,icon = icon("thumbs-down"),color="olive")
  })
  output$aBox <- renderInfoBox({
    total <- dim(grade_data())[1]
    a <- dim(filter(grade_data(), grade=='A'))[1]
    perc <- percent(a/total)
    infoBox("% of Restaurants rated A", perc ,icon = icon("thumbs-up"),color="olive")
  })
  
  #------------------Heatmap tab code
  # 
  boro_cuisine <- reactive({
    if(input$general_year=='1'){
      unique_score
    }else{
      filter(unique_score, year %in% input$general_year)
    }
  })
  
  # How Scores are distributed across Boroughs
  output$cuisine_borough_plot<- renderPlotly({
    top20_cuisine <- boro_cuisine() %>%
      group_by(cuisine)%>%
      summarise(n=n())%>%
      top_n(20,wt=n)
    
    
    subset_top20 <- subset(boro_cuisine(),cuisine %in% top20_cuisine$cuisine)
    subset_top20$cuisine = factor(subset_top20$cuisine )
    
    plot_data = subset_top20 %>% 
      group_by(cuisine,borough)%>%
      summarize(Avg_Score = mean(score), n= n())
    
    plot_ly(x=plot_data$borough, y=plot_data$cuisine, 
            z = plot_data$Avg_Score, type = "heatmap")%>% 
      layout(yaxis = list( tickangle = 30),margin=list(l=100))
  })
  
  #----------------data for closure map
  closure_data <- reactive({
    unique_closure <- unique(closure_shiny[c("camis","restaurant","date","borough","year","score",
                                             "n_closures","n_infractions","address",
                                             "lon","lat")])
    filter(unique_closure,year %in% input$close_year, 
           score >= input$score_range[1],
           score <= input$score_range[2])
  })
  
  # closure map renderProxy and basemap
  output$map <- renderLeaflet({
    leaflet(closure_data()) %>%
      addTiles() %>%  # Add default OpenStreetMap map titles
      addMarkers(lat = closure_data()$lat, lng = closure_data()$lon,
                 clusterOptions = markerClusterOptions(),
                 popup = ~ paste('<b><font color="Red">', restaurant, '</font></b><br/>', 
                                 'ADDRESS: ',address, '<br/>',  
                                 'SCORE:', score, '<br/>',
                                 'DATE:', date,'<br/>',
                                 '# OF INFRACTIONS:',n_infractions,'<br/>'))
  })
  
  observe({
    data <- closure_data
  })
  
  #----------------closure information 
  # number of days closed data (reactive from select input_year)
  n_closed <- unique(closure_shiny[c("camis","date","score","days_diff","year")])
  n_closed <- n_closed[!(is.na(closure_shiny$days_diff)),] 
  n_closed <- n_closed %>%
    filter(days_diff>=0,score>10) #remove outliers from corrupted data
  n_closed$diff_cat =ifelse(n_closed$days_diff<8,n_closed$days_diff,"8 or more days")
  n_closed$diff_cat = as.factor(n_closed$diff_cat)
  levels(n_closed$diff_cat) = 
    c("0 days", "1 day","2 days","3 days","4 days", "5 days","6 days","7 days","8 or more days")
  
  # reactive dataframe according to user input
  days_closed <- reactive({
    if(input$closure_info_year=='1'){
      n_closed
    }else{
      filter(n_closed, year %in% input$closure_info_year)
    }
  })
  
  # plot Histogram of days closed
  output$days_close_hist <- renderGvis({
    gvis_days_data <- days_closed() %>% 
      group_by(diff_cat)%>%
      summarise(n=n())%>%
      filter(diff_cat!="0 days")
    
    gvisColumnChart(gvis_days_data, 
                    options = list(
                      legend = 'none',
                      series="[{color:'A6D0BD', targetAxisIndex: 0}]",
                      width = "automatic",
                      height = "automatic"
                    ))
})
  #plot barplot
  output$days_close_barplot <- renderPlotly({
    plot_ly(days_closed(), y = ~score, color = ~diff_cat, type = "box")
  })
  # infoBox with percentage of restaurants closed at a particular year
  closure_info <- reactive({
    if(input$closure_info_year == 1){
      unique_health
    }else{
      filter(unique_health, year %in% input$closure_info_year)      
    }
  })
  
  
  output$closureBox <- renderInfoBox({
    closure <- dim(filter(closure_info(), action == 'closed'))[1]
    total <- dim(closure_info())[1]
    perc <- percent(closure/total)
    infoBox("% Closures", perc ,icon = icon("pencil"),color="olive",width=6)
  })
  
  #----------------closure_prob tab
  # unique restaurant inspections entries
  unique_health_overall<- reactive({
    if(input$closure_prob_year=='1'){
      unique_health
    }else{
      filter(unique_health, year %in% input$closure_prob_year)
    }
    
  })
  # unique closure of restaurants entries
  unique_health_closure  <- reactive({
    if(input$closure_prob_year=='1'){
      unique_health %>% filter(action=='closed')
    }else{
      filter(unique_health, year %in% input$closure_prob_year) %>% filter(action=='closed')
    }
  })
  
  prob_closure <- reactive({
    #by cuisine and borough
    by_cuisine_borough_overall <- unique_health_overall() %>%
      group_by(borough,cuisine)%>%
      summarise(n=n())%>%
      arrange(desc(n))
    
    # closures by cuisine and boroughs
    by_cuisine_borough_closure <- unique_health_closure() %>%
      group_by(borough,cuisine)%>%
      summarise(n_closures =n())%>%
      arrange(desc(n_closures))
    
    #probability of closure by cuisine and borough
    probability_closure <- left_join(by_cuisine_borough_overall,
                                     by_cuisine_borough_closure,
                                     by = c("borough","cuisine"))
    probability_closure$prob <- probability_closure$n_closures/probability_closure$n
    probability_closure <- arrange(probability_closure,desc(prob))
    probability_closure <- probability_closure[!(is.na(probability_closure$prob)),]
  })
  
  # plot probability of closure by borough and cuisine
  output$closure_prob_plot <- renderGvis({
    # Setting up table for GoogleVis
    probability_closure <- prob_closure()
    probability_closure$borocui <- paste0(probability_closure$borough,", ",probability_closure$cuisine)
    gvisdata <- probability_closure %>%
      group_by(borocui)%>%
      summarise(prob)%>%
      arrange(desc(prob))%>%
      top_n(input$closure_prob_n,wt = prob)
    
    gvisColumnChart(gvisdata,options=list(vAxis="{format:'#,###%'}",
                                          legend = 'none',
                                          series="[{color:'A6D0BD', targetAxisIndex: 0}]"))
  })
  
  #plot probability of closure by borough
  closure_prob_borough <- reactive({
    # Aggregate closure,borough into by borough for googleVis Chart  
    closure_prob_borough <- prob_closure()%>%
      group_by(borough)%>%
      summarise(n=sum(n),n_closures=sum(n_closures))
    closure_prob_borough$prob <-  closure_prob_borough$n_closures/ closure_prob_borough$n
    closure_prob_borough
    
  })
  
  # Chart for closure by Borough
  output$closure_prob_plot_borough <- renderGvis({
    gvisdata <- closure_prob_borough() %>%arrange(desc(prob))%>%select(borough,prob)
    gvisColumnChart(gvisdata,options=list(vAxis="{format:'#,###.##%'}",
                                          legend = 'none',
                                          series="[{color:'A6D0BD', targetAxisIndex: 0}]"))
    
  })
  
  output$closure_prob_data <- DT::renderDataTable(
    prob_closure() %>% top_n(input$closure_prob_n, wt=prob)%>%mutate(prob=percent(prob))
  )
  output$closure_prob_borough_data <- DT::renderDataTable(
    closure_prob_borough() %>%arrange(desc(prob))%>%mutate(prob=percent(prob))
  ) 
  
  #----------------closure datatable 
  output$closure <- DT::renderDataTable(closure_shiny[c("restaurant","address","date","cuisine","score",
                                                        "violation.code")])
  
  #---------------- link to my LinkedIn 
  output$lk_in = renderMenu ({
    menuItem("LinkedIn", icon = icon("linkedin-square"),
             href = "https://www.linkedin.com/in/yvonne-lau")
  })
  
  #----------------link to my blog
  output$blg = renderMenu ({
    menuItem("Blog", icon = icon("link"),
             href = "http://blog.nycdatascience.com/author/yvonnelau/")
  })
}