library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("order returns from HTML", {
  d <- whatr_html(id) %>% whatr_doubles()
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 3)
})

test_that("order returns from game ID", {
  d <- whatr_doubles(game = id)
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 3)
})
