library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("info returns from HTML", {
  i <- whatr_html(id) %>% whatr_info()
  expect_s3_class(i, "tbl")
  expect_length(i, 3)
  expect_equal(nrow(i), 1)
})

test_that("info returns from game ID", {
  i <- whatr_info(game = id)
  expect_s3_class(i, "tbl")
  expect_length(i, 3)
  expect_equal(nrow(i), 1)
})
