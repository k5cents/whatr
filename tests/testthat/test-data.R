library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("categories return from game ID", {
  d <- whatr_data(game = id)
  expect_type(d, "list")
  expect_length(d, 5)
})
