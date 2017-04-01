#global.R
library(dplyr)
library(tidyr)
library(ggplot2)

americanAmber = read.csv('data/americanAmber_redAle.csv')
americanAmber$Style = rep('American Amber', nrow(americanAmber))
americanBlackAle = read.csv('data/americanBlackAle.csv')
americanBlackAle$Style = rep('American Black Ale', nrow(americanBlackAle))
americanBlondeAle = read.csv('data/americanBlondeAle.csv')
americanBlondeAle$Style = rep('American Blonde Ale', nrow(americanBlondeAle))
americanBrownAle = read.csv('data/americanBrownAle.csv')
americanBrownAle$Style = rep('American Brown Ale', nrow(americanBrownAle))
americanDoubleIPA = read.csv('data/americanDouble_imperialIPA.csv')
americanDoubleIPA$Style = rep('American Double/Imperial IPA', nrow(americanDoubleIPA))
americanImperialStout = read.csv('data/americanDouble_imperialStout.csv')
americanImperialStout$Style = rep('American Double/Imperial Stout', nrow(americanImperialStout))
americanIPA = read.csv('data/americanIPA.csv')
americanIPA$Style = rep('American IPA', nrow(americanIPA))
americanPale_wheatAle = read.csv('data/americanPale_wheatAle.csv')
americanPale_wheatAle$Style = rep('American Pale/Wheat Ale', nrow(americanPale_wheatAle))
americanPaleAle = read.csv('data/americanPaleAle.csv')
americanPaleAle$Style = rep('American Pale Ale', nrow(americanPaleAle))
americanPorter = read.csv('data/americanPorter.csv')
americanPorter$Style = rep('American Porter', nrow(americanPorter))
americanStout = read.csv('data/americanStout.csv')
americanStout$Style = rep('American Stout', nrow(americanStout))

beerStyle = rbind(americanAmber, americanBlackAle, americanBlondeAle,
                  americanBrownAle, americanDoubleIPA, americanImperialStout,
                  americanIPA, americanPale_wheatAle, americanPaleAle,
                  americanPorter, americanStout)

#data cleaning, removing empty spaces, NAs and converting to numeric
beerStyle[beerStyle == ''] <- NA
beerStyle = na.omit(beerStyle)
beerStyle$Ratings = as.numeric(sub(',', '', beerStyle$Ratings))
beerStyle$ABV = sub('\\?', NA, beerStyle$ABV)
beerStyle$ABV = as.numeric(beerStyle$ABV)
beerStyle$Avg = sub('-', NA, beerStyle$Avg)
beerStyle$Avg = as.numeric(beerStyle$Avg)


#test plot and stats
# na.omit(beerStyle) %>% group_by(Style) %>% summarise(sum = mean(ABV))
# 
# plot(beerStyle$ABV, beerStyle$Avg)
# abline(lm(beerStyle$Avg ~ beerStyle$ABV))
# 
# summary(lm(beerStyle$Avg ~ beerStyle$ABV))
# 
# ggplot(beerStyle_highRatings, aes(ABV, Avg, col = Style)) + geom_point() + 
#   geom_abline(intercept = 3.3, slope = 0.07) 
# 
# ggplot(beerStyle_highRatings, aes(x = Style, y = Avg)) + geom_boxplot() +
#   coord_flip() +
#   theme_minimal()
# 
# ggplot(beerStyle_highRatings, aes(x = Style, fill = NULL)) + geom_histogram(stat = 'count') +
#   coord_flip()
# 
# beerStyle_highRatings = beerStyle[beerStyle$Ratings > 1000,]
# 
# TukeyHSD(aov(beerStyle$Avg ~ beerStyle$Style))