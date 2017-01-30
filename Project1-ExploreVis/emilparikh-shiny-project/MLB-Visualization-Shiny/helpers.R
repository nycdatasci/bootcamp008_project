suppressMessages({
  library(dplyr)
  library(ggplot2)
  library(ggcorrplot)
  library(tidyr)
  library(scales)
  library(ggthemes)
  library(grid)
  library(gridExtra)
})


#use function to prepare master data to use garbage cleanup
#rather than relying on access to rm() command
getMasterData <- function(){
  data <- readRDS(file = "data/Teams2005AndUp.rds")
  
  #separate by playoff vs nonplayoff
  playoff <- data %>%
    filter(DivWin | WCWin) %>%
    mutate(group = 1)
  
  #divide each nonplayoff team by top/bottom percentage by year
  #2 = top nonplayoff 1=bottom, but change to 3 so doesn't conflict with playoff teams
  nonplayoff <- data %>%
    filter(!(DivWin | WCWin)) %>%
    group_by(yearID) %>%
    mutate(group = ntile(winPercent, 2))
  
  nonplayoff[nonplayoff$group==1, ]$group = 3
  
  nonplayoff <- as.data.frame(nonplayoff)
  
  #final data to work with
  data <- rbind(playoff, nonplayoff) %>% arrange(yearID)
  
  return(data)
}

#### MEANDIFF FUNCTION ####
getDiff <- function(barPlotData, statistic, roundPlaces){
  data <- barPlotData %>%
    select(Year=yearID, madePlayoffs, one_of(statistic)) %>%
    spread_(key = "madePlayoffs", value = statistic) %>%
    summarise(Difference=Yes-No)
  
  #turn from vertical to horizontal to put under bar graph
  data <- as.data.frame(data %>% spread(key=Year, value = Difference))
  rownames(data) <- "(Playoff - Nonplayoff)"
  
  #change from column mean to row means
  #m <- mean(data$Difference)
  m <- apply(data, 1, mean)[[1]]
  
  #round dec places by row
  #data$Difference <- round(data$Difference, roundPlaces)
  data <- round(data, roundPlaces)
  
  return(list(
    data = data,
    mean = m
  ))
}


##### BARPLOT FUNCTIONS  #####
getBarPlotData <- function(masterData, summaryCols, grps){
  barPlotData <- masterData %>%
    filter(group %in% grps) %>%
    group_by(yearID, madePlayoffs) %>%
    summarise_each(funs(mean), one_of(summaryCols))
  
  #min/max to calculate yaxis interval
  mins <- sapply(summaryCols, function(x){min(barPlotData[x])})
  maxes <- sapply(summaryCols, function(x){max(barPlotData[x])})
  yTicks <- (maxes-mins)/9
  
  return(list(
    data = barPlotData,
    mins = mins,
    maxes = maxes,
    yTicks = yTicks
  ))
}

#plot the chosen statistic by nonplayoff/playoff team by year
plotBar <- function(df, yCol, lab, yFrom, yTo, yBy, roundYAxis){
  xAxisTitle <- "Made Playoffs"
  background <- "#FFFFFF"
  
  df$yearID <- as.numeric(as.character(df$yearID))
  
  ggplot(df, aes_string(x="yearID", y=yCol)) +
    geom_bar(stat="identity", position = "dodge", alpha=0.65, aes(fill = madePlayoffs)) +
    geom_line(show.legend = FALSE, size = 2, aes(color=madePlayoffs)) +
    labs(x="Year", y=paste("Mean", lab)) +
    theme_fivethirtyeight() +
    theme(
      panel.spacing.x = unit(.2, "in"),
      panel.background = element_rect(fill = background),
      plot.background = element_blank(),
      axis.title = element_text(size = 14),
      axis.text.y = element_text(size = 12),
      axis.text.x = element_text(size = 12),
      legend.position = "right",
      legend.direction = "vertical",
      legend.background = element_rect(fill = background),
      legend.box.spacing = unit(0.05, "in"),
      legend.key.size = unit(.2, "in")
    ) +
    scale_fill_manual(name = "Made Playoffs", values = c("#cc0000", "#000088")) +
    scale_color_manual(name = "Made Playoffs", values = c("#cc0000", "#000088")) +
    coord_cartesian(ylim=c(yFrom, yTo)) +
    scale_x_continuous(breaks = 2005:2015) +
    scale_y_continuous(breaks = round(seq(yFrom, yTo, by = yBy), roundYAxis), labels = comma)
}

#rnd <- function(x){trunc(x+sign(x)*0.5)}

### GGCORRPLOTS ###
createCorrPlots <- function(masterData, grps=1){
  
  masterData <- masterData[masterData$group %in% grps, ]
  
  hitData <- masterData[,c(lblList$Hitting,"winPercent")]
  corr <- round(cor(hitData),3)
  #corr[abs(corr)<.25]=0
  p.mat <- cor_pmat(hitData)
  gHitting <- ggcorrplot(corr,outline.color = "#cccccc", type = "lower", p.mat = p.mat, insig = "blank", ggtheme = theme_bw, lab = TRUE) +
  theme(
    panel.border = element_blank()
  )
  
  
  pitchData <- masterData[,c(lblList$Pitching,"winPercent")]
  corr <- round(cor(pitchData),3)
  #corr[abs(corr)<.25]=0
  p.mat <- cor_pmat(pitchData)
  gPitching <- ggcorrplot(corr,outline.color = "#cccccc", type = "lower", p.mat = p.mat, insig = "blank", ggtheme = theme_bw, lab = TRUE) +
    theme(
      panel.border = element_blank()
    )
  
  return(list(
    hitting = gHitting,
    pitching = gPitching
  ))
}

### SCATTERPLOTS ###
plotScatter <- function(df, xCol, yCol, xLab, yLab, grps){
  df <- df[df$group %in% grps, ]
  background <- "#FFFFFF"
  
  ggplot(df, aes_string(x=xCol, y=yCol)) +
    geom_point(size = 3, aes(color=madePlayoffs)) +
    geom_smooth(method = "lm", se=FALSE, aes(color=madePlayoffs)) +
    labs(x=xLab, y=yLab) +
    theme_fivethirtyeight() +
    theme(
      panel.spacing.x = unit(.2, "in"),
      panel.background = element_rect(fill = background),
      plot.background = element_blank(),
      axis.title = element_text(size = 14),
      axis.text.y = element_text(size = 12),
      axis.text.x = element_text(size = 12),
      legend.position = "right",
      legend.direction = "vertical",
      legend.background = element_rect(fill = background),
      legend.key = element_rect(fill = background),
      legend.box.spacing = unit(0.05, "in"),
      legend.key.size = unit(.2, "in")
    ) +
    scale_color_manual(name = "Made Playoffs", values = c("#cc0000", "#000088"))
}
