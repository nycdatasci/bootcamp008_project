shinyServer(function(input, output) ({
   
  output$corr <- renderPlot({corrplot(VGdataCor, method = 'pie', order = 'hclust')
  })
  output$score  <- renderPlot({ggplot(VGdata, aes_string(x=input$rate, y=input$sale)) +geom_point(
    aes(color = Genre)) + geom_smooth() + ylim(c(0,15)) + ggtitle("Review Scores versus Unit Sales(in millions)")})
  output$regSale<- renderPlot({ggplot(VGdata, aes_string(
    x = input$reg1, y= input$reg2)) + geom_point(aes(color=Genre)) +geom_smooth()})
  output$avgGscore <- renderPlot({ggplot(genreAvgScore, aes(x=Genre, y=scores, fill = type, group =type)) + geom_bar(
    stat='identity', position = 'dodge') + ggtitle('Average Genre Review Scores')})
  output$wordc <- renderPlot({comparison.cloud(BestSellerM, colors=brewer.pal(length(levels(BestSeller$Genre)), "Paired"), scale=c(3,0.5), title.size = 1)})
  output$ConsoleComp <- renderPlot({ggplot(bigThree, aes(x=factor(1), y=Total_Sales, fill = companyPlatform)) + geom_bar(stat = 'Identity')+ coord_polar(theta='y')+ theme(axis.title.y=element_blank(),
                                                                                                                                                                           axis.text.y=element_blank(),
                                                                                                                                                                           axis.ticks.y=element_blank(),
                                                                                                                                                                           axis.ticks.x=element_blank(),
                                                                                                                                                                           axis.text.x=element_blank())+ ggtitle('Distribution of Sales Across Regions') +ylab('Sales Distribution')})
  output$ConsoleComp1 <- renderPlot({ggplot(bigThree, aes(x=factor(1), y=Total_Users, fill = companyPlatform)) + geom_bar(stat = 'Identity')+ coord_polar(theta='y')+ theme(axis.title.y=element_blank(),
                                                                                                                                                                           axis.text.y=element_blank(),
                                                                                                                                                                           axis.ticks.y=element_blank(),
                                                                                                                                                                           axis.ticks.x=element_blank(),
                                                                                                                                                                           axis.text.x=element_blank()) + ggtitle('Users Count Across Regions')+ylab('Number of User Reviews')})
  output$topTwoGenre <- renderPlot({ggplot(YearTopTwoGenre, aes(x=Year_of_Release, y=total.genre.sales)) + geom_bar(stat='Identity', aes(fill=Genre))})
  output$topTwoPlat <- renderPlot({ggplot(YearTopTwoPlat, aes(x=Year_of_Release, y=total.plat.sales)) + geom_bar(stat='Identity', position = 'stack', aes(fill=Platform))+xlab(
    'Year of Release') + ylab('Units Sold in Millions') + ggtitle('Top Two Console Games Sold')})
  output$YearRegionSales <-renderPlot({ggplot(data = tot_region_sales, aes(x = Year_of_Release)) + geom_line(aes(y=tot_NA_sales, colour = 'NA Sales'))+ geom_line(aes(y=tot_EU_sales, colour = 'EU Sales')) + geom_line(aes(y=tot_JP_sales, colour = 'JP Sales')) + xlab(
    'Units sold in Millions') + ylab('Year of Release') + ggtitle('Regional Units Sold Comparison')
    })
  
  output$radar <-renderPlot({ggradar(scaled_bigThree) +  ggtitle('Regional Performance of Consoles')})
  output$table <-renderDataTable({
    datatable(VGdata, rownames=FALSE) %>% 
      formatStyle(input$selected,  
                  background="skyblue", fontWeight='bold')})

  })
)
