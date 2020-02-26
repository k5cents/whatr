library(testthat)
library(whatr)

id <- sample(2000:5000, 1)
test_that("summary returns from HTML", {
  s <- whatr_html(id) %>% whatr_summary()
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
})

test_that("summary returns from game ID", {
  s <- whatr_summary(game = id)
  expect_s3_class(s, "tbl")
  expect_length(s, 5)
})
