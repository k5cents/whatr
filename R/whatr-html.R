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
#' @param doc One of "showscores" or "showgame" used for [whatr_scores()] or
#'   [whatr_clues()], etc. respectively. Either document can be returned from
#'   the input of the other.
#' @return A J! Archive `html_document`.
#' @examples
#' whatr_html(x = 6304, out = "showscores")
#' whatr_html(x = "2019-06-03", out = "showgame")
#' whatr_html("#8006", "showgame") %>% whatr_html("showscores")
#' @importFrom httr GET content
#' @export
whatr_html <- function(x, out = c("showgame", "showscores")) {
  out <- match.arg(out, c("showgame", "showscores"))
  if (is.numeric(x)) { # is numeric game is return out
    z <- "game_id"
    out_get <- httr::GET(
      url = sprintf("http://www.j-archive.com/%s.php", out),
      query = list(game_id = x)
    )
    data <- httr::content(out_get)
    return(data); message(sprintf("in: %s, out: %s", z, out))
  } else if (is(x, "xml_node")) { # is already html document
    # check if already showscores and return if wanted
    c <- as.character(x)
    if (stringr::str_detect(c, "ddred") & out == "showscores") {
      z <- "score_doc"
      print(x); message(sprintf("in: %s, out: %s", z, out))
    } else if (!stringr::str_detect(c, "ddred") & out == "showscores") {
      z <- "game_doc"
      game <- stringr::str_extract(c, "(?<=chartgame.php\\?game_id\\=)\\d+")
      j_score <- httr::GET(
        url = "http://www.j-archive.com/showscores.php",
        query = list(game_id = game)
      )
      data <- httr::content(j_score)
      return(data); message(sprintf("in: %s, out: %s", z, out))
    } else if (!stringr::str_detect(c, "ddred") & out == "showgame") {
      z <- "game_doc"
      data <- x
      return(data); message(sprintf("in: %s, out: %s", z, out))
    } else if (stringr::str_detect(c, "ddred") & out == "showgame") {
      z <- "show_doc"
      game <- stringr::str_extract(c, "(?<=chartgame.php\\?game_id\\=)\\d+")
      j_game <- httr::GET(
        url = "http://www.j-archive.com/showgame.php",
        query = list(game_id = game)
      )
      data <- httr::content(j_score)
      return(data); message(sprintf("in: %s, out: %s", z, out))
    }
  } else {
    # date or show
    if (stringr::str_starts(x, "#")) {
      type <- z <- "show"
    } else if (stringr::str_detect(x, "^\\d{4}-\\d+-\\d+$")) {
      type <- z <- "date"
    } else {
      error("unable to determine input type")
    }
    if (out == "showgame") {
      # read redirect page
      j_game <- httr::GET(
        url = "http://www.j-archive.com/search.php",
        query = list(search = paste(type, sub("#", "", x), sep = ":"))
      )
      data <- httr::content(j_game)
      return(data); message(sprintf("in: %s, out: %s", z, out))
    } else if (out == "showscores") {
      # get redirect game url
      j_head <- httr::HEAD(
        url = "http://www.j-archive.com/search.php",
        query = list(search = paste(type, sub("#", "", x), sep = ":"))
      )
      # switch redirect url to scores
      game <- stringr::str_extract(j_head$url, "\\d+$")
      j_score <- httr::GET(
        url = "http://www.j-archive.com/showscores.php",
        query = list(game_id = game)
      )
      data <- httr::content(j_score)
      return(data); message(sprintf("in: %s, out: %s", z, out))
    }
  }
}

