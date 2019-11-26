#' Scrape Jeopardy game clues
#'
#' Confusingly, clues are "questions" pased to contestants in the form of an
#' answer. The clues are the questions read by the host which must be answered
#' by the contestants.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tidy tibble or correct answers.
#' @examples
#' whatr_clues(game = 6304)
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @importFrom dplyr mutate left_join select
#' @export
whatr_clues <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  showgame %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "question") %>%
    dplyr::bind_cols(whatr_order(game)) %>%
    dplyr::select(round, clue, col, row, question)
}
