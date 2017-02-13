library(stringr)
library(wordcloud)
library(memoise)
library(ggplot2)
library(reshape)
library(googleVis)
library(tm)
library(SnowballC)
library(wordcloud2)
library(RColorBrewer)
library(dplyr)
library(tidyr)

source("globals.R")

function(input, output,session){
  #---------------- Recommendation tab
  # filter a list by category
  by_category <- reactive({
    data_review_only %>% dplyr::filter(Category == input$category)
  })
  
  # product_words filtered
  product_words_by_category <- reactive({
    product_words %>% dplyr::filter(Category == input$category)
  })
  
  #Update the selection of tags on step 2
  observe({
    updateSelectInput(session, "tags",
                      choices = unique(product_words_by_category()$word)) 
    })
  
  answer <- reactiveValues(rec = NULL)
  
  # Generate a result when button is clicked
  observeEvent(input$recommend,{
    query <- query_tf_idf(input$tags,product_words_by_category())
    answer$rec <- recommend(query,5,product_words_by_category())
    
  })

  # Render Data table: just to make sure things are still working
  output$rec <- DT::renderDataTable(
    answer$rec
  ) 
  
  #---------------- Wordcloud tab
  
  output$wordcloud2 <- renderWordcloud2({
    wordcloud2(word_freq)
  })
  
  #---------------- general information tab
  output$ratings <- renderPlot({
    ggplot(data_review_only, aes(x=UserRating))+
      geom_bar(aes(fill = '#ffc0cb')) + 
      ggtitle("Distribution of User Ratings")+
      guides(fill=FALSE)
  })
  
  output$top_brands <- renderGvis({
    brands <- unique(data[c("Brand", "BrandNReviews")]) 
    brands <- arrange(brands,desc(BrandNReviews))
    brands <- brands %>% top_n(10)
    gvisColumnChart(brands,options = list(colors = "['#ffc0cb']", 
                                          title="Top 10 most Reviewed Brands",
                                            titleTextStyle="{color:'#ff6680', fontSize:18}"))

  })
  
  output$top_products <- renderGvis({
    products <- unique(data[c("Product", "ProductNReviews")]) 
    products <- arrange(products,desc(ProductNReviews))
    products <- products %>% top_n(10)
    gvisColumnChart(products, options = list(colors = "['#ffc0cb']",
                                             title="Top 10 most Reviewed Products",
                                             titleTextStyle="{color:'#ff6680', fontSize:18}"))
  })
  
  
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