library(testthat)
library(whatr)

test_that("order returns from HTML", {
  rand_wait()
  d <- whatr_html(6185) %>% whatr_doubles()
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 3)
})

test_that("order returns from game ID", {
  rand_wait()
  d <- whatr_doubles(game = 6185)
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 3)
})
