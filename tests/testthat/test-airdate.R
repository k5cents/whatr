library(testthat)
library(whatr)

test_that("info returns from HTML", {
  rand_wait()
  i <- whatr_html(6185) %>% whatr_airdate()
  expect_s3_class(i, "tbl")
  expect_length(i, 3)
  expect_equal(nrow(i), 1)
})

test_that("info returns from game ID", {
  rand_wait()
  i <- whatr_airdate(game = 6185)
  expect_s3_class(i, "tbl")
  expect_length(i, 3)
  expect_equal(nrow(i), 1)
})
