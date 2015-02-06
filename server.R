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
        library(shinythemes),
        library(lubridate),
        library(zoo),
        library(timeDate),
        library(forecast),
        library(knitr),
        library(reshape),
        library(DT),
        library(RColorBrewer),
        library(googleVis),
        library(BreakoutDetection),
        library(rmarkdown)))


source("data.R")

shinyServer(function(input, output, session) {
        
############################### ~~~~~~~~1~~~~~~~~ ##############################
        
## NAVTAB 1 - EDA

getDataset1 <- reactive({
        switch(input$tabOne,
               "Greenpeace" = tosa[,2],
               "Amnesty International" = tosa[,3],
               "PETA" = tosa[,4],
               "RedCross" = tosa[,5],
               "Unicef" = tosa[,6])
})

## Tabset 1

## Line chart function

        linePlotInput <- function() {
                plot.ts(getDataset1(), 
                     axes = FALSE, 
                     type = "l",
                     col = "darkblue",
                     lwd = "1.5",
                     main = input$tabOne,
                     ylab = "Time on Site in seconds")
                a <- seq(as.Date(tos$Date, format = "%d.%m.%y")[1] - 1, 
                         by = "months", length = length(date) + 11)
                axis(1, at = as.numeric(a)/365.3 + 1970, 
                     labels = format(a, format = "%d.%m.%Y"), cex.axis = 0.9)
                axis(2, cex.axis = 0.9, las = 2)
                box()
                             
        }

        output$linePlot <- renderPlot({
                
                ## Adding a progress bar 
                
                ## Create a Progress object
                
                progress <- shiny::Progress$new()
                
                on.exit(progress$close())
                
                progress$set(message = "Creating Plot", value = 0)
                
                n <- 5
                
                for (i in 1:n) {
                        # Each time through the loop, add another row of data.
                        # This is a stand-in for a long-running computation.
                        
                        # Increment the progress bar, and update the detail text.
                        progress$inc(1/n, detail = paste("Doing part", i))
                        
                        linePlotInput()
                        
                        # Pause for 0.1 seconds to simulate a long computation.
                        Sys.sleep(0.1)
                }
        })


        clinePlotInput <- function() {
                mpdf <- data.frame(tos[2:6])
                colnames(mpdf) <- c("Greenpeace", "Amnesty", 
                                    "PETA", "RedCross", "Unicef")
                legNames <- names(mpdf)
                customCol <- brewer.pal(n = 5, name = "Dark2")
                matplot(mpdf, 
                        type = "l",
                        lty = 1,
                        lwd = 2,
                        main = "All websites in comparison",
                        ylab = "Time on Site in seconds",
                        col = customCol,
                        xaxt = "n")
                legend("topleft", legNames, lty = 0,text.col = customCol)
        }

        output$clinePlot <- renderPlot({
                clinePlotInput()
        })

## Tabset 2

## Boxplot plot function

        boxPlotInput <- function() {
                boxplot(getDataset1(),
                        main = input$tabOne,
                        ylab = "Time on Site in seconds",
                        col = "mintcream")
        }

        ## Caption function
        output$boxPlotCaption <- renderText({
                paste("The time on site per user of the", 
                      input$tabOne, "website.",
                      "The median for this website is at", 
                      median(getDataset1()), "seconds.")
        })

        output$boxPlot <- renderPlot({
                boxPlotInput()
        })

        output$cboxPlot <- renderPlot({
                customCol <- brewer.pal(n = 5, name = "Dark2")
                bpdf <- tos[2:6]
                colnames(bpdf) <- c("Greenpeace", "Amnesty", 
                                    "PETA", "RedCross", "Unicef")
                boxplot(bpdf,
                        main = "All websites in comparison",
                        ylab = "Time on Site in seconds",
                        col = customCol)
        })
        
## Tabset 3

## Histogram function

        histPlotInput <- function() {
                
                histogramPlot <- hist(getDataset1())
                multiplier <- histogramPlot$counts / histogramPlot$density
                mydensity <- density(getDataset1())
                mydensity$y <- mydensity$y * multiplier[1]
                
                plot(histogramPlot, 
                     main = input$tabOne,
                     xlab = "Time on Site in seconds",
                     col = "mintcream")
                box()
                lines(mydensity)
                
                myx <- seq(min(getDataset1()), max(getDataset1()), 
                           length.out= 100)
                mymean <- mean(getDataset1())
                mysd <- sd(getDataset1())
                
                normal <- dnorm(x = myx, mean = mymean, sd = mysd)
                lines(myx, normal * multiplier[1], 
                      col = "midnightblue", lwd = 2)
                
                sd_x <- seq(mymean - 3 * mysd, mymean + 3 * mysd, by = mysd)
                sd_y <- dnorm(x = sd_x, mean = mymean, 
                              sd = mysd) * multiplier[1]
                
                segments(x0 = sd_x, y0= 0, x1 = sd_x, y1 = sd_y, 
                         col = "firebrick4", lwd = 2)
        }
                
        ## Caption function
        output$histPlotCaption <- renderText({
                paste("The time on site histogram for the", 
                input$tabOne, "website.",
                "The mean for this website is at", 
                round(mean(getDataset1()), digits = 2),
                "seconds and the standard deviation is",
                round(sd(getDataset1()), digits = 2),".")
        })
        
        output$histPlot <- renderPlot({
                histPlotInput()
        })

## Tabset 4

## Generate an HTML table view of the data

        output$dataTable <- renderDataTable({
                datatable(tos)
        })
                  
############################### ~~~~~~~~2~~~~~~~~ ##############################
        
## NAVTAB 2 - Forecasting

## Getting data
getDataset2 <- reactive({
        switch(input$tabTwo,
               "Greenpeace" = tosa[,2],
               "Amnesty International" = tosa[,3],
               "PETA" = tosa[,4],
               "RedCross" = tosa[,5],
               "Unicef" = tosa[,6])
        
})


## function of the Forecasting models
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

## Caption function
output$forecastCaption <- renderText({
        paste("The time on site per user of", input$tabTwo, "with the", 
              input$model, "Forecasting model.")
})

## Forecast model plot function
forecastPlotInput <- function() {
        x <- forecast(getModel(), h=input$ahead)
        
        plot(x, flty = 3, axes = FALSE)
        a <- seq(as.Date(tos$Date, format = "%d.%m.%y")[1] - 1, 
                 by = "months", length = length(date) + 11)
        axis(1, at = as.numeric(a)/365.3 + 1970, 
             labels = format(a, format = "%d/%m/%Y"), 
             cex.axis = 0.9)
        axis(2, cex.axis = 0.9, las = 2)
        box()
}


output$forecastPlot <- renderPlot({
        
## Adding a progress bar 
        
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
        
## NAVTAB 3 - Breakout Detection
        
## Getting data
getDataset3 <- reactive({
        switch(input$tabThree,
               "Greenpeace" = tosa[,2],
               "Amnesty International" = tosa[,3],
               "PETA" = tosa[,4],
               "RedCross" = tosa[,5],
               "Unicef" = tosa[,6])
        
        })

        ## Breakout detection function 
        adPlotInput <- function() {
                tos$Date <- as.Date(tos$Date, format = "%d.%m.%y")
                tos$Date <- as.POSIXlt(tos$Date)
                adDF <- data.frame(tos$Date, getDataset3())
                
                names(adDF)[1] <- paste("timestamp")
                names(adDF)[2] <- paste("count")
                
                res <- breakout(adDF, 
                         min.size=24, 
                         method = "multi", 
                         beta =0.001, 
                         degree=1, 
                         plot = TRUE, 
                         title = input$tabThree, 
                         xlab = "Time", 
                         ylab = "Time on Site in seconds")
                res$plot

        }

        ## Caption function
        breakoutCaptionInput <- function() {
                tos$Date <- as.Date(tos$Date, format = "%d.%m.%y")
                tos$Date <- as.POSIXlt(tos$Date)
                adDF <- data.frame(tos$Date, getDataset3())
                
                names(adDF)[1] <- paste("timestamp")
                names(adDF)[2] <- paste("count")
                
                res <- breakout(adDF, 
                                min.size=24, 
                                method = "multi", 
                                beta =0.001, 
                                degree=1, 
                                plot = F, 
                                title = input$tabThree, 
                                xlab = "Time", 
                                ylab = "Time on Site in seconds")
                
                bod <- res$loc[ ]
                dbod <- adDF$timestamp[bod]
                dbod <- as.character(dbod)
                dbod <- paste(dbod[], sep="", collapse=" , ")
                
        }
        
        output$breakoutCaptionT <- renderText({
                paste("Detected breakouts for the", input$tabThree, 
                      "website:")
                })

        output$breakoutCaptionV <- renderText({
                 breakoutCaptionInput()
                  
                })

        ## Printing the plot

        output$adPlot <- renderPlot({
                adPlotInput()
        })

        
############################### ~~~~~~~~4~~~~~~~~ ##############################
        
## NAVTAB 4 - Decomposition

## Getting data
getDataset4 <- reactive({
        switch(input$tabFour,
               "Greenpeace" = tosa[,2],
               "Amnesty International" = tosa[,3],
               "PETA" = tosa[,4],
               "RedCross" = tosa[,5],
               "Unicef" = tosa[,6])
        
})

## Tabset 1

## Normal Timeseries Decomposition Plot    

        plotNdcomp <- function() {
                ds_ts <- ts(getDataset4(), frequency=12)
                Ndcomp <- decompose(ds_ts)
                plot(Ndcomp)
        }

        ## Normal TS DC Plot Caption

        output$NTScaption <- renderText({
                paste("The data of the", input$tabThree, 
                      "website decomposed into seasonal, trend and irregular 
                      components using moving averages.")
        })

        ## Printing the plot

        output$Ndcomp <- renderPlot({
                plotNdcomp()
        })

## Tabset 2

## STL Timeseries Decomposition Plot         

        ## Plot function
        plotSTLdcomp <- function() {
                ds_ts <- ts(getDataset4(), frequency=12)
                STLdcomp <- stl(ds_ts, s.window="periodic", robust=TRUE)
                plot(STLdcomp)
        }

        ## STL Caption

        output$STLcaption <- renderText({
                paste("The data of the", input$tabThree, 
                      "website decomposed into seasonal, trend and irregular 
                      components using loess (acronym STL).")
        })

        ## Printing the plot

        output$STLdcomp <- renderPlot({
                plotSTLdcomp()
        })

############################### ~~~~~~~~5~~~~~~~~ ##############################

## NAVTAB 5 - Calendar View

## Getting data

getDataset5 <- reactive({
        switch(input$tabFive,
               "Greenpeace" = tos[,2],
               "Amnesty International" = tos[,3],
               "PETA" = tos[,4],
               "RedCross" = tos[,5],
               "Unicef" = tos[,6])
        
})

## Calendar plot function

calendarPlotInput <- function() {
        Date <- as.Date(tos$Date, format = "%d.%m.%y")
        Date <- as.POSIXlt(Date)
        calDF <- data.frame(Date, getDataset5())
        names(calDF)[2] <- paste("Values")
        
        gvisCalendar(calDF, 
                            datevar ="Date", 
                            numvar = "Values",
                            options =list(
                                    title = input$tabFive,
                                    height = 350,
                                    calendar = "{yearLabel: { fontName: 'Times-Roman',
                                    fontSize: 32, color: '#1EB18A', bold: true},
                                    cellSize: 10,
                                    cellColor: { stroke: 'grey', strokeOpacity: 0.2 },
                                    focusedCellColor: {stroke:'red'}}")
                            )
}

output$calendarPlot <- renderGvis({
        
        calendarPlotInput()      
})

############################### ~~~~~~~~F~~~~~~~~ ##############################

## Footer

output$dataPeriodCaption <- renderText({
        paste("Data period from", 
              head(tos[,1], n = 1), "to",
              tail(tos[,1], n = 1),".")
        })

})