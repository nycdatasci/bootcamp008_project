library(dplyr)
library(ggplot2)
library(shiny)
library(DT)
library(tidyr)
ql=read.csv("ql.csv",stringsAsFactors = F)
matches <- read.csv("match.csv")
hname <- read.csv("hero_names.csv")
itemname <- read.csv("item_ids.csv")
ql_grp = group_by(ql,hero_id)
q6=left_join(ql,matches,by="match_id")[,c(2,3,5:15,17,19)]
hname <- hname[c(1:106,108,109),]
sec_to_min <- function(x){
  m=x%/%60
  if(m<20){ return("< 20 min")}
  if(m<30){ return("20 ~ 30 min")}
  if(m<40){ return("30 ~ 40 min")}
  if(m<50){ return("40 ~ 50 min")}
  else{ return("> 50 min")}
}
q6=mutate(q6,GameTime=sapply(duration,sec_to_min))
