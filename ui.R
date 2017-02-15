shinyUI(dashboardPage(

  dashboardHeader(title = 'Analysis of Video Game Sales since 1980 to Dec 2016'),

  dashboardSidebar(
    sidebarUserPanel("Content"),
    sidebarMenu(
      menuItem("Intro", tabName = "markdown"),
      menuItem("Correlation Matrix", tabName = "corr"),
      menuItem("Genre Data Visualization", tabName = "Genre"),
      menuItem("Best Seller Words by Genre", tabName = 'wordc'),
      menuItem("Console Wars Sales", tabName = 'ConsoleComp'),
      menuItem("Regional Yearly Sales", tabName = "YearRegionSales"),
      menuItem("Do Ratings Affect Sales",tabName = 'score'),
      menuItem("Regional Influence Total Sales", tabName = 'regSale'),
      menuItem("Data", tabName = "data", icon = icon("database"))

           )
    ),
    
  dashboardBody(
    tabItems(
      tabItem(tabName = "markdown", h1(img(src="pic.jpg", height = 400)),
              h1(class = 'text-muted','"He who fails to plan is planning to fail
                                          ", Churchill'),
              p(paste("In 1970, Atari was an industry giant in Silicon Valley with one of the largest R&D Divisions.  In 1983, they
                    played a large role in creating the video game crash and then became defunct in 1984.  Nintendo was initially founded 
                    as a card company but blossomed into the console industry when Gunpei Yokoi pioneered the handheld console in 
                    Nintendo's Game&Watch series.  Sixteen years later, he would also be responsible for one of their biggest console failures
                    in their Virtual Boy.  In 1979, Sony produced the world's first portable music player, the Walkman.  Expanding rapidly
                    through the electronics market, Sony was thought to be too big to fail.  However, strings of commercial mistakes lead to a near
                    demise till Sony was saved by their Playstation 2, which has now reported to be the best selling console of all time.  Now with the
                    entry of mobile apps into the video game market, it's up to the industry giants once again, to adapt or die.")),
              p(paste("This app is an alpha project to look at various trends in the console gaming industry using Kaggle's Video Game Sales dataset."))),
      tabItem(tabName = "corr", h2(plotOutput('corr')),
      p(class = "text-muted",paste("The standard correlation matrix doesn't display anything unexpected.  Most columns with
      similar class data tend to correlate with each other.  Pie chart method is used to give clarity on correlation coefficients."
      ))),
      tabItem(tabName = "Genre", p(class = "text-muted",  
      paste('A common opinion is that critics tend to give more favorable reviews compared to users but we see critics score
      and user score are fairly similar with the average user giving higher scores on average per genre than critics.  
      The only outlier is along the sports column where critics rate them higher than users do.  Sports are also by
      far the most likely genre to be franchised such as "Madden", "NFL", etc. where each edition only offers minor improvements.  
      For a critic where games are typically played for a smaller span of time, franchised series are judged mostly on individual
      merit whereas users may not view paying for minor improvements to be justified to the same degree.'
      ), h1(plotOutput('avgGscore')), 
      p(class = "text-muted",  
      paste("Sales wise, desired genres follow very strong trends.  In the earlier 80's and 90's, when technology aren't
      as Sega's own mascot, Sonic the Hedgehog. Early shooters such as Asteroids and Space Invaders also did well in the
            pre-8bit era.  As technology progressed and systems became more powerful, we see a trend towards genres that
            were able to demonstrate the more powerful graphics and engines.  By 2000, action games took over the market
            and never let up.  Note that 2016's data hasn't been completely processed yet hence the lower numbers."
       )),h1(plotOutput('topTwoGenre')))
      ),
      tabItem(tabName = "wordc", h1(plotOutput('wordc')), 
              paste('Word cloud of best selling words in title by Genre.  Frequency of word is signified by color density.'
              )),
      tabItem(tabName = "ConsoleComp", p(class = "text-muted",  
        paste("The console wars started between Nintendo and Sega.  While history should record that Nintendo was ultimately
        victorious, the big stories since 2010 has been between Microsoft and Sony. However, as demonstrated by the radar plot,
        Sony's global dominance in the console market carries them through.  In addition, we see Japan's loyalty to the national
        brand under Nintendo with Microsoft doing exceptionally poor in the region.  In particular, we also notice Nintendo's dominance
        from 2000 to 2008 due to the popularity of their portable consoles such as the Nintendo DS.  They were overthrown by Sony's Playstation
        as mobiles become increasingly the go to choice for small portable app based games.  Current trends show Nintendo has yet to been unable to 
        wrest the console market from Sony")),
        h1(plotOutput('radar')), 
        h1(plotOutput('topTwoPlat')),
        p(paste('By examining the pie chart, it looks as if Sony and Nintendo are controlling equal shares of the market, one must remember that Nintendo
        had a "head start".  Since this pie chart is recording distribution of sales since 1980, one can conclude that Nintendo is actually losing market 
        shares to Sony and Microsoft.
        ')),
        h1(
          plotOutput('ConsoleComp')),
        p(paste("There are also more reviews submitted for Microsoft's console games compared to reviews submitted from other console
        companies.  Given, that the reviews are mostly pulled from English speaking regions, there may also be correlation between Microsoft's
        console performance in sales and whether or not the region speaks English.
        ")), h1(plotOutput('ConsoleComp1'))
        ),
      tabItem(tabName = "YearRegionSales", fluidRow(box(width =12, sliderInput(inputId = 'yearID', label = "Year", min = 1980, max = 2020,
                                                                               step = 1, value = c(1980, 2020)),
                                                                               h1(plotOutput('YearRegionSales'))))),
      tabItem(tabName = "data","Data Base", fluidRow(box(width=12, DT::dataTableOutput("table")))),
      tabItem(tabName = "score", fluidRow(box(width = 12, title = "Controls",
        selectInput(inputId = "rate",
                       label = "Rated By",
                       choices = list("Critics Ratings" = "Critic_Score",
                                      "Users Ratings" = "User_Score")),
        selectInput(inputId = "sale",
                       label = "Regions",
                       choices = list("NA Sales" = "NA_Sales",
                                      "EU Sales" = "EU_Sales",
                                      "JP Sales" = "JP_Sales",
                                      "Other Region Sales" = "Other_Sales",
                                      "Global Sales" = "Global_Sales")), 
        h1(plotOutput('score'))))),
      tabItem(tabName = "regSale", fluidRow(box(width =12, title="Regions",
        selectInput(inputId = "reg1",
                       label = "Region 1",
                       choices = list("North America" = 'NA_Sales',
                                      "Europe" = 'EU_Sales',
                                      "Japan" = 'JP_Sales',
                                      "other" = "Other_Sales",
                                      "Global" = "Global_Sales")),
        selectInput(inputId = "reg2",
                       label = "Region 2",
                       choices = list("North America" = 'NA_Sales',
                                      "Europe" = 'EU_Sales',
                                      "Japan" = 'JP_Sales',
                                      "other" = "Other_Sales",
                                      "Global" = "Global_Sales")))),
        h1(plotOutput('regSale')))

      )
))
)


