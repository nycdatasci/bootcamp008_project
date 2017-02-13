library(shiny)
library(ggplot2)
library(dplyr)
library(leaflet)



function(input, output) {
  plotType <- reactive({
    if(input$tax){
      return("_aftertax")
    }else{
      return("")
    }
  })
  
  
  great_df <- reactive({
    yelps_ratings= input$yelp
    if(input$yelp_min>=0){
      df= subset(super_burrito, review_count>input$yelp_min) 
      subset(df, rating>=yelps_ratings[1] & rating<=yelps_ratings[2]) 
      
    }
    else{
    subset(super_burrito, rating>=yelps_ratings[1] & rating<=yelps_ratings[2]) 
    }
  })   

  greater_df <- reactive({
    if(input$shortage){
      great_df()[is.na(great_df()$"message"),]
    }else{
      great_df()
    }
    
  }
    
    
  )
  pallette <- reactive({
    data= greater_df()
    pal <- colorNumeric(
      palette = c("#addd82","#78c679",'#41ab5d','#238443','#006837','#004529'),
      domain = data[,paste0(input$menu_item1,plotType())]
    )
    print(pal)
    
  })


   
output$mymap = renderLeaflet({   
  leaflet(data = greater_df()) %>% addProviderTiles("Stamen.Toner") %>%
    addCircleMarkers(~long, 
                     ~lat,
                     radius=5,
                     color = ~pallette()(get(paste0(input$menu_item1,plotType()))),
                     popup=~paste("Address:",address.x,"<br>",
                                  "City:",city.x,"<br>",
                                  "State:",state,"<br>",
                                  "Zipcode:",zipcode,"<br>",
                                  "Hours:",hours,"<br>",
                                  "Tax Rate:", rate, "<br>",
                                  "Yelp Rating:",rating,"<br>",
                                  "Food Shortage:",message,"<br>",
                                  "Number of Yelp Reviews:", review_count, "<br>",
                                  "Steak Burrito Price:",get(paste0("Steak Burrito",plotType())),"<br>",
                                  "Chicken Burrito Price:",get(paste0("Chicken Burrito",plotType())),"<br>",
                                  "Barbacoa Burrito Price:",get(paste0("Barbacoa Burrito",plotType())),"<br>",
                                  "Carnitas Burrito Price:",get(paste0("Carnitas Burrito",plotType())),"<br>",
                                  "Chorizo Burrito Price:",get(paste0("Chorizo Burrito",plotType())),"<br>",
                                  "Sofritas Burrito Price:",get(paste0("Sofritas Burrito",plotType())),"<br>",
                                  "Veggie Burrito Price:",get(paste0("Veggie Burrito",plotType()))
                     )) %>% addLegend("bottomright", pal = pallette(), values = ~get(paste0(input$menu_item1,plotType())),
                                      title = paste0(input$menu_item1," Price"),
                                      labFormat = labelFormat(prefix = "$"),
                                      opacity = 1
                     )
  
    })

  output$num_chipotle <- renderValueBox({
    
    num_chipotle=nrow(steak_burrito)
    

    valueBox(
      value = formatC(num_chipotle, digits = 0, format = "f"),
      subtitle = "Number of Chipotles",
      color =  "aqua"
    )
  })


  output$num_countries <- renderValueBox({
    
    num_countries=length(unique(steak_burrito$country))
    

    valueBox(
      value = formatC(num_countries, digits = 0, format = "f"),
      subtitle = "Number of Countries",
      color = "aqua"
    )
  })

  
  output$num_states <- renderValueBox({
    us_steak_burrito = filter(steak_burrito,country=="US")
    num_states=length(unique(us_steak_burrito$state))
    
    
    valueBox(
      value = formatC(num_states, digits = 0, format = "f"),
      subtitle = "Number of U.S. states (including D.C. as state)",
      color =  "aqua"
    )
  })
  
  


good_df <- reactive({
  filter(map_df, menu_items == input$menu_item | is.na(menu_items))
  })

shortage_df <- reactive({

    
})

output$mytable = renderDataTable({
  table_df = good_df()
  table_df = table_df[!is.na(table_df$menu_items),]
  table = dplyr::select(table_df, State=state,County=NAME,Price =med_price)
  unique(table)
  
})

output$plot3 = renderPlot({
  df = good_df()
  # df = df[!is.na(df$menu_items),]
  df = dplyr::select(df,num,item_price)
  df = unique(df)
  ggplot(data=df, aes(x=as.factor(item_price))) + geom_bar() + xlab(paste0(input$menu_item," Price")) + ylab("Count")+
  ggtitle(paste0(input$menu_item," Price Counts") )
  
})

output$plot <- renderPlot(
  ggplot(good_df(), aes(x=long, y=lat, group=group)) +
  geom_polygon(aes(fill=med_price))+
    scale_fill_gradient(low = "#ffffcc", high = "#800026",
                        na.value="#282727", 
                        breaks=seq(min(good_df()[,'med_price'], na.rm = T), max(good_df()[,'med_price'], na.rm = T), by=.2))+
  coord_map()+ labs(title=paste0("Median ", input$menu_item," By U.S. County"))+
  guides(fill=guide_legend(title=paste0("Median ", input$menu_item," Price ($)"))) + theme_bw())

output$plot2 <- renderPlot(
  ggplot(carnitas_map, aes(map_id = state)) + geom_map(aes(fill=percent),map=states_map) +scale_fill_distiller(palette = "Reds",direction=1)+
    expand_limits(x = states_map$long, y = states_map$lat)+ theme_bw() + labs(title=paste0("Chipotles With Carnitas That Doesn't Meet Antibiotic Protocol"))+
    guides(fill=guide_legend(title="% of Chipotles")) +coord_map()
  )


output$region_table <- renderPlot(
  map_df %>% 
    filter(menu_items=="Steak Burrito") %>% 
    dplyr::select(num,item_price,bls_regions)%>% 
    unique() %>% 
    ggplot(aes(x=bls_regions,y=item_price)) + geom_boxplot()

  )


output$scatterplot <- renderPlot(
  reg_vars %>% 
    filter(menu_items=="Steak Burrito") %>% 
    dplyr::select(num,item_price,Transportation,`Living_Wage` ,POP_ESTIMATE_2015,Births_2015,`Minimum_Wage`,R_NET_MIG_2015,rate,rating,review_count,Housing,`Annual_taxes`,`Required_annual_income_before_taxes`,Other,Food,`Required annual income before taxes`,Medical)%>% 
    unique() %>% 
    ggplot(aes_string(x=input$the_col_name,y="item_price")) + geom_point() + geom_smooth(method="lm")
  
)

output$regression <- renderPrint({ summary(lm(item_price ~ `Annual taxes` + Food + Housing + Medical + Other + 
                                                `Required annual income before taxes` + Transportation + 
                                                `Living Wage.x` + rate + rating + review_count + 
                                                R_NET_MIG_2015 + bls_regions + Economic_typology_2015 + Births_2015 + 
                                                POP_ESTIMATE_2015 + Rural.urban_Continuum.Code_2013,data=joined.steak)) }
  
  
)

}

