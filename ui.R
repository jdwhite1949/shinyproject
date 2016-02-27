library(shiny)
# Define UI for application that acquires Federal Reserve data, presents data 
shinyUI(fluidPage(
    
    # Application title
    titlePanel(
        tags$div(style="margin-left:20px;", 
        tags$h3("Selected Federal Reserve Economic Indicators with Predictions"))),
    
    sidebarLayout(position="left",    
    
    # Sidebar with input objects
    sidebarPanel(
            p("Documentation / Instructions", style="font-size: 10pt; font-weight:bold; 
              color:blue; text-align:left"),
            p("This application downloads economic indicator data from the St. Louis 
              Federal Reserve via their API based on your selection in the drop down 
              tool below.", style="font-size: 10pt"),
            p("The range of the data is the past 10 years / monthly values.", 
              style="font-size: 10pt"), 
            p("Predictions (calculations) are made for the upcoming 12 months and 
              displayed within the chart and the data table on the left.", 
              style="font-size: 10pt"),
            p("Select Fed Indicator from drop down box and click Submit Button:", 
                style="font-size: 10pt; font-weight:bold; color:green; text-align:center"),
            uiOutput("choose_fred_id"),
            actionButton("goButton", "Submit"),
            br(), br(),
            p("Depending upon download speed, the chart and table may take a moment to appear",
                style="font-size: 10pt; font-weight:bold; color:blue; text-align:left"),
            span(textOutput("text2"), style="font-size:10pt; color:green;"),
            width = 3
        ),

    mainPanel(
            span(textOutput("text3"), align="left", style="font-size:12; 
                 font-weight:bold;"),
            plotOutput("plot1"),
            div(span(strong(textOutput("text1")), align="center",
                     style="font-size:12; color:green;")),
            div(tableOutput("table1"), align="center", style="font-size:10;")
        )
    )
))