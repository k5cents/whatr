library(testthat)
library(whatr)

test_that("answers return from HTML", {
  rand_wait()
  a <- whatr_html(6185) %>% whatr_answers()
  expect_s3_class(a, "tbl")
  expect_length(a, 5)
})

test_that("answers return from game ID", {
  rand_wait()
  a <- whatr_answers(game = 6185)
  expect_s3_class(a, "tbl")
  expect_length(a, 5)
})
