library(testthat)
library(whatr)

test_that("full board returns from HTML", {
  rand_wait()
  b <- whatr_html(6185) %>% whatr_board()
  expect_s3_class(b, "tbl")
  expect_length(b, 7)
})

test_that("full board returns from game ID", {
  rand_wait()
  b <- whatr_board(game = 6185)
  expect_s3_class(b, "tbl")
  expect_length(b, 7)
})

test_that("tiebreaker boards are handled", {
  rand_wait()
  b <- whatr_board(game = 5922)
  expect_s3_class(b, "tbl")
  expect_length(unique(b[["round"]]), 4)
})
