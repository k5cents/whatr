library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("categories return from game ID", {
  d <- whatr_data(game = id)
  expect_type(d, "list")
  expect_length(d, 5)
  Sys.sleep(runif(1, 5, 10))
})
