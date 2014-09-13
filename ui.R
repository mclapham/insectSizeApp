library(shiny)

# Define UI for dataset viewer application
shinyUI(fluidPage(
  
  # Application title.
  headerPanel(img(src="insectSize_logo.png",width=800),windowTitle="Insect size"),
  
  sidebarLayout(
    sidebarPanel(
      h5("Initial file loads automatically but requires a few seconds. Only press submit after changing settings."),
      
      textInput("taxon", h4("Filter by taxon name:"),"Insecta"),
      
      radioButtons("bodypart", label = h4("Body part"),
                   choices = list("Wing" = "Wing", "Body" = "Body"),selected = "Wing"),
    
      helpText("Wing element includes wing, forewing, hindwing, elytron, tegmen, and hemelytron"),
    
      selectInput("preservation", label = h4("Select preservation mode"), 
                choices = list("All" = "All", "Amber" = "Amber","Rock" = "Rock"), selected = "All"),
      
      radioButtons("logaxis",label=h4("Log or linear y-axis"),
                   choices = list("Log" = "Log", "Linear" = "Linear"),selected = "Log"),
      
      submitButton("Submit"),
      
      h5("If you use this information in a publication, please acknowledge the Paleobiology Database"),
      
      h5("Comments or suggestions? Email mclapham@ucsc.edu"),
      
      a("https://github.com/mclapham/insectSizeApp")
    ),

    mainPanel(
      
      h4("Compression (rock) fossils as gray symbols; amber fossils as orange symbols"),
      
      plotOutput("plot"),
      
      downloadButton("downloadData", "Download measurements")
        
        )
    )
  )
)
