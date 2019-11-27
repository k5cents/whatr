#' Scrape Jeopardy game categories
#'
#' For a given game, return a table of category names and their position on the
#' board for each round. Categories are assigned to one of six distinct columns
#' on the game board.
#'
#' @details
#' From the [J! Archive glossary](https://j-archive.com/help.php#category):
#' [Categories are] a collection of five clues, related by subject matter or
#' otherwise, (ostensibly) arranged in order of difficulty, and assigned a
#' (frequently punny) title and, sometimes, special instructions, e.g., for
#' clues in a category the title of which contains words or letters in quotation
#' marks, the correct responses will themselves contain (or sometimes begin
#' with) those words or letters.
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tibble of categories and positions.
#' @examples
#' whatr_categories(game = 6304)
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @importFrom dplyr mutate select
#' @export
whatr_categories <- function(game = NULL, date = NULL, show = NULL) {
  data <- showgame(game, date, show)
  data %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text(trim = TRUE) %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(name = NULL, value = "category") %>%
    dplyr::mutate(
      round = c(rep(1L, 6), rep(2L, 6), 3L),
      col = c(1L:6L, 1L:6L, 0L)
    ) %>%
    dplyr::select(round, col, category)
}
