
shinyServer(function(input, output){
    output$map <- renderPlot({
        ggplot(result, aes(x=long, y=lat, group=group, fill=logloans)) +
            geom_polygon() + scale_fill_gradient(low = "yellow", high = "blue")+ #+coord_equal(ratio=3)
            coord_fixed()
    })
    
    output$grades <- renderPlot({
        ggplot(u, aes(addr_state, fill = grade))+ geom_bar()
    })

    output$correls <- renderPlot({
        corrplot(m, method="ellipse", type = 'upper',mar=c(2,1,5,1))
    })
    
    output$rates <- renderPlot({
        ggplot(pctstgryr[pctstgryr$issue_d == as.character(input$slider1),], aes(x = addr_state, y = ir, color=grade)) + 
              geom_point(aes(fill = grade, size=3)) + scale_size(guide = 'none') +
              coord_cartesian(ylim = c(6, 23))
    })
    
    # show data using DataTable
    output$table <- DT::renderDataTable({
          datatable(pctstgr, rownames=FALSE) %>%
            formatStyle(input$selected, background="skyblue", fontWeight='bold')
    })
  
})