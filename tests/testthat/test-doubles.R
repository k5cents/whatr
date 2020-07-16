library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("order returns from HTML", {
  d <- whatr_html(id) %>% whatr_doubles()
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 3)
  Sys.sleep(runif(1, 5, 10))
})

test_that("order returns from game ID", {
  d <- whatr_doubles(game = id)
  expect_s3_class(d, "tbl")
  expect_length(d, 6)
  expect_equal(nrow(d), 3)
  Sys.sleep(runif(1, 5, 10))
})
