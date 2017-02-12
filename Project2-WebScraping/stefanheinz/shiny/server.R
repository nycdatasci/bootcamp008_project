# server.R

shinyServer(function(input, output, session) {
  # observe({
  #   title = input$selTitle
  #
  #   songsFiltered = filterDF(
  #     songs,
  #     input$selArtist,
  #     input$selTitle,
  #     input$selQuarter,
  #     input$selMonth,
  #     input$selWday,
  #     input$selSeason,
  #     input$selRushHour,
  #     input$selDateRange
  #   )
  #
  #   cat(nrow(songsFiltered))
  #
  #   updateSelectInput(
  #     session,
  #     'selArtist',
  #     choices=distinct(songsFiltered, artist), #arrange(distinct(songsFiltered, artist), artist),
  #     selected=NULL
  #   )
  # })

  ## START
  output$datesLoaded = renderInfoBox({
    infoBox(
      h4('Data loaded'),
      paste(
        min(songs$date),
        '-',
        max(songs$date)
      ),
      icon=icon('calendar'),
      color='red'
    )
  })

  output$daysLoaded = renderInfoBox({
    infoBox(
      h4('Days loaded'),
      n_distinct(songs$date),
      icon=icon('calendar-check-o'),
      color='red'
    )
  })

  output$songsPlayed = renderInfoBox({
    infoBox(
      h4('Total songs played'),
      format(nrow(songs), scientific=F, decimal.mark='.', big.mark=','),
      icon=icon('music'),
      color='red'
    )
  })

  output$distSongsPlayed = renderInfoBox({
    infoBox(
      h4('Distinct songs played'),
      format(n_distinct(songs$title), scientific=F, decimal.mark='.', big.mark=','),
      icon=icon('file-audio-o'),
      color='red'
    )
  })

  output$distArtistsPlayed = renderInfoBox({
    infoBox(
      h4('Distinct artists played'),
      format(n_distinct(songs$artist), scientific=F, decimal.mark='.', big.mark=','),
      icon=icon('microphone'),
      color='red'
    )
  })

  output$topSong = renderInfoBox({
    topSong = songs %>%
      group_by(artist, title) %>%
      summarise(
        n = n()
      ) %>% arrange(desc(n)) %>% head(1)

    infoBox(
      h4('Top Song'),
      paste(topSong$artist, '-', topSong$title, paste0('(', topSong$n, ')')),
      icon=icon('thumbs-up'),
      color='red'
    )
  })

  output$topArtist = renderInfoBox({
    topSong = songs %>%
      group_by(artist) %>%
      summarise(
        n = n()
      ) %>% arrange(desc(n)) %>% head(1)

    infoBox(
      h4('Top Artist'),
      paste(topSong$artist, paste0('(', topSong$n, ')')),
      icon=icon('thumbs-up'),
      color='red'
    )
  })

  ## FILTERS
  observeEvent(input$abResetFilter, {
    reset('selArtist')
    reset('selTitle')
    reset('selQuarter')
    reset('selMonth')
    reset('selWday')
    reset('selSeason')
    reset('selRushHour')
    reset('selDateRange')
  })

  observeEvent(input$abResetWordCloud, {
    reset('sliWordCloudWords')
    reset('tiWordCloudFilter')
    reset('rbWordCloudMoose')
  })

  ## SONGS
  songsTableReact = reactive({
    withProgress(message='Generating data table...', {
      songsFiltered = filterDF(
        songs,
        input$selArtist,
        input$selTitle,
        input$selQuarter,
        input$selMonth,
        input$selWday,
        input$selSeason,
        input$selRushHour,
        input$selDateRange
      )

      incProgress(0.25)

      distSongs = songsFiltered %>%
        group_by(artist, title) %>%
        summarise(
          from = min(ts),
          to = max(ts),
          playCount = n()
        ) %>%
        arrange(desc(playCount))

      incProgress(0.75)

      datatable(
        mutate(
          distSongs,
          from=strftime(from, format='%F %H:%M', tz='Europe/Berlin'),
          to=strftime(to, format='%F %H:%M', tz='Europe/Berlin')
        ),
        options = list(
          pageLength = 25
        )
      )
    })
  })

  output$songsTable = renderDataTable({
    songsTableReact()
  })


  songsCalendarReact = reactive({
    withProgress(message='Generating calendar...', {
      songsFiltered = filterDF(
        songs,
        input$selArtist,
        input$selTitle,
        input$selQuarter,
        input$selMonth,
        input$selWday,
        input$selSeason,
        input$selRushHour,
        input$selDateRange
      )

      incProgress(0.25)

      distSongs = songsFiltered %>%
        group_by(date) %>%
        summarise(
          playCount = n()
        ) %>%
        arrange(desc(playCount))

      incProgress(0.75)

      gvisCalendar(
        distSongs,
        datevar='date',
        numvar='playCount',
        options = list(
          width='100%',
          title=paste('Songs x Year'),
          colorAxis=
            paste(
              '{',
              'minValue: 0, colors: [\'#FFFFFF\', \'#FF0000\']',
              '}'
            )
        )
      )
    })
  })

  output$songsCalendar = renderGvis({
    songsCalendarReact()
  })


  songsClockReact = reactive({
    withProgress(message='Generating clock...', {
      songsFiltered = filterDF(
        songs,
        input$selArtist,
        input$selTitle,
        input$selQuarter,
        input$selMonth,
        input$selWday,
        input$selSeason,
        input$selRushHour,
        input$selDateRange
      )

      incProgress(0.25)

      distSongs = songsFiltered %>%
        group_by(hour) %>%
        summarise(
          playCount = n()
        )

      fromCol = '#FFFFFF'
      toCol = '#FF0000'
      songsCol = colorRampPalette(c(fromCol, toCol))(24)

      incProgress(0.75)

      ggplot(distSongs, aes(x=hour, y=playCount, fill=playCount)) +
        geom_bar(stat='identity') +
        coord_polar() +
        theme_bw() +
        labs(x = 'Hour of day', y = '', fill = 'Playcount') +
        theme(
          plot.title = element_text(hjust = 0.5, size = 22),
          plot.subtitle = element_text(hjust = .5, size = 16),
          axis.text.y = element_blank(),
          axis.ticks.y = element_blank()
        ) +
        guides(fill='legend') +
        ggtitle(paste('Playcounts during the day')) +
        scale_fill_gradient(low='darkred', high=toCol)
    })
  })

  output$songsClock = renderPlot({
    songsClockReact()
  })


  songsHistoReact = reactive({
    withProgress(message='Generating histogram...', {
      songsFiltered = filterDF(
        songs,
        input$selArtist,
        input$selTitle,
        input$selQuarter,
        input$selMonth,
        input$selWday,
        input$selSeason,
        input$selRushHour,
        input$selDateRange
      )

      incProgress(0.25)

      distSongs = songsFiltered %>%
        group_by(artist, title) %>%
        summarise(
          playCount = n()
        )

      incProgress(0.75)

      gvisHistogram(
        distSongs[, 'playCount'],
        options = list(
          width='100%',
          height=500,
          title=paste('Frequency of playcounts'),
          hAxis=
            paste(
              "{",
              "slantedText: true",
              "}"
            ),
          colors=
            paste(
              '[',
              '\'red\'',
              ']'
            )
        )
      )
    })
  })

  output$songsHisto = renderGvis({
    songsHistoReact()
  })


  songsArtistReact = reactive({
    withProgress(message='Generating bar chart...', {
      songsFiltered = filterDF(
        songs,
        input$selArtist,
        input$selTitle,
        input$selQuarter,
        input$selMonth,
        input$selWday,
        input$selSeason,
        input$selRushHour,
        input$selDateRange
      )

      incProgress(0.25)

      distSongs = songsFiltered %>%
        group_by(artist) %>%
        summarise(
          songCount = n_distinct(title)
        ) %>% arrange(desc(songCount))

      incProgress(0.75)

      gvisColumnChart(
        distSongs[input$sliSongsPerArtist[1]:input$sliSongsPerArtist[2], ],
        xvar='artist',
        yvar='songCount',
        options = list(
          width='100%',
          height=500,
          title=paste('Songs per Artist'),
          hAxis=
            paste(
              '{',
              'slantedText: true,',
              'textStyle:',
              '{',
              'fontSize: 9',
              '}',
              '}'
            ),
          vAxis=
            paste(
              '{',
              'minorGridlines:',
              '{',
              'count: 1',
              '}',
              '}'
            ),
          colors=
            paste(
              '[',
              '\'red\'',
              ']'
            ),
          chartArea='{ width: \'90%\' }'
        )
      )
    })
  })

  output$songsArtist = renderGvis({
    songsArtistReact()
  })


  songsCloudReact = reactive({
    input$abWordCloud

    if (input$abWordCloud > abWordCloudVal) {
      abWordCloudVal <<- input$abWordCloud

      withProgress(message='Generating word cloud...', {
        songsFiltered = filterDF(
          songs,
          input$selArtist,
          input$selTitle,
          input$selQuarter,
          input$selMonth,
          input$selWday,
          input$selSeason,
          input$selRushHour,
          input$selDateRange
        )

        incProgress(0.1)

        # Dict for wordcloud
        titleSplit = unlist(lapply(unique(songsFiltered$title), function(x) strsplit(x, '\\s|-|,|&|\\?|\\(|\\)')))
        titleDict = {}

        incProgress(0.3)

        for (word in titleSplit) {
          word = trimws(tolower(word))

          if (word!='' & nchar(word) > 0) {
            if (word %in% names(titleDict)) {
              titleDict[word] = titleDict[word] + 1
            } else {
              titleDict[word] = 1
            }
          }
        }

        incProgress(0.5)

        titleDict = data.frame(word=names(titleDict), freq=titleDict, stringsAsFactors=F)
        titleDict = arrange(titleDict, desc(freq))

        incProgress(0.6)

        filterWords = strsplit(input$tiWordCloudFilter, ',')[[1]]

        if (input$rbWordCloudMoose == 'Moose') {
          figPath = 'www/wordcloud-path.png'
          shape = NULL
        } else {
          figPath = NULL
          shape = 'circle'
        }

        wordcloud2(
          filter(
            titleDict[1:min(nrow(titleDict), input$sliWordCloudWords), ],
            word %ni% filterWords
          ),
          figPath=figPath,
          shape=shape,
          color='red',
          size=1
        )
      })
    }
  })

  output$songsCloud = renderWordcloud2({
    songsCloudReact()
  })
})
