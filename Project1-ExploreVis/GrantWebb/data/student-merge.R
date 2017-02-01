#d1=read.table("student-mat.csv",sep=";",header=TRUE)
#d2=read.table("student-por.csv",sep=";",header=TRUE)

#d3=merge(d1,d2,by=c("school","sex","age","address","famsize","Pstatus","Medu","Fedu","Mjob","Fjob","reason","nursery","internet"))
#print(nrow(d3)) # 382 students

student_mat_df = read.csv("~/Desktop/Main Folder/NYC_Data_Science/DataScienceProject1/data/student-mat.csv", stringsAsFactors = FALSE)
View(student_mat_df)
str(student_mat_df)
student_por_df = read.csv("~/Desktop/Main Folder/NYC_Data_Science/DataScienceProject1/data/student-por.csv", stringsAsFactors = FALSE)
View(student_por_df)
str(student_por_df)
student_df <- rbind(student_mat_df,student_por_df)
student_df_norepeats <- student_df %>% distinct(school,sex,age,address,famsize,Pstatus,
                                                Medu,Fedu,Mjob,Fjob,reason,
                                                guardian,traveltime,studytime,failures,
                                                schoolsup, famsup,activities,nursery,higher,internet,
                                                romantic,famrel,freetime,goout,Dalc,Walc,health,absences, .keep_all = TRUE)
library(ggplot2)
library(dplyr)
at_home_mom <- filter(student_df_norepeats, student_df_norepeats$Mjob == "at_home")
head(at_home_mom)
ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc, fill = student_df_norepeats$Mjob)) +
         geom_bar() +
         ggtitle("")

head(student_df$Dalc)


ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = student_df_norepeats$Mjob)) +
  geom_bar() +
  ggtitle("")
 
ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc, fill = student_df_norepeats$Fjob)) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = student_df_norepeats$Fjob)) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc, fill = student_df_norepeats$famsize)) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = student_df_norepeats$famsize)) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc, fill = student_df_norepeats$romantic)) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = student_df_norepeats$romantic)) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc, fill = as.factor(student_df_norepeats$freetime))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$freetime))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$famrel))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$famrel))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$sex))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$sex))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$goout))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$goout))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$guardian))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$guardian))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$address))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$address))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc, y = student_df_norepeats$absences)) +
  geom_point() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, y = student_df_norepeats$absences)) +
  geom_point() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$address))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$address))) +
  geom_bar() +
  ggtitle("")
ggplot(student_df_norepeats, aes(x=student_df_norepeats$Dalc,fill = as.factor(student_df_norepeats$nursery))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes(x=student_df_norepeats$Walc, fill = as.factor(student_df_norepeats$nursery))) +
  geom_bar() +
  ggtitle("")

ggplot(student_df_norepeats, aes_string(x=student_df_norepeats$Walc, y='G3', group = student_df_norepeats$Walc)) +
  geom_boxplot() + xlab(label = "Walc") + ylab(label = "Grades") +
  ggtitle("")


#t.test
#Description Tab (about the data and myself)
# 
ggplot(at_home_mom, aes_string(x=at_home_mom$Dalc, y='G3', group = at_home_mom$Dalc)) +
  geom_boxplot() + xlab(label = "Dalc") + ylab(label = "Grades") +
  ggtitle("")

ggplot(at_home_mom, aes_string(x=at_home_mom$Walc, y='G3', group = at_home_mom$Walc)) +
  geom_boxplot() + xlab(label = "Walc") + ylab(label = "Grades") +
  ggtitle("")
