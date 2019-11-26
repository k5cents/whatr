#' Scrape Jeopardy game air info
#'
#' For a given episode, return three variables used to identify an episode:
#' 1. The J! Archive game ID: issued sequentially as episodes are archived.
#' 2. The sequential show number: most recent episode is the highest show.
#' 3. The date the episode originally aired in the United States.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A single tibble row of air info.
#' @examples
#' whatr_info(game = 6304)
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_text
#' @importFrom stringr str_extract
#' @importFrom tibble tibble
#' @export
whatr_info <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  title <- rvest::html_text(rvest::html_node(showgame, "title"))
  tibble::tibble(
    game = as.integer(game),
    show = as.integer(stringr::str_extract(title, "(\\d+)")),
    date = as.Date(stringr::str_extract(title, "\\d+-\\d+-\\d+$"))
  )
}
