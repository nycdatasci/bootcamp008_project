library(dplyr)
library(ggplot2)
library(shiny)
library(DT)
library(tidyr)
shinyServer(function(input, output) {
  d1 <- reactive({
    t10wh=arrange(summarise(ql_grp,winRatio=sum(V16==1)/n()),desc(winRatio))
    Dt=left_join(head(t10wh,input$Ng1),hname,by="hero_id")
    return(Dt)
  })
  output$g1 <- renderPlot({
    Dt=d1()
    p <- ggplot(Dt,aes(x=reorder(localized_name,rev(winRatio)), y=winRatio))+geom_bar(stat="identity",fill="orange")+coord_cartesian(ylim=c(0.2,0.65)) +ggtitle("Top Most winning Ratio Heroes")+xlab("Hero Names")+ylab("Winning Ratio")
    p
    })
  output$t1 <- renderDataTable({
    Dt=d1()
    DT::datatable(Dt[,4],options=list(pageLength=10,seaching=FALSE))
  })
  d2 <- reactive({
    t10ph=arrange(summarise(ql_grp,count=n()),desc(count))
    Dt=left_join(head(t10ph,input$Ng2),hname,by="hero_id")
    return(Dt)
  })
  output$g2 <- renderPlot({
    Dt=d2()
    p <- ggplot(Dt,aes(x=reorder(localized_name,rev(count)), y=count))+geom_bar(stat="identity",fill="darkgreen") +ggtitle("Top Most Popular Heroes")+xlab("Hero Names")+ylab("Pick times")
    p
  })
  output$t2 <- renderDataTable({
    Dt=d2()
    DT::datatable(Dt[,4],options=list(pageLength=10,seaching=FALSE))
  })
  d3 <- reactive({
    t10mw <- arrange(summarise(ql_grp,aveGoldmin=mean(gold_per_min)),desc(aveGoldmin)) 
    Dt=left_join(head(t10mw,input$Ng3),hname,by="hero_id")
    return(Dt)
  })
  output$g3 <- renderPlot({
    Dt=d3()
    p <- ggplot(Dt,aes(x=reorder(localized_name,rev(aveGoldmin)), y=aveGoldmin))+geom_bar(stat="identity",fill="pink") +ggtitle("Top Most wealthy Heroes")+xlab("Hero Names")+ylab("Ave Gold min")
    p
  })
  output$t3 <- renderDataTable({
    Dt=d3()
    DT::datatable(Dt[,4],options=list(pageLength=10,seaching=FALSE))
  })
  d4 <- reactive({
    t10mi <- ql[,c(10:15)]
    FreqTable=table(as.matrix(t10mi))
    popularItem=head(sort(FreqTable,decreasing=TRUE),input$Ng4)
    popularItem=popularItem[-1]
    item_id=as.integer(names(popularItem))
    Dt=left_join(cbind(data.frame(popularItem),item_id),itemname,by="item_id")
  })
  output$g4 <- renderPlot({
    Dt=d4()
    p <- ggplot(Dt,aes(x=reorder(item_name,rev(popularItem)), y=popularItem))+geom_bar(stat="identity",fill="darkgrey") +ggtitle("Top Most Popular Items")+xlab("Item names")+ylab("In bags when game ends")
    p
  })
  output$t4 <- renderDataTable({
    Dt=d4()
    DT::datatable(select(Dt,3),options=list(pageLength=10,seaching=FALSE))
  })
  
  d5 <- reactive({
    H_id=filter(hname,localized_name %in% input$mychooser$right)[,2]
    d5=arrange(summarise(ql_grp,winRatio=sum(V16==1)/n()),desc(winRatio))
    Dt=left_join(filter(d5,hero_id%in% H_id),hname,by="hero_id")
    return(Dt)
  })
  output$g5 <- renderPlot({
    Dt=d5()
    p <- ggplot(Dt,aes(x=reorder(localized_name,rev(winRatio)), y=winRatio))+geom_bar(fill="darkgreen",stat="identity") +ggtitle("Top Most winning Ratio Heroes")+xlab("Selected Hero Names")+
      ylab("Winning Ratio")
    p
  })
  output$t5 <- renderDataTable({
    Dt=d5()
    DT::datatable(Dt[,4],options=list(pageLength=10,seaching=FALSE))
  })
  
  d6 <- reactive({
    H_id=filter(hname,localized_name %in% input$sig)[,2]
    Dt=filter(q6,hero_id==H_id)
  })
  output$g6 <- renderPlot({
    Dt=d6()
    single_grp=group_by(Dt,GameTime)
    D=summarise(single_grp,winRatio=sum(V16==1)/n())
    D$GameTime=factor(D$GameTime, levels = c("< 20 min","20 ~ 30 min","30 ~ 40 min","40 ~ 50 min","> 50 min"))
    D=D[order(D$GameTime),]
    p <- ggplot(D,aes(x=GameTime,y=winRatio,group=1))+geom_point()+geom_line()+ggtitle("Winning Ratio to Duration")
    p
  })
  output$t6 <- renderDataTable({
    Dt=d6()
    t6=summarise(Dt,aveGPM=mean(gold_per_min),aveKillsPerMin=mean(kills/duration*60),
                 aveDeathPerMin=mean(deaths/duration*60),aveAssistPermin=mean(assists/duration*60),winRatio=sum(V16==1)/n())
    Dat=summarise(group_by(q6,hero_id),aveGPM=mean(gold_per_min),aveKillsPerMin=mean(kills/duration*60),
               aveDeathPerMin=mean(deaths/duration*60),aveAssistPermin=mean(assists/duration*60),winRatio=sum(V16==1)/n())
    H_id=filter(hname,localized_name %in% input$sig)[,2]
    A=apply(Dat[-1,-1],2,function(x){return(which(order(x,decreasing=T)==H_id))})
    t6=rbind(t6,A)
    rownames(t6)=c("Value","Ranking")
    t6=DT::datatable(t6,options=list(searching=FALSE,paging=FALSE))
    t6
  })
  
  d7 <- reactive({
    d7=ql%>%group_by(match_id)%>%summarise(aveTotalGold=sum(gold_per_min)/2,aveTotalXp=sum(xp_per_min)/2)
    teamD=summarise(d7,aveTotalGold=mean(aveTotalGold),aveTotalXp=mean(aveTotalXp))
    EheroD=ql%>%group_by(hero_id)%>%summarise(aveGPM=mean(gold_per_min),aveXPM=mean(xp_per_min))
    EheroD=EheroD[-1,]
    H_id=filter(hname,localized_name %in% c(input$m1,input$m2,input$m3,input$m4))[,2]
    YrH=teamD-sapply(filter(EheroD,hero_id %in% H_id)[,2:3],sum)  
    Dt=filter(EheroD,aveGPM<=YrH[1,1]*1.1,aveGPM>=YrH[1,1]*0.9,aveXPM>=YrH[1,2]*0.9,aveXPM<=YrH[1,2]*1.1)
    t10wh=summarise(ql_grp,winRatio=sum(V16==1)/n())
    DDt=arrange(filter(t10wh,hero_id %in% Dt$hero_id),desc(winRatio))%>%left_join(.,hname,by="hero_id")
    DDt=DDt[,c(2,4)]
    return(DDt)
  })
  

  output$t7 <-renderDataTable ({
    DDt=d7()
    DT::datatable(DDt,options=list(searching=FALSE))
  })
  output$g7 <- renderPlot({
    DDt=d7()
    p <- ggplot(DDt,aes(x=reorder(localized_name,rev(winRatio)), y=winRatio))+geom_bar(stat="identity",fill="darkgrey")+coord_cartesian(ylim=c(0.2,0.65)) +ggtitle("Last One Pick")+xlab("Hero Names")+ylab("Winning Ratio")
    p
  })
})

