library(shiny)
library(shinydashboard)
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
student_df_norepeats$Dalc <- as.factor(student_df_norepeats$Dalc)
student_df_norepeats$Walc <- as.factor(student_df_norepeats$Walc)
student_df_norepeats$age <- as.factor(student_df_norepeats$age)
choice = c("Age" = "age",
           "Sex" = "sex",
           "Urban or Rural" = "address",
           "Family Size > 3" = "famsize",
           "Mother's Job" = "Mjob",
           "Father's Job" = "Fjob",
           "Reason School Choice" ="reason", 
           "Extra Paid Coures" = "paid", 
           "Internet Access at Home" = "internet",
           "Romantically Involved" = "romantic",
           "Attended Nursery School" = "nursery",
           "Gaurdian" = "guardian"
) 
class_time_grades =  c("Morning Classes" = "G1",
                       "Afternoon Classes" = "G2",
                       "All Classes" = "G3",
                       "Absences" = "absences"
)
