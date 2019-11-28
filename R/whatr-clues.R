#' Scrape Jeopardy game clues
#'
#' Confusingly, clues are "questions" posed to contestants in the form of an
#' answer. The clues are the questions read by the host which must be answered
#' by the contestants.
#'
#' @details
#' From the [J! Archive glossary](https://j-archive.com/help.php#category):
#' \[Clues are\] a "question" posed to Jeopardy! contestants, descriptively
#' phrased as the answer to the correct response. Clues have some dollar value
#' associated with them, except in cases of Daily Doubles or Final Jeopardy!
#' clues, which are wagered upon prior to the revealing of the clue... At the
#' start of the Jeopardy! Round, the returning champion, or the player at the
#' leftmost lectern if there is no returning champion, selects the first clue;
#' thereafter, for the rest of the round, the clues are selected by the last
#' player to give a correct response. At the beginning of the Double Jeopardy!
#' Round, the player with the lowest score selects the first clue.
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
  data <- showgame(game, date, show)
  data %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::bind_cols(whatr_order(game)) %>%
    dplyr::select(round, col, row, n, clue)
}
