library(tidyverse)
library(ggthemes)
setwd('/Users/ethanweber/Desktop/Untitled Folder/dffr')
beef = read_rds('beef.rds')
chicken = read_rds('chicken.rds')
lamb = read_rds('lamb.rds')
lasagna = read_rds('lasagna.rds')
mac = read_rds('macaroni.rds')
pasta = read_rds('pasta.rds')
pork = read_rds('pork.rds')
rice = read_rds('rice.rds')
spea = read_rds('splitpeasoup.rds')

all = rbind(beef, chicken, lamb, lasagna, mac, pasta, pork, rice, spea)
all = all[,-438]
all2 = filter(all, kind != 'splitpeasoup')
all2[all2$kind=='lasagna',]$kind = 'carb_based'
all2[all2$kind=='macaroni',]$kind = 'carb_based'
all2[all2$kind=='pasta',]$kind = 'carb_based'
all2[all2$kind=='rice',]$kind = 'carb_based'
all2[all2$kind == 'beef',]$kind = 'meat'
all2[all2$kind == 'lamb',]$kind = 'meat'
all2[all2$kind == 'pork',]$kind = 'meat'
c = group_by(filter(all, OrgBy == 'Category', stars == 5), kind) %>% summarise(n())
a = (group_by(filter(all, OrgBy == 'Category', stars == 5), kind) %>% summarise(n()))[2]
b = (group_by(filter(all, OrgBy == 'Category', kind == c('beef', 'chicken', 'pasta')), kind) %>% summarise(n()))[2]
cbind(c[1], 'percent' = 100*a/b)
names(all2)
ggplot(all2, aes(x = (rev_count)^(1/2))) + geom_density(binwidth = 1) + theme_economist() + xlab('Square Root of Review Count') + ggtitle('Review Counts')
median(all$rev_count)
ggplot(all2[-479,], aes(x = (pics)^(1/2))) + geom_density(binwidth = 1) + theme_economist() + xlab('Square Root of Pic Count') + ggtitle('Pic Count')
all2[479,]$pics
ggplot(all, aes(x = pics, y  = rev_count)) + geom_point() + theme_economist() + ggtitle("Large Outlier", subtitle = '4.8 stars. +10k reviews. +1,000 pictures.') + xlab('Picture Count: Median = 3') + ylab('Review Count: Median = 31')
?ggtitle

#group_by(filter(all, OrgBy == 'Category'), kind) %>%
ggplot(all2, aes(x = kind, y = stars)) + geom_violin() + theme_economist()

ggplot(all, aes (x = stars)) + geom_histogram() + theme_economist() + facet_wrap('stars')
ggplot(filter(all[-479,], rev_count > 60, stars > 3.75), aes(x = stars, y = rev_count)) + 
  geom_point()  + theme_economist() + scale_y_continuous(limits = c(60, 2000)) + 
  scale_x_continuous(limits = c(3.65, 5)) + ggtitle('Stars Not Closely Correlated with Review Count') + 
  ylab('Review Counts 60+') + xlab('Stars 3.65+')
ggplot(filter(all[-479,], stars >= 3.6, pics >= 5), aes(x = stars, y = pics)) + geom_smooth() + geom_point() + theme_economist() + scale_y_continuous(limits = c(3.6, 200))


??quartile

group_by(all2, kind) %>% summarise(n())


filter(all2, kind == 'meat')$stars %>% sd(na.rm = TRUE)
filter(all2, kind == 'chicken')$stars %>% sd(na.rm = TRUE)
filter(all2, kind == 'carb_based')$stars %>% sd(na.rm = TRUE)
length(filter(all2, kind == 'carb_based')$stars)


#all %>% group_by(kind) %>% 
ggplot(filter(all, OrgBy == 'Category'), aes( x = kind, y = stars, color = kind)) + geom_boxplot() + theme_economist()
ggplot(all2, aes(x = kind, y = stars)) + geom_violin() + theme_economist()

ggplot(filter(all, OrgBy == 'Category'), aes( x = kind, y = pics, color = kind)) + geom_violin() + theme_economist()
filter(all, OrgBy == 'Category') %>% group_by(kind) %>% 
  summarise('mean' = mean(pics), 'median' = median(pics), max(pics)) %>% 
  ggplot(aes(x = kind)) + geom_bar(aes(y = median), stat= 'identity') + theme_economist() + ggtitle('Picture Counts')

ggplot(all2, aes(x = kind)) + geom_bar()

beefstars = filter(all, kind == 'beef')$stars
chickenstars = filter(all, kind == 'chicken')$stars
lambstars = filter(all, kind == 'lamb')$stars
porkstars = filter(all, kind == 'pork')$stars
pastastars = filter(all, kind == 'pasta')$stars
ricestars = filter(all, kind == 'rice')$stars
chicken2 = filter(all2, kind == 'chicken')$stars
meat2 = filter(all2, kind == 'meat')$stars
carb2 = filter(all, kind == 'carb_based')$stars

bart = list(beefstars, chickenstars, lambstars, porkstars, pastastars, ricestars)

bart2 = list(beefstars, lambstars, porkstars, chickenstars)

bart3 = list(chicken2, meat2, carb2)
  
bartlett.test(bart)
fligner.test(bart)

bartlett.test(bart2)
fligner.test(bart2)

bartlett.test(bart3)
bartlett.test(bart3)

x = filter(all, (kind == c('beef', 'chicken', 'pork')))#  (kind == 'chicken'), (kind == 'pork'))# , kind == 'pork') 
x

#%>% 
ggplot(x, aes(x = kind, y = stars), color =  kind) + geom_boxplot() 
?scale_color_economist
ggplot(x, aes(x = kind, y = fat_cal_pct)) + geom_violin()

ggplot(all, aes(x = kind, y = fat_cal_pct)) + geom_violin()
ggplot(all, aes(x = kind, y = stars)) + geom_violin()
ggplot(all, aes(x = kind, y = carb_cal_pct)) + geom_violin()

ggplot(all, aes(x = stars, y = pics)) + geom_hex()# + geom_density()

ggplot(all, aes(x = noingreds, y = stars, color = kind)) + geom_jitter() + geom_smooth(color = 'blue')
all2 = mutate(all2, 'cholesterolpercal' = cholesterol_mg/cals)
all2$cholesterol_mg = as.numeric(all2$cholesterol_mg)
all2 = mutate(all2, 'cholesterolpercal' = cholesterol_mg/cals)

fit <- lm(stars ~ noingreds + fat_cal_pct+ rev_count + kind + pics, data=(all2))#, kind == 'carb_based'))
summary(fit)
ggplot(fit, aes(x = rev_count, y = stars)) + stat_smooth(method = "lm", col = "red") + geom_point()

chefj = c("Chef John's Ham and Potato Soup", "Chef John's Lasagna", "Chef John's Macaroni and Cheese", "Chef John's Sloppy Joes", "Chef John's Tandoori Chicken")




all2 = mutate(all2, 'Chef_John' = (name == chefj))
all2
all2[,-c("name == chefj")]
names(all2)

group_by(all, kind) %>% summarise(n())


c = group_by(filter(all2, stars == 5), kind) %>% summarise(n())
d = group_by(filter(all), kind) %>% summarise(median(stars))
d
TP = cbind( c[1], 100*c[2]/d[2])
names(TP) = c('Type', 'Percent')
ggplot(TP, aes(x = Type, y = Percent)) + geom_bar(stat = 'identity') + theme_economist() + ggtitle("Percent of 5's")
a = (group_by(filter(all, OrgBy == 'Category', stars == 5), kind) %>% summarise(n()))[2]
b = (group_by(filter(all, OrgBy == 'Category', kind == c('beef', 'chicken', 'pasta')), kind) %>% summarise(n()))[2]
cbind(c[1], 'percent' = 100*a/b)
