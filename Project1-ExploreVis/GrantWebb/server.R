library(googleVis)
library(ggplot2)
library(dplyr)
library(DT)
student_mat_df = read.csv("~/Desktop/Main Folder/NYC_Data_Science/DataScienceProject1/data/student-mat.csv", stringsAsFactors = FALSE)
student_por_df = read.csv("~/Desktop/Main Folder/NYC_Data_Science/DataScienceProject1/data/student-por.csv", stringsAsFactors = FALSE)
student_df <- rbind(student_mat_df,student_por_df)
student_df_norepeats <- student_df %>% distinct(school,sex,age,address,famsize,Pstatus,
                                                Medu,Fedu,Mjob,Fjob,reason,
                                                guardian,traveltime,studytime,failures,
                                                schoolsup, famsup,activities,nursery,higher,internet,
                                                romantic,famrel,freetime,goout,Dalc,Walc,health,absences, .keep_all = TRUE)
student_df_norepeats$Dalc <- ordered(student_df_norepeats$Dalc,
                                     levels = c(1,2,3,4,5), 
                                     labels = c("very little", "little", "medium","heavy","very heavy"))
student_df_norepeats$Walc <- ordered(student_df_norepeats$Walc,
                                     levels = c(1,2,3,4,5), 
                                     labels = c("very little", "little", "medium","heavy","very heavy"))
student_df_norepeats$age <- as.factor(student_df_norepeats$age)
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
  