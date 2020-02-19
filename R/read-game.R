#' Return a J! Archive game ID
#'
#' Return the game ID for a show air date or number. The game ID is needed to
#' return the "showgame" or "showscore" page.
#'
#' @param game The J! Archive game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J! Archive game ID number.
#' @examples
#' whatr_id(game = 6304)
#' whatr_id(date = "2019-06-03")
#' whatr_id(show = 8006)
#' @importFrom httr HEAD
#' @importFrom stringr str_extract
#' @export
whatr_id <- function(game = NULL, date = NULL, show = NULL) {
  if (is.null(game)) {
    else_arg <- c(!is.null(date), !is.null(show))
    type <- c("date", "show")[else_arg]
    input <- c(date, show)
    response <- httr::HEAD(
      url = "http://www.j-archive.com/search.php",
      query = list(search = paste(type, input, sep = ":"))
    )
    game <- stringr::str_extract(response$url, "\\d+$")
  }
  return(as.character(game))
}

#' Scrape a J! Archive "showscore" page
#'
#' GET the "showscore" HTML document object which can be parsed. Use with
#' functions like [whatr_scores()].
#'
#' @param game The J! Archive game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J! Archive showscore `html_document`.
#' @examples
#' read_scores(game = 6304)
#' @importFrom httr GET content
#' @export
read_scores <- function(game = NULL, date = NULL, show = NULL) {
  response <- httr::GET(
    url = "http://www.j-archive.com/showscores.php",
    query = list(game_id = whatr_id(game, date, show))
  )
  showscore <- httr::content(response)
  return(showscore)
}

# Scrape a J! Archive "showgame" page
#
# GET the "showgame" HTML document object which can be parsed. Use with
# functions like [whatr_clues()].
#
# @param game The J! Archive game ID number.
# @param date The original date an episode aired.
# @param show The sequential show number.
# @return The J! Archive showgame `html_document`.
# @examples
# read_game(game = 6304)
# @importFrom httr GET content
# @export
# read_game <- function(game = NULL, date = NULL, show = NULL) {
#   response <- httr::GET(
#     url = "http://www.j-archive.com/showgame.php",
#     query = list(game_id = whatr_id(game, date, show))
#   )
#   showgame <- httr::content(response)
#   return(showgame)
# }
