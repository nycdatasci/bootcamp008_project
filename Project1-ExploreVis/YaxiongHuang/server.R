library(shiny)
library(ggplot2)
library(dplyr)
library(dygraphs)
library(googleVis)
library(ggvis)






shinyServer(function(input, output){
  #Trend line for the total death for all years
  GroupByYear<-reactive({
    data %>% group_by(Year) %>% summarise(TotalDeath = sum(Deaths,na.rm=TRUE))
  })
  
  output$Trendline<-renderDygraph({
    dygraph(GroupByYear(),width = 900, main = "2007 - 2014 Death Trend",xlab = "Year",ylab = "Total Death") %>%
    dyRangeSelector(dateWindow = c("2006", "2016"))
    
  })
  
  #Trend line for the total death by sex for all years
  output$TrendlineBySex<-renderPlot({
    data %>% group_by(Year,Sex) %>% summarise(Total = sum(as.numeric(Deaths))) %>%
      ggplot(.,aes(Year,Total)) + geom_line(aes(color = Sex)) + ylab('Total Death') + facet_wrap(~Sex)
  })
  
  #Trend line for the death by leading cause
  GroupByYearLeadingCause<-reactive({
    data %>% group_by(Year,Leading.Cause) %>% summarise(Total_Death = sum(as.numeric(Deaths),na.rm=TRUE))
  })
  output$TrendByLeadingCause<-renderPlot({
    
    ggplot(GroupByYearLeadingCause()[GroupByYearLeadingCause()$Leading.Cause%in%input$Leading.Cause,],aes(Year,Total_Death)) + 
    geom_point() + 
    geom_line(aes(color = Leading.Cause)) + 
    ylab('Total Death') + 
    ggtitle('2007-2014 Death Trend by Leading Cause') + 
    theme(plot.title = element_text(hjust = 0.5)) + 
    guides(fill=guide_legend(title = "Leading Cause")) +
    theme(plot.title = element_text(size = 15, face = "bold")) 
    
  })
  
  #Barchart for death by leading cause
  SelectedSex<-reactive({
    if(input$Sex5=='All'){
      return (data %>% group_by(Year,Leading.Cause) %>% filter(Leading.Cause == input$Leading.Cause1)%>%
              summarise(TotalDeath = sum(as.numeric(Deaths),na.rm=TRUE)) 
              )
    }else{
      return (data %>% group_by(Year,Sex,Leading.Cause) %>% filter(Leading.Cause == input$Leading.Cause1,Sex == input$Sex5)%>%
                summarise(TotalDeath = sum(as.numeric(Deaths),na.rm=TRUE))
      )
      
    }
  })
  
  plot_df1 <- reactive({
    if (input$Sex5 == "All"){
      return ('All')
    }else if(input$Sex5 == 'M'){
      return ('Male')
    }else{
      return ('Female')
    }
    
  })
  
  output$DeathBySexLeadingCause<-renderPlot({
    
    ggplot(SelectedSex(),aes(factor(Year),TotalDeath)) + 
    geom_bar(stat="identity",fill ='blue4') + xlab("Year") + ylab("Total Death") + 
    ggtitle(paste("Death By Leading Cause for",plot_df1(),sep=' ')) + theme(plot.title = element_text(hjust = 0.5)) + theme(plot.title = element_text(size = 15, face = "bold"))
  })
  
  #Trend line for death by race ethnicity and Leading causes
 
  
  output$TrendByLeadingCauseAndRace<-renderPlot({
    
    data %>% group_by(Race_Ethnicity,Leading.Cause,Year) %>% summarise(TotalDeath = sum(as.numeric(Deaths),na.rm=TRUE)) %>% filter(Race_Ethnicity %in% input$RaceSelection,Leading.Cause==input$LeadingCauseType10) %>%
    ggplot(aes(Year,TotalDeath)) +
      geom_point() +
      geom_line(aes(color = Race_Ethnicity)) +
      ylab('Total Death') +
      ggtitle('2007-2014 Death Trend by Leading Cause and Race')+
      theme(plot.title = element_text(hjust = 0.5,size = 15, face = "bold")) +
      guides(fill=guide_legend(title = "Leading Cause")) 
    
  })
  
  
  
  
  #Trend line for the death by race ethnicity
  output$TrendLineByRaceEthnicity<-renderPlot({
   
    g<-group_by(data,Year,Race_Ethnicity)
    s<-summarise(g,Total_Death = sum(as.numeric(Deaths),na.rm=TRUE)) 
    ggplot(s[s$Race_Ethnicity%in%input$Race_Ethnicity,],aes(Year,Total_Death)) + geom_point() + 
    geom_line(aes(color = Race_Ethnicity)) + ylab('Total Death') + 
    ggtitle('2007-2014 Death Trend') + theme(plot.title = element_text(hjust = 0.5)) + 
    guides(fill=guide_legend(title = "Race Ethnicity")) + theme(plot.title = element_text(size = 15, face = "bold"))
  })
    
  

  
  #barchart by year for total death by year, option selection for Sex
  output$DeathBySex<-renderGvis({
    data$Year <- as.factor(data$Year)
    k<-group_by(data,Year,Sex)
    summary<-summarise(k[k$Sex==input$Sex,],TotalDeath = sum(Deaths,na.rm=TRUE))
    print (class(summary$Year))
    gvisColumnChart(summary,xvar = "Year",yvar = "TotalDeath", 
                    options=list(chartArea="{right: 150}"))
    #ggplot(summary,aes(factor(Year),TotalDeath)) + geom_bar(stat="identity",fill = ifelse(input$Sex=="M",'blue4','brown4')) + xlab("Year") + ylab("Total Death") + ggtitle(paste("Death by Year for",ifelse(input$Sex=='M','Male','Female'),sep = ' ' )) + theme(plot.title = element_text(hjust = 0.5))
  })
  
  
    
  
 
  plot_df <- reactive({
    if (input$Sex1 == "All"){
      return (data)
    }else{
      return (data %>% filter(Sex == input$Sex1))
    }
    
  })
  
  Label<-reactive({
    if(input$Sex1 == "All"){
      return ("All")
    }else if (input$Sex1 == "M"){
      return ("Male")
    }else{
      return ("Female")
    }
  })
  
  #Do the density plot for the death by sex with the facet wrap by race ethnicity
  output$DeathByRaceAndSexDensity<-renderPlot({
    ggplot(plot_df(),aes(x=Deaths)) + geom_density(aes(fill = Race_Ethnicity)) + 
      facet_wrap( ~ Race_Ethnicity) + xlab("Deaths") + 
      ggtitle(paste("Density Plot for",Label(),sep =' ')) + 
      theme(plot.title = element_text(hjust = 0.5)) + 
      guides(fill=guide_legend(title = "Race Ethnicity")) +
      theme(plot.title = element_text(size = 15, face = "bold"))
    })
 
  
  
  
  
  #Barchart for total death by race ethnicity for all years
  output$TotalDeathByRaceEthnicityBarchart<-renderPlot({
    group_by(data,Race_Ethnicity) %>%
    summarise(.,Total_Death = sum(Deaths)) %>%
    ggplot(., aes(reorder(Race_Ethnicity,-Total_Death),Total_Death,fill = Race_Ethnicity)) + 
    geom_bar(stat="identity") + guides(fill=guide_legend(title="Race Ethnicity")) + 
    xlab("Race Ethnicity") + ylab("Total Death") + ggtitle("Total Death by Race Ethnicity") + 
    theme(plot.title = element_text(hjust = 0.5)) + theme(plot.title = element_text(size = 15, face = "bold"))
    
  })
      
  
  
  #Plot the barchart for the top 5 leading causes
  output$Top5LeadingCauses<-renderPlot({
    groupByLeadingCause<-group_by(data,Leading.Cause) 
    summary<-summarise(groupByLeadingCause,sum = sum(Deaths,na.rm = T)) 
    ggplot(arrange(summary,desc(sum))[1:5,],aes(reorder(Leading.Cause,-sum),sum,fill=Leading.Cause)) + 
    geom_bar(stat="identity") + guides(fill=guide_legend(title="Leading Cause")) +
    scale_fill_discrete(breaks=c("Diseases of Heart (I00-I09, I11, I13, I20-I51)","Malignant Neoplasms (Cancer: C00-C97)","All Other Causes","Influenza (Flu) and Pneumonia (J09-J18)","Diabetes Mellitus (E10-E14)"))+
    xlab("Leading Cause") + ylab("Total Death") + 
    scale_x_discrete(labels=c("Diseases of Heart","Malignant Neoplasms","All Other Causes","Influenza (Flu) and Pneumonia","Diabetes Mellitus")) + 
    ggtitle("Top 5 Leading Causes of Death") + theme(plot.title = element_text(hjust = 0.5)) + theme(plot.title = element_text(size = 15, face = "bold"))
  })
  
  #Plot barcharts for Heart Disease and Stroke Indicators (2012 -2014)
  output$HeartDiseaseStrokeMortality<-renderPlot(
    ggplot(HD1,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 100,000 Population') + 
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  output$HeartDiseaseStrokeHospitalizations<-renderPlot(
    ggplot(HD2,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15))+ xlab('Race Ethnicity') + ylab('Hospitalizations per 10,000 population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  #Plot barcharts for Injury-Related Indicators (2012-2014)
  output$InjuryMortality<-renderPlot(
    ggplot(IR1,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  output$InjuryHospitalizations<-renderPlot(
    ggplot(IR2,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Hospitalizations per 100,000 Population')
    + theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  #Plot barcharts for Respiratory Disease Indicators (2012-2014)
  output$RespiratoryMortality<-renderPlot(
    ggplot(RD1,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  output$RespiratoryHospitalizations<-renderPlot(
    ggplot(RD2,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=12)) + xlab('Race Ethnicity') + ylab('Hospitalizations per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  ##Plot barcharts for Substance Abuse and Mental Health-Related Indicators
  output$DrugSuicideMortality<-renderPlot(
    ggplot(SAM1,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  output$DrugRelatedHospitalizations<-renderPlot(
    ggplot(SAM2,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Hospitalizations per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  #Plot barcharts for Diabetes
  output$DiabetesMortality<-renderPlot(
    ggplot(DI1,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  output$DiabetesHospitalizations<-renderPlot(
    ggplot(DI2,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Hospitalizations per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  
  #Plot barcharts for Cancer Indicators
  output$CancerIncidence<-renderPlot(
    ggplot(CI1,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Incidence per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  output$CancerMortality<-renderPlot(
    ggplot(CI2,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 100,000 Population') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  #Plot barcharts for Birth-Related indicators
  output$InfantMortality<-renderPlot(
    ggplot(BI,aes(x=factor(Race_Ethnicity),y=Mortality)) + facet_wrap(~MortalityType) + 
    geom_bar(stat="identity",aes(fill = factor(Race_Ethnicity))) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
    theme(strip.text = element_text(size=15)) + xlab('Race Ethnicity') + ylab('Mortality per 1,000 live births') +
    theme(plot.title = element_text(size = 15, face = "bold"))
  )
  
  
  #barchart for Death by year and leading cause
  output$BarChart <- renderPlot({
    m<-filter(data,Year == input$Year & Leading.Cause == input$LeadingCauseType)
    p<-ggplot(m,aes(x=factor(Race_Ethnicity),y=Deaths))
    p+geom_bar(stat="identity",aes(fill=Sex),position="dodge")+ xlab("Race Ethnicity") + 
    ggtitle(paste("Death by Race Ethnicity for The Year of",input$Year, sep = ' ')) + 
    theme(plot.title = element_text(hjust = 0.5)) + theme(plot.title = element_text(size = 15, face = "bold"))
  })


 #barchart for Total Death by year and leading cause
  data1<-reactive({
    data %>% filter(Year == input$Year1 & Leading.Cause == input$LeadingCauseType1)
  })
 output$BarChart1<- renderPlot({
  #m<-filter(data,Year == input$Year1 & Leading.Cause == input$LeadingCauseType1)
  p<-ggplot(data1(),aes(x=factor(Race_Ethnicity),y=Deaths))
  p+geom_bar(stat="identity",aes(fill=Race_Ethnicity))+ xlab("Race Ethnicity") + 
  ggtitle(paste("Total Death by Race Ethnicity for The Year of",input$Year1, sep = ' ')) + 
  theme(plot.title = element_text(hjust = 0.5)) + guides(fill=guide_legend(title = "Race Ethnicity")) + 
  ylab("Total Death") + theme(plot.title = element_text(size = 15, face = "bold"))
})
 #barchart for Total Death by leading cause
 output$BarChart2 <- renderPlot({
   m<-filter(data,Leading.Cause == input$LeadingCauseType2)
   p<-ggplot(m,aes(x=factor(Race_Ethnicity),y=Deaths))
   p+geom_bar(stat="identity",aes(fill=Race_Ethnicity))+ xlab("Race Ethnicity") + 
   ggtitle(paste("Total Death by Race Ethnicity for", input$LeadingCauseType2,sep=' ')) + 
   theme(plot.title = element_text(hjust = 0.5)) + theme(plot.title = element_text(size = 15, face = "bold"))
 })
})
