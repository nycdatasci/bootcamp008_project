library(shiny)
library(shinydashboard)
library(googleVis)
library(ggplot2)
library(dplyr)
library(DT)

student_mat_df = read.csv("./data/student-mat.csv", stringsAsFactors = FALSE)
student_por_df = read.csv("./data/student-por.csv", stringsAsFactors = FALSE)
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
student_df_norepeats$Medu <- ordered(student_df_norepeats$Medu,
                                     levels = c(0,1,2,3,4),
                                     labels = c("none","up to 4th grade","up to 5th-9th grade",
                                                "secondary education","higer education"))
student_df_norepeats$Fedu <- ordered(student_df_norepeats$Fedu,
                                     levels = c(0,1,2,3,4),
                                     labels = c("none","up to 4th grade","up to 5th-9th grade",
                                                "secondary education","higer education"))
student_df_norepeats$traveltime <-ordered(student_df_norepeats$traveltime,
                                          levels = c(1,2,3,4),
                                          labels = c("< 15 min", "15 to 30 min", "30 min to 1 hr", "> 1hr"))
student_df_norepeats$studytime <-ordered(student_df_norepeats$studytime,
                                          levels = c(1,2,3,4),
                                          labels = c("< 2 hrs", "2 to 5 hrs", "5 to 10 hrs", "> 10 hrs"))
student_df_norepeats$famrel <- ordered(student_df_norepeats$famrel,
                                       levels = c(1,2,3,4,5),
                                       labels = c("very bad","bad","average","good","excellent"))
student_df_norepeats$freetime <- ordered(student_df_norepeats$freetime,
                                       levels = c(1,2,3,4,5),
                                       labels = c("very low","low","average","high","very high"))
student_df_norepeats$goout <- ordered(student_df_norepeats$goout,
                                         levels = c(1,2,3,4,5),
                                         labels = c("very low","low","average","high","very high"))


student_df_norepeats$age <- as.factor(student_df_norepeats$age)
student_df_norepeats$failures <- as.factor(student_df_norepeats$failures)
student_df_norepeats$Dalc <- as.factor(student_df_norepeats$Dalc)
student_df_norepeats$Walc <- as.factor(student_df_norepeats$Walc)
choice = c("Age" = "age",
           "Sex" = "sex",
           "Urban or Rural" = "address",
           "Parent's Cohabitation status" = "Pstatus",
           "Family Size > 3" = "famsize",
           "Mother's Education Level" = "Medu",
           "Father's Education Level" = "Fedu",
           "Mother's Job" = "Mjob",
           "Father's Job" = "Fjob",
           "Reason School Choice" ="reason", 
           "Gaurdian" = "guardian",
           "Travel Time" = "traveltime",
           "Study Time" = "studytime",
           "Number of Past Class Failures" = "failures",
           "Extra Educational Support" = "schoolsup",
           "Family Educational Support" = "famsup",
           "Extra Paid Coures" = "paid", 
           "Extra-curricular Activities" = "activities",
           "Attended Nursery School" =  "nursery",
           "Wants to Take Higher Education" = "higher",
           "Internet Access at Home" = "internet",
           "Romantically Involved" = "romantic",
           "Quality of Family Relationships" = "famrel",
           "Free Time After School" = 'freetime',
           "Going Out With Friends" = "goout"
           
          
) 
class_time_grades =  c("Morning Classes" = "G1",
                       "Afternoon Classes" = "G2",
                       "All Classes" = "G3",
                       "Absences" = "absences"
)
