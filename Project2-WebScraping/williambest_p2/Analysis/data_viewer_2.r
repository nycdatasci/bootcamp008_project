library(RSQLite)
library(ggplot2)

get.data.from.sqlite <- function(db.name, table.name) {
  con <- dbConnect(SQLite(), dbname=db.name)
  db.query <- paste('select * from', table.name)
  table.data <- dbGetQuery(con, db.query)
  return(table.data)
}

game.data <- get.data.from.sqlite("bgg_data_3.db", "board_games")

collected.ranks <- grep('[[:digit:]]+', game.data$rank, value=TRUE)
collected.ranks <- as.numeric(collected.ranks)

missing.data <- as.matrix(setdiff(1:4999, collected.ranks))


hist(missing.data, breaks = 50)
# currently missing 20% of top games, and 10% of bottom games
# I have all of the middle games


#####
# Clean the data
#####

clean.data <- game.data %>% 
  filter(grepl('[[:digit:]]+', rank)) %>% mutate(rank = as.numeric((rank))) %>%
  filter(grepl('[[:digit:]]+', num_votes)) %>% mutate(num_votes = as.numeric((num_votes))) %>%
  filter(grepl('[[:digit:].]+', geek_rating)) %>% mutate(geek_rating = as.numeric((geek_rating))) %>%
  filter(grepl('[[:digit:].]+', avg_rating)) %>% mutate(avg_rating = as.numeric((avg_rating))) %>%
  filter(grepl('[[:digit:].]+', avg_rating_std_deviations)) %>% mutate(avg_rating_std_deviations = as.numeric((avg_rating_std_deviations)))
  
######

rank.votes <- clean.data %>% select(rank, num_votes)
rank.votes <- rank.votes[complete.cases(rank.votes), ]

ggplot(rank.votes, aes(x=rank, y=num_votes)) + geom_point()

######

year.votes <- clean.data %>% select(year_published, num_votes) %>% filter(year_published > 1950)
year.votes <- year.votes[complete.cases(year.votes), ]

ggplot(year.votes, aes(x=year_published, y=num_votes)) + geom_point()

######

year.comments <- clean.data %>% select(year_published, num_comments) %>% filter(year_published > 1950)
year.comments <- year.comments[complete.cases(year.comments), ]

ggplot(year.comments, aes(x=year_published, y=num_comments)) + geom_point()


######

votes.comments <- clean.data %>% select(num_votes, num_comments, rank)
votes.comments <- votes.comments[complete.cases(votes.comments), ]

ggplot(votes.comments, aes(x=num_votes, y=num_comments, color=rank)) + geom_point() + scale_colour_continuous("Rank", limits= c(1, 5000), low="green", high="blue") + scale_x_log10() + scale_y_log10()


######

weight.rating <- clean.data %>% select(weight, avg_rating, rank)
weight.rating <- weight.rating[complete.cases(weight.rating), ]

ggplot(weight.rating, aes(x=weight, y=avg_rating, color=rank)) + geom_point() + scale_colour_continuous("Rank", limits= c(1, 5000), low="green", high="blue")


######

retention.rank <- clean.data %>% mutate(retention = prev_owned / (owned + prev_owned)) %>% select(retention, geek_rating, rank)
retention.rank <- retention.rank[complete.cases(retention.rank), ]

ggplot(retention.rank, aes(x=geek_rating, y=retention, color=rank)) + geom_point() + scale_colour_continuous("Rank", limits= c(1, 5000), low="green", high="blue") + xlab("Geek Rating") + ylab("Non-Retention")


######

geek.rating.rounded <- clean.data %>% mutate(rating = round(geek_rating, digits = 1)) %>% 
  select(rating) %>% group_by(rating) %>% summarise(count = n()) %>% mutate(rating.method = "Geek Rating")


hist(clean.data$geek_rating)

avg.rating.rounded <- clean.data %>% mutate(rating = round(avg_rating, digits = 1)) %>%
  select(rating) %>% group_by(rating) %>% summarise(count = n()) %>% mutate(rating.method = "Avg. Rating")

hist(clean.data$avg_rating)


rating.comparison <- rbind(geek.rating.rounded, avg.rating.rounded)

#ggplot(rating.comparison, aes(x=rating, y=count, color=rating.method)) + geom_line()
#p2 <- ggplot(avg.rating.rounded, aes(x=avg_rating, y=count)) + geom_line(colour='blue')


#######

geek.rating.mu <- mean(clean.data$geek_rating)
geek.rating.sd <- sd(clean.data$geek_rating)

num.votes.mu <- mean(clean.data$geek_rating)
num.votes.sd <- sd(clean.data$geek_rating)


# how far above average geek rating is the game? <- this gives us a score
# how many people thought talking about it was important? <- this gives us weight
score.mechanics <- clean.data %>% select(geek_rating, num_votes, mechanics) %>% 
  mutate(score = (geek_rating - geek.rating.mu)) %>% 
  mutate(weight = log10(num_votes)) %>%
  mutate(score = score * weight / log10(mean(num_votes))) %>%
  select(score, mechanics)

score.mechanics <- score.mechanics %>% 
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  group_by(mechanics) %>% summarise(score = mean(score))


########


valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", num_fans)) %>% mutate(fans = as.numeric(num_fans))

# how far above average geek rating is the game? <- this gives us a score
# how many people thought talking about it was important? <- this gives us weight
fans.mechanics <- valid.data %>% select(fans, num_votes, mechanics) %>% 
  select(fans, mechanics)

fans.mechanics <- fans.mechanics %>% 
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  group_by(mechanics) %>% summarise(fans = mean(fans))


#########

valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", num_fans)) %>% mutate(fans = as.numeric(num_fans))

# how far above average geek rating is the game? <- this gives us a score
# how many people thought talking about it was important? <- this gives us weight
fans.categories <- valid.data %>% select(fans, num_votes, categories) %>% 
  select(fans, categories)

fans.categories <- fans.categories %>% 
  mutate(categories = strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>%
  group_by(categories) %>% summarise(fans = mean(fans))

#########


valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", weight)) %>% mutate(weight = as.numeric(weight))

# how far above average geek rating is the game? <- this gives us a score
# how many people thought talking about it was important? <- this gives us weight
weight.mechanics <- valid.data %>% select(weight, mechanics) %>% 
  select(weight, mechanics)

weight.mechanics <- weight.mechanics %>% 
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  group_by(mechanics) %>% summarise(weight = mean(weight))


#########

valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", min_playtime)) %>% mutate(min_playtime = as.numeric(min_playtime))

playtime.mechanics <- valid.data %>% select(min_playtime, mechanics) %>% 
  select(min_playtime, mechanics)

playtime.mechanics <- playtime.mechanics %>% 
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  group_by(mechanics) %>% summarise(min_playtime = mean(min_playtime))


########

valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", min_playtime)) %>% mutate(min_playtime = as.numeric(min_playtime))
valid.data <- valid.data %>% filter(grepl("[[:digit:].]+", weight)) %>% mutate(weight = as.numeric(weight))
valid.data <- valid.data %>% filter(grepl("[[:digit:].]+", num_fans)) %>% mutate(num_fans = as.numeric(num_fans))

ggplot(valid.data, aes(x=min_playtime, y=num_fans, color=weight)) + geom_point() + 
  scale_colour_continuous(limits= c(1, 5), low="green", high="blue") + scale_x_log10() + geom_jitter()


#########

valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", num_expansions)) %>% mutate(num_expansions = as.numeric(num_expansions))
valid.data <- valid.data %>% filter(grepl("[[:digit:].]+", num_fans)) %>% mutate(num_fans = as.numeric(num_fans))
expansions.rank <- valid.data %>% group_by(num_expansions) %>% summarise(rank.mu = mean(rank), num_fans = mean(num_fans))

ggplot(expansions.rank, aes(x=num_expansions, y=num_fans, color=rank.mu, size=3)) + geom_point() + scale_colour_continuous("Rank", low="green", high="blue")


#########
# game mechanic worth playing once only?

valid.data <- clean.data %>% 
  filter(grepl("[[:digit:]]+", owned)) %>% mutate(owned = as.numeric(owned)) %>%
  filter(grepl("[[:digit:]]+", prev_owned)) %>% mutate(prev_owned = as.numeric(prev_owned))


play.once <- valid.data %>% select(categories, prev_owned, owned)
play.once <- play.once[complete.cases(play.once), ]


play.once <- play.once %>% 
  mutate(categories = strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>%
  group_by(categories) %>% summarise(retention = sum(owned) / (sum(prev_owned) + sum(owned)))

##########

valid.data <- clean.data %>% 
  filter(grepl("[[:digit:]]+", min_playtime)) %>% mutate(min_playtime = as.numeric(min_playtime)) %>% 
  filter(grepl("[[:digit:]]+", total_plays)) %>% mutate(total_plays = as.numeric(total_plays))

valid.data <- valid.data %>% filter(min_playtime < 1000)

#valid.data <- valid.data %>% mutate(ppf = total_plays / num_fans)

ggplot(valid.data, aes(x=total_plays, y=min_playtime, color=rank)) + geom_point() + geom_jitter() + scale_x_log10()

###########


fans.mechanics <- fans.mechanics %>% 
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  group_by(mechanics) %>% summarise(fans = mean(fans)) %>% arrange(desc(fans))

top.mechanics <- fans.mechanics[1:10, ]
top.mechanics[, 1]

test <- clean.data %>%
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  filter(mechanics %in% top.mechanics$mechanics)


############

###########


fans.categories <- fans.categories %>% 
  mutate(categories, strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>%
  group_by(categories) %>% summarise(fans = mean(fans)) %>% arrange(desc(fans))

top.categories <- fans.categories[1:10, ]
top.categories[, 1]


############

valid.data <- clean.data %>% 
  filter(grepl("[[:digit:]+]", num_fans)) %>% 
  mutate(num_fans = log10(as.numeric(num_fans))) %>% filter(num_fans > 0) %>%
  select(num_fans, geek_rating)

ggplot(valid.data, aes(x=num_fans, y=geek_rating)) + geom_point()

cor(valid.data)


############

valid.data <- clean.data %>% filter(grepl("[[:digit:].]+", num_fans)) %>% mutate(fans = as.numeric(num_fans)) %>% filter(fans > 0)

zombie.games <- valid.data

zombie.games <- zombie.games %>% 
  mutate(categories = strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>%
  filter(categories == "Zombies")

zombie.games <- zombie.games[1:10, ]
zombie.games[, 1]