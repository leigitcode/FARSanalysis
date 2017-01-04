
<!-- README.md is generated from README.Rmd. Please edit that file -->
Aim of the Package
------------------

The US National Highway Traffic Safety Administration records American data about fatal injuries due to motor vehicle crashes using the Fatality Analysis Reporting System (FARS). More information is available at <https://www.nhtsa.gov/research-data/fatality-analysis-reporting-system-fars>. This package provides functions to analyze and visualize the FARS data. A data summary of FARS data for a particular year or range of years can be generated. Also, a state map displaying FARS data for a particular year can be generated.

Accessing the Package
---------------------

This package is available on GitHub and can be installed using the devtools package:

``` r
library(devtools)
install_github("leigit/FARSanalysis")
library(FARSanalysis)
```

Example - Summarize Data
------------------------

Data from the FARS data link should be downloaded for the years of interest. The 2013 FARS accident data file is provided with the package. To see the number of accidents grouped by month and year for a given number of years:

``` r
#summarize for 1 year
fars_summarize_years(2013)
#summarize for a range of years
fars_summarize_years(c(2013,2014))
```

Example - State Map Visualization
---------------------------------

Data from the FARS data link should be downloaded for the year of interest. The 2013 FARS accident data file is provided with the package. To display a map of a state with the accidents plotted on the map:

``` r
#generate state map of Alabama for FARS data in 2013
fars_map_state(1,2013)
```

Additional Functions
--------------------

There are also functions in the package which are called by the functions in the previous examples. These functions can be run separately:

``` r
#generate filename for a particular year
make_filename(2013)
#read a FARS file
filename<-system.file("extdata","accident_2013.csv.bz2",package="FARSanalysis")
fars_read(filename)
#read the FARS file and return data as a list where each list item is a tbl_df object containing month and year data for one file.
fars_read_years(2013)
```
