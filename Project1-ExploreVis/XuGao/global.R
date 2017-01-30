ql=read.csv("/Users/gaoxu/Desktop/DataSProject/Project 1/ql.csv",stringsAsFactors = F)
matches <- read.csv("/Users/gaoxu/Desktop/DataSProject/Project 1/match.csv")
hname <- read.csv("/Users/gaoxu/Desktop/DataSProject/Project 1/hero_names.csv")
itemname <- read.csv("/Users/gaoxu/Desktop/DataSProject/Project 1/item_ids.csv")
ql_grp = group_by(ql,hero_id)
q6=left_join(ql,matches,by="match_id")[,c(2,3,5:15,17,19)]
sec_to_min <- function(x){
  m=x%/%60
  if(m<20){ return("< 20 min")}
  if(m<30){ return("20 ~ 30 min")}
  if(m<40){ return("30 ~ 40 min")}
  if(m<50){ return("40 ~ 50 min")}
  else{ return("> 50 min")}
}
q6=mutate(q6,GameTime=sapply(duration,sec_to_min))
