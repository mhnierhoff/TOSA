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

shinyUI(navbarPage("Time on Site Analysis", 
                   
                   theme = shinytheme("flatly"),
                   
                   
                   
############################### ~~~~~~~~1~~~~~~~~ ##############################                   

## NAVTAB 1 - Interactive Chart

tabPanel("Overview",
         
         tags$head(includeScript("./js/ga-tosa.js")),
         
         sidebarLayout(
                 
                 sidebarPanel(
                         
                         tags$h4("Exploratory Data Analysis"),
                         tags$br(),
                         radioButtons(inputId = "tabOne",
                                      label = "Select an NPO website:",
                                      choices = c("Greenpeace",
                                                  "Amnesty International",
                                                  "PETA", "RedCross",
                                                  "Unicef"),
                                      selected = "Greenpeace"),
                         
                         width = 3),
                 
                 mainPanel(
                         
                         tabsetPanel(
                                 tabPanel("Line Chart", 
                                          plotOutput("linePlot"),
                                          tags$hr(),
                                          plotOutput("clinePlot")),
                                 
                                 tabPanel("Boxplot",
                                          plotOutput("boxPlot"),
                                          tags$div(textOutput("boxPlotCaption"), 
                                                 align = "center"),
                                          tags$hr(),
                                          plotOutput("cboxPlot")),
                                 
                                 tabPanel("Histogram",
                                          plotOutput("histPlot"),
                                          tags$div(textOutput("histPlotCaption"), 
                                                  align = "center")),
                                 
                                 tabPanel("Raw Data",
                                          tags$br(),
                                          dataTableOutput("dataTable"))
                                               
                         ),
                         width = 6)
         )
),
                   
############################### ~~~~~~~~2~~~~~~~~ ##############################

## NAVTAB 2 - Forecasting

tabPanel("Forecasting",
         
         sidebarLayout(
                 
                 sidebarPanel(
                         radioButtons(inputId = "tabTwo",
                                     label = "Select an NPO website:",
                                     choices = c("Greenpeace",
                                                 "Amnesty International",
                                                 "PETA", "RedCross",
                                                 "Unicef"),
                                     selected = "Greenpeace"),
                         
                         tags$hr(),
                         
                         selectInput(inputId = "model",
                                     label = "Select a Forecasting model:",
                                     choices = c("ARIMA", "ETS", "TBATS", 
                                                 "StructTS", "Holt-Winters", 
                                                 "Theta", "Cubic Spline",
                                                 "Random Walk", "Naive",
                                                 "Mean"),
                                     selected = "ARIMA"),
                         
                         tags$hr(),
                         
                         numericInput("ahead", "Days to forecast ahead:", 30),
                         
                         width = 3),
                 
                 mainPanel(
                         
                         plotOutput("forecastPlot"),
                         tags$strong(textOutput("forecastCaption"), 
                                     align = "center"),
                         
                         width = 6)
                 
         )
),
                   
                   
############################### ~~~~~~~~3~~~~~~~~ ##############################                   

## NAVTAB 3 - Anomaly Detection

tabPanel("Breakout Detection",
         
         sidebarLayout(
                 
                 sidebarPanel(
                         radioButtons(inputId = "tabThree",
                                      label = "Select an NPO website:",
                                      choices = c("Greenpeace",
                                                  "Amnesty International",
                                                  "PETA", "RedCross",
                                                  "Unicef"),
                                      selected = "Greenpeace"),
                         
                         width = 3),
                 
                 mainPanel(
                         
                         plotOutput("adPlot"),
                         tags$div(textOutput("breakoutCaptionT"), 
                                     align = "center"),
                         tags$div(textOutput("breakoutCaptionV"), 
                                     align = "center"),
                         
                         width = 6)
         )
),
                   
############################### ~~~~~~~~4~~~~~~~~ ##############################
                   
## NAVTAB 4 - Decomposition

tabPanel("Decomposition",
         
         sidebarLayout(
                 
                 sidebarPanel(
                         radioButtons(inputId = "tabFour",
                                      label = "Select an NPO website:",
                                      choices = c("Greenpeace",
                                                  "Amnesty International",
                                                  "PETA", "RedCross",
                                                  "Unicef"),
                                      selected = "Greenpeace"),
                         
                         width = 3),
                 
                 mainPanel(
                         
                         
                         tabsetPanel(
                                 
                                 tabPanel("Normal Timeseries Decomposition",
                                          tags$br(),
                                          plotOutput("Ndcomp"),
                                          tags$div(textOutput("NTScaption"),
                                                   align = "center")),
                                 
                                 tabPanel("STL Decomposition",
                                          tags$br(),
                                          tags$div(strong("STL Decomposition"), 
                                                   align ="center"),
                                          plotOutput("STLdcomp"),
                                          tags$div(textOutput("STLcaption"),
                                                   align = "center"))
                                 
                         ),
                         
                         width = 6)
                 
         )
         
),          

############################### ~~~~~~~~4~~~~~~~~ ##############################

## NAVTAB 5 - Calendar View

tabPanel("Calendar View",
         
         sidebarLayout(
                 
                 sidebarPanel(
                         radioButtons(inputId = "tabFive",
                                      label = "Select an NPO website:",
                                      choices = c("Greenpeace",
                                                  "Amnesty International",
                                                  "PETA", "RedCross",
                                                  "Unicef"),
                                      selected = "Greenpeace"),
                         
                         width = 3),
                 
                 mainPanel(
                         
                         htmlOutput("calendarPlot"),
                         
                         width = 6)
                 
         )
         
),

############################### ~~~~~~~~A~~~~~~~~ ##############################
                   
## About

tabPanel("About",
         fluidRow(
                 column(1,
                        p("")),
                 column(10,
                        includeMarkdown("./about/about.md")),
                 column(1,
                        p(""))
         )
),

############################### ~~~~~~~~F~~~~~~~~ ##############################
                   
## Footer
                   
tags$hr(),

tags$span(style="color:darkslategrey", 
          tags$div(textOutput("dataPeriodCaption"), 
                        align = "center")
         ),

tags$span(style="color:darkslategrey", 
          tags$div("Data source: Alexa.com | Metric: Alexa Time on Site", 
                   align="center")
        ),

tags$br(),

tags$span(style="color:grey", 
          tags$footer(("2015 - Created by"), 
                      tags$a(
                              href="http://nierhoff.info",
                              target="_blank",
                              "Maximilian H. Nierhoff."), 
                      align = "center")
          
        )
)
)