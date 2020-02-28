
<!-- README.md is generated from README.Rmd. Please edit that file -->

# whatr <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-maturing-blue.svg)](https://www.tidyverse.org/lifecycle/#maturing)
[![CRAN
status](https://www.r-pkg.org/badges/version/whatr)](https://CRAN.R-project.org/package=whatr)
[![Travis build
status](https://travis-ci.org/kiernann/whatr.svg?branch=master)](https://travis-ci.org/kiernann/whatr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/whatr/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/whatr?branch=master')
<!-- badges: end -->

> *This* R package was made to facilitate the analysis of game show data
> by scraping the J\! Archive.

> What is… whatr?

## Installation

You can install the development version of ‘whatr’ from
[GitHub](https://github.com/kiernann/whatr) with:

``` r
# install.packages("remotes")
remotes::install_github("kiernann/whatr")
```

## Usage

``` r
library(whatr)
data <- whatr_html(6304)
whatr_board(data)[, 5:7]
#> # A tibble: 61 x 3
#>    category       clue                                                         answer              
#>    <chr>          <chr>                                                        <chr>               
#>  1 Picture The I… For An Optimistic View Of Things, Take A Look Through These  Rose-Colored Glasses
#>  2 Picture The I… If You Have These, It Means You're Well-Organized            Your Ducks In A Row 
#>  3 Picture The I… It's What's Going On Here                                    Comparing Apples & …
#>  4 Picture The I… Greenhouse Gas Emission Due To Human Activity Leaves Behind… A Carbon Footprint  
#>  5 Picture The I… Note The Lovely Weather; It Means To Take Advantage Of An O… Make Hay While The …
#>  6 Literature     Melville's 'Bartleby The Scrivener' Is Subtitled 'A Story O… Wall Street         
#>  7 Literature     In A 1923 Book By Kahlil Gibran, Almustafa Is This Mystical… The Prophet         
#>  8 Literature     In 'Charlotte's Web', Templeton Is This Creature             A Rat               
#>  9 Literature     In A Novel Simone De Beauvoir Depicted Herself As Anne & Th… (Albert) Camus      
#> 10 Literature     The Title Peak Of This Thomas Mann Novel Is Home To A Swiss… Magic Mountain      
#> # … with 51 more rows
whatr_scores(data)
#> # A tibble: 63 x 5
#>    round     n name  score double
#>    <int> <int> <chr> <int> <lgl> 
#>  1     1     1 James  1000 TRUE  
#>  2     1     2 Emma   1000 FALSE 
#>  3     1     3 James   800 FALSE 
#>  4     1     4 James  1000 FALSE 
#>  5     1     5 Emma   1000 FALSE 
#>  6     1     6 Jay     800 FALSE 
#>  7     1     7 James   600 FALSE 
#>  8     1     8 James  1000 FALSE 
#>  9     1     9 James  1000 FALSE 
#> 10     1    10 Emma    800 FALSE 
#> # … with 53 more rows
whatr_plot(data)
```

<img src="man/figures/README-usage-1.png" width="100%" />

-----

The ‘whatr’ project is released with a [Contributor Code of
Conduct](https://kiernann.com/whatr/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to its terms.

The J\! Archive is created by fans, for fans. The *Jeopardy\!* game show
and all elements thereof, including but not limited to copyright and
trademark thereto, are the property of Jeopardy Productions, Inc. and
are protected under law. This package is not affiliated with, sponsored
by, or operated by Jeopardy Productions, Inc or the J\! Archive itself.

<!-- refs: start -->

<!-- refs: end -->
