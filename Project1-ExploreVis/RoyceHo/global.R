library(dplyr)
library(shiny)
library(shinydashboard)
library(shinyjs)
library(DT)
library(ggplot2)

#clean df
ehresp = read.csv("ehresp_2014.csv")
ehresp[ehresp< 0] = NA
drops = c("tulineno","erhhch", "erspemch", "ethgt", "etwgt",
          "eufinlwgt", "euinclvl", "exincome1")
ehresp = ehresp[, !(names(ehresp) %in% drops)]
ehresp = setNames(ehresp, c("id", "income1", "bmi", "income", "tpreat", "tseat", "sodatype", "drink", "seat",      
                            "exercise", "exfreq", "fastfd", "fastfdfrq", "ffyday", "fdsit", "snap", 
                            "genhth", "groshp", "hgt", "income2", "meat", "milk", "prpmel", "soda", "stores", 
                            "streason", "therm", "wgt", "wic"))
ehresp = mutate(ehresp, ttoteat = tpreat + tseat)
col_names = colnames(ehresp)
col_names = sort(col_names[-c(1)])

#variable grouping
importantvars = c("bmi", "hgt", "wgt", "genhth")
financialvars = c("income", "income1", "income2", "fdsit", "snap", "wic")
exercisevars = c("exercise", "exfreq")
eattypevars = c("drink", "soda", "sodatype", "milk", "meat", "fastfd", "fastfdfrq", "ffyday")
mealprepvars = c("groshp", "stores", "streason","prpmel", "therm")
timeeatvars = c("seat", "tpreat", "tseat", "ttoteat")
contvars = c("bmi", "tpreat", "tseat", "exfreq", "fastfdfrq", "hgt", "wgt", "ttoteat")
catvars = c("income1", "income", "sodatype", "drink", "seat", "exercise", "fastfd", "ffyday", "fdsit", "snap", 
            "genhth", "groshp","income2", "meat", "milk", "prpmel", "soda", "stores", "streason", "therm", "wic")

#redo income values
ehresp[c("income1", "income2")][is.na(ehresp[c("income1", "income2")])] = FALSE
for(i in 1:nrow(ehresp)){
  if(ehresp$income1[i] == 1){
    ehresp$income[i] = 1
  } else if(ehresp$income1[i] == 3){
    ehresp$income[i] = 2
  } else if(ehresp$income2[i] == 2){
    ehresp$income[i] = 5
  } else if(ehresp$income2[i] == 3){
    ehresp$income[i] = 4
  } else if(ehresp$income1[i] == 2 & ehresp$income2[i] == 1){
    ehresp$income[i] = 3
  } else {
    ehresp$income[i] = NA
  }
}
ehresp[c("income1", "income2")][ehresp[c("income1", "income2")]== 0] = NA

#rename factors of categorical vars
ehresp$income = as.factor(ehresp$income)
levels(ehresp$income) = c("income > 185% P.T.", "income = 185% P.T.", "130% < income < 185% P.T.",
                          "income = 130% P.T.", "income < 130% P.T")
ehresp$income = ordered(ehresp$income, levels = c("income < 130% P.T","income = 130% P.T.","130% < income < 185% P.T.",
                                                  "income = 185% P.T." , "income > 185% P.T."))
ehresp$income1 = as.factor(ehresp$income1)
levels(ehresp$income1) = c("income > 185% P.T.","income < 185% P.T.","income = 185% P.T.")
ehresp$income1 = ordered(ehresp$income1, levels = c("income < 185% P.T.", "income = 185% P.T.", "income > 185% P.T."))
ehresp$income2 = as.factor(ehresp$income2)
levels(ehresp$income2) = c("income > 130% P.T.","income < 130% P.T.","income = 130% P.T.")
ehresp$income2 = ordered(ehresp$income2, levels = c("income < 130% P.T.", "income = 130% P.T.", "income > 130% P.T."))
ehresp$sodatype = as.factor(ehresp$sodatype)
levels(ehresp$sodatype) = c("diet", "regular", "both")
ehresp$drink = as.factor(ehresp$drink)
levels(ehresp$drink) = c("yes", "no")
ehresp$drink = ordered(ehresp$drink, levels = c("no", "yes"))
ehresp$seat = as.factor(ehresp$seat)
levels(ehresp$seat) = c("yes", "no")
ehresp$seat = ordered(ehresp$seat, levels = c("no", "yes"))
ehresp$exercise = as.factor(ehresp$exercise)
levels(ehresp$exercise) = c("yes", "no")
ehresp$exercise = ordered(ehresp$exercise, levels = c("no", "yes"))
ehresp$fastfd = as.factor(ehresp$fastfd)
levels(ehresp$fastfd) = c("yes", "no")
ehresp$fastfd = ordered(ehresp$fastfd, levels = c("no", "yes"))
ehresp$ffyday = as.factor(ehresp$ffyday)
levels(ehresp$ffyday) = c("yes", "no")
ehresp$ffyday = ordered(ehresp$ffyday, levels = c("no", "yes"))
ehresp$fdsit = as.factor(ehresp$fdsit)
levels(ehresp$fdsit) = c("Enough to eat", "Sometimes not enought to eat", "Often not enough to eat")
ehresp$fdsit = ordered(ehresp$fdsit, levels = c("Often not enough to eat","Sometimes not enought to eat","Enough to eat"))
ehresp$snap = as.factor(ehresp$snap)
levels(ehresp$snap) = c("yes", "no")
ehresp$snap = ordered(ehresp$snap, levels = c("no", "yes"))
ehresp$genhth = as.factor(ehresp$genhth)
levels(ehresp$genhth) = c("Excellent", "Very Good", "Good", "Fair", "Poor")
ehresp$genhth = ordered(ehresp$genhth, levels = c("Poor", "Fair", "Good", "Very Good", "Excellent"))
ehresp$groshp = as.factor(ehresp$groshp)
levels(ehresp$groshp) = c("yes", "no", "split eq. w/ household members")
ehresp$groshp = ordered(ehresp$groshp, levels = c("no", "yes", "split eq. w/ household members"))
ehresp$meat = as.factor(ehresp$meat)
levels(ehresp$meat) = c("yes", "no")
ehresp$meat = ordered(ehresp$meat, levels = c("no", "yes"))
ehresp$milk = as.factor(ehresp$milk)
levels(ehresp$milk) = c("yes", "no")
ehresp$milk = ordered(ehresp$milk, levels = c("no", "yes"))
ehresp$prpmel = as.factor(ehresp$prpmel)
levels(ehresp$prpmel) = c("yes", "no", "split eq. w/ household members")
ehresp$prpmel = ordered(ehresp$prpmel, levels = c("no", "yes", "split eq. w/ household members"))
ehresp$soda = as.factor(ehresp$soda)
levels(ehresp$soda) = c("yes", "no")
ehresp$soda = ordered(ehresp$soda, levels = c("no", "yes"))
ehresp$stores = as.factor(ehresp$stores)
levels(ehresp$stores) = c("Grocery store", "Supercenter", "Warehouse club", "Drugstore / Convenience store", "other")
ehresp$streason = as.factor(ehresp$streason)
levels(ehresp$streason) = c("Price", "Location", "Quality", "Variety", "Customer service", "other")
ehresp$therm = as.factor(ehresp$therm)
levels(ehresp$therm) = c("yes", "no")
ehresp$therm = ordered(ehresp$therm, levels = c("no", "yes"))
ehresp$wic = as.factor(ehresp$wic)
levels(ehresp$wic) = c("yes", "no")
ehresp$wic = ordered(ehresp$wic, levels = c("no", "yes"))

#graph selections
ngraphs = c("Density", "Histogram")
cgraphs = c("Bar")
nngraphs = c("Line","Box", "Density2D", "Scatter", "Violin") #aes(group = cut_width(carat, 0.25))
ncgraphs = ngraphs
cngraphs = c("Box", "Violin")
ccgraphs = cgraphs
nncgraphs = c("Line", "Density2D", "Scatter") #split graphs using facet
cncgraphs = c("Box", "Violin") #aes = v3, also change v3 selection
nccgraphs = c()
#data dictionary
datadic = data.frame(var = sort(col_names), 
                     def = c("bmi: Body mass index",
                       "drink: If you drank drinks other than water yesterday",
                       "exercise: If you participated in any physical activities or exercises, outside your job duties, in the past 7 days",
                       "exfreq: Number of times you participated in physical activites or exercises in the past 7 days",
                       "fastfd: Did you purchase prepared food from a deli, carry-out, delivery food, or fast food in the past 7 days",
                       "fastfdfrq: Number of times you purchased fastfood in the past 7 days",
                       "fdsit: What best describes the amount of food eaten in your household in the last 30 days",
                       "ffyday: Did you purchase fast food yesterday",
                       "genhth: What best describes your physical health",
                       "groshp: Do you normally do grocery shopping in your household",
                       "hgt: Height without shoes in inches",
                       "income: Relationship between your income and poverty threshold",
                       "income1: Relationship between your income and 185% of poverty threshold",
                       "income2: Relationship between your income and 130% of poverty threshold",
                       "meat: Did you eat any meat, poultry, or seafood in the past 7 days",
                       "milk: Did you drink unpasterized or raw milk in the past 7 days",
                       "prpmel: Do you normally prepare your own meals in your household",  
                       "seat: Did you snack or eat a meal while doing something else yesterday",
                       "snap: In the past 30 days, did you or any member of your household receive Supplemental Nutrition Assistance Program(SNAP) or food stamp benefits",
                       "soda: Did you drink and soft drinks yesterday",
                       "sodatype: Types of soft drinks consumed",
                       "stores: Where do you get the majority of your groceries",
                       "streason: Reason for shopping at a particular store",
                       "therm: Do you use a thermometer when preparing meals",
                       "tpreat: Total time spent eating and drinking yesterday when it was the primary activity",
                       "tseat: Total time spent eating and drinking yesterday when it was the secondary activity",
                       "ttoteat: Total time spent eating and drinking yesterday",
                       "wgt: Weight without shoes in pounds",
                       "wic: Did you or any member of your household receive benefits from the Women, Infants, and Children program (WIC) in the past 30 days")
                     )

labs = theme_bw() + theme(axis.text=element_text(size=10), axis.title=element_text(size=14,face= "bold"), 
                          plot.title = element_text(size = 20, face = "bold", hjust = 0.5))





