library(testthat)
library(whatr)

id <- sample(whatr::episodes$game, 1)
test_that("answers return from HTML", {
  p <- whatr_html(id) %>% whatr_plot()
  expect_s3_class(p, "ggplot")
})

test_that("answers return from game ID", {
  p <- whatr_plot(id)
  expect_s3_class(p, "ggplot")
})
