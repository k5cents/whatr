#' Return a J! Archive game ID
#'
#' Return the game ID for a show air date or number. The game ID is needed to
#' return the "showgame" or "showscores" page.
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

#' Scrape a J! Archive "showscores" page
#'
#' GET the "showscores" HTML document object which can be parsed. Use with
#' functions like [whatr_scores()].
#'
#' @param game The J! Archive game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J! Archive showscores `html_document`.
#' @examples
#' read_scores(game = 6304)
#' @importFrom httr GET content
#' @export
read_scores <- function(game = NULL, date = NULL, show = NULL) {
  response <- httr::GET(
    url = "http://www.j-archive.com/showscores.php",
    query = list(game_id = whatr_id(game, date, show))
  )
  showscores <- httr::content(response)
  return(showscores)
}

#' Scrape a J! Archive "showgame" page
#'
#' GET the "showgame" HTML document object which can be parsed. Use with
#' functions like [whatr_players()].
#'
#' @param game The J! Archive game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J! Archive showgame `html_document`.
#' @examples
#' read_game(game = 6304)
#' @importFrom httr GET content
#' @export
read_game <- function(game = NULL, date = NULL, show = NULL) {
  response <- httr::GET(
    url = "http://www.j-archive.com/showgame.php",
    query = list(game_id = whatr_id(game, date, show))
  )
  showgame <- httr::content(response)
  return(showgame)
}

#' Return the right J! Archive HTML document
#'
#' To avoid downloading and reading the J! Archive over and over, this function
#' can be used to return an HTML document from one of four types of input:
#' 1. Game ID (6304)
#' 2. Show number ("#8006")
#' 3. Air date ("2019-06-03")
#' 4. HTML document itself
#'
#' @param x Any kind of J! Archive game identifier.
#' @param doc One of "showgame" or "showscores" used for [whatr_clues()] or
#'   [whatr_scores()] respectively. Either document can be returned from the
#'   input of the other.
#' @return A J! Archive `html_document`.
#' @examples
#' whatr_html(x = 6304, out = "showscores")
#' @importFrom httr GET content
#' @export
whatr_html <- function(x, out = c("showgame", "showscores")) {
  out <- match.arg(out, c("showgame", "showscores"))
  if (is.numeric(x)) {
    game <- x
  } else if (is(x, "xml_node")) {
    html <- x
  } else {
    # date or show
    if (!is.na(as.Date(as.character(x)))) {
      type <- "date"
      date <- x
    } else if (stringr::str_starts(x, "#")) {
      type <- "show"
      show <- x
    } else {
      error("unable to determine input type")
    }
    if (out == "showgame") {
      # read redirect page
      j_search <- httr::GET(
        url = "http://www.j-archive.com/search.php",
        query = list(search = paste(type, x, sep = ":"))
      )
      data <- httr::content(j_search)
    } else if (out == "showscores") {
      # get redirect game url
      j_search <- httr::HEAD(
        url = "http://www.j-archive.com/search.php",
        query = list(search = paste(type, x, sep = ":"))
      )
      # switch redirect url to scores
      game <- stringr::str_extract(j_search$url, "\\d+$")
      j_score <- httr::GET(
        url = sprintf("http://www.j-archive.com/%s.php", out),
        query = list(game_id = whatr_id(game, date, show))
      )
      data <- httr::content(j_score)
    }
  }
}

