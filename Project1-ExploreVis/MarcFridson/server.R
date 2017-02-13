
# This is the server logic for a Shiny web application.
# You can find out more about building applications with Shiny here:
#
# http://shiny.rstudio.com
#

library(shiny)
library(shinydashboard)
library(dplyr)
library(ggplot2)
library(ggthemes)
library(reader)
library(reshape2)
library(tidyr)
library(graphics)
library(stats)
library(rprojroot)
library(grDevices)
library(lattice)
library(Matrix)
library(methods)
library(utils)
library(xtable)
library(DT)

nfl<-readRDS("./data/nfl")

shinyServer(function(input, output) {
  # nfl<-readRDS("data/nfl")
  output$team_plot <- renderPlot({
    Tm_rnd_group<-group_by(filter(nfl,Position.Standard %in% input$check_pos, Year %in% min(input$year_slide):max(input$year_slide)),Tm,Rnd)
    Tm_rnd_Outcome_Summary<-summarise(Tm_rnd_group,Drafted_Players=n(),Avg_Years_Played=mean(Years_Played,2),Pro_Bowl_App=sum(PB),Avg_PBs=mean(PB,3),Avg_PBs_PerYear=mean(PB_Per_Year_Played,2))
    (Team_Years_Facet_Plot<-ggplot(Tm_rnd_Outcome_Summary,aes(Rnd,Avg_Years_Played,colour=Rnd,label=round(Avg_Years_Played,digits = 0)))+geom_point()+geom_text(hjust = 0, nudge_x = -.5,size=2.5)+facet_wrap(~Tm,ncol=12,scales="free",shrink=FALSE)+xlab("Draft Round")+ylab("Avg. # Years Played")+theme(axis.text.x=element_text(size=8),axis.text.y=element_text(size=8))+scale_colour_tableau()+scale_shape_tableau())
  })
  output$Rnd_Summary <- renderTable({
    rd_group<-group_by(filter(nfl,Position.Standard %in% input$check_pos,Year %in% min(input$year_slide):max(input$year_slide)),Rnd)
    Rnd_Overall_Outcome_Summary<-t(summarise(rd_group,"# of Players Drafted"=n(),"Average Years Played"=mean(Years_Played,2),"Total Pro Bowl Appearances"=sum(PB),Avg_PBs=mean(PB,3),Avg_PBs_PerYear=mean(PB_Per_Year_Played,2),QB = sum(Position.Standard=="QB"),RB = sum(Position.Standard=="RB"),WR = sum(Position.Standard=="WR"),TE = sum(Position.Standard=="TE"),T = sum(Position.Standard=="T"),DL = sum(Position.Standard=="DL"),DT = sum(Position.Standard=="WR"),LB = sum(Position.Standard=="LB"),DB = sum(Position.Standard=="DB"),ST = sum(Position.Standard=="K" | Position.Standard=="P" | Position.Standard=="LS"))[,1:4])
    colnames(Rnd_Overall_Outcome_Summary)<-c("Round 1","Round 2","Round 3","Round 4","Round 5","Round 6","Round 7")
    Rnd_Overall_Outcome_Summary<-Rnd_Overall_Outcome_Summary[-1,]
    
  }, 
  striped=TRUE,hover=TRUE,bordered=TRUE,spacing="l",rownames = TRUE,width = "100%")

  output$pb_plot <- renderPlot({
    rnd_pos_group<-group_by(filter(nfl,Tm %in% input$team_sel,Year %in% min(input$year_slide2):max(input$year_slide2)),Rnd,Position=Position.Standard)
    Rnd_Pos_Outcome_Summary<-summarise(rnd_pos_group,Drafted_Players=n(),Avg_Years_Played=mean(Years_Played,2),Pro_Bowl_App=sum(PB),Avg_PBs=mean(PB,3),Avg_PBs_PerYear=mean(PB_Per_Year_Played,2))
    (Rnd_Years_Plot<-ggplot(Rnd_Pos_Outcome_Summary,aes(Rnd,Pro_Bowl_App,fill=Position))+geom_bar(stat="identity",position="dodge")+xlab("Draft Age")+ylab("Avg. # Years Played")+theme_fivethirtyeight()+scale_colour_tableau()+scale_shape_tableau())    
  })

  output$age_plot <- renderPlot({
    age_group<-group_by(filter(nfl,Tm %in% input$team_sel2,Year %in% min(input$year_slide3):max(input$year_slide3)),Age,Position.Standard)
    Age_Outcome_Summary<-filter(summarise(age_group,Drafted_Players=n(),Avg_Years_Played=mean(Years_Played,2),Pro_Bowl_App=sum(PB),Avg_PBs=mean(PB,3),Avg_PBs_PerYear=mean(PB_Per_Year_Played,2),QB = sum(Position.Standard=="QB"),RB = sum(Position.Standard=="RB"),WR = sum(Position.Standard=="WR"),TE = sum(Position.Standard=="TE"),T = sum(Position.Standard=="T"),DL = sum(Position.Standard=="DL"),DT = sum(Position.Standard=="WR"),LB = sum(Position.Standard=="LB"),DB = sum(Position.Standard=="DB"),ST = sum(Position.Standard=="K" | Position.Standard=="P" | Position.Standard=="LS")),Age!="Not Applicable" & Position.Standard!="LS")
    (Age_Years_Plot<-ggplot(Age_Outcome_Summary,aes(Position.Standard,Avg_Years_Played,fill=Age))+geom_bar(stat="identity",position="dodge")+xlab("Draft Age")+ylab("Avg. # Years Played")+theme_fivethirtyeight()+scale_colour_tableau()+scale_shape_tableau()) 
  })
  
  output$sch_tbl <- DT::renderDataTable({
    sch_group<-group_by(nfl,College=College.Univ)
    College_Outcome_Summary<-summarise(sch_group,"Drafted Players"=n(),"Avg. Years Played"=mean(Years_Played,2),"Pro Bowl Appearances"=sum(PB),QB = sum(Position.Standard=="QB"),RB = sum(Position.Standard=="RB"),WR = sum(Position.Standard=="WR"),TE = sum(Position.Standard=="TE"),T = sum(Position.Standard=="T"),DL = sum(Position.Standard=="DL"),DT = sum(Position.Standard=="WR"),LB = sum(Position.Standard=="LB"),DB = sum(Position.Standard=="DB"),ST = sum(Position.Standard=="K" | Position.Standard=="P" | Position.Standard=="LS")) 
  }, width = "99%",options=list(pageLength=15))

})
