lower48 <- state.abb
lower48 <- state.abb[state.abb!="AK" & state.abb!="HI"]
tornadoes <- read.csv("Tornadoes_SPC_1950to2015.csv")
tornadoes <- tornadoes[tornadoes$st %in% lower48, ]
tornadoes.since.1996 <- tornadoes %>% filter(yr >= 1996)
tornadoes.since.1996 <- tornadoes.since.1996 %>% mutate(date = as.Date(date, "%m/%d/%Y"))
tornadoes.since.1996 <- tornadoes.since.1996 %>% mutate(X1 = row.names(tornadoes.since.1996))

saveRDS(tornadoes.since.1996,"tornadoes_since_1996.rds")
#write.csv(tornadoes, "tornadoes.csv")
