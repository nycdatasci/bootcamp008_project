library(ggplot2)
library(dplyr)
library(ggthemes)

mutations <- read.csv('mutations_final.csv')

function(input, output, session) {
  
  selectedData <- reactive({
    filter(mutations, GENE_NAME == input$gene)
  })
  
  selectFill <- reactive({
    return(input$NT)
  })
  
  addLocation <- reactive({
    df = data.frame(location = c(max(selectedData()$location), min(selectedData()$location)))#, input$NT  = "Limits")
    df[input$NT] = c("End","Start")
    return(df)
  })
  
  output$plot <- renderPlot(
    ggplot(selectedData(), aes(x = DISEASE)) + 
      geom_histogram(stat = "count", aes(fill = TYPE)) + 
      xlab("Disease") + ylab("# of Mutations") +
      coord_flip() +
      theme_minimal())
    
  output$new <- renderPlot({
      ggplot(data = rbind(addLocation(), na.omit(selectedData()[, c("location", input$NT)])), aes_string(x = 'location', y = 0, color=input$NT)) + 
        geom_line(color = 1) + 
        geom_point(shape = 3, size = 10) +
        ggtitle(input$gene) +
        theme(line = element_blank(),
        axis.ticks.y=element_blank(),
        axis.line.y = element_blank(),
        axis.text.y = element_blank(),
        axis.title.y = element_blank() + 
        theme_minimal())
      })
  
  output$text1 <- renderText({
    if (input$gene == 'KRAS'){
      paste('The KRAS gene encodes K-ras, a protein in the RAS/MAPK pathway responsible for carrying
cellular signals from outside the cell to the nucleus, instructing the cell to proliferate
            or differentiate. Mutations are associated with pancreatic and non-smallcell lung cancer.')
    } else if (input$gene == 'APC') {
      paste('The APC gene provides is a tumor suppressor gene coding for the APC
protein. The APC gene is a potent inhibitor of beta-catinin, which regulates cell growth 
            and proliferation. As such nonfunctional APC leads to oncogenic and unregulated growth. APC mutations 
            are the most common mutation linked to colon cancer.')
    }
  })
  output$Author <- renderText({
    paste('Kyle Gallatin is a harmonious mix of biologist and data analyst. 
Recently achieveing his Masters in Molecular and Cellular Biology, 
he seeks to fuse novel analytical methods with both complex and large 
biological data sets for the greater advancement of both medicine and research.')
  })
}
