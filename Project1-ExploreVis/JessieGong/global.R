library(dplyr)
library(shiny)
library(ggmap)
library(shiny)
library(googleVis)

## tab DRG drop down menu selection ##
year = list("2011" = "2011", "2012" = "2012", "2013" = "2013", "2014" = "2014")
state = list("Inpatient" = "Inpatient", "Outpatient" = "Outpatient", "Total" = "Total")
DRG = in_total_DRG
cost = colnames(in_total)[3:4]
hospital = as.list(unique(in_2014[,3]))
top = list("Top 5" = 5, "Top 10" = 10, "Top 20" = 20)
  
## tab DRG dataset ##
#inpatient 2014
in_2014 = read.csv('Medicare_Provider_Charge_Inpatient_DRGALL_FY2014.csv',stringsAsFactors = FALSE)
t = in_2014 %>% group_by(DRG.Definition) %>% summarise(count = sum(Total.Discharges))
t = arrange(t,desc(count))[1:100, ]
in_2014 = left_join(t,in_2014)
cols.dont.want <- "count"
in_2014 = in_2014[, ! names(in_2014) %in% cols.dont.want, drop = F]
#out_2014 = read.csv('Medicare_Provider_Charge_Outpatient_APC32_CY2014.csv')
in_2014_state=in_2014 %>% 
  group_by(Provider.State,DRG.Definition) %>% 
  summarise(Average.Charges = mean(Average.Covered.Charges),
            Average.Medicare.Payments=mean(Average.Medicare.Payments),
            Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2014")

#inpatient 2013
in_2013 = read.csv('Medicare_Provider_Charge_Inpatient_DRG100_FY2013.csv',stringsAsFactors = FALSE)
in_2013=in_2013[complete.cases(in_2013),]
#out_2013 = read.csv('Medicare_Provider_Charge_Outpatient_APC30_CY2013_v2.csv')
in_2013_state=in_2013 %>% 
  group_by(Provider.State,DRG.Definition) %>% 
  summarise(Average.Charges = mean(Average.Covered.Charges),
            Average.Medicare.Payments = mean(Average.Medicare.Payments),
            Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2013")

#inpatient 2012
in_2012 = read.csv('Medicare_Provider_Charge_Inpatient_DRG100_FY2012.csv',stringsAsFactors = FALSE)
#out_2012 = read.csv('Medicare_Provider_Charge_Outpatient_APC30_CY2012.csv')
in_2012_state=in_2012 %>% 
  group_by(Provider.State,DRG.Definition) %>% 
  summarise(Average.Charges = mean(Average.Covered.Charges),
            Average.Medicare.Payments=mean(Average.Medicare.Payments),
            Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2012")

#inpatient 2011
in_2011 = read.csv('Medicare_Provider_Charge_Inpatient_DRG100_FY2011.csv',stringsAsFactors = FALSE)
in_2011_state=in_2011 %>% 
  group_by(Provider.State,DRG.Definition) %>% 
  summarise(Average.Charges = mean(Average.Covered.Charges),
            Average.Medicare.Payments = mean(Average.Medicare.Payments),
            Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2011")

#inpatient 2011-2014 charges/payments by state
in_total = rbind(in_2011_state,in_2012_state,in_2013_state,in_2014_state)

in_total_DRG = unique(in_total[,2])

q = in_2012 %>% group_by(DRG.Definition) %>% summarise(count = n())
q = arrange(t,desc(count))[1:100, ]

#inpatient 2011-2014 charges/payments by hospital
in_2011_hospital = in_2011 %>% mutate(year = "2011")
in_2012_hospital = in_2012 %>% mutate(year = "2012")
in_2013_hospital = in_2013 %>% mutate(year = "2013")
in_2014_hospital = in_2014 %>% mutate(year = "2014")
in_total_hospital = rbind(in_2011_hospital,in_2012_hospital,in_2013_hospital,in_2014_hospital)

#inpatient 2011-2014 total spending (spending of an individual DRG for an individual Provider = 
# discharges*medicare payments
in_2011_spending = in_2011 %>% 
  mutate(Individual.Spending = Total.Discharges * Average.Medicare.Payments, year = "2011") %>%
  group_by(DRG.Definition) %>% 
  summarise(Total.Spending = sum(Individual.Spending), 
            Total.Discharges = sum(Total.Discharges),
            Average.Medicare.Payments = mean(Average.Medicare.Payments),
            Total.Medicare.Payments = sum(Average.Medicare.Payments)) %>%
  mutate(year = "2011") %>%
  arrange(desc(Total.Spending)) 

in_2012_spending = in_2012 %>% 
  mutate(Individual.Spending = Total.Discharges * Average.Medicare.Payments, year = "2012") %>%
  group_by(DRG.Definition) %>% 
  summarise(Total.Spending = sum(Individual.Spending), 
            Total.Discharges = sum(Total.Discharges),
            Average.Medicare.Payments = mean(Average.Medicare.Payments),
            Total.Medicare.Payments = sum(Average.Medicare.Payments)) %>% 
  mutate(year = "2012") %>%
  arrange(desc(Total.Spending)) 

in_2013_spending = in_2013 %>% 
  mutate(Individual.Spending = Total.Discharges * Average.Medicare.Payments, year = "2013") %>%
  group_by(DRG.Definition) %>% 
  summarise(Total.Spending = sum(Individual.Spending), 
            Total.Discharges = sum(Total.Discharges),
            Average.Medicare.Payments = mean(Average.Medicare.Payments),
            Total.Medicare.Payments = sum(Average.Medicare.Payments)) %>% 
  mutate(year = "2013") %>%
  arrange(desc(Total.Spending))

in_2014_spending = in_2014 %>% 
  mutate(Individual.Spending = Total.Discharges * Average.Medicare.Payments, year = "2014") %>%
  group_by(DRG.Definition) %>% 
  summarise(Total.Spending = sum(Individual.Spending), 
            Total.Discharges = sum(Total.Discharges),
            Average.Medicare.Payments = mean(Average.Medicare.Payments),
            Total.Medicare.Payments = sum(Average.Medicare.Payments)
            ) %>% 
  mutate(year = "2014") %>%
  arrange(desc(Total.Spending))


in_spending_top = rbind(in_2011_spending[1:10, ], in_2012_spending[1:10, ],
                        in_2013_spending[1:10, ], in_2014_spending[1:10, ])
in_spending_top_10 = unique(in_spending_top[,1])


#inpatient 2011-2014 total discharges per DRG
in_2011_discharges = in_2011 %>% group_by(DRG.Definition) %>%
  summarise(Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2011", Total.Discharges.Percent = Total.Discharges/sum(Total.Discharges)) %>%
  arrange(desc(Total.Discharges))

in_2012_discharges = in_2012 %>% group_by(DRG.Definition) %>%
  summarise(Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2012", Total.Discharges.Percent = Total.Discharges/sum(Total.Discharges)) %>%
  arrange(desc(Total.Discharges))

in_2013_discharges = in_2013 %>% group_by(DRG.Definition) %>%
  summarise(Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2013", Total.Discharges.Percent = Total.Discharges/sum(Total.Discharges)) %>%
  arrange(desc(Total.Discharges))

in_2014_discharges = in_2014 %>% group_by(DRG.Definition) %>%
  summarise(Total.Discharges = sum(Total.Discharges)) %>%
  mutate(year = "2014", Total.Discharges.Percent = Total.Discharges/sum(Total.Discharges)) %>%
  arrange(desc(Total.Discharges))

in_discharges_top = rbind(in_2011_discharges[1:10, ], in_2012_discharges[1:10, ],
                          in_2013_discharges[1:10, ], in_2014_discharges[1:10, ])

in_discharges_top_10 = unique(in_discharges_top[,1])

discharges_spending = rbind(in_discharges_top_10, in_spending_top_10)
discharges_spending_10 = unique(discharges_spending[,1])


#Charges/medicare payments
r_2011 = in_2011 %>% mutate(ratio = Average.Covered.Charges/Average.Medicare.Payments) %>%
  summarise(mm=mean(ratio)) #4.527335
r_2012 = in_2012 %>% mutate(ratio = Average.Covered.Charges/Average.Medicare.Payments) %>%
  summarise(mm=mean(ratio)) #4.71288
r_2013 = in_2013 %>% mutate(ratio = Average.Covered.Charges/Average.Medicare.Payments) %>%
  summarise(mm=mean(ratio)) #4.953122
r_2014 = in_2014 %>% mutate(ratio = Average.Covered.Charges/Average.Medicare.Payments) %>%
  summarise(mm=mean(ratio)) #5.009671


