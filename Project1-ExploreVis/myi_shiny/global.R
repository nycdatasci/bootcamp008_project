library(corrplot)
library(dplyr)
library(DT)
library(maps)
library(ggplot2)
library(shiny)
library(shinydashboard)
library('tidyr')

t=read.csv('./data/myLoanStats3a.csv', header=TRUE, skip=1)
g=c(3,7,10,14,15,17,18,25,26,27,34,35)
g[3:12]=g[3:12]-1
t=t[,g]

t$int_rate = as.numeric(gsub('%', '', t$int_rate))
t$revol_util = as.numeric(gsub('%', '', t$revol_util))
t$addr_state=as.character(t$addr_state)
t=t[!is.na(t$addr_state),]

t$loan_status = as.character(t$loan_status)

states <- map_data("state")

statenames <- unlist(sapply(t$addr_state, function(x) if(length(state.name[grep(x, state.abb)]) == 0) "District of Columbia" else state.name[grep(x, state.abb)]) )


y=data.frame(cbind(state.abb, state.name))
colnames(y)[1] = 'addr_state'
u=merge(t,y, by='addr_state')

statect <- data.frame(table(u$state.name))
colnames(statect)= c('region', 'numloans')
statect$region=tolower(statect$region)

result<-merge(statect, states, by=c("region"))
result <- result[order(result$order),]
result['logloans'] = log(result$numloans)

# US map with loan count
p <- ggplot(result, aes(x=long, y=lat, group=group, fill=logloans)) + 
  geom_polygon() + scale_fill_gradient(low = "yellow", high = "blue", trans="log") + 
  coord_equal(ratio=1.75)


u$issue_d <- substr(u$issue_d, 5, 8)
intbyyrst<-aggregate(u$int_rate,by=list(u$issue_d, u$state.name), 
                     function(x) median(x, na.rm=TRUE))

years <- c("2007", "2008", "2009", "2010", "2011")
colnames(intbyyrst) <- c("year", "region", "interest.rate")
intbyyrst$region=tolower(intbyyrst$region)
result3 <- merge(intbyyrst, states, by="region")

lower <- floor(summary(intbyyrst$interest.rate)[1])[[1]]
upper <- ceiling(summary(intbyyrst$interest.rate)[6])[[1]]

states2 <- data.frame(map("state", plot=FALSE)[c("x","y")])

result3 <- result3[order(result3$order),]
result3.year <- result3[grep(years, result3$year),]
usamap0 <- ggplot(data=states2, aes(x=x, y=y)) + geom_path()+ geom_polygon(data=result3.year, 
                                                                          aes(x=long, y=lat, group = group, fill=interest.rate))

usamap = (usamap0 + scale_fill_gradient(low="yellow", high="blue", limits=c(lower, upper)) + 
        coord_equal(ratio=2.00) + 
        # opts(title = paste('Median Interest Rates for all Issued Loans by State in', year)) +
        labs(fill="Interest Rate (%)") + xlab("") + ylab(""))

# breakout by state and year. map of dispersion of rates.
# slider for this.
oned=summarise(group_by(result3, region, year), 
               medianInt=median(interest.rate))

# group by grade of loan. map 
# loan status mapping

# correlation matrix
m=cor(u[,c(2,3,6,9,11)])
# margins bottom, left, top right
corrplot(m, method="ellipse", type = 'upper',mar=c(2,1,2,1))

#u[!(u$loan_status %in% c("Fully Paid","Current","In Grace Period")),]

u=mutate(u, goodloan = ifelse(
  u$loan_status %in% c("Fully Paid","Current","In Grace Period"),1,0))

# pctpct=summarise(group_by(u, addr_state), stavg = mean(goodloan), stsd=sd(goodloan))
# 
# pctgrade=summarise(group_by(u, grade), stavg = mean(goodloan), stsd=sd(goodloan))

pctstgr=summarise(group_by(u, addr_state, grade), stavg = mean(goodloan), stsd=sd(goodloan), ir = mean(int_rate), irsd = sd(int_rate))

pctstgr[, c('stavg', 'stsd', 'ir', 'irsd')] = round(pctstgr[, c('stavg', 'stsd', 'ir', 'irsd')], 3)


pctstgryr=summarise(group_by(u, addr_state, issue_d, grade), stavg = mean(goodloan), stsd=sd(goodloan), ir = mean(int_rate), irsd = sd(int_rate))
pctstgryr=drop_na(pctstgryr)


# for invalid graphics state error
dev.off()
