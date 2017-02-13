library(RSQLite)
library(ggplot2)
library(dplyr)
library(tidyr)
library(corrplot)
library(stats)

get.data.from.sqlite <- function(db.name, table.name) {
  con <- dbConnect(SQLite(), dbname=db.name)
  db.query <- paste('select * from', table.name)
  table.data <- dbGetQuery(con, db.query)
  return(table.data)
}

game.data <- get.data.from.sqlite("bgg_data_3.db", "board_games")

# Then clean
# there is a minimum set of data I want to work with

clean.data <- game.data %>% 
  filter(grepl('[[:digit:]]+', rank)) %>% mutate(rank = as.numeric((rank))) %>%
  filter(grepl('[[:digit:]]+', num_votes)) %>% mutate(num_votes = as.numeric((num_votes))) %>%
  filter(grepl('[[:digit:].]+', geek_rating)) %>% mutate(geek_rating = as.numeric((geek_rating))) %>%
  filter(grepl('[[:digit:].]+', avg_rating)) %>% mutate(avg_rating = as.numeric((avg_rating))) %>%
  filter(grepl('[[:digit:].]+', avg_rating_std_deviations)) %>% mutate(avg_rating_std_deviations = as.numeric((avg_rating_std_deviations)))


## Do we reject null hypothesis and say with 95% certainty that the game categor is special
category.is.special <- function(all.games, category.value, check.feature, use.log=FALSE, tta="greater") {

  
  population.games <- all.games %>% 
    mutate(categories = strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>%
    filter(categories != category.value) %>%
    select(-designers, -mechanics, -categories) %>%
    distinct()
  
  population.games <- population.games[grepl('[[:digit:].]+', population.games[, check.feature]), ]
  population.games[, check.feature] <- as.numeric(population.games[, check.feature])
  
  population.data <- data.frame(population.games[, check.feature])
  names(population.data) <- c("values")
  
  
  sample.games <- all.games %>% 
    mutate(categories = strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>% 
    filter(categories == category.value) %>%
    select(-designers, -mechanics, -categories) %>%
    distinct()
  
  sample.games <- sample.games[grepl('[[:digit:].]+', sample.games[, check.feature]), ]
  sample.games[, check.feature] <- as.numeric(sample.games[, check.feature])
  
  sample.data <- data.frame(sample.games[, check.feature])
  names(sample.data) <- c("values")
  
  if (use.log) {
    population.data <- log10(population.data)
    population.data <- population.data %>% filter(values >= 0)
    sample.data <- log10(sample.data)
    sample.data <- sample.data %>% filter(values >= 0)
  }
  
  sample.data <- sample.data %>% na.omit()
  population.data <- population.data %>% na.omit()

  t.data <- t.test(sample.data, population.data, alternative = tta)
  
  t.data$p.value
}

## Do we reject null hypothesis and say with 95% certainty that the game mechanic is special
mechanic.is.special <- function(all.games, mechanic.value, check.feature, use.log=FALSE, tta="greater") {
  
  
  population.games <- all.games %>% 
    mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
    filter(mechanics != mechanic.value) %>%
    select(-designers, -mechanics, -mechanics) %>%
    distinct()
  
  population.games <- population.games[grepl('[[:digit:].]+', population.games[, check.feature]), ]
  population.games[, check.feature] <- as.numeric(population.games[, check.feature])
  
  population.data <- data.frame(population.games[, check.feature])
  names(population.data) <- c("values")
  
  
  sample.games <- all.games %>% 
    mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>% 
    filter(mechanics == mechanic.value) %>%
    select(-designers, -mechanics, -mechanics) %>%
    distinct()
  
  sample.games <- sample.games[grepl('[[:digit:].]+', sample.games[, check.feature]), ]
  sample.games[, check.feature] <- as.numeric(sample.games[, check.feature])
  
  sample.data <- data.frame(sample.games[, check.feature])
  names(sample.data) <- c("values")
  
  if (use.log) {
    population.data <- log10(population.data)
    population.data <- population.data %>% filter(values >= 0)
    sample.data <- log10(sample.data)
    sample.data <- sample.data %>% filter(values >= 0)
  }
  
  sample.data <- sample.data %>% na.omit()
  population.data <- population.data %>% na.omit()
  
  t.data <- t.test(sample.data, population.data, alternative = tta)
  
  t.data$p.value
}

## Do we reject null hypothesis and say with 95% certainty that the game mechanic is special
designer.is.special <- function(all.games, designer.value, check.feature, use.log=FALSE, tta="greater") {
  
  
  population.games <- all.games %>% 
    mutate(designers = strsplit(designers, split = "|", fixed=TRUE)) %>% unnest(designers) %>%
    filter(designers != designer.value) %>%
    select(-designers, -designers, -designers) %>%
    distinct()
  
  population.games <- population.games[grepl('[[:digit:].]+', population.games[, check.feature]), ]
  population.games[, check.feature] <- as.numeric(population.games[, check.feature])
  
  population.data <- data.frame(population.games[, check.feature])
  names(population.data) <- c("values")
  
  
  sample.games <- all.games %>% 
    mutate(designers = strsplit(designers, split = "|", fixed=TRUE)) %>% unnest(designers) %>% 
    filter(designers == designer.value) %>%
    select(-designers, -designers, -designers) %>%
    distinct()
  
  
  if (length(sample.games) < 10) {
    return(1.0)
  }
  
  sample.games <- sample.games[grepl('[[:digit:].]+', sample.games[, check.feature]), ]
  sample.games[, check.feature] <- as.numeric(sample.games[, check.feature])
  
  sample.data <- data.frame(sample.games[, check.feature])
  names(sample.data) <- c("values")
  
  if (use.log) {
    population.data <- log10(population.data)
    population.data <- population.data %>% filter(values >= 0)
    sample.data <- log10(sample.data)
    sample.data <- sample.data %>% filter(values >= 0)
  }
  
  sample.data <- sample.data %>% na.omit()
  population.data <- population.data %>% na.omit()
  
  t.data <- t.test(sample.data, population.data, alternative = tta)
  
  t.data$p.value
}


########################################

game.categories <- clean.data %>% 
  mutate(categories = strsplit(categories, split = "|", fixed=TRUE)) %>% unnest(categories) %>%
  select(categories) %>% unique() %>%
  mutate(avg.rating = 1, num.fans = 1, num.votes = 1, num.comments = 1)

  
for (category in game.categories$categories) {
  game.categories[game.categories$categories==category, "avg.rating"] <- category.is.special(clean.data, category, "avg_rating", FALSE, "greater")
  game.categories[game.categories$categories==category, "num.fans"] <- category.is.special(clean.data, category, "num_fans", TRUE, "greater")
  game.categories[game.categories$categories==category, "num.votes"] <- category.is.special(clean.data, category, "num_votes", TRUE, "greater")
  game.categories[game.categories$categories==category, "num.comments"] <- category.is.special(clean.data, category, "num_comments", TRUE, "greater")
}

###

game.mechanics <- clean.data %>% 
  mutate(mechanics = strsplit(mechanics, split = "|", fixed=TRUE)) %>% unnest(mechanics) %>%
  select(mechanics) %>% unique() %>%
  mutate(avg.rating = 1, num.fans = 1, num.votes = 1, num.comments = 1)

for (mechanic in game.mechanics$mechanics) {
  game.mechanics[game.mechanics$mechanics==mechanic, "avg.rating"] <- mechanic.is.special(clean.data, mechanic, "num_votes", FALSE, "greater")
  game.mechanics[game.mechanics$mechanics==mechanic, "num.fans"] <- mechanic.is.special(clean.data, mechanic, "num_fans", TRUE, "greater")
  game.mechanics[game.mechanics$mechanics==mechanic, "num.votes"] <- mechanic.is.special(clean.data, mechanic, "num_votes", TRUE, "greater")
  game.mechanics[game.mechanics$mechanics==mechanic, "num.comments"] <- mechanic.is.special(clean.data, mechanic, "num_comments", TRUE, "greater")
}

####

game.designers <- clean.data %>% 
  mutate(designers = strsplit(designers, split = "|", fixed=TRUE)) %>% unnest(designers) %>%
  select(designers) %>% unique() %>%
  mutate(avg.rating = 1, num.fans = 1, num.votes = 1, num.comments = 1)

for (designer in game.designers$designers) {
  game.designers[game.designers$designers==designer, "avg.rating"] <- designer.is.special(clean.data, designer, "num_votes", FALSE, "greater")
  game.designers[game.designers$designers==designer, "num.fans"] <- designer.is.special(clean.data, designer, "num_fans", TRUE, "greater")
  game.designers[game.designers$designers==designer, "num.votes"] <- designer.is.special(clean.data, designer, "num_votes", TRUE, "greater")
  game.designers[game.designers$designers==designer, "num.comments"] <- designer.is.special(clean.data, designer, "num_comments", TRUE, "greater")
}

####

hist((as.numeric(clean.data$rank)))
