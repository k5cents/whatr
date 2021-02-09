library(testthat)
library(whatr)

test_that("summary returns from HTML", {
  rand_wait()
  s <- whatr_html(6185) %>% whatr_synopsis()
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
})

test_that("summary returns from game ID", {
  rand_wait()
  s <- whatr_synopsis(game = 6185)
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
})
