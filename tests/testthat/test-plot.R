library(testthat)
library(whatr)

test_that("answers return from HTML", {
  rand_wait()
  p <- whatr_html(6185) %>% whatr_plot()
  expect_s3_class(p, "ggplot")
})

test_that("answers return from game ID", {
  rand_wait()
  p <- whatr_plot(6185)
  expect_s3_class(p, "ggplot")
})
