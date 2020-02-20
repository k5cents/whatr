library(testthat)
library(whatr)

test_that("scores returns from HTML", {
  s <- read_scores(6304) %>% whatr_scores()
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
  expect_length(unique(s$round), 3)
  expect_type(s$double, "logical")
})

test_that("scores returns from game ID", {
  s <- whatr_scores(game = 6304)
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
  expect_length(unique(s$round), 3)
  expect_type(s$double, "logical")
})
