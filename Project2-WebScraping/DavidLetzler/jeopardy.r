#Full scraped data at https://github.com/dletzler/dletzler.github.io

#Import/prepare score data
setwd("c:/Users/David/Documents/NYCDSA/Project 2/score")
jeop_score<-read.csv("Jeopardy_score.csv", stringsAsFactors = F)
jeop_score<-jeop_score[, c("Episode", "Date", "Contestant", "Comment", "ScoreFirst", "ScoreSecond", "FinalCat", "FinalQ", "FinalA", "FinalCorrect", "Final")]
jeop_score$ScoreFirst<-as.numeric(jeop_score$ScoreFirst)
jeop_score$ScoreSecond<-as.numeric(jeop_score$ScoreSecond)
jeop_score$Final<-as.numeric(jeop_score$Final)
jeop_score$Date<-gsub(".*day, ", "", jeop_score$Date)
jeop_score$Date<-as.Date(jeop_score$Date, "%B %d, %Y")

library(dplyr)
jeop_score_plus<- jeop_score %>% mutate(Wager = abs(Final - ScoreSecond), SecondOnly = ScoreSecond - ScoreFirst)

#What percentage of Jeopardy/Double Jeopardy Leaders win the game?  How much does each Round add, on average, to the winner's win probability?

winners<-jeop_score_plus %>% group_by(Episode) %>% filter(Final==max(Final)) %>% select(Episode, Date, Contestant, Final)
dj.leader<-jeop_score_plus %>% group_by(Episode) %>% filter(ScoreSecond==max(ScoreSecond)) %>% select(Episode, Contestant, ScoreSecond)
j.leader<-jeop_score_plus %>% group_by(Episode) %>% filter(ScoreFirst==max(ScoreFirst)) %>% select(Episode, Contestant, ScoreFirst)

losers<-jeop_score_plus %>% group_by(Episode) %>% filter(Final==min(Final)) %>% select(Episode, Date, Contestant, Final)
dj.loser<-jeop_score_plus %>% group_by(Episode) %>% filter(ScoreSecond==min(ScoreSecond)) %>% select(Episode, Contestant, ScoreSecond)
j.loser<-jeop_score_plus %>% group_by(Episode) %>% filter(ScoreFirst==min(ScoreFirst)) %>% select(Episode, Contestant, ScoreFirst)

win.dj<-full_join(dj.leader, winners, by= "Episode")
win.j<-full_join(j.leader, winners, by= "Episode")
same.dj.win<-win.dj %>% filter(Contestant.x==Contestant.y)
same.j.win<-win.j %>% filter(Contestant.x==Contestant.y)

lose.dj<-full_join(dj.loser, winners, by="Episode")
lose.j<-full_join(j.loser, winners, by="Episode")
diff.dj.win<-lose.dj %>% filter(Contestant.x==Contestant.y)
diff.j.win<-lose.j %>% filter(Contestant.x==Contestant.y)

comp.games<-length(unique(winners$Episode))
second.prob<-c(nrow(same.dj.win)/comp.games, (comp.games - nrow(same.dj.win) - nrow(diff.dj.win))/comp.games, nrow(diff.dj.win)/comp.games)
first.prob<-c(nrow(same.j.win)/comp.games, (comp.games - nrow(same.j.win) - nrow(diff.j.win))/comp.games, nrow(diff.j.win)/comp.games)

library(ggplot2)
library(ggthemes)
win.prob<-c(first.prob, second.prob)
round<-c("Jeopardy!", "Jeopardy!", "Jeopardy!", "Double Jeopardy!","Double Jeopardy!","Double Jeopardy!")
place<-c("1st", "2nd", "3rd", "1st", "2nd", "3rd")
prob.graph<-data.frame(round, place, win.prob)
colnames (prob.graph)= c("Round", "Place", "Win.Probability")
prob.graph$Round<-factor(prob.graph$Round, levels=c("Jeopardy!", "Double Jeopardy!"))
j<-ggplot(data=prob.graph, aes(x=Place, y=Win.Probability))
j + geom_bar(stat="identity", aes(fill=Place)) + facet_grid(.~ Round) + labs(title="Probability of Winning Based on Position After Each Round", y="Win Probability") +  geom_label(label=paste0(signif(prob.graph$Win.Probability * 100, 3), "%")) + theme_economist() + guides(fill=F) + theme(plot.title = element_text(hjust = 0.5)) + scale_fill_manual(values=c("darkblue", "steelblue1", "blue"))

prob.added<-data.frame(c("Jeopardy!", "Double Jeopardy!", "Final Jeopardy!"), c(nrow(same.j.win)/comp.games- 1/3, nrow(same.dj.win)/comp.games - nrow(same.j.win)/comp.games, 1 - nrow(same.dj.win)/comp.games))
colnames (prob.added)= c("Round", "Win.Probability.Added")
prob.added$Round<-factor(prob.added$Round, levels=c("Jeopardy!", "Double Jeopardy!", "Final Jeopardy!"))
wpa<-ggplot(data=prob.added, aes(x=Round, y=Win.Probability.Added))
wpa + geom_bar(stat="identity", aes(fill=Round)) + labs(title="Average Winner's WPA (Win Probability Added) by Round", y = "Win Probability Added") + geom_label(label=paste0(signif(prob.added$Win.Probability.Added * 100, 3), "%")) + theme_economist() + guides(fill=F) + theme(plot.title = element_text(hjust = 0.5)) + scale_fill_manual(values=c("darkblue", "steelblue1", "blue"))

#How well does performance in each round predict performance in following rounds?
jeop_plus<-jeop_score_plus[complete.cases(jeop_score_plus),]
jeop_plus$FinalCorrect<-factor(jeop_plus$FinalCorrect, levels = c("Yes", "No"))
r<-cor.test(jeop_plus$ScoreFirst, jeop_plus$SecondOnly) #r=.39, p < 2x10e-16
jeop_model<-lm(jeop_plus$SecondOnly ~ jeop_plus$ScoreFirst)
skill<-ggplot(data=jeop_plus, aes(x=ScoreFirst, y=SecondOnly))
skill + geom_point(aes(color=jeop_plus$FinalCorrect)) + scale_color_manual(values = c("darkgreen", "red")) + geom_smooth(method="lm", color="black") + labs(title= "Comparing Jeopardy! Round Performances", x="Jeopardy! Score ($)", y="Double Jeopardy! Score ($)", color="Correct Final Jeopardy! Answer") +  theme_economist() + theme(legend.position = "right", plot.title = element_text(hjust = 0.5)) + geom_text(x=-1000, y=35000, label=paste0("y = ", round(jeop_model$coefficients[1]), " + ", signif(jeop_model$coefficients[2], 3), "x, r = ", signif(r[[4]][[1]],2), ", p < 2.2e-16"))

library(VIM)
jeop_final<-jeop_plus[jeop_plus$ScoreSecond>0,]
final.right<-jeop_final %>% group_by(FinalCorrect) %>% summarize(Percent=n()/nrow(jeop_final)) #50.7% wrong, 49.2% right
final.right$FinalCorrect<-factor(final.right$FinalCorrect, levels=c("Yes", "No"))

set.seed(5)
train<-sample(1:nrow(jeop_final), .3*nrow(jeop_final))
jeop_test<-jeop_final
jeop_test[train, "FinalCorrect"]<-NA
imputed<-kNN(jeop_test, variable="FinalCorrect", dist_var = "ScoreSecond", 126)  
final.predict<-table(imputed$FinalCorrect[train], jeop_final$FinalCorrect[train])#Correct only 50.4% of the time!
final.knn<-data.frame(c("Correct", "Incorrect"), c((final.predict[1,1]+final.predict[2,2])/length(train), (final.predict[1,2]+final.predict[2,1])/length(train)))
colnames(final.knn)<-c("kNN.Result", "Percentage")

fj1<-ggplot(data=final.right, aes(x = factor(1), y=Percent, fill=FinalCorrect))
fj1 + geom_bar(stat="identity", position="fill", alpha=0.7) + scale_fill_manual(values = c("darkgreen", "red")) + coord_polar(theta="y") + labs(title="Final Jeopardy! Accuracy Rate", x="", y="Percentage Correct", fill="Correct?") + geom_label(label=paste(signif(final.right$Percent, 3)*100, "%"), fill=c("forestgreen", "red"), position="jitter") + theme_economist() + theme(legend.position = "right", plot.title = element_text(hjust = 0.5))

fj2<-ggplot(data = final.knn, aes(x=factor(1), y=Percentage, fill=kNN.Result))
fj2 + geom_bar(stat="identity", position="fill", alpha=0.7) + scale_fill_manual(values = c("darkgreen", "red")) + coord_polar(theta="y") + labs(title="Predicting Final J! Accuracy from Score", x="", y="Percentage Correct", fill="kNN, k=15 & 126") + geom_label(label=paste(signif(final.knn$Percentage, 3)*100, "%"), fill=c("forestgreen", "red"), position="jitter") + theme_economist() + theme(legend.position = "right", plot.title = element_text(hjust = 0.5))


#The Questions
#Import and pre-process
setwd("c:/Users/David/Documents/NYCDSA/Project 2/jeopardy_1")
jeop_qs<-read.csv("Jeopardy.csv", stringsAsFactors=F, na.strings="NA")
jeop_qs<-jeop_qs[, c("Episode", "Date", "Round", "Order", "Category", "Value", "Clue", "Answer", "Right", "Wrong1", "Wrong2", "Wrong3", "Wrong4", "DailyDouble")]
jeop_qs$Value<-as.numeric(jeop_qs$Value)
jeop_qs$DailyDouble<-as.numeric(jeop_qs$DailyDouble)
jeop_qs$Date<-gsub(".*day, ", "", jeop_qs$Date)
jeop_qs$Date<-as.Date(jeop_qs$Date, "%B %d, %Y")

jeop_qs$Right[jeop_qs$Wrong1=="Triple Stumper"]<-"Triple Stumper"
jeop_qs$Right[jeop_qs$Wrong2=="Triple Stumper"]<-"Triple Stumper"
jeop_qs$Right[jeop_qs$Wrong3=="Triple Stumper"]<-"Triple Stumper"
jeop_qs$Right[jeop_qs$Wrong4=="Triple Stumper"]<-"Triple Stumper"

jeop_qs$Wrong1[jeop_qs$Wrong1=="Triple Stumper"]<-NA
jeop_qs$Wrong2[jeop_qs$Wrong2=="Triple Stumper"]<-NA
jeop_qs$Wrong3[jeop_qs$Wrong3=="Triple Stumper"]<-NA
jeop_qs$Wrong4[jeop_qs$Wrong4=="Triple Stumper"]<-NA
jeop_qs<-jeop_qs[,-13]
jeop_qs<-jeop_qs[order(jeop_qs$Date),]


#Expected Value Function
expected.value<-function(x){
  if (x[9] == "Triple Stumper"){
    a = 0
  }
  else{
    a = as.numeric(x[6])
  }
  
  if (is.na(x[10])){
    b = 0
  }
  
  else{
    b = as.numeric(-x[6])
  }
  
  if (is.na(x[11])){
    c = 0
  }
  
  else{
    c = as.numeric(-x[6])
  }
  
  if (is.na(x[12])){
    d = 0
  }
  
  else{
    d = as.numeric(-x[6])
  }
  
  values<-as.numeric(c(a,b,c,d))
  buzz<-as.numeric(values[values!=0])
  
  if (length(buzz)>0){
    
    ev <- sum(values)/length(buzz)
    
    return (ev)
  }
  else{
    return (0)
  }
}

# What is the relationship of clue difficulty to monetary value?

jeop_asked<-filter(jeop_qs, Clue!="Not asked")

total.round.qs<-jeop_qs %>% group_by(Round) %>% summarize(Total = n())
stumper<-jeop_qs %>% group_by(Round) %>% filter(Right=="Triple Stumper") %>% summarize(Total=n())

Expected.Value<-rep(0, nrow(jeop_asked))
for (i in 1:nrow(jeop_asked)){
  Expected.Value[i]<-expected.value(jeop_asked[i,])
}

jeop_asked$Expected.Value<-Expected.Value

era1<-filter(jeop_asked, Date < as.Date("November 26, 2001", "%B %d, %Y"))
era2<-filter(jeop_asked, Date >= as.Date("November 26, 2001", "%B %d, %Y"))


value.exp<-jeop_asked %>% group_by(Value, Round) %>% summarize(Avg.Exp.Value=mean(Expected.Value))
value.exp1<-era1 %>% group_by(Value, Round) %>% summarize(Avg.Exp.Value=mean(Expected.Value))
value.exp1<-value.exp1[c(6,11,15,17,19,10, 16, 20, 22, 24), ]
value.exp2<-era2 %>% group_by(Value, Round) %>% summarize(Avg.Exp.Value=mean(Expected.Value))
value.exp2$Round<-factor(value.exp2$Round, levels=c("Jeopardy! Round", "Double Jeopardy! Round"))
value.exp2 %>% mutate(Ratio = Avg.Exp.Value/Value)
value.exp2$Value<-as.factor(value.exp2$Value)

exp<-ggplot(data=value.exp2, aes(x=Value, y=Avg.Exp.Value))
exp + geom_bar(stat="identity", aes(fill=Round), position="dodge") + theme_economist() + labs(title="Expected Value of Each Question Level (2001-Present)", x= "Value ($)", y= "Expected Value ($)") + geom_text(label=paste0("$", round(value.exp2$Avg.Exp.Value)), check_overlap=T) + theme(legend.position = "right", plot.title = element_text(hjust = 0.5))


#How many questions go unasked?

unasked<-jeop_qs %>% group_by(Date) %>% filter(Clue=="Not asked") %>% summarize(Unasked = n()/60)
unasked.values<-jeop_qs %>% filter(Date >= as.Date("November 26, 2001", "%B %d, %Y")) %>% group_by(Round, Value) %>% filter(Clue=="Not asked") %>% summarize(Unasked.Value=n())
values.total<-jeop_qs %>% filter(Date >= as.Date("November 26, 2001", "%B %d, %Y")) %>% group_by(Round, Value) %>% summarize(Total.Freq=n())
values.unasked<-full_join(values.total, unasked.values, by=c("Value", "Round"))
values.unasked$Unasked.Value[is.na(values.unasked$Unasked.Value)]<-0
values.unasked<-values.unasked %>% mutate(Percent.Unasked=Unasked.Value/Total.Freq)
values.unasked.filter<-values.unasked[values.unasked$Total.Freq>100,] #High-Value Clues go most unasked!
values.unasked.filter$Round<-factor(values.unasked.filter$Round, levels=c("Jeopardy! Round", "Double Jeopardy! Round"))
values.unasked.filter$Value<-as.factor(values.unasked.filter$Value)

un<-ggplot(data=values.unasked.filter, aes(x=Value, y=Percent.Unasked))
un + geom_bar(stat="identity", aes(fill=Round), position="dodge") + theme_economist() + labs(title="Fraction of Each Question Level Unasked (2001-Present)", x= "Value ($)", y= "Frequency Unasked") + theme(legend.position = "right", plot.title = element_text(hjust = 0.5))


#Daily Doubles
daily.freq<-jeop_qs %>% filter(Date >= as.Date("November 26, 2001", "%B %d, %Y")) %>% filter(!is.na(DailyDouble)) %>% group_by(Round, Value) %>% summarize(Total.DD=n())
daily.total<-full_join(values.total, daily.freq, by=c("Value", "Round"))
daily.total$Total.DD[is.na(daily.total$Total.DD)]<-0
daily.total<-daily.total %>% mutate(Daily.Percent=Total.DD/Total.Freq)

daily.right<-jeop_qs %>% filter(Date >= as.Date("November 26, 2001", "%B %d, %Y")) %>% filter(!is.na(DailyDouble)) %>% filter(is.na(Wrong1)) %>% summarize(DD.right=n())
daily.right[1,1]/sum(daily.freq$Total.DD) #64.8% right over time

daily.value.right<- jeop_qs %>% filter(Date >= as.Date("November 26, 2001", "%B %d, %Y")) %>% filter(!is.na(DailyDouble)) %>% group_by(Round, Value) %>% filter(is.na(Wrong1)) %>% summarize(DD.Right=n())
daily.values<-full_join(daily.freq, daily.value.right, by=c("Round", "Value"))
daily.value.percent<-daily.values %>% mutate(Percent.Right=DD.Right/Total.DD)
daily.percent.filter<-daily.value.percent[daily.value.percent$Total.DD>100,]

ratio<-jeop_qs %>% filter(Date >= as.Date("November 26, 2001", "%B %d, %Y") )%>% filter(!is.na(DailyDouble)) %>% group_by(Round, Value) %>% mutate(Wager.Ratio = DailyDouble/Value) %>% summarize(Ratio=median(Wager.Ratio))
daily.percent.ratio<-inner_join(daily.percent.filter, ratio, by=c("Round", "Value"))

dd.expected<-daily.percent.ratio %>% mutate(Expected.Value = (Ratio * Value *Percent.Right) - (Ratio * Value * (1-Percent.Right)))
dd.expected$Value<-as.factor(dd.expected$Value)
dd.expected$Round<-factor(dd.expected$Round, levels=c("Jeopardy! Round", "Double Jeopardy! Round"))

dd<-ggplot(data=dd.expected, aes(x= Value, y=Expected.Value), na.rm=T)
dd + geom_bar(stat="identity", aes(fill=Round), position="dodge") + theme_economist() + labs(title="Expected Daily Double! Value (2001-Present)", x= "Value ($)", y= "Expected Value ($)") + geom_text(label=paste0("$", round(dd.expected$Expected.Value)), check_overlap=T) + theme(legend.position = "right", plot.title = element_text(hjust = 0.5))


# What are the most common categories & answers?
answers<-jeop_qs %>% group_by(Answer) %>% summarize(Total = n())
answers<-answers[order(answers$Total, decreasing=T), ] # Top 32 are places!
answers<-filter(answers, Answer!="Not asked" & Answer!="=")
write.csv(answers, file="Jeopardy_answers.csv")

answers1<-read.csv("Jeopardy_answers.csv", stringsAsFactors = F)
answer_group<-answers1 %>% group_by(Group) %>% summarize(Number=n(), Total=sum(Total))
answer_group<-answer_group[order(answer_group$Total, decreasing=T),]
answer_group<-answer_group[-1,]
answer_group.sub<-answer_group[1:10,]
answer_group.sub$Group<-factor(answer_group.sub$Group, levels=rev(answer_group.sub$Group))

ans<-ggplot(data=answer_group.sub, aes(x=Group, y=Total))
ans + geom_bar(stat="identity", aes(fill=Group)) + coord_flip() + labs(title="Most Common Types among Top 300 'Jeopardy!' Answers", x="Type", y="Frequency") + geom_label(label=answer_group.sub$Number) + guides(fill=F) + theme_economist()


categories<-jeop_qs %>% group_by(Category) %>% summarize(Total = ceiling(n()/6))
categories<-categories[order(categories$Total, decreasing=T), ]
write.csv(categories, file="Jeopardy_categories.csv")

categories1<-read.csv("Jeopardy_categories.csv", stringsAsFactors = F)
category_group<-categories1 %>% group_by(Field) %>% summarize(Number=n(), Total=sum(Total))
category_group<-category_group[order(category_group$Total, decreasing=T),]
category_group<-category_group[-1,]
category_group$Field<-factor(category_group$Field, levels=c("Education", "Sports", "News", "Product", "Animals", "Food", "Popular Culture", "Religion", "Grab Bag", "Science", "Literature", "Arts", "History", "Word", "Geography"))

cat<-ggplot(data=category_group, aes(x=Field, y=Total))
cat + geom_bar(stat="identity", aes(fill=Field)) + coord_flip() + labs(title="Meta-Categories of 100 Most Frequent 'Jeopardy!' Categories", x="Meta-Category", y="Frequency") + geom_label(label=category_group$Number) + guides(fill=F) + theme_economist()

#debug
jeop_score %>% group_by(Date) %>% summarize(Number = n()) %>% filter(Number!=3)
error1<-jeop_qs$Episode[!(jeop_qs$Episode %in% jeop_score$Episode)]
error1<-unique(error1)
debug<-jeop_qs %>% group_by(Date) %>% summarize(TotalQ = n())
error2<-filter(debug, TotalQ!=60)


#Unused material

#What are the most common final answers?

answers<-jeop_score %>% group_by(FinalA) %>% summarize(Total = ceiling(n()/3))
categories<-jeop_score %>% group_by(FinalCat) %>% summarize(Total = ceiling(n()/3))
answers<-answers[order(answers$Total, decreasing=T),]
categories<-categories[order(categories$Total, decreasing=T),]


#Who are the biggest winners in show history?

winnings<-winners %>% group_by(Contestant) %>% summarize(Total = sum(Final), Start = min(Date))
winnings<-winnings[order(winnings$Total, decreasing=T), ]
plot(winnings$Start, winnings$Total)

#Fun with outliers

filter(winners, Final==min(Final))
#2 (trick question--20th c), #3190 (two tied, one out, DAR), #7216 (two tied, Little Rock) had no winner--plus three Celebrity games where everyone tied(Teri Garr, Naomi Judd, Jane Curtin; Matthew Fox, Jon Lovitz, Carl Lewis; Kelton Ellis, Joe Vertnik, Tori Amos)
real.winners <- winners[winners$Final>0, ] 
filter(real.winners, Final==min(Final))
#$1 winner Darryl Scott--everyone whiffed on Mandela; Ben Salisbury and Brandi Chastain in Celebs

all.dates<-data.frame(unique(jeop_score$Date))
colnames(all.dates)<-"Date"
unasked.whole<-full_join(all.dates, unasked, by="Date") 
unasked.whole$Unasked[is.na(unasked.whole$Unasked)]<-0
unasked.filter<-filter(unasked.whole, Unasked<=0.2)
cor.test(unasked.filter$Unasked, as.numeric(unasked.filter$Date)) # r=-0.15
unasked.model<-lm(unasked.filter$Unasked ~ unasked.filter$Date) # slope*365=-0.000709

