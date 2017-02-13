suppressMessages({
  library(shiny)
  library(dplyr)
  library(ggplot2)
  library(ggthemes)
})

factorColors <- c("#F8766D","#EA8331","#D89000","#C09B00","#A3A500","#7CAE00","#39B600","#00BB4E","#00BF7D","#00C1A3","#00BFC4","#00BAE0","#00B0F6","#35A2FF","#9E9AF6","#CF8FFF","#E76BF3","#E76BF3","#FF62BC","#FF6A98")
  
getFacetPlotsAndData <- function(){
  data <- getData()
  
  # use to set colors depending on factor
  factorsJoined <- c(as.vector(data$genre$Genre%>%unique()),as.vector(data$network$Network%>%unique()))
  namedColors <- c(factorColors, factorColors)
  names(namedColors) <- factorsJoined
  
  return(list(
    genre_count = createFacetPlot(data$genre, "Year", "Count", "Genre"),
    genre_rating = createFacetPlot(data$genre, "Year", "Median Rating", "Genre"),
    genre_years = createFacetPlot(data$genre, "Year", "Median Number of Years", "Genre"),
    genre_votes = createFacetPlot(data$genre, "Year", "Total Votes", "Genre"),
    network_count = createFacetPlot(data$network, "Year", "Count", "Network"),
    network_rating = createFacetPlot(data$network, "Year", "Median Rating", "Network"),
    network_years = createFacetPlot(data$network, "Year", "Median Number of Years", "Network"),
    network_votes = createFacetPlot(data$network, "Year", "Total Votes", "Network"),
    all_data = data$genre_all,
    namedColors = namedColors,
    genre_data = data$genre,
    network_data = data$network
  ))
  
  
}

getData <- function(){
  df_genres <- read.csv("data/df_genres.csv", stringsAsFactors = F)
  df_genres["genre"] <- lapply(df_genres["genre"], factor)
  df_genres["original_network"] <- lapply(df_genres["original_network"], factor)
  
  df_final <- read.csv("data/df_final.csv", stringsAsFactors = F)
  df_final["original_network"] <- lapply(df_final["original_network"], factor)
  
  genre_year <- df_genres %>% group_by(start_year, genre) %>% summarise(`Median Number of Years`=median(num_years, na.rm=T), `Median Rating`=median(rating, na.rm=T), `Total Votes`=sum(votes, na.rm=TRUE), Count=n())
  #bad_genres <- c("anthology", "biography", "news", "history", "horror", "music", "musical", "short", "sport", "talk-show", "western", "war", "game-show", "documentary", "fantasy")
  #bad_genres <- c("")
  bad_genres <- c("anthology", "biography", "short", "sport", "war", "musical", "western")
  
  genre_year <- genre_year %>% filter(!(genre %in% bad_genres))
  genre_year <- genre_year %>% rename(Year=start_year, Genre=genre)
  
  network_year <- df_final %>% group_by(start_year, original_network) %>% summarise(`Median Number of Years`=median(num_years, na.rm=T),`Median Rating`=median(rating, na.rm=T), `Total Votes`=sum(votes, na.rm=TRUE), Count=n())
  top_networks_df <- (df_final %>% filter(original_network != "none") %>% group_by(original_network) %>% summarise(count=n()) %>% arrange(desc(count)) %>% top_n(20, count))
  top_networks_vec <- top_networks_df[["original_network"]]
  network_year <- network_year %>% filter(original_network %in% top_networks_vec)
  network_year <- network_year %>% rename(Network=original_network, Year=start_year)
  
  return(list(
    genre = genre_year %>% unique(),
    network = network_year %>% unique(),
    genre_all = df_genres %>%
      select(
        Year=start_year,
        Genre=genre,
        Title=title,
        Network=original_network,
        `Number of Years` = num_years,
        Rating = rating,
        Votes = votes
      ) %>%
      filter(!is.na(Rating)) %>%
      unique()
  ))
}

createFacetPlot <- function(data, x, y, by){
  x <- as.name(x)
  y <- as.name(y)
  by <- as.name(by)
  
  names(factorColors) <- as.vector(data[[as.character(by)]]) %>% unique

  title <- paste0(y, " of Shows per ", x, " by ", by)
  
  plt <- ggplot(data, aes_string(x=x, y=y)) + 
    geom_point(aes_string(color=by)) + 
    facet_wrap(as.formula(paste("~", by))) + 
    ggtitle(title) + 
    theme_fivethirtyeight() + 
    theme(
      plot.title = element_text(
        hjust = 0.5,
        margin = margin(0,0,20,0),
        size = 14
      ),
      legend.position = "none",
      panel.background = element_rect(fill = "#ffffff"),
      plot.background = element_rect(fill = "#ffffff"),
      strip.background = element_rect(fill="#000000"),
      strip.text = element_text(color="#ffffff"),
      panel.spacing = unit(20, "pt"),
      axis.title = element_text(size = 14),
      axis.text = element_text(size = 12),
      axis.text.x = element_text(angle = 45)
    ) +
    scale_color_manual(values = factorColors)
  
  return(plt)
}

getDetailPlot <- function(data, title, x, y, xRange, yRange, ptColor){
  
  ggplot(data, aes_string(x=x, y=y)) + 
    geom_point(size=3, color=ptColor) + 
    ggtitle(title) + 
    theme_fivethirtyeight() + 
    theme(
      plot.title = element_text(
        hjust = 0.5,
        margin = margin(0,0,20,0),
        size = 14
      ),
      legend.position = "none",
      panel.background = element_rect(fill = "#ffffff"),
      plot.background = element_rect(fill = "#ffffff"),
      strip.background = element_rect(fill="#000000"),
      strip.text = element_text(color="#ffffff"),
      panel.spacing = unit(20, "pt"),
      axis.title = element_text(size = 14),
      axis.text = element_text(size = 12)
    ) +
    coord_cartesian(xlim = xRange, ylim = yRange)
}