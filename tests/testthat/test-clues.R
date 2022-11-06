library(testthat)
library(whatr)

test_that("clues return from HTML", {
  rand_wait()
  c <- whatr_html(6185) %>% whatr_clues()
  expect_s3_class(c, "tbl")
  expect_length(c, 5)
})

test_that("clues return from game ID", {
  rand_wait()
  c <- whatr_clues(game = 6185)
  expect_s3_class(c, "tbl")
  expect_length(c, 5)
})

test_that("tiebreaker clues are handled", {
  rand_wait()
  c <- whatr_clues(game = 5922)
  expect_s3_class(c, "tbl")
  expect_length(unique(c[["round"]]), 4)
})
