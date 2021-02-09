library(testthat)
library(whatr)

test_that("players return from HTML", {
  rand_wait()
  p <- whatr_html(6185) %>% whatr_players()
  expect_s3_class(p, "tbl")
  expect_length(p, 4)
  expect_equal(nrow(p), 3)
})

test_that("players return from game ID", {
  rand_wait()
  p <- whatr_players(game = 6185)
  expect_s3_class(p, "tbl")
  expect_length(p, 4)
})
