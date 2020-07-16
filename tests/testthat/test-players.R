library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("players return from HTML", {
  p <- whatr_html(id) %>% whatr_players()
  expect_s3_class(p, "tbl")
  expect_length(p, 4)
  expect_equal(nrow(p), 3)
  Sys.sleep(runif(1, 5, 10))
})

test_that("players return from game ID", {
  p <- whatr_players(game = id)
  expect_s3_class(p, "tbl")
  expect_length(p, 4)
  Sys.sleep(runif(1, 5, 10))
})
