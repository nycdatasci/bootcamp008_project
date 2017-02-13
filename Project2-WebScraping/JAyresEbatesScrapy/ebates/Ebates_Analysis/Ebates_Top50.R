Ebates_Top50 <- read_csv("~/github_repos/bootcamp008_project/Project2-WebScraping/JAyresEbatesScrapy/JAyresP2Ebates/ebates_v3/Ebates_v3_Analysis/Ebates_Top50.csv")
Ebates_Vals <- read_csv("~/github_repos/bootcamp008_project/Project2-WebScraping/JAyresEbatesScrapy/JAyresP2Ebates/ebates_v3/Ebates_v3_Analysis/Ebates_Vals.csv")
Ebates_Mid <- read_csv("~/github_repos/bootcamp008_project/Project2-WebScraping/JAyresEbatesScrapy/JAyresP2Ebates/ebates_v3/Ebates_v3_Analysis/Ebates_Mid.csv")
View(Ebates_Mid)
View(Ebates_Vals)
View(Ebates_Top50)
summary(Ebates_Top50)
summary(ebates)

library(ggplot2)
library(RColorBrewer)

# Total Cash Back to Number of Coupons offered - Top 50
g <- ggplot(data = Ebates_Top50, aes(x = Total, y = No_Coupons)) + geom_point() + geom_smooth(method = "lm")
g
g + coord_trans(x = "log10", y = "log10") + xlab("Total Cash Back") + ylab("Coupon Offers") + theme_bw()

# Total Cash Back to Avg Cash Back - Top 50
g <- ggplot(data = Ebates_Top50, aes(x = Total, y = AvgCashBack)) + geom_point() 
g
g + coord_trans(x = "log10", y = "log10") 

# Total Cash Back to Total Retailer Purchases - Top 50
g <- ggplot(data = Ebates_Top50, aes(x = Total, y = TotalPurchAmt)) + geom_point() + geom_smooth(method = "lm")
g
g + coord_trans(x = "log10", y = "log10") + xlab("Total Cash Back") + ylab("Total Retailer Dollars") + theme_bw()


# Total Cash Back to Number of Coupons offered - All
g <- ggplot(data = Ebates_Vals, aes(x = Total, y = No_Coupons)) + geom_point(position = "jitter") + geom_smooth(method = "lm")
g
g + xlab("Total Cash Back") + ylab("Coupon Offers") + theme_bw()

# Total Cash Back to Total Retailer Purchases - All
g <- ggplot(data = Ebates_Vals, aes(x = Total, y = TotalPurchAmt)) + geom_point(position = "jitter") + geom_smooth(method = "lm")
g
g + xlab("Total Cash Back") + ylab("Total Retailer Dollars") + theme_bw()


# Total Cash Back to Number of Coupons offered - Middle
g <- ggplot(data = Ebates_Mid, aes(x = Total, y = No_Coupons)) + geom_point() + geom_smooth(method = "lm")
g
g + coord_trans(x = "log10", y = "log10") + xlab("Total Cash Back") + ylab("Coupon Offers") + theme_bw()

