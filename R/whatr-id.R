#' Return a J! Archive game ID
#'
#' Can return the game ID for a show air date or number.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J-Archive! game ID number.
whatr_id <- function(game = NULL, date = NULL, show = NULL) {
  if (!is.null(game)) {
    return(as.character(game))
  } else if (!is.null(date)) {
    url <- paste0("http://www.j-archive.com/search.php?search=date:", as.Date(date))
    stringr::str_extract(httr::HEAD(url)$url, "\\d+$")
  } else if (!is.null(show)) {
    url <- paste0("www.j-archive.com/search.php?search=show:", show)
    stringr::str_extract(httr::HEAD(url)$url, "\\d+$")
  } else {
    stop("a game identifier is needed")
  }
}

#' Scrape a J! Archive "showgame" page
#'
#' Use [xml2::read_html()] to scrape the entire page as R object.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J-Archive! showgame page.
showgame <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  return(showgame)
}
