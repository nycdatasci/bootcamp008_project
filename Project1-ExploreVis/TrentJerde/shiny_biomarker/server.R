library(shiny)
library(dplyr)
library(ggplot2)
# library(tidyr)
# library(readr)
library(feather)
data.file <- file.path(
  "/Users/trentonjerde/ds_stuff/projects/biomarker/shiny_biomarker/data",
  "data.shiny.feather"
)
data.shiny <- read_feather(data.file)
std.err <- function(x) sd(x)/sqrt(length(x))

# Define server logic for random distribution application
function(input, output) {
  
  # Plot
  output$plot <- renderPlot({
    
    # Input
    subj.input <- as.integer(input$subj)
    contact.input <- as.integer(input$contact)
    voltage.input <- as.integer(input$voltage)
    
    # Data
    data.shiny.tmp <- data.shiny %>% 
      filter(
        area %in% 1:4 & 
             subj == subj.input & 
          contact == contact.input & 
          voltage == voltage.input  
      ) %>% 
      mutate(area = as.factor(area))
    data.shiny.tmp <- data.shiny.tmp %>% 
      group_by(area, contact, voltage, run, block) %>% 
      summarise(
        bold.avg = mean(bold), 
        dbs.val = unique(dbs)
      )
    data.shiny.tmp <- data.shiny.tmp %>% 
      mutate(
        res = 
          (lag(bold.avg) - bold.avg) / 
          mean(c(lag(bold.avg), bold.avg), na.rm = TRUE) * 
          100
      ) %>% 
      filter(dbs.val == 0)
    data.shiny.tmp <- data.shiny.tmp %>% 
      group_by(area, contact, voltage, run) %>% 
      mutate(pair = 1:n()) %>% 
      select(area, contact, voltage, run, pair, res)
    data.shiny.tmp <- data.shiny.tmp %>% 
      group_by(area, contact, voltage) %>% 
      summarise(
        res.avg = mean(res, na.rm = TRUE), 
        res.sem = std.err((res))
      )
    
    # Plot
    ggplot(
      data.shiny.tmp, 
      aes(
        area, 
        res.avg, 
        ymin = res.avg - res.sem, 
        ymax = res.avg + res.sem)
      ) +
      geom_bar(stat = "identity") + 
      geom_linerange() + 
      scale_x_discrete(
        breaks=c("1","2","3","4"),
        labels=c("L-M1", "R-M1", "L-Cbl", "R-Cbl")) + 
      xlab("Brain Area") + 
      ylab("fMRI Percent Signal Change") + 
      theme_minimal()
  })
  
  # # Generate a summary of the data
  # output$summary <- renderPrint({
  #   summary(data())
  # })
  # 
  # # Generate an HTML table view of the data
  # output$table <- renderTable({
  #   data.frame(x=data())
  # })
}