library(shiny)
library(shinysky)

fluidPage(
  titlePanel("Onco/Tumor Supressor Gene Database"),
  sidebarPanel(
    helpText('This app shows you the number of mutations, corresponding cancer types and mutations types by gene. There are over 27,000 genes in this dataset. Click the "Gene Map" tab for a visual representation of the gene and its mutations. The location of each mutation refers to its location on cDNA.'),
    #textInput.typeahead(
      #id="thti"
      #,placeholder="type a gene"
      #,local= data.frame(unique(mutations$GENE_NAME))
      #,valueKey = unique(mutations$GENE_NAME)
      #,tokens=c(1:length(unique(mutations$GENE_NAME)))
     # ,template = HTML("<p class='repo-language'>{{info}}</p> <p class='repo-name'>{{name}}</p> <p class='repo-description'>You need to learn more CSS to customize this further</p>")
    #),
    textInput(inputId = "gene",label = "Enter a Gene Name"),
    selectizeInput(inputId = "NT", label = "Select Mutation Type for the Gene Map", 
    choices = c("NT_Change", "Deletion", "Insertion"))),
  mainPanel(
    tabsetPanel(type = "tabs",
                tabPanel("Cancer Mutations", plotOutput("plot")),
                tabPanel("Gene Map", plotOutput("new"),
                textOutput("text1")),
                tabPanel("DNA Repair Mechanisms", img(src="DNA_Repair.png")),
                tabPanel("About the Author", img(src="handsome_man.jpg", height = 500, width = 500),
                         textOutput("Author"))
             
)))