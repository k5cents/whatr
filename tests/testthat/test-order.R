library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("order returns from HTML", {
  o <- whatr_html(id) %>% whatr_order()
  expect_s3_class(o, "tbl")
  expect_length(o, 4)
})

test_that("order returns from game ID", {
  o <- whatr_order(game = id)
  expect_s3_class(o, "tbl")
  expect_length(o, 4)
})
