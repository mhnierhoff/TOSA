
### Last Update


```r
Sys.time()
```

```
## [1] "2015-02-07 15:37:29 CET"
```

***

### Code

The code of this application can be found in this [Github repository.][1]

***

### Data Set

The used data set was derived from an own account and own comparisons by the use of Alexa.com Competitive Intelligence metrics.

The presented plots, forecasts and calculations relate to the Alexa Time on Site metric.

Related websites:

* [Greenpeace][2]

* [Amnesty International][3]

* [PETA][4]

* [Red Cross][5]

* [Unicef][6]


***

### Notices

This application is primarily a demo to show what is possible. 

In case of any questions related to this application, feel free to write [me a mail.][7]

***

### First Tab - Overview

In simple but appropriate words:

> In statistics, exploratory data analysis (EDA) is an approach to analyzing data sets to summarize their main characteristics, often with visual methods. [(wikipedia.org)][7]

The line chart gives an first impression of the selected data set, while the boxplot shows the median, quartiles, outliers and also gives a first view on the respective distribution. Finally the histogram enables a clear presentation of the distribution of the selected data set. At least the raw data tab makes it possible to check every single value of the data set.

***

### Second Tab - Forecasting Models

#### Auto.Arima
Fit best ARIMA model to univariate time series

**Description:**

Returns best ARIMA model according to either AIC, AICc or BIC value. The function conducts a search over possible model within the order constraints provided.

***

#### ETS
Exponential smoothing state space model

**Description:**

Returns ets model applied to y.

***

#### TBATS
TBATS model (Exponential smoothing state space model with Box-Cox transformation, ARMA errors, Trend and Seasonal components)

**Description:**

Fits a TBATS model applied to y, as described in De Livera, Hyndman & Snyder (2011). Parallel processing is used by default to speed up the computations.

***

#### StructTS
Forecasting using Structural Time Series models

**Description:**


Returns forecasts and other information for univariate structural time series models.

***

#### Holt-Winters
Forecasting using Holt-Winters objects

**Description:**

Returns forecasts and other information for univariate Holt-Winters time series models.

***

#### Theta
Theta method forecast

**Description:**

Returns forecasts and prediction intervals for a theta method forecast.

***

#### Random Walk
Random Walk Forecast

**Description:**

Returns forecasts and prediction intervals for a random walk with drift model applied to x.

***

#### Naive
Naive forecasts

**Description:**

```naive()``` returns forecasts and prediction intervals for an ARIMA(0,1,0) random walk model ap- plied to x. ```snaive()``` returns forecasts and prediction intervals from an ARIMA(0,0,0)(0,1,0)m model where m is the seasonal period.

***

#### Cubic Spline
Cubic Spline Forecast

**Description:**

Returns local linear forecasts and prediction intervals using cubic smoothing splines.

***

#### Mean
Mean Forecast

**Description:**

Returns forecasts and prediction intervals for an iid model applied to x. 

***

#### References for the Forecast R package

Hyndman RJ (2015). forecast: Forecasting functions for time series and linear models. R package version 5.8, http://github.com/robjhyndman/forecast.

Hyndman RJ and Khandakar Y (2008). “Automatic time series forecasting: the forecast package for R.” Journal of Statistical Software, 26(3), pp. 1–22. http://ideas.repec.org/a/jss/jstsof/27i03.html.

***

### Third Tab - Breakout Detection

The Breakout Detection is being solved through the Twitter R package with the respective name. You can check the code and more information in their [repo on Github.][9]

> The underlying algorithm – referred to as E-Divisive with Medians (EDM) – employs energy statistics to detect divergence in mean. Note that EDM can also be used detect change in distribution in a given time series. EDM uses robust statistical metrics, viz., median, and estimates the statistical significance of a breakout through a permutation test.

***

### Fourth Tab - Decomposition

#### Normal Timeseries Decomposition

This decomposition formula splits the data into seasonal, trend and irregular components using moving averages. The additive model uses the following formula: Y[t] = T[t] + S[t] + e[t].

#### STL Decomposition

> STL is a very versatile and robust method for decomposing time series. STL is an acronym for “Seasonal and Trend decomposition using Loess”, while Loess is a method for estimating nonlinear relationships. The STL method was developed by Cleveland et al. (1990) [(Source)][10]

***

### Fifth Tab - Calendar View

The view of the data in a calendar allows to inspect the respective values per day interactively and also enables a quick detection of differences between weekdays and weekends. Furthermore, seasonal differences can also be discovered at a first glance.

***

### Used R Packages


```r
library(zoo)
library(timeDate)
library(forecast)
library(lubridate)
library(shiny)
library(shinyIncubator)
library(shinythemes)
library(knitr)
library(reshape)
library(DT)
library(RColorBrewer)
library(googleVis)
library(BreakoutDetection)
library(rmarkdown)
```

***

### Last Session Info


```r
devtools::session_info()
```

```
## Session info --------------------------------------------------------------
```

```
##  setting  value                       
##  version  R version 3.1.2 (2014-10-31)
##  system   x86_64, darwin13.4.0        
##  ui       X11                         
##  language (EN)                        
##  collate  de_DE.UTF-8                 
##  tz       Europe/Berlin
```

```
## Packages ------------------------------------------------------------------
```

```
##  package    * version date       source        
##  devtools   * 1.7.0   2015-01-17 CRAN (R 3.1.2)
##  digest     * 0.6.8   2014-12-31 CRAN (R 3.1.2)
##  evaluate   * 0.5.5   2014-04-29 CRAN (R 3.1.0)
##  formatR    * 1.0     2014-08-25 CRAN (R 3.1.1)
##  htmltools  * 0.2.6   2014-09-08 CRAN (R 3.1.1)
##  knitr      * 1.9     2015-01-20 CRAN (R 3.1.2)
##  rmarkdown  * 0.5.1   2015-01-26 CRAN (R 3.1.2)
##  rstudioapi * 0.2     2014-12-31 CRAN (R 3.1.2)
##  stringr    * 0.6.2   2012-12-06 CRAN (R 3.1.2)
##  yaml       * 2.1.13  2014-06-12 CRAN (R 3.1.0)
```


[1]: https://github.com/mhnierhoff/TOSA "TOSA Github Repo"

[2]: http://www.greenpeace.org/international/en/ "Greenpeace Website"

[3]: http://www.amnesty.org "Amnesty Website"

[4]: http://www.peta.org "PETA Website"

[5]: http://www.redcross.org "Red Cross Website"

[6]: http://www.unicef.org "Unicef Website"

[7]: http://nierhoff.info/#contact "Contact"

[8]: http://en.wikipedia.org/wiki/Exploratory_data_analysis "EDA on wikipeda.org"

[9]: https://github.com/twitter/BreakoutDetection "Twitter Breakout Detection R Package"

[10]: https://www.otexts.org/fpp/6/5 "STL Decomposition"

***
