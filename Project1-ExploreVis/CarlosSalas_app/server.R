library(shiny)
library(ggplot2)
library(RColorBrewer)
library(tibble)
library(DT)
library(tidyr)
library(dplyr)
library(magrittr)

#setwd('C:\\Users\\Carlo\\Desktop\\BACKUP\\CODING\\NYC DATA SCIENCE ACADEMY\\Project 1 - Shiny\\app') #delete setwd once app is done

#---------------------------------------------------------------------------------------------
# Step 1: Get original dataset
df <- read.csv('turnaround_data.csv', stringsAsFactors = FALSE)
# Step 2: Use library tidyr() to clean and turn into long format:
df_long_ih <- gather(df, key= 'type_ih', value='ret',8:31)
# Step 3: Add a new var called 'ih' (investment horizon) to complement type_ih: 
df_long_ih <- mutate(df_long_ih, ih = type_ih) %>% 
  mutate(ih = gsub('tr_','', ih)) %>%
  mutate(ih = gsub('alpha_','', ih)) %>%
  mutate(ih = gsub('an_','', ih))
# Step 4: Add a new var called 'type' to determine whether it's tr, alpha, tr_an or alpha_an
df_long_ih <- mutate(df_long_ih, type = type_ih) %>% 
  mutate(type = gsub('_0.5y','', type)) %>%
  mutate(type = gsub('_1y','', type)) %>%
  mutate(type = gsub('_1.5y','', type)) %>%
  mutate(type = gsub('_2y','', type)) %>%
  mutate(type = gsub('_2.5y','', type)) %>%
  mutate(type = gsub('_3y','', type))
# now we tranform cyclicality score into factors:
df_long_ih$cyclicality_score <- as.factor(df_long_ih$cyclicality_score)
levels(df_long_ih$cyclicality_score) <- c('Very Low','Low','Medium','High','Very High')
# IMPORTANT NOTE: we will work with two df versions: df (wide format) and df_long_ih (long data):
# 1) df => wide format
# 2) df_long_ih => long format
#---------------------------------------------------------------------------------------------------

shinyServer(function(input, output) {
  # input translator for INVESTMENT HORIZON ANALYSIS tab 
  rv_input <- reactive({
    switch(input$rv,
           'Total Return' = 'tr',
           'Alpha' = 'alpha',
           'Total Return CAGR' = 'tr_an',
           'Alpha CAGR' = 'alpha_an')
    }) 
  
  # input translator for SECTOR/INDUSTRY ANALYSIS tab => we can't use rv_input as it belongs to other tab
  urv_input <- reactive({
    switch(input$urv,
           'Total Return' = 'tr',
           'Alpha' = 'alpha',
           'Total Return CAGR' = 'tr_an',
           'Alpha CAGR' = 'alpha_an')
  }) 
  
  # input translator for RISK-REWARD ANALYSIS tab => we can't use rv_input as it belongs to other tab
  rrv_input <- reactive({
    switch(input$rrv,
           'Total Return' = 'tr',
           'Alpha' = 'alpha',
           'Total Return CAGR' = 'tr_an',
           'Alpha CAGR' = 'alpha_an')
  }) 
  
  output$raw_data <- DT::renderDataTable({
    DT::datatable(df)
  })

  output$pie1 <- renderPlot({
    ggplot(df, aes(x=factor(1), fill= factor(sector))) + geom_bar() + coord_polar(theta = "y") +
      ggtitle("SECTOR SEGMENTATION") +
      theme(plot.title = element_text(hjust= 0.5, face ='bold'),
            legend.title = element_text(face ='bold'),
            axis.title.y = element_blank(), axis.text.x=element_blank(), axis.ticks.y=element_blank()) + 
      scale_fill_brewer(palette = 'RdYlGn', name='GICS Sector')
    })

  output$pie2 <- renderPlot({
    ggplot(df, aes(x=industry)) + geom_bar(aes(fill=sector), show.legend = FALSE) + coord_polar(theta = "x") +
      ggtitle("INDUSTRY SEGMENTATION") +
      theme(axis.title.y=element_blank(), #eliminate axis elements
            axis.text.y=element_blank(),
            axis.ticks.y=element_blank()) + 
      theme(plot.title = element_text(hjust= 0.5, face ='bold')) +
      scale_fill_brewer(palette = 'RdYlGn')

    })

  output$pie3 <- renderPlot({
    ggplot(df, aes(x=factor(1), fill= factor(cyclicality_score))) + geom_bar() + coord_polar(theta = "y") +
      ggtitle('CYCLICALITY SEGMENTATION') +
      theme(plot.title = element_text(hjust= 0.5, face ='bold'),
            legend.title = element_text(face ='bold'),
            axis.title.y = element_blank(), axis.text.x=element_blank(), axis.ticks.y=element_blank()) + 
      scale_fill_brewer(palette = 'RdYlGn', name='Cyclicality Score', direction = -1)
  })

  output$bar1 <- renderPlot({

    bar_type_ih <- group_by(df_long_ih,type, ih) %>% 
      summarize (
        mean = mean(ret, na.rm=TRUE),
        vol = sd(ret, na.rm=TRUE),
        median = sd(ret, na.rm=TRUE),
        max = max(ret, na.rm=TRUE), 
        min = min(ret, na.rm=TRUE)) %>% filter(type == rv_input()) %>%
      mutate(ih = as.factor(as.numeric(gsub('y','', ih)))) # same as .[bar_type_ih$type == rv_input,]

    ggplot(bar_type_ih, aes_string(x='ih',y = input$st)) + geom_col(aes(fill = ih),show.legend = FALSE) + 
      ggtitle('SELECTED RETURN STAT PER INVESTMENT HORIZON') +
      theme(plot.title = element_text(hjust= 0.5, face = 'bold'), axis.title = element_text(face='bold')) +
      labs(x='Investment Horizon in Years' ) +
      scale_fill_brewer(palette = 'RdYlGn', name='Investment Horizon') 
    
  })
  
  output$dens <- renderPlot({
    # first we filter by user's desired return variable and clean ih column to allow plot as categorical:
    ggplot( df_long_ih %>% mutate(ih = as.factor(as.numeric(gsub('y','', ih)))) %>% filter(type == rv_input()), 
            aes(ret)) +
      geom_density(aes(fill=factor(ih)), size=0.5, alpha= 0.3) + 
      ggtitle('DENSITY PLOT PER INVESTMENT HORIZON') +
      theme(plot.title = element_text(hjust= 0.5, face='bold'), 
            axis.title = element_blank(), legend.title = element_text(face = 'bold')) +
      scale_fill_brewer(palette = 'RdYlBu', name='Investment Horizon') +
      coord_cartesian(xlim = c(-0.4, 0.4))
  })
  
  output$box <- renderPlot({
    
    ggplot( na.exclude(df_long_ih %>% filter(type == urv_input()) %>% filter(ih == input$uih)), 
            aes(y=ret,x=reorder(sector, ret, median))) +
      geom_boxplot(aes(fill= cyclicality_score)) + 
      ggtitle('BOXPLOT PER SECTOR') +
      labs(y='return', x = 'GICS Sector') +
      theme(plot.title = element_text(hjust= 0.5, face ='bold'),
            legend.title = element_text(face ='bold'),axis.title = element_text(face = 'bold')) + 
      scale_fill_brewer(palette = 'RdYlGn', name='Cyclicality Score', direction = -1) +
      geom_hline(yintercept=0,colour='red',size=1,linetype=2) 
    
    
  })

  output$dot <- renderPlot({

    ggplot( na.exclude(df_long_ih %>% filter(type == urv_input()) %>% filter(ih == input$uih)), 
            aes(y=ret,x=reorder(sector,ret, median))) +
      geom_dotplot(aes(fill = cyclicality_score), binaxis = "y", stackdir = "center",dotsize = 0.5)+
      ggtitle('DOTPLOT PER SECTOR') +
      labs(y='return', x = 'GICS Sector') +
      theme(plot.title = element_text(hjust= 0.5, face ='bold'),
            legend.title = element_text(face ='bold'), axis.title = element_text(face = 'bold')) + 
      scale_fill_brewer(palette = 'RdYlGn', name='Cyclicality Score',direction = -1) +
      geom_hline(yintercept=0,colour='red',size=1 ,linetype=2) 
      
    })
  
  output$rrw <- renderPlot({
    
    dfrw <- df_long_ih %>% filter(type == rrv_input()) %>% filter(ih == input$rih) %>% group_by_(input$rsec) %>%
      summarize(
        hr = sum(ret>0, na.rm = TRUE) / n()*100,
        avg = mean(ret, na.rm=TRUE),
        rr = mean(ret>0, na.rm=TRUE)/ abs(mean(ret<0,na.rm=TRUE))
        )

    ggplot(dfrw, aes(y= hr,x=rr)) +
      geom_point(aes_string(color= input$rsec),size=4, show.legend = FALSE)+
      ggtitle('HIT RATIO (% WIN RATIO) VS RISK-REWARD RATIO') +
      labs(y='Hit Ratio', x = 'Risk-Reward') +
      theme(plot.title = element_text(hjust= 0.5, face ='bold'),
            legend.title = element_text(face ='bold'), axis.title = element_text(face = 'bold')) + 
      scale_fill_brewer(palette = 'RdYlGn', name='Cyclicality Score',direction = -1) +
      geom_hline(yintercept=50,colour='red',size=1,linetype=2) + 
      geom_vline(xintercept=1,colour='red',size=1,linetype=2) +
      geom_text(aes_string(x='rr',y='hr',label=input$rsec), hjust=0.7, vjust=1.4,angle = 45) 


    
    
  })

  output$prob_ret <- DT::renderDataTable({
    
    df_rl <- na.exclude(df) %>% summarize(
      prob_1y = sum(tr_1y>0 & tr_0.5y< input$sl, na.rm = TRUE)/n(),
      prob_1.5y = sum(tr_1.5y>0 & tr_0.5y< input$sl, na.rm = TRUE)/n(),
      prob_2y = sum(tr_2y>0 & tr_0.5y< input$sl, na.rm = TRUE)/n(),
      prob_2.5y = sum(tr_2.5y>0 & tr_0.5y< input$sl, na.rm = TRUE)/n(),
      prob_3y = sum(tr_3y>0 & tr_0.5y< input$sl, na.rm = TRUE)/n()
    )
    
    df_rw <- na.exclude(df) %>% summarize(
      prob_1y = sum(tr_1y>0 & tr_0.5y> input$sl, na.rm = TRUE)/n(),
      prob_1.5y = sum(tr_1.5y>0 & tr_0.5y> input$sl, na.rm = TRUE)/n(),
      prob_2y = sum(tr_2y>0 & tr_0.5y> input$sl, na.rm = TRUE)/n(),
      prob_2.5y = sum(tr_2.5y>0 & tr_0.5y> input$sl, na.rm = TRUE)/n(),
      prob_3y = sum(tr_3y>0 & tr_0.5y> input$sl, na.rm = TRUE)/n()
    )
    
    scenario <- c('negative total return (first six months)','positive total return (first six months')
    prob_r <- cbind(scenario,round(rbind(df_rl,df_rw),3))
    prob_d <- prob_r[2,]- prob_r[1,]
    prob_d[1,1] <- 'positive start - negative start'
    prob_r <- rbind(prob_r,prob_d)
    
    DT::datatable(prob_r)
  })
  
  output$prob_alpha <- DT::renderDataTable({
    
    df_al <- na.exclude(df) %>% summarize(
      prob_1y = sum(alpha_1y>0 & alpha_0.5y<0, na.rm = TRUE)/n(),
      prob_1.5y = sum(alpha_1.5y>0 & alpha_0.5y<0, na.rm = TRUE)/n(),
      prob_2y = sum(alpha_2y>0 & alpha_0.5y<0, na.rm = TRUE)/n(),
      prob_2.5y = sum(alpha_2.5y>0 & alpha_0.5y<0, na.rm = TRUE)/n(),
      prob_3y = sum(alpha_3y>0 & alpha_0.5y<0, na.rm = TRUE)/n()
    )
    
    df_aw <- na.exclude(df) %>% summarize(
      prob_1y = sum(alpha_1y>0 & alpha_0.5y>0, na.rm = TRUE)/n(),
      prob_1.5y = sum(alpha_1.5y>0 & alpha_0.5y>0, na.rm = TRUE)/n(),
      prob_2y = sum(alpha_2y>0 & alpha_0.5y>0, na.rm = TRUE)/n(),
      prob_2.5y = sum(alpha_2.5y>0 & alpha_0.5y>0, na.rm = TRUE)/n(),
      prob_3y = sum(alpha_3y>0 & alpha_0.5y>0, na.rm = TRUE)/n()
    )
    
    scenario <- c('negative alpha (first six months)','positive alpha (first six months')
    prob_a <- cbind(scenario,round(rbind(df_al,df_aw),3))
    prob_da <- prob_a[2,]- prob_a[1,]
    prob_da[1,1] <- 'positive start - negative start'
    prob_a <- rbind(prob_a,prob_da)
    
    DT::datatable(prob_a)
    
    
    
  })
  
    
}
)

