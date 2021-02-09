library(testthat)
library(whatr)

test_that("categories return from game ID", {
  rand_wait()
  d <- whatr_data(game = 6185)
  expect_type(d, "list")
  expect_length(d, 5)
})
