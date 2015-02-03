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
        library(rCharts),
        library(zoo),
        library(timeDate),
        library(forecast),
        library(knitr),
        library(rmarkdown)))


options(RCHART_WIDTH = 500)

#source("data.R")

shinyServer(function(input, output, session) {
        
############################### ~~~~~~~~1~~~~~~~~ ##############################
        
## NAVTAB 1 - Interactive Chart

## Tabset 1

## Interactive plot creation
        interactivePlotInput <- function() {
                h1 <- hPlot(x = "Date",
                            y= "",
                        data = tos,
                        type = "line")
        }

        output$interactivePlot <- renderChart2({
        
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
                
                                interactivePlotInput()
                
                        # Pause for 0.1 seconds to simulate a long computation.
                        Sys.sleep(0.1)
                }
        
        })

## Tabset 2

## Boxplot plot creation
        boxPlotInput <- function() {
                boxplot(tos[2:6],
                        main= "Time on Site per User",
                        ylab= "Time on Site in seconds",
                        col = c("chartreuse4", "yellow", "cadetblue3", "red", "cadetblue1"))
        }

        output$boxPlot <- renderPlot({
                boxPlotInput()
        })
        
        
        
############################### ~~~~~~~~2~~~~~~~~ ##############################
        
## NAVTAB 2 - Forecasting

## Getting data
getDataset2 <- reactive({
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
               "ETS" = ets(getDataset2()),
               "ARIMA" = auto.arima(getDataset2()),
               "TBATS" = tbats(getDataset2(), use.parallel=TRUE),
               "StructTS" = StructTS(getDataset2(), "level"),
               "Holt-Winters" = HoltWinters(getDataset2(), gamma=FALSE),
               "Theta" = thetaf(getDataset2()),
               "Random Walk" = rwf(getDataset2()),
               "Naive" = naive(getDataset2()),
               "Mean" = meanf(getDataset2()),
               "Cubic Spline" = splinef(getDataset2()))
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