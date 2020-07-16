library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("summary returns from HTML", {
  s <- whatr_html(id) %>% whatr_synopsis()
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
  Sys.sleep(runif(1, 5, 10))
})

test_that("summary returns from game ID", {
  s <- whatr_synopsis(game = id)
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
  Sys.sleep(runif(1, 5, 10))
})
