library(testthat)
library(whatr)

test_that("order returns from HTML", {
  rand_wait()
  o <- whatr_html(6185) %>% whatr_order()
  expect_s3_class(o, "tbl")
  expect_length(o, 4)
})

test_that("order returns from game ID", {
  rand_wait()
  o <- whatr_order(game = 6185)
  expect_s3_class(o, "tbl")
  expect_length(o, 4)
})
