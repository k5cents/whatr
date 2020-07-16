library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("answers return from HTML", {
  a <- whatr_html(id) %>% whatr_answers()
  expect_s3_class(a, "tbl")
  expect_length(a, 5)
  Sys.sleep(runif(1, 5, 10))
})

test_that("answers return from game ID", {
  a <- whatr_answers(game = id)
  expect_s3_class(a, "tbl")
  expect_length(a, 5)
  Sys.sleep(runif(1, 5, 10))
})
