
<!-- README.md is generated from README.Rmd. Please edit that file -->

# whatr <img src='man/figures/logo.png' align="right" height="139" />

<!-- badges: start -->

[![Lifecycle:
experimental](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](https://www.tidyverse.org/lifecycle/#experimental)
[![CRAN
status](https://www.r-pkg.org/badges/version/whatr)](https://CRAN.R-project.org/package=whatr)
[![Travis build
status](https://travis-ci.org/kiernann/whatr.svg?branch=master)](https://travis-ci.org/kiernann/whatr)
[![Codecov test
coverage](https://codecov.io/gh/kiernann/whatr/branch/master/graph/badge.svg)](https://codecov.io/gh/kiernann/whatr?branch=master')
<!-- badges: end -->

> This package was design to facilitate the analysis of game show data.

> What is… what R?

The package contains both past data and the tools used to update with
future games from the fan-made episode [J\!
Archive](http://j-archive.com/).

The J\! Archive is created by fans, for fans. The *Jeopardy\!* game show
and all elements thereof, including but not limited to copyright and
trademark thereto, are the property of Jeopardy Productions, Inc. and
are protected under law. This package is not affiliated with, sponsored
by, or operated by Jeopardy Productions, Inc.

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
id <- whatr_id(date = "2019-06-03")
whatr_scores(game = id)
#> # A tibble: 65 x 5
#>    round     n name  score double
#>    <int> <int> <chr> <int> <lgl> 
#>  1     1     1 James  1000 TRUE  
#>  2     1     1 Jay       0 TRUE  
#>  3     1     1 Emma      0 TRUE  
#>  4     1     2 Emma   1000 FALSE 
#>  5     1     3 James   800 FALSE 
#>  6     1     4 James  1000 FALSE 
#>  7     1     5 Emma   1000 FALSE 
#>  8     1     6 Jay     800 FALSE 
#>  9     1     7 James   600 FALSE 
#> 10     1     8 James  1000 FALSE 
#> # … with 55 more rows
whatr_board(game = id)[, 4:7]
#> # A tibble: 61 x 4
#>        n category       clue                                                    answer             
#>    <int> <chr>          <chr>                                                   <chr>              
#>  1    25 Picture The I… For An Optimistic View Of Things, Take A Look Through … Rose-Colored Glass…
#>  2    24 Picture The I… If You Have These, It Means You're Well-Organized       Your Ducks In A Row
#>  3     7 Picture The I… It's What's Going On Here                               Comparing Apples &…
#>  4     6 Picture The I… Greenhouse Gas Emission Due To Human Activity Leaves B… A Carbon Footprint 
#>  5     4 Picture The I… Note The Lovely Weather; It Means To Take Advantage Of… Make Hay While The…
#>  6    26 Literature     Melville's 'Bartleby The Scrivener' Is Subtitled 'A St… Wall Street        
#>  7    23 Literature     In A 1923 Book By Kahlil Gibran, Almustafa Is This Mys… The Prophet        
#>  8    15 Literature     In 'Charlotte's Web', Templeton Is This Creature        A Rat              
#>  9     3 Literature     In A Novel Simone De Beauvoir Depicted Herself As Anne… (Albert) Camus     
#> 10     1 Literature     The Title Peak Of This Thomas Mann Novel Is Home To A … Magic Mountain     
#> # … with 51 more rows
```

-----

Please note that the ‘whatr’ project is released with a [Contributor
Code of Conduct](https://kiernann.com/whatr/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->
