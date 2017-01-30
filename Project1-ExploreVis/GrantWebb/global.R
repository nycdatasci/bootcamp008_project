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
