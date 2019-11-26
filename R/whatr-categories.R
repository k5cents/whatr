#' Scrape Jeopardy game categories
#'
#' Categories are collections of five clues, related by subject matter and
#' arranged in order of difficulty. In the structure of the game board,
#' categories are the columns.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tidy tibble or correct answers.
#' @examples
#' whatr_answers(game = 6304)
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_split str_extract str_remove str_to_title str_replace_all fixed str_which
#' @importFrom magrittr extract
#' @importFrom purrr map
#' @importFrom dplyr add_row bind_cols select
#' @export
whatr_categories <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  showgame %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(value = "category", name = NULL) %>%
    dplyr::mutate(round = c(rep(1, 6), rep(2, 6), 3)) %>%
    dplyr::mutate(col = c(1:6, 1:6, NA)) %>%
    dplyr::select(round, col, category)
}
