suppressMessages(library(shiny))
suppressMessages(library(curl))
suppressMessages(library(XML))
suppressMessages(library(httr))
suppressMessages(library(forecast))

options(stringsAsFactors = FALSE)

FedId <- read.csv("FREDID.csv", header = TRUE)
fred.choices <- as.list(FedId$selBoxValue)

# assign api key to variable
api.key <-  "d4f3a2d6533bd888e813ca01c9617ea9"
# assign FRED url to variable
fred.url <- "https://api.stlouisfed.org/fred/series/observations?series_id="

# Define server logic required to draw a line chart and create table data
shinyServer(function(input, output) {

    # output for dynamic drop down select box
    output$choose_fred_id <- renderUI({
        selectInput("select", NULL, fred.choices)
        })

    # get user seleclion, if made.
    forecast.data <- eventReactive(input$goButton, {
        sel <- input$select # get input and convert to series id
        selection <- FedId[which(FedId$selBoxValue==sel), 2]    
        # call function to get forecast data object for plot and table
        fdata <- get.data(selection)
        fdata
    })

    # create plot from user input
    output$plot1 <- renderPlot({
        # function call to generate data for plot        
        p.data <- forecast.data()
        # use data to create plot
        plot(p.data, main="10 Year Results & 12 Month Forecast", xlab="Years",
              ylab="Economic Indicator Units")
    })

    output$table1 <- renderTable({
        # function to generate data for table
        t.data <- forecast.data()
        get.table.data(t.data)
    })

    table.label <- eventReactive(input$goButton, {
        "Calculated Forecast Values for 12 Months into Future"
    })
    
    output$text1 <- renderText({
        table.label()
    })

    cf.message <- eventReactive(input$goButton, {
        "The Lo and Hi values for the table are for the 80% and 90% confidence intervals."
    })
    
    output$text2 <- renderText({
        cf.message()
    })
    
    units.message <- eventReactive(input$goButton, {
        units.sel <- input$select
        units.selection <- FedId[which(FedId$selBoxValue==units.sel), 3]
        table.units <- c("Units for chart and table: ", units.selection)
        table.units
    })
    
    output$text3 <- renderText({
        units.message()
    })

})

# function to create data for chart(s)
get.data <- function(id){
    # get data in XML format
    fred.data <- GET(paste0(fred.url, id, "&api_key=", api.key))
    # parse XML data
    fred.xml.doc <- xmlTreeParse(fred.data)
            
    # create empty data frame
    df <- data.frame(date=character(), value=character()) #init data frame
    # get length of data vector
    n <- xmlSize(fred.xml.doc$doc$children$observations) # init number var
            
    # xml data to data frame
    for(i in 1:n){
        obs.date <- xmlGetAttr(fred.xml.doc$doc$children$observations[[i]], "date")
        obs.value <- xmlGetAttr(fred.xml.doc$doc$children$observations[[i]], "value")
        df[i, 1] <- obs.date
        df[i, 2] <- obs.value
    }
            
    # change variable classes
    df$date <- as.Date(df$date)
    df$value <- suppressWarnings(as.numeric(df$value))
            
    # set variable to acquire date from 120 months ago to present
    n.sub <- n-120
    start.year <- as.numeric(format(df$date[n.sub], "%Y"))
    start.mon <- as.numeric(format(df$date[n.sub], "%m"))
    ts.values <- df$value[n.sub:n]
            
    # convert to time series
    data.ts <- ts(ts.values, frequency = 12, start = c(start.year, start.mon))
            
    # forecasting 12 periods into future
    data.forecast <<- forecast(data.ts, 12)
}
    
get.table.data <- function(x){
    data.capture <- capture.output(x)
    # initialize a data frame
    df1 <- data.frame(Month=character(), Forecast=numeric(), Lo_80=numeric(), 
                      Hi_80=numeric(), Lo_90=numeric(), Hi_90=numeric())
    for(i in 2:13){
        # convert string data to data frame
        obs.mon <- gsub("  ", "", substring(data.capture[i], 1, 14))
        obs.fore <- gsub(" ", "", substring(data.capture[i], 15, 23))
        obs.L80 <- gsub(" ", "", substring(data.capture[i], 24, 32))
        obs.H80 <- gsub(" ", "", substring(data.capture[i], 33, 41))
        obs.L90 <- gsub(" ", "", substring(data.capture[i], 42, 50))
        obs.H90 <- gsub(" ", "", substring(data.capture[i], 51, 59))
        df1[i-1,1] <- obs.mon
        df1[i-1,2] <- round(as.numeric(obs.fore), 3)
        df1[i-1,3] <- round(as.numeric(obs.L80), 3)
        df1[i-1,4] <- round(as.numeric(obs.H80), 3)
        df1[i-1,5] <- round(as.numeric(obs.L90), 3)
        df1[i-1,6] <- round(as.numeric(obs.H90), 3)
    }
    df1
}   
