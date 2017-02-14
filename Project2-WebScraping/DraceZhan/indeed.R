
library(tidyr)
library(dplyr)
library(readr)
library(gdata)

indeed <- read_csv("C:/Users/Drace/indeed/indeed.csv", stringsAsFactors=FALSE)
indeedRev <-read.csv('~/WebScrapeProj/IndeedCsvs/indeedRev.csv', stringsAsFactors=FALSE)
ratingCol = c('worklife', 'compensation', 'jobsecurity', 'management', 'culture', 'companyScore')
salaryCol = c('position', 'salary', 'company')
reviewCol = c('reviewJob', 'review', 'pro', 'con', 'companyReview')

RatingsIndeed = indeed[ratingCol]
RatingsIndeedComp = RatingsIndeed[complete.cases(RatingsIndeed),]
colnames(RatingsIndeedComp)[6] = 'company'
SalaryIndeed = indeed[salaryCol]
SalaryIndeedComp = SalaryIndeed[complete.cases(SalaryIndeed),]
ReviewIndeed = indeedRev[reviewCol]
ReviewIndeedComp = ReviewIndeed[complete.cases(ReviewIndeed),]
colnames(ReviewIndeedComp)[5] = 'company'
colnames(ReviewIndeedComp)[1] = 'position'

RatingsIndeedComp$worklife = substring(RatingsIndeedComp$worklife, 31,33)
RatingsIndeedComp$compensation = substring(RatingsIndeedComp$compensation, 31,33)
RatingsIndeedComp$jobsecurity = substring(RatingsIndeedComp$jobsecurity, 31,33)
RatingsIndeedComp$management = substring(RatingsIndeedComp$management, 31,33)
RatingsIndeedComp$culture = substring(RatingsIndeedComp$culture, 31,33)


SalaryIndeedComp = SalaryIndeedComp[-1,]
SalaryIndeedComp$salary = substring(SalaryIndeedComp$salary, 2)
SalaryIndeedComp$position[172] = 'Operator,Chemical Operator,Mechanic,Process Operator,Machine Operator,Researcher,Senior Research Associate,Research Associate,Chemist,Research Scientist,Team Leader,Consultant,Site Manager,Quality Control Manager,Project Leader,Administrative Assistant,Safety Health and Environment Assistant,Operations Associate,Inventory Control Specialist,Technician,R&D Engineer,Process Engineer,Engineer'
SalaryIndeedComp$position[269] = "Maintenance Associate,Electrical Technician,Clinical Trial Administrator,Senior Research Associate,Analytical Chemist,Director,Senior Data Manager,Director of Operations,Clinical Research Scientist,Administrative Assistant,Safety Health and Environment Assistant,Feasibility Manager,Data Entry Clerk,Programmer,Senior Systems Administrator,Front End Developer"
#SalaryTopHalf = SalaryIndeedComp[1:469,]
SalaryNested = SalaryIndeedComp%>% unnest(
  position = strsplit(position, ','), salary = strsplit(salary, '\\$'))
#test = SalaryTopHalf%>% unnest(
#  position = strsplit(position, ','))
#test2 = SalaryTopHalf%>% unnest(
#  salary = strsplit(salary, '\\$'))
ReviewIndeedComp$position = substring(ReviewIndeedComp$position, 1, nchar(ReviewIndeedComp$position)-3)
ReviewIndeedComp$review =substring(ReviewIndeedComp$review, 1, nchar(ReviewIndeedComp$review)-3)
ReviewIndeedComp$pro = substring(ReviewIndeedComp$pro, 1, nchar(ReviewIndeedComp$pro)-3)
ReviewIndeedComp$con = substring(ReviewIndeedComp$con, 1, nchar(ReviewIndeedComp$con)-3)

SalaryRatings = merge(SalaryNested, RatingsIndeedComp, by='company', all = T)
SalaryRatings = SalaryRatings[!duplicated(SalaryRatings),]
SalaryRatings$salary = as.numeric(gsub('\\$|,', '', SalaryRatings$salary))
View(SalaryRatings)
write.csv(SalaryRatings, file = "c:\\Users\\Drace\\indeedSR.csv", row.names = FALSE)




TestNested = ReviewIndeedComp%>% unnest('position' = strsplit(position, 'XXX'))
TestNested1 = ReviewIndeedComp%>% unnest('review' = strsplit(review, 'XXX'))
TestNested2 = ReviewIndeedComp%>% unnest('pro' = strsplit(pro, 'XXX'))
TestNested3 = ReviewIndeedComp%>% unnest('con' = strsplit(con, 'XXX'))

reviews = TestNested1[,c(-1,-2,-3)]
cons = TestNested3[,c(-1, -2, -3)]
pros = TestNested2[,c(-1, -2, -3)]

write.csv(reviews, file = "c:\\Users\\Drace\\UnnestedReviews.csv", row.names = FALSE)
write.csv(pros, file = "c:\\Users\\Drace\\UnnestedPros.csv", row.names = FALSE)
write.csv(cons, file = "c:\\Users\\Drace\\UnnestedCons.csv", row.names = FALSE)

position = TestNested[,c(-1, -2, -3)]
proCons = transform(merge(pros, cons, by=0, all.x=T, Row.names=NULL))
proCons$Row.names = NULL
proCons = proCons[!duplicated(proCons),]
proConsPosit = transform(merge(position, proCons, by =0, all.x = T), Row.names=NULL)
ReviewNested = transform(merge(reviews, proConsPosit, by =0, all.x = T), Row.names=NULL)
  
View(ReviewNested)
write.csv(ReviewNested, file = "c:\\Users\\Drace\\Review.csv", row.names = FALSE)

messyJoin = cbind(SalaryRatings, ReviewNested)
View(messyJoin)

write.csv(messyJoin, file = "c:\\Users\\Drace\\IndeedMessy.csv", row.names = FALSE)

ReviewIndeedComp = ReviewIndeedComp %>% unnest('position' = position)
