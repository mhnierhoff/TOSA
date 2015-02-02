################# ~~~~~~~~~~~~~~~~~ ######## ~~~~~~~~~~~~~~~~~ #################
##                                                                            ##
##                            Time on Site Analysis                           ##
##                                                                            ##            
##                    App & Code by Maximilian H. Nierhoff                    ##
##                                                                            ##
##                           http://nierhoff.info                             ##
##                                                                            ##
##         Live version of this app: https://nierhoff.shinyapps.io/TOSA       ##
##                                                                            ##
##         Github Repo for this app: https://github.com/mhnierhoff/TOSA       ##
##                                                                            ##
################# ~~~~~~~~~~~~~~~~~ ######## ~~~~~~~~~~~~~~~~~ #################

suppressPackageStartupMessages(c(
        library(shiny),
        library(shinyIncubator),
        library(zoo),
        library(timeDate),
        library(forecast),
        library(knitr),
        library(rmarkdown)))



source("data.R")

shinyServer(function(input, output, session) {
        
############################### ~~~~~~~~1~~~~~~~~ ##############################
        
## NAVTAB 1 - Interactive Chart
        
        
        
        
############################### ~~~~~~~~2~~~~~~~~ ##############################
        
## NAVTAB 2 - Forecasting

## Getting data
getDataset <- reactive({
        switch(input$fcpage,
               "Greenpeace" = tosa[,2],
               "Amnesty International" = tosa[,3],
               "PETA" = tosa[,4],
               "RedCross" = tosa[,5],
               "Unicef" = tosa[,6])
        
})


## Creation of the Forecasting models
getModel <- reactive({
        switch(input$model,
               "ETS" = ets(getDataset()),
               "ARIMA" = auto.arima(getDataset()),
               "TBATS" = tbats(getDataset(), use.parallel=TRUE),
               "StructTS" = StructTS(getDataset(), "level"),
               "Holt-Winters" = HoltWinters(getDataset(), gamma=FALSE),
               "Theta" = thetaf(getDataset()),
               "Random Walk" = rwf(getDataset()),
               "Naive" = naive(getDataset()),
               "Mean" = meanf(getDataset()),
               "Cubic Spline" = splinef(getDataset()))
})

## Caption creation
output$forecastCaption <- renderText({
        paste("The time on site per user of", input$fcpage, "with the", 
              input$model, "Forecasting model.")
})

## Model plot creation
forecastPlotInput <- function() {
        x <- forecast(getModel(), h=input$ahead)
        
        plot(x, flty = 3, axes = FALSE)
        a <- seq(as.Date(tos$Date, format = "%d.%m.%y")[1] + 1, 
                 by = "months", length = length(date) + 11)
        axis(1, at = as.numeric(a)/365.3 + 1970, 
             labels = format(a, format = "%d/%m/%Y"), 
             cex.axis = 0.9)
        axis(2, cex.axis = 0.9, las = 2)
}


output$forecastPlot <- renderPlot({
        
        ##########    Adding a progress bar  ##########
        
        ## Create a Progress object
        
        progress <- shiny::Progress$new()
        
        on.exit(progress$close())
        
        progress$set(message = "Creating Plot", value = 0)
        
        n <- 10
        
        for (i in 1:n) {
                # Each time through the loop, add another row of data.
                # This is a stand-in for a long-running computation.
                
                # Increment the progress bar, and update the detail text.
                progress$inc(1/n, detail = paste("Doing part", i))
                
                forecastPlotInput()
                
                # Pause for 0.1 seconds to simulate a long computation.
                Sys.sleep(0.1)
        }
        
})
        
############################### ~~~~~~~~3~~~~~~~~ ##############################
        
## NAVTAB 3 - Anomaly Detection
        
        
############################### ~~~~~~~~4~~~~~~~~ ##############################
        
## NAVTAB 4 - Decomposition
        
        
})