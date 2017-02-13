
shinyServer(function(input, output){
  #show map using googleVis
  output$DailyAlcohol <- renderPlot({
  
    ggplot(student_df_norepeats, aes_string(x=student_df_norepeats$Dalc , fill = input$selected)) +
      geom_bar(position = "dodge") + xlab(label = "Daily Alcohol Use") +
      ggtitle("")  
  })
  output$WeekendAlcohol <- renderPlot({
    
    ggplot(student_df_norepeats, aes_string(x=student_df_norepeats$Walc , fill = input$selected)) +
      geom_bar(position = "dodge") +xlab(label = "Weekend Alcohol Use") + 
      ggtitle("")  
  })
  output$BoxDailyAlcohol <- renderPlot({
    
    ggplot(student_df_norepeats, aes_string(x=student_df_norepeats$Dalc, y=input$grades, group = student_df_norepeats$Dalc)) +
      geom_boxplot() + xlab(label = "Daily Alcohol Use") + ylab(label = "Grades") +
      ggtitle("")
  })
  output$BoxWeekendAlcohol <- renderPlot({
    ggplot(student_df_norepeats, aes_string(x=student_df_norepeats$Walc, y=input$grades, group = student_df_norepeats$Walc)) +
      geom_boxplot() + xlab(label = "Weekend Alcohol Use") + ylab(label = "Grades") +
      ggtitle("")
  })
  output$table <- DT::renderDataTable({
    datatable(student_df_norepeats, rownames = FALSE) %>%
      formatStyle(input$selected,
               background="skyblue", fontWeight='bold')
  })

 
})
  