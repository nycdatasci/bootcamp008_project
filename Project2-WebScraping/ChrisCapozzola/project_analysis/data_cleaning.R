library(dplyr)
library(readr)
library(VIM)
library(tidyr)
library(VIM)
library(PASWR)
library(mice)
library(Hmisc)
library(ggplot2)
library(corrplot)
library(car)
library(MASS)

### Read in Data
ufc.fighter.df = read.csv("/Users/arianiherrera/Desktop/NYCDataScience/Scrapy_Project/project_analysis/data/ufc_fighter_data.csv", na.strings=c("","NA"))
col.names = colnames(ufc.fighter.df)


### Clean Data
# clean fight record splitting into wins losses and draws as numerics
ufc.fighter.df$fight_record = gsub("\\,.*","",ufc.fighter.df$fight_record) # remove no contest
ufc.fighter.df <- within(ufc.fighter.df, fight_record[fight_record=="None"] <- "0-0-0") # entries with None change to 0-0-0
ufc.fighter.df = separate(data = ufc.fighter.df, col = fight_record, into = c("wins", "loses", "draws"), sep = "\\-")
ufc.fighter.df$wins = as.numeric(ufc.fighter.df$wins)
ufc.fighter.df$loses = as.numeric(ufc.fighter.df$loses)
ufc.fighter.df$draws = as.numeric(ufc.fighter.df$draws)
ufc.fighter.df = mutate(ufc.fighter.df, total.fights = wins + loses + draws)
ufc.fighter.df = mutate(ufc.fighter.df, win.pct = ifelse(total.fights == 0, 0, wins/total.fights))

# clean height strings to include total inches measurement only and as numeric field
ufc.fighter.df$height = gsub('\\".*',"",ufc.fighter.df$height) # get ft and inches
ufc.fighter.df = separate(data = ufc.fighter.df, col = height, into = c("ft", "inches")) # break out columns
ufc.fighter.df = mutate(ufc.fighter.df, height.inches = 12*as.numeric(ft) + as.numeric(inches)) # mutate to total inches
drops = c("ft", "inches", "height")
ufc.fighter.df = ufc.fighter.df[ , !(names(ufc.fighter.df) %in% drops)]

# clean weights to include pounds as numeric
ufc.fighter.df$weight = gsub('\\ .*',"",ufc.fighter.df$weight)
ufc.fighter.df$weight = as.numeric(ufc.fighter.df$weight)

# clean ground strikes landed to numeric
ufc.fighter.df$ground_strikes_landed = as.numeric(ufc.fighter.df$ground_strikes_landed)

# clean reach
ufc.fighter.df$reach = gsub('\\".*',"",ufc.fighter.df$reach)
ufc.fighter.df$reach = as.numeric(ufc.fighter.df$reach)

# clean leg reach
ufc.fighter.df$leg_reach = gsub('\\".*',"",ufc.fighter.df$leg_reach)
ufc.fighter.df$leg_reach = as.numeric(ufc.fighter.df$leg_reach)

# clean  strikes avoided
ufc.fighter.df <- within(ufc.fighter.df, strikes_avoided_pct[strikes_avoided_pct=="N/A\t\t\t\t\t"] <- "NA")
ufc.fighter.df$strikes_avoided_pct = as.numeric(ufc.fighter.df$strikes_avoided_pct)

# clean age
ufc.fighter.df$age = gsub("None", NA, ufc.fighter.df$age)
ufc.fighter.df$age = as.numeric(ufc.fighter.df$age)

# clean takedowns defended pct
ufc.fighter.df <- within(ufc.fighter.df, takedowns_defended_pct[takedowns_defended_pct=="N/A\t\t"] <- "NA")
ufc.fighter.df$takedowns_defended_pct = as.numeric(ufc.fighter.df$takedowns_defended_pct)

# clean standing strikes

ufc.fighter.df$standing_strikes_landed = gsub("None", NA, ufc.fighter.df$standing_strikes_landed)
ufc.fighter.df$standing_strikes_landed = as.numeric(ufc.fighter.df$standing_strikes_landed)

# clean other strikes
ufc.fighter.df$other_strikes_landed = gsub("None", NA, ufc.fighter.df$other_strikes_landed)
ufc.fighter.df$other_strikes_landed = as.numeric(ufc.fighter.df$other_strikes_landed)



### Fix Missing Data
data.aggr = aggr(ufc.fighter.df)
num.cell.missing = sum(sapply(ufc.fighter.df, countNA))
pct.cells.missing = num.cell.missing/(nrow(ufc.fighter.df)*ncol(ufc.fighter.df))

# feature histograms
h.age <- ggplot(data = ufc.fighter.df, aes(x = ufc.fighter.df$age)) + geom_histogram(stat = "count")
h <- ggplot(data = ufc.fighter.df, aes(x = ufc.fighter.df$age)) + geom_histogram(stat = "count")
h.weight <- hist(ufc.fighter.df$weight)

## impute missing data
ufc.fighter.mis <- ufc.fighter.df
ufc.fighter.mis$ground_strikes_landed <- with(ufc.fighter.mis, impute(ground_strikes_landed, 'random'))
ufc.fighter.mis$strikes_avoided_pct <- with(ufc.fighter.mis, impute(strikes_avoided_pct, mean))
ufc.fighter.mis$attempted_strikes <- with(ufc.fighter.mis, impute(attempted_strikes, median))
ufc.fighter.mis$weight <- with(ufc.fighter.mis, impute(weight, median))
ufc.fighter.mis$passes <- with(ufc.fighter.mis, impute(passes, 'random'))
ufc.fighter.mis$age <- with(ufc.fighter.mis, impute(age, mean))
ufc.fighter.mis$reach <- with(ufc.fighter.mis, impute(reach, 'random'))
ufc.fighter.mis$leg_reach <- with(ufc.fighter.mis, impute(leg_reach, 'random'))
ufc.fighter.mis$submissions <- with(ufc.fighter.mis, impute(submissions, median))
ufc.fighter.mis$takedowns_defended_pct <- with(ufc.fighter.mis, impute(takedowns_defended_pct, mean))
ufc.fighter.mis$successful_takedowns <- with(ufc.fighter.mis, impute(successful_takedowns, median))
ufc.fighter.mis$attempted_takedowns <- with(ufc.fighter.mis, impute(attempted_takedowns, median))
ufc.fighter.mis$sweeps <- with(ufc.fighter.mis, impute(sweeps, median))
ufc.fighter.mis$standing_strikes_landed <- with(ufc.fighter.mis, impute(standing_strikes_landed, 'random'))
ufc.fighter.mis$other_strikes_landed <- with(ufc.fighter.mis, impute(other_strikes_landed, 'random'))
ufc.fighter.mis$height.inches <- with(ufc.fighter.mis, impute(height.inches, 'random'))

## EDA

# summary(ufc.fighter.mis)
# sapply(ufc.fighter.mis, sd)
ufc.cor = cor(ufc.fighter.mis[ , !(names(ufc.fighter.mis) %in% c("hometown", "fighter_name", "fight_out_of"))])
numeric.col = ufc.fighter.mis[ , names(ufc.fighter.mis) %in% c("age", "attempted_strikes", "ground_strikes_landed", "successful_takedowns", "takedowns_defended_pct")]
# corrplot(ufc.cor)

ufc.wins.model.empty = lm(win.pct ~ 1, data = ufc.fighter.mis)
ufc.wins.model.full = lm(win.pct ~ . - hometown - fighter_name - fight_out_of - total.fights - wins - loses - draws, data = ufc.fighter.mis)

# influencePlot(ufc.wins.model.full)
# avPlots(ufc.wins.model.full)

ufc.scope = list(lower = formula(ufc.wins.model.empty), upper = formula(ufc.wins.model.full))

ufc.forwardBIC = step(ufc.wins.model.empty, ufc.scope, direction = "forward", k = log(nrow(ufc.fighter.mis)))
ufc.backwardBIC = step(ufc.wins.model.full, ufc.scope, direction = "backward", k = log(nrow(ufc.fighter.mis)))
ufc.bothBIC.empty = step(ufc.wins.model.empty, ufc.scope, direction = "both", k = log(nrow(ufc.fighter.mis)))
ufc.bothBIC.full = step(ufc.wins.model.full, ufc.scope, direction = "both", k = log(nrow(ufc.fighter.mis)))

# summary(ufc.forwardBIC)
# plot(ufc.forwardBIC)
# influencePlot(ufc.forwardBIC)
# vif(ufc.forwardBIC)
# avPlots(ufc.forwardBIC)
# confint(ufc.forwardBIC)






