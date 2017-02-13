library(RSQLite)
library(ggplot2)

get.data.from.sqlite <- function(db.name, table.name) {
  con <- dbConnect(SQLite(), dbname=db.name)
  db.query <- paste('select * from', table.name)
  table.data <- dbGetQuery(con, db.query)
  return(table.data)
}

game.data <- get.data.from.sqlite("bgg_data.db", "board_games")

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
  filter(grepl('[[:digit:]]+', year_published)) %>% mutate(year_published = as.numeric((year_published))) %>%
  filter(grepl('[[:digit:]]+', num_comments)) %>% mutate(num_comments = as.numeric((num_comments))) %>%
  filter(grepl('[[:digit:].]+', geek_rating)) %>% mutate(geek_rating = as.numeric((geek_rating))) %>%
  filter(grepl('[[:digit:].]+', avg_rating)) %>% mutate(avg_rating = as.numeric((avg_rating))) %>%
  filter(grepl('[[:digit:].]+', avg_rating_std_deviations)) %>% mutate(avg_rating_std_deviations = as.numeric((avg_rating_std_deviations))) %>%
  filter(grepl('[[:digit:].]+', weight)) %>% mutate(weight = as.numeric((weight)))

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
