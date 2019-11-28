library(testthat)
library(whatr)

test_that("different data returns same length", {
  game <- 123
  scores <- whatr_scores(game)
  clues <- whatr_clues(game)
  answers <- whatr_answers(game)
  categories <- whatr_categories(game)
  expect_equal(max(clues$n), nrow(answers))
  expect_equal(max(scores$n), nrow(answers))
  expect_equal(nrow(categories), 13)
})
