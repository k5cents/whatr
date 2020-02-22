library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("full board returns from HTML", {
  b <- read_game(id) %>% whatr_board()
  expect_s3_class(b, "tbl")
  expect_length(b, 7)
})

test_that("full board returns from game ID", {
  b <- whatr_board(game = id)
  expect_s3_class(b, "tbl")
  expect_length(b, 7)
})
