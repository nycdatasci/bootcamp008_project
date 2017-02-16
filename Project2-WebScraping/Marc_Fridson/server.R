
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
library(grDevices)
library(lattice)
library(Matrix)
library(methods)
library(utils)
library(xtable)
library(DT)
shinyServer(function(input, output) {
  output$team_plot <- renderPlot({
    Tm_rnd_group<-dplyr::group_by(filter(nfl,Position.Standard %in% input$check_pos, Year %in% min(input$year_slide):max(input$year_slide)),Tm,Rnd)
    Tm_rnd_Outcome_Summary<-summarise(Tm_rnd_group,Drafted_Players=n(),"Avg_Years_Played"=mean(Years_Played,2),"Pro_Bowl_App"=sum(PB),"Avg_PBs"=mean(PB,3),"Avg_PBs_PerYear"=mean(PB_Per_Year_Played,2))
    (Team_Years_Facet_Plot<-ggplot(Tm_rnd_Outcome_Summary,aes(Rnd,Avg_Years_Played,colour=Rnd,label=round(Avg_Years_Played,digits = 0)))+geom_point()+geom_text(hjust = 0, nudge_x = -.5,size=2.5)+facet_wrap(~Tm,ncol=12,scales="free",shrink=FALSE)+xlab("Draft Round")+ylab("Avg. # Years Played")+theme(axis.text.x=element_text(size=8),axis.text.y=element_text(size=8))+scale_colour_tableau()+scale_shape_tableau())
  })
  output$Rnd_Summary <- renderTable({
    rd_group<-dplyr::group_by(filter(nfl,Position.Standard %in% input$check_pos,Year %in% min(input$year_slide):max(input$year_slide)),Rnd)
    Rnd_Overall_Outcome_Summary<-t(summarise(rd_group,"# of Players Drafted"=n(),"Average Years Played"=mean(Years_Played,2),"Total Pro Bowl Appearances"=sum(PB),"Avg_PBs"=mean(PB,3),"Avg_PBs_PerYear"=mean(PB_Per_Year_Played,2),"QB" = sum(Position.Standard=="QB"),"RB" = sum(Position.Standard=="RB"),"WR" = sum(Position.Standard=="WR"),"TE" = sum(Position.Standard=="TE"),"T" = sum(Position.Standard=="T"),"DL" = sum(Position.Standard=="DL"),"DT" = sum(Position.Standard=="WR"),"LB" = sum(Position.Standard=="LB"),"DB" = sum(Position.Standard=="DB"),"ST" = sum(Position.Standard=="K" | Position.Standard=="P" | Position.Standard=="LS"))[,1:4])
    colnames(Rnd_Overall_Outcome_Summary)<-c("Round 1","Round 2","Round 3","Round 4","Round 5","Round 6","Round 7")
    Rnd_Overall_Outcome_Summary<-Rnd_Overall_Outcome_Summary[-1,]
    
  }, 
  striped=TRUE,hover=TRUE,bordered=TRUE,spacing="l",rownames = TRUE,width = "100%")
  
  output$pb_plot <- renderPlot({
    rnd_pos_group<-dplyr::group_by(filter(nfl,Tm %in% input$team_sel,Year %in% min(input$year_slide2):max(input$year_slide2)),Rnd,Position=Position.Standard)
    Rnd_Pos_Outcome_Summary<-summarise(rnd_pos_group,Drafted_Players=n(),"Avg_Years_Played"=mean(Years_Played,2),"Pro_Bowl_App"=sum(PB),"Avg_PBs"=mean(PB,3),"Avg_PBs_PerYear"=mean(PB_Per_Year_Played,2))
    (Rnd_Years_Plot<-ggplot(Rnd_Pos_Outcome_Summary,aes(Rnd,Pro_Bowl_App,fill=Position))+geom_bar(stat="identity",position="dodge")+xlab("Draft Age")+ylab("Avg. # Years Played")+theme_fivethirtyeight()+scale_colour_tableau()+scale_shape_tableau())    
  })
  
  output$age_plot <- renderPlot({
    age_group<-dplyr::group_by(filter(nfl,Tm %in% input$team_sel2,Year %in% min(input$year_slide3):max(input$year_slide3)),Age,Position.Standard)
    Age_Outcome_Summary<-filter(summarise(age_group,"Drafted_Players"=n(),"Avg_Years_Played"=mean(Years_Played,2),"Pro_Bowl_App"=sum(PB),"Avg_PBs"=mean(PB,3),"Avg_PBs_PerYear"=mean(PB_Per_Year_Played,2),"QB" = sum(Position.Standard=="QB"),"RB" = sum(Position.Standard=="RB"),"WR" = sum(Position.Standard=="WR"),"TE" = sum(Position.Standard=="TE"),"T" = sum(Position.Standard=="T"),"DL" = sum(Position.Standard=="DL"),"DT" = sum(Position.Standard=="WR"),"LB" = sum(Position.Standard=="LB"),"DB" = sum(Position.Standard=="DB"),"ST" = sum(Position.Standard=="K" | Position.Standard=="P" | Position.Standard=="LS")),Age!="Not Applicable" & Position.Standard!="LS")
    (Age_Years_Plot<-ggplot(Age_Outcome_Summary,aes(Position.Standard,Avg_Years_Played,fill=Age))+geom_bar(stat="identity",position="dodge")+xlab("Draft Age")+ylab("Avg. # Years Played")+theme_fivethirtyeight()+scale_colour_tableau()+scale_shape_tableau()) 
  })
  
  output$sch_tbl <- DT::renderDataTable({
    sch_group<-dplyr::group_by(nfl,College=College.Univ)
    College_Outcome_Summary <- summarise(sch_group, "Drafted Players" = n(), "Avg. Years Played" = mean(Years_Played, 2), "Pro Bowl Appearances" = sum(PB), "QB" = sum(Position.Standard == "QB"), "RB" = sum(Position.Standard == "RB"), "WR" = sum(Position.Standard == "WR"), "TE" = sum(Position.Standard == "TE"), "T" = sum(Position.Standard == "T"), "DL" = sum(Position.Standard == "DE" | Position.Standard == "DT"), "LB" = sum(Position.Standard == "LB"), "DB" = sum(Position.Standard == "DB"), "ST" = sum(Position.Standard == "K" | Position.Standard == "P" | Position.Standard == "LS"))
  },options=list(pageLength=15,width="99%"))
  
  output$qb_plot <- renderPlot({
    qb_sub<-filter(qb_sub,year %in% min(input$year_slide4):max(input$year_slide4))
    (QB_plot<-ggplot(qb_sub,aes_string(input$xlab1,input$ylab1,colour="pos"))+geom_point()+scale_colour_tableau()+scale_shape_tableau())
  })
    
    output$rbfb_plot <- renderPlot({
      rbfb_sub<-filter(rbfb_sub,year %in% min(input$year_slide5):max(input$year_slide5))
     (RBFB_plot<-ggplot(rbfb_sub,aes_string(input$xlab2,input$ylab2,colour="pos"))+geom_point()+scale_colour_tableau()+scale_shape_tableau())
    })
    
    
    output$wrte_plot <- renderPlot({

      wrte_sub<-filter(wrte_sub,year %in% min(input$year_slide6):max(input$year_slide6))
      (WRTE_Plot<-ggplot(wrte_sub,aes_string(x=input$xlab3,y=input$ylab3,color="pos"))+geom_point())
    })
    
    output$k_plot <- renderPlot({
      k_sub<-filter(k_sub,year %in% min(input$year_slide7):max(input$year_slide7))
      (Kick_Plot<-ggplot(k_sub,aes_string(input$xlab4,input$ylab4,colour="pos"))+geom_point()+scale_colour_tableau()+scale_shape_tableau())
    })
    
    
    output$p_plot <- renderPlot({
      p_sub<-filter(p_sub,year %in% min(input$year_slide8):max(input$year_slide8))
      (Punt_Plot<-ggplot(p_sub,aes_string(input$xlab5,input$ylab5,colour="pos"))+geom_point()+scale_colour_tableau()+scale_shape_tableau())
    })
    
    
    
    
    
    
    
  })
