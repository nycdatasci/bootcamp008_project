'%ni%' <- Negate('%in%')

filterDF = function(df, selArtist, selTitle, selQuarter, selMonth, selWday, selSeason, selRushHour, selDateRange) {
  if (!is.null(selArtist))
    df = filter(df, artist %in% selArtist)

  if (!is.null(selTitle))
    df = filter(df, title %in% selTitle)

  if (!is.null(selQuarter))
    df = filter(df, quarter %in% selQuarter)

  if (!is.null(selMonth))
    df = filter(df, month %in% selMonth)

  if (!is.null(selWday))
    df = filter(df, wdayLbl %in% selWday)

  if (!is.null(selSeason))
    df = filter(df, season %like% selSeason)

  if (!is.null(selRushHour))
    df = filter(df, rushHour %in% selRushHour)

  if (!is.null(selDateRange))
    df = filter(df, date >= selDateRange[1] & date <= selDateRange[2])

  return(df)
}
