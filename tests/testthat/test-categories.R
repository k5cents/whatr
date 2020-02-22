library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("scores returns from HTML", {
  s <- read_game(6304) %>% whatr_categories()
  expect_s3_class(s, "tbl")
  expect_length(s, 3)
})

test_that("scores returns from game ID", {
  s <- whatr_categories(game = 6304)
  expect_s3_class(s, "tbl")
  expect_length(s, 3)
})
