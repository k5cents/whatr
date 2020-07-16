library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("clues return from HTML", {
  c <- whatr_html(id) %>% whatr_clues()
  expect_s3_class(c, "tbl")
  expect_length(c, 5)
  Sys.sleep(runif(1, 5, 10))
})

test_that("clues return from game ID", {
  c <- whatr_clues(game = id)
  expect_s3_class(c, "tbl")
  expect_length(c, 5)
  Sys.sleep(runif(1, 5, 10))
})
