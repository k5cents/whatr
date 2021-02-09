library(testthat)
library(whatr)

expect_showgame <- function(object) {
  expect_true(is(object, "xml_document") & !grepl("ddred", object))
}

expect_showscores <- function(object) {
  expect_true(is(object, "xml_document") & grepl("ddred", object))
}

# id ----------------------------------------------------------------------

test_that("game ID can be converted to showgame HTML", {
  rand_wait()
  expect_showgame(whatr_html(6185, out = "showgame"))
})

test_that("game ID can be converted to showscores HTML", {
  rand_wait()
  expect_showscores(whatr_html(6185, out = "showscores"))
})

# html --------------------------------------------------------------------

game_url <- paste0("http://www.j-archive.com/showgame.php?game_id=", 6185)
game_html <- read_html(game_url)
score_url <- paste0("http://www.j-archive.com/showscores.php?game_id=", 6185)
score_html <- read_html(score_url)
test_that("showgame HTML can be converted to showscores HTML", {
  expect_showscores(whatr_html(game_html, out = "showscores"))
})

test_that("showgame HTML can be converted to showgame HTML", {
  expect_showgame(whatr_html(game_html, out = "showgame"))
})

test_that("showscores HTML can be converted to showscores HTML", {
  expect_showscores(whatr_html(score_html, out = "showscores"))
})

test_that("showscores HTML can be converted to showgame HTML", {
  expect_showgame(whatr_html(score_html, out = "showgame"))
})

# show --------------------------------------------------------------------

test_that("show num can be converted to showgame HTML", {
  rand_wait()
  expect_showgame(whatr_html("#7819", out = "showgame"))
})

test_that("show num can be converted to showscores HTML", {
  rand_wait()
  expect_showscores(whatr_html("#7819", out = "showscores"))
})

# date --------------------------------------------------------------------

test_that("air date can be converted to showgame HTML", {
  rand_wait()
  expect_showgame(whatr_html(as.Date("2018-09-12"), out = "showgame"))
})

test_that("air date can be converted to showscores HTML", {
  rand_wait()
  expect_showscores(whatr_html(as.Date("2018-09-12"), out = "showscores"))
})

# error -------------------------------------------------------------------

test_that("air date can be converted to showscores HTML", {
  rand_wait()
  expect_error(whatr_html("test", out = "showscores"))
})
