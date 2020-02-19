library(testthat)
library(whatr)

test_that("game ID can be found from date", {
  game <- whatr_id(date = "2019-06-03")
  expect_equal(game, "6304")
})

test_that("game ID can be found from show number", {
  game <- whatr_id(show = 8006)
  expect_equal(game, "6304")
})
