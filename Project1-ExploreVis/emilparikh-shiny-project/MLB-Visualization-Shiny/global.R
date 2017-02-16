suppressMessages({
  library(shiny)
  library(shinydashboard)
})

lblList <- list(
  Pitching = c(
    "Earned Run Average" = "ERA",
    "Hits Allowed" = "HA",
    "Home Runs Allowed" = "HRA",
    "Saves" = "SV",
    "Strikeouts" = "SOA",
    "Walks Allowed" = "BBA"
  ),
  Hitting = c(
    "Batting Average" = "BA",
    "Caught Stealing" = "CS",
    "Doubles" = "X2B",
    "Hits" = "H",
    "Home Runs" = "HR",
    "On Base %" = "OBP",
    "Runs Scored" = "R",
    "Sacrifice Flies" = "SF",
    "Stolen Bases" = "SB",
    "Strikeouts" = "SO",
    "Triples" = "X3B",
    "Walks" = "BB"
  )
)

lbls <- names(lblList)

statToLabel <- list(
  "ERA" = "Earned Run Average",
  "BA" = "Batting Average",
  "HR" = "Home Runs",
  "OBP" = "On Base %",
  "R" = "Runs Scored",
  "SO" = "Hitter Strikeouts",
  "BB" = "Walks",
  "BBA" = "Walks Allowed",
  "HA" = "Hits Allowed",
  "HRA" = "Home Runs Allowed",
  "SV" = "Saves",
  "SOA" = "Pitcher Strikeouts",
  "H" = "Hits",
  "X2B" = "Doubles",
  "X3B" = "Triples",
  "SB" = "Stolen Bases",
  "CS" = "Caught Stealing",
  "SF" = "Sacrifice Flies",
  "winPercent" = "Win %"
)

statToShortLabel <- list(
  "ERA" = "ERA",
  "BA" = "BA",
  "HR" = "HR",
  "OBP" = "OBP",
  "R" = "Runs Scored",
  "SO" = "SO",
  "BB" = "BB",
  "BBA" = "BB Allowed",
  "HA" = "Hits Allowed",
  "HRA" = "Home Runs Allowed",
  "SV" = "Saves",
  "SOA" = "Pitcher SO",
  "H" = "Hits",
  "X2B" = "Doubles",
  "X3B" = "Triples",
  "SB" = "Stolen Bases",
  "CS" = "Caught Steals",
  "SF" = "Sacrifice Flies",
  "winPercent" = "Win %"
)

summaryCols <- unlist(lblList, use.names = F)
