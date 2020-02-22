
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
whatr_board(game = id)
#> # A tibble: 61 x 7
#>    round   col   row     n category     clue                                        answer         
#>    <int> <int> <int> <int> <chr>        <chr>                                       <chr>          
#>  1     1     1     1    25 Picture The… For An Optimistic View Of Things, Take A L… Rose-Colored G…
#>  2     1     1     2    24 Picture The… If You Have These, It Means You're Well-Or… Your Ducks In …
#>  3     1     1     3     7 Picture The… It's What's Going On Here                   Comparing Appl…
#>  4     1     1     4     6 Picture The… Greenhouse Gas Emission Due To Human Activ… A Carbon Footp…
#>  5     1     1     5     4 Picture The… Note The Lovely Weather; It Means To Take … Make Hay While…
#>  6     1     2     1    26 Literature   Melville's 'Bartleby The Scrivener' Is Sub… Wall Street    
#>  7     1     2     2    23 Literature   In A 1923 Book By Kahlil Gibran, Almustafa… The Prophet    
#>  8     1     2     3    15 Literature   In 'Charlotte's Web', Templeton Is This Cr… A Rat          
#>  9     1     2     4     3 Literature   In A Novel Simone De Beauvoir Depicted Her… (Albert) Camus 
#> 10     1     2     5     1 Literature   The Title Peak Of This Thomas Mann Novel I… Magic Mountain 
#> # … with 51 more rows
```

-----

Please note that the ‘whatr’ project is released with a [Contributor
Code of Conduct](https://kiernann.com/whatr/CODE_OF_CONDUCT.html). By
contributing to this project, you agree to abide by its terms.

<!-- refs: start -->

<!-- refs: end -->
