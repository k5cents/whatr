#' What are categories?
#'
#' _These_ are collections of five clues related by subject matter.
#'
#' @param html An HTML document from [read_game()].
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
#' @return Tidy tibble of category titles.
#' @format A tibble with (usually 13) rows and 3 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{category}{Category title, often humorous or with instructions.}
#' }
#' @examples
#' whatr_categories(game = 6304)
#' read_game(6304) %>% whatr_categories()
#' @importFrom rlang .data
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @importFrom dplyr mutate select
#' @export
whatr_categories <- function(html = NULL, game = NULL) {
  # read showscore html
  if (is.null(html)) {
    showgame <- read_game(game)
  } else {
    showgame <- html
  }
  cats <- showgame %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text(trim = TRUE) %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(name = NULL, value = "category") %>%
    dplyr::mutate(
      round = c(rep(1L, 6), rep(2L, 6), 3L),
      col = c(1L:6L, 1L:6L, 1L)
    ) %>%
    dplyr::select(.data$round, .data$col, .data$category)
  return(cats)
}
