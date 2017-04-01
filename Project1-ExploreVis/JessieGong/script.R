library(dplyr)
library(ggplot2)

test=read.csv("Medicare_Provider_Charge_Inpatient_DRGALL_FY2014.csv")

DRG = test$DRG.Definition %>% unique(incomparables = T)


#boxplot


cols.dont.want <- "count"

tt=in_2014[, ! names(in_2014) %in% cols.dont.want, drop = F]



in_total_all=in_total %>% group_by(Provider.State) %>% summarise(count=sum(Avg_c))
#Geo plot
GeoStates <- gvisGeoChart(in_total_all, locationvar = "Provider.State", colorvar = "count",
                         options=list(region="US", 
                                      displayMode="regions", 
                                      resolution="provinces",
                                      width=600, height=400))
plot(GeoStates)

in_total_DRG = in_total %>% group_by(Provider.State, GeoInput)

#table with pages
PopTable <- gvisTable(Population, 
                      formats=list(Population="#,###",
                                   '% of World Population'='#.#%'),
                      options=list(page='enable'))
plot(PopTable)





#ui
#   box(width = 6,
#       selectizeInput("select_year_2", label = h3("Choose the year..."), 
#                      choice = year, selected = "2014"),
#       selectizeInput("select_DRG_2", label = h3("Choose DRG"),
#                      choice = DRG, selected = "194 - SIMPLE PNEUMONIA & PLEURISY W CC"),
#       selectizeInput("select_hospital", label = h3("Choose the Hospital"),
#                      choice = hospital, selected = "870", multiple = TRUE,
#                      options = list(maxItems = 5))
# )
# box(width = 8, 
#     plotOutput("box_plot"),
# htmlOutput("subtable1")),




#          box(width = 4, height = 160,
#              title = "Select Year", status = "info", solidHeader = TRUE,
#              selectizeInput("select_year_2", label = h3("Choose the year..."), 
#                          choice = year, selected = "2014")),
#          
#          box(width = 4, height = 160,
#              title = "Select DRG", status = "info", solidHeader = TRUE,
#              selectizeInput("select_DRG_2", label = h3("Choose DRG"),
#                          choice = DRG, selected = "194 - SIMPLE PNEUMONIA & PLEURISY W CC")),
# 
#          box(width = 4, height = 160,
#              title = "Select Hospital", status = "info", solidHeader = TRUE,
#              selectizeInput("select_hospital", label = h3("Choose the Hospital"),
#                          choice = hospital, selected = "870", multiple = TRUE,
#                          options = list(maxItems = 5)))),
# 
# # Row 2, box plot charges/payments comparison
# fluidRow(
#          box(width = 12,
#              plotOutput("box_plot")),
#              uiOutput('subtable1')




# output$box_plot = renderPlot({
#   boxplot_tbl() %>%
#     select(Provider.Name, Average.Covered.Charges, Average.Medicare.Payments) %>%
#     tidyr::gather(type, value, -Provider.Name) %>%
#   ggplot(aes(x = factor(Provider.Name), y = value, fill = type)) +
#     geom_col(position = "dodge")
# })

# output$box_plot = renderGvis({
#   
#   # boxplot_tbl() %>%
#     # select(Provider.Name, Average.Covered.Charges, Average.Medicare.Payments) %>%
#     # tidyr::gather(type, value, -Provider.Name) %>%
#   gvisColumnChart(
#     # data = in_total_hospital %>% filter(DRG.Definition == input$select_DRG_2 & 
#     #                 year == input$select_year_2 &
#     #                 Provider.Name %in% input$select_hospital),
#     in_total_hospital,
#     xvar = "Provider.Name",
#     yvar = "Average.Covered.Charges"
#       # c("Average.Covered.Charges",
#       #   "Average.Medicare.Payments")
#     )
#   })
