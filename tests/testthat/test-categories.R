library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("categories return from HTML", {
  c <- whatr_html(id) %>% whatr_categories()
  expect_s3_class(c, "tbl")
  expect_length(c, 3)
})

test_that("categories return from game ID", {
  c <- whatr_categories(game = id)
  expect_s3_class(c, "tbl")
  expect_length(c, 3)
})
