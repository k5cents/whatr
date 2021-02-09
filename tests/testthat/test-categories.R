library(testthat)
library(whatr)

test_that("categories return from HTML", {
  rand_wait()
  c <- whatr_html(6185) %>% whatr_categories()
  expect_s3_class(c, "tbl")
  expect_length(c, 3)
})

test_that("categories return from game ID", {
  rand_wait()
  c <- whatr_categories(game = 6185)
  expect_s3_class(c, "tbl")
  expect_length(c, 3)
})
