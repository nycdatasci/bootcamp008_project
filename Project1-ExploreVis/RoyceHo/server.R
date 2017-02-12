shinyServer(function(input, output) {
  perc <- function(x) {
    a = na.omit(ehresp[x]) %>% group_by_(x) %>% summarise(b = n()) %>% mutate(c = round(100* b/sum(b)))
    return(paste(paste0(a[[3]],"%"), levels(ehresp[[x]]),collapse = " \n"))
  }
  seldf <- function(v1, v2 = NULL, v3 = NULL){
    return(data.frame(na.omit(ehresp[, c(v1, v2, v3)])))
  }
  var3list <- function(x){
    return(sort(append(x[!(x %in% contvars)], "genhth")))
  }
  assignplot <- function(v1, v2, v3){
    if(v1 %in% contvars){
      if(v2 == "None"){
        return(ngraphs)
      } else if(v2 %in% contvars){
        if(v3 == "None"){
          return(nngraphs)
        } else{
          return(nncgraphs)
        }
      } else if(v3 == "None"){
        return(ncgraphs)
      } else {
        return(nccgraphs)
      }
    } else {
      if(v2 == "None"){
        return(cgraphs)
      } else if (v2 %in% contvars){
        if(v3 == "None"){
          return(cngraphs)
        } else {
          return(cncgraphs)
        }
      } else {
        return(ccgraphs)
      }
    }
  }
  
  plotfunc <- function(v1, v2, v3, v4){
    if(v2 == "None"){
      return(plot1var(v1, v4))
    } else if(v3 == "None"){
      return(plot2var(v1, v2, v4))
    } else{
      return(plot3var(v1, v2, v3, v4))
    }
  }
  
  plot1var <- function(v1, v4){
    return(switch(v4, Bar = bar1p(v1), Density = dens1p(v1), Histogram = hist1p(v1)))
  }
  plot2var <- function(v1, v2, v4){
    return(switch(v4, Bar = bar2p(v1, v2), Box = box2p(v1, v2), Density = dens2p(v1,v2), Density2D = dens2d2p(v1,v2), 
                  Histogram = hist2p(v1,v2), Line = line2p(v1, v2), Scatter = scat2p(v1, v2), Violin = viol2p(v1, v2)))
  }
  plot3var <- function(v1, v2, v3, v4){
    return(switch(v4, Density2D = dens2d3p(v1, v2, v3), Line = line3p(v1, v2, v3), Scatter = scat3p(v1, v2, v3)))
  }
  bar1p <- function(v1){
    return(ggplot(data = seldf(v1,v1),aes_string(x =v1)) + geom_bar())
  } 
  dens1p <- function(v1){
    return(ggplot(data = seldf(v1,v1),aes_string(x =v1)) + geom_density())
  }
  hist1p <- function(v1){
    return(ggplot(data = seldf(v1,v1),aes_string(x =v1)) + geom_histogram()) 
  }
  bar2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x =v1)) + geom_bar(aes_string(fill = v2), position = "fill"))
  } 
  box2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x = v1, y = v2)) + geom_boxplot())
  }
  dens2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x =v1)) + geom_density(aes_string(color = v2, fill = v2), alpha = 0.1))
  }
  dens2d2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x =v1, y = v1)) + geom_density2d())
  }
  hist2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x =v1)) + geom_histogram(aes_string(fill = v2))) 
  }
  line2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x =v1, y = v2)) + geom_smooth())
  }
  scat2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x =v1, y = v2)) + geom_point(position = "jitter"))
  }
  viol2p <- function(v1, v2){
    return(ggplot(data = seldf(v1,v2),aes_string(x = v1, y = v2)) + geom_violin())
  }
  dens2d3p <- function(v1, v2, v3){
    return(ggplot(data = seldf(v1,v2,v3),aes_string(x =v1, y =v2)) + geom_density2d(aes_string(color = v3)))
  } 
  line3p <- function(v1, v2, v3){
    return(ggplot(data = seldf(v1,v2, v3),aes_string(x =v1, y = v2)) + geom_smooth(aes_string(color = v3)))
  }
  scat3p <- function(v1, v2, v3){
    return(ggplot(data = seldf(v1,v2,v3),aes_string(x =v1, y = v2)) + geom_point(aes_string(color = v3)))
  } 

  output$hplot <- renderPlot(
    plotfunc(input$h1, input$h2, input$h3, input$h4) + ggtitle("Health") + labs 
  )
  output$fplot <- renderPlot(
    plotfunc(input$f1, input$f2, input$f3, input$f4) + ggtitle("Financial Situation") + labs
  )
  output$eplot <- renderPlot(
    plotfunc(input$e1, input$e2, input$e3, input$e4) + ggtitle("Exercise") + labs
  )
  output$mplot <- renderPlot(
    plotfunc(input$m1, input$m2, input$m3, input$m4) + ggtitle("Meal Preparation") + labs
  )
  output$foplot <- renderPlot(
    plotfunc(input$fo1, input$fo2, input$fo3, input$fo4) + ggtitle("Food Type") + labs
  )
  output$tplot <- renderPlot(
    plotfunc(input$t1, input$t2, input$t3, input$t4) + ggtitle("Time Spent Eating") + labs
  )
  output$iplot <- renderPlot(
    plotfunc(input$i1, input$i2, input$i3, input$i4) + ggtitle("Comparing Variables") + labs
  )
  output$h2 <- renderUI({
    selectizeInput(inputId = "h2", label = "Variable 2", choices = append(c("None"),importantvars[!(importantvars %in% c(input$h1))]))
  })
  output$h3 <- renderUI({
    if (input$h1 %in% catvars | input$h2 %in% catvars | input$h2 == "None"){
      selectizeInput(inputId = "h3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "h3", label = "Variable 3", choices = append(c("None"), c("genhth")))
    } 
  })
  output$f2 <- renderUI({
    selectizeInput(inputId = "f2", label = "Variable 2", choices = append(c("None"), importantvars))
  })
  output$f3 <- renderUI({
    if (input$f1 %in% catvars | input$f2 %in% catvars | input$f2 == "None"){
      selectizeInput(inputId = "f3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "f3", label = "Variable 3", choices = append(c("None"), var3list(financialvars)[!(var3list(financialvars) %in% c(input$f1, input$f2))]))
    } 
  })
  output$e2 <- renderUI({
    selectizeInput(inputId = "e2", label = "Variable 2", choices = append(c("None"), importantvars))
  })
  output$e3 <- renderUI({
    if (input$e1 %in% catvars | input$e2 %in% catvars | input$e2 == "None"){
      selectizeInput(inputId = "e3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "e3", label = "Variable 3", choices = append(c("None"), var3list(exercisevars)[!(var3list(exercisevars) %in% c(input$e1, input$e2))]))
    } 
  })
  output$m2 <- renderUI({
    selectizeInput(inputId = "m2", label = "Variable 2", choices = append(c("None"), importantvars))
  })
  output$m3 <- renderUI({
    if (input$m1 %in% catvars | input$m2 %in% catvars | input$m2 == "None"){
      selectizeInput(inputId = "m3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "m3", label = "Variable 3", choices = append(c("None"), var3list(mealprepvars)[!(var3list(mealprepvars) %in% c(input$m1, input$m2))]))
    } 
  })
  output$fo2 <- renderUI({
    selectizeInput(inputId = "fo2", label = "Variable 2", choices = append(c("None"), importantvars))
  })
  output$fo3 <- renderUI({
    if (input$fo1 %in% catvars | input$fo2 %in% catvars | input$fo2 == "None"){
      selectizeInput(inputId = "fo3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "fo3", label = "Variable 3", choices = append(c("None"), var3list(eattypevars)[!(var3list(eattypevars) %in% c(input$fo1, input$fo2))]))
    } 
  })
  output$t2 <- renderUI({
    selectizeInput(inputId = "t2", label = "Variable 2", choices = append(c("None"), importantvars))
  })
  output$t3 <- renderUI({
    if (input$t1 %in% catvars | input$t2 %in% catvars | input$t2 == "None"){
      selectizeInput(inputId = "t3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "t3", label = "Variable 3", choices = append(c("None"), var3list(timeeatvars)[!(var3list(timeeatvars) %in% c(input$t1, input$t2))]))
    } 
  })
  output$i2 <- renderUI({
    selectizeInput(inputId = "i2", label = "Variable 2", choices = append(c("None"), col_names[!(col_names %in% c(input$i1))]), selected = "wgt")
  })
  output$i3 <- renderUI({
    if (input$i1 %in% catvars | input$i2 %in% catvars | input$i2 == "None"){
      selectizeInput(inputId = "i3", label = "Variable 3", choices = c("None"))
    } else{
      selectizeInput(inputId = "i3", label = "Variable 3", choices = append(c("None"), col_names[!(col_names %in% c(input$i1, input$i2))][!(col_names[!(col_names %in% c(input$i1, input$i2))] %in% contvars)]))
    } 
  })

  
  
  
  
  output$h4 <- renderUI({
    selectizeInput(inputId = "h4", label = "Plot Type", choices = assignplot(input$h1, input$h2, input$h3))
  })
  output$hv1 <- renderText({
    as.character(datadic[datadic$var == input$h1,][2][[1]])
  })
  output$hv2 <- renderText({
    as.character(datadic[datadic$var == input$h2,][2][[1]])
  })
  output$hv3 <- renderText({
    if(input$h3 == "None"){ return()}
    as.character(datadic[datadic$var == input$h3,][2][[1]])
  })
  output$hv4 <- renderText({
    if (input$h1 %in% contvars){
      paste("average", input$h1, ":", round(mean(ehresp[[input$h1]], na.rm = TRUE)),
            "\nmedian", input$h1, ":", round(median(ehresp[[input$h1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$h1, ":", perc(input$h1), collapse = " ")
    }
  })
  output$hv5 <- renderText({
    if (input$h2 == "None"){
      return()
    } else if (input$h2 %in% contvars){
      paste("average", input$h2, ":", round(mean(ehresp[[input$h2]], na.rm = TRUE)),
            "\nmedian", input$h2, ":", round(median(ehresp[[input$h2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$h2, ":", perc(input$h2), collapse = " ")
    }
  })
  output$hv6 <- renderText({
    if (input$h3 == "None"){
      return()
    } else if (input$h3 %in% contvars){
      paste("average", input$h3, ":", round(mean(ehresp[[input$h3]], na.rm = TRUE)),
            "\nmedian", input$h3, ":", round(median(ehresp[[input$h3]], na.rm = TRUE)),collapse = " ")
    } else {
      paste(input$h3, ":", perc(input$h3), collapse = " ")
    }
  })
  output$f4 <- renderUI({
    selectizeInput(inputId = "f4", label = "Plot Type", choices = assignplot(input$f1, input$f2, input$f3))
  })
  output$fv1 <- renderText({
    as.character(datadic[datadic$var == input$f1,][2][[1]])
  })
  output$fv2 <- renderText({
    as.character(datadic[datadic$var == input$f2,][2][[1]])
  })
  output$fv3 <- renderText({
    if(input$f3 == "None"){ return()}
    as.character(datadic[datadic$var == input$f3,][2][[1]])
  })
  output$fv4 <- renderText({
    if (input$f1 %in% contvars){
      paste("average", input$f1, ":", round(mean(ehresp[[input$f1]], na.rm = TRUE)),
            "\nmedian", input$f1, ":", round(median(ehresp[[input$f1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$f1, ":", perc(input$f1), collapse = " ")
    }
  })
  output$fv5 <- renderText({
    if (input$f2 == "None"){
      return()
    } else if (input$f2 %in% contvars){
      paste("average", input$f2, ":", round(mean(ehresp[[input$f2]], na.rm = TRUE)),
            "\nmedian", input$f2, ":", round(median(ehresp[[input$f2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$f2, ":", perc(input$f2), collapse = " ")
    }
  })
  output$fv6 <- renderText({
    if (input$f3 == "None"){
      return()
    } else if (input$f3 %in% contvars){
      paste("average", input$f3, ":", round(mean(ehresp[[input$f3]], na.rm = TRUE)),
            "\nmedian", input$f3, ":", round(median(ehresp[[input$f3]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$f3, ":", perc(input$f3), collapse = " ")
    }
  })
  output$e4 <- renderUI({
    selectizeInput(inputId = "e4", label = "Plot Type", choices = assignplot(input$e1, input$e2, input$e3))
  })
  output$ev1 <- renderText({
    as.character(datadic[datadic$var == input$e1,][2][[1]])
  })
  output$ev2 <- renderText({
    as.character(datadic[datadic$var == input$e2,][2][[1]])
  })
  output$ev3 <- renderText({
    if(input$e3 == "None"){ return()}
    as.character(datadic[datadic$var == input$e3,][2][[1]])
  })
  output$ev4 <- renderText({
    if (input$e1 %in% contvars){
      paste("average", input$e1, ":", round(mean(ehresp[[input$e1]], na.rm = TRUE)),
            "\nmedian", input$e1, ":", round(median(ehresp[[input$e1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$e1, ":", perc(input$e1), collapse = " ")
    }
  })
  output$ev5 <- renderText({
    if (input$e2 == "None"){
      return()
    } else if (input$e2 %in% contvars){
      paste("average", input$e2, ":", round(mean(ehresp[[input$e2]], na.rm = TRUE)),
            "\nmedian", input$e2, ":", round(median(ehresp[[input$e2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$e2, ":", perc(input$e2), collapse = " ")
    }
  })
  output$ev6 <- renderText({
    if (input$e3 == "None"){
      return()
    } else if (input$e3 %in% contvars){
      paste("average", input$e3, ":", round(mean(ehresp[[input$e3]], na.rm = TRUE)),
            "\nmedian", input$e3, ":", round(median(ehresp[[input$e3]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$e3, ":", perc(input$e3), collapse = " ")
    }
  })
  output$m4 <- renderUI({
    selectizeInput(inputId = "m4", label = "Plot Type", choices = assignplot(input$m1, input$m2, input$m3))
  })
  output$mv1 <- renderText({
    as.character(datadic[datadic$var == input$m1,][2][[1]])
  })
  output$mv2 <- renderText({
    as.character(datadic[datadic$var == input$m2,][2][[1]])
  })
  output$mv3 <- renderText({
    if(input$m3 == "None"){ return()}
    as.character(datadic[datadic$var == input$m3,][2][[1]])
  })
  output$mv4 <- renderText({
    if (input$m1 %in% contvars){
      paste("average", input$m1, ":", round(mean(ehresp[[input$m1]], na.rm = TRUE)),
            "\nmedian", input$m1, ":", round(median(ehresp[[input$m1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$m1, ":", perc(input$m1), collapse = " ")
    }
  })
  output$mv5 <- renderText({
    if (input$m2 == "None"){
      return()
    } else if (input$m2 %in% contvars){
      paste("average", input$m2, ":", round(mean(ehresp[[input$m2]], na.rm = TRUE)),
            "\nmedian", input$m2, ":", round(median(ehresp[[input$m2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$m2, ":", perc(input$m2), collapse = " ")
    }
  })
  output$mv6 <- renderText({
    if (input$m3 == "None"){
      return()
    } else if (input$m3 %in% contvars){
      paste("average", input$m3, ":", round(mean(ehresp[[input$m3]], na.rm = TRUE)),
            "\nmedian", input$m3, ":", round(median(ehresp[[input$m3]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$m3, ":", perc(input$m3), collapse = " ")
    }
  })
  output$fo4 <- renderUI({
    selectizeInput(inputId = "fo4", label = "Plot Type", choices = assignplot(input$fo1, input$fo2, input$fo3))
  })
  output$fov1 <- renderText({
    as.character(datadic[datadic$var == input$fo1,][2][[1]])
  })
  output$fov2 <- renderText({
    as.character(datadic[datadic$var == input$fo2,][2][[1]])
  })
  output$fov3 <- renderText({
    if(input$fo3 == "None"){ return()}
    as.character(datadic[datadic$var == input$fo3,][2][[1]])
  })
  output$fov4 <- renderText({
    if (input$fo1 %in% contvars){
      paste("average", input$fo1, ":", round(mean(ehresp[[input$fo1]], na.rm = TRUE)),
            "\nmedian", input$fo1, ":", round(median(ehresp[[input$fo1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$fo1, ":", perc(input$fo1), collapse = " ")
    }
  })
  output$fov5 <- renderText({
    if (input$fo2 == "None"){
      return()
    } else if (input$fo2 %in% contvars){
      paste("average", input$fo2, ":", round(mean(ehresp[[input$fo2]], na.rm = TRUE)),
            "\nmedian", input$fo2, ":", round(median(ehresp[[input$fo2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$fo2, ":", perc(input$fo2), collapse = " ")
    }
  })
  output$fov6 <- renderText({
    if (input$fo3 == "None"){
      return()
    } else if (input$fo3 %in% contvars){
      paste("average", input$fo3, ":", round(mean(ehresp[[input$fo3]], na.rm = TRUE)),
            "\nmedian", input$fo3, ":", round(median(ehresp[[input$fo3]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$fo3, ":", perc(input$fo3), collapse = " ")
    }
  })
  output$t4 <- renderUI({
    selectizeInput(inputId = "t4", label = "Plot Type", choices = assignplot(input$t1, input$t2, input$t3))
  })
  output$tv1 <- renderText({
    as.character(datadic[datadic$var == input$t1,][2][[1]])
  })
  output$tv2 <- renderText({
    as.character(datadic[datadic$var == input$t2,][2][[1]])
  })
  output$tv3 <- renderText({
    if(input$t3 == "None"){ return()}
    as.character(datadic[datadic$var == input$t3,][2][[1]])
  })
  output$tv4 <- renderText({
    if (input$t1 %in% contvars){
      paste("average", input$t1, ":", round(mean(ehresp[[input$t1]], na.rm = TRUE)),
            "\nmedian", input$t1, ":", round(median(ehresp[[input$t1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$t1, ":", perc(input$t1), collapse = " ")
    }
  })
  output$tv5 <- renderText({
    if (input$t2 == "None"){
      return()
    } else if (input$t2 %in% contvars){
      paste("average", input$t2, ":", round(mean(ehresp[[input$t2]], na.rm = TRUE)),
            "\nmedian", input$t2, ":", round(median(ehresp[[input$t2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$t2, ":", perc(input$t2), collapse = " ")
    }
  })
  output$tv6 <- renderText({
    if (input$t3 == "None"){
      return()
    } else if (input$t3 %in% contvars){
      paste("average", input$t3, ":", round(mean(ehresp[[input$t3]], na.rm = TRUE)),
            "\nmedian", input$t3, ":", round(median(ehresp[[input$t3]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$t3, ":", perc(input$t3), collapse = " ")
    }
  })
  output$i4 <- renderUI({
    selectizeInput(inputId = "i4", label = "Plot Type", choices = assignplot(input$i1, input$i2, input$i3))
  })
  output$iv1 <- renderText({
    as.character(datadic[datadic$var == input$i1,][2][[1]])
  })
  output$iv2 <- renderText({
    as.character(datadic[datadic$var == input$i2,][2][[1]])
  })
  output$iv3 <- renderText({
    if(input$i3 == "None"){ return()}
    as.character(datadic[datadic$var == input$i3,][2][[1]])
  })
  output$iv4 <- renderText({
    if (input$i1 %in% contvars){
      paste("average",input$i1, ":", round(mean(ehresp[[input$i1]], na.rm = TRUE)),
            "\nmedian", input$i1, ":", round(median(ehresp[[input$i1]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$i1, ":", perc(input$i1), collapse = " ")
    }
  })
  output$iv5 <- renderText({
    if (input$i2 == "None"){
      return()
    } else if (input$i2 %in% contvars){
      paste("average", input$i2, ":", round(mean(ehresp[[input$i2]], na.rm = TRUE)),
            "\nmedian", input$i2, ":", round(median(ehresp[[input$i2]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$i2, ":", perc(input$i2), collapse = " ")
    }
  })
  output$iv6 <- renderText({
    if (input$i3 == "None"){
      return()
    } else if (input$i3 %in% contvars){
      paste("average", input$i3, ":", round(mean(ehresp[[input$i3]], na.rm = TRUE)),
            "\nmedian", input$i3, ":", round(median(ehresp[[input$i3]], na.rm = TRUE)), collapse = " ")
    } else {
      paste(input$i3, ":", perc(input$i3), collapse = " ")
    }
  })
# appendix
  output$dict <- renderDataTable(
    datadic
  )

})
