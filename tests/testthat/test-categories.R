library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("categories return from HTML", {
  c <- read_game(id) %>% whatr_categories()
  expect_s3_class(c, "tbl")
  expect_length(c, 3)
})

test_that("categories return from game ID", {
  c <- whatr_categories(game = id)
  expect_s3_class(c, "tbl")
  expect_length(c, 3)
})
