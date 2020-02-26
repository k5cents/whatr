library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("players return from HTML", {
  p <- whatr_html(id) %>% whatr_players()
  expect_s3_class(p, "tbl")
  expect_length(p, 5)
  expect_equal(nrow(p), 3)
})

test_that("players return from game ID", {
  p <- whatr_players(game = id)
  expect_s3_class(p, "tbl")
  expect_length(p, 5)
})
