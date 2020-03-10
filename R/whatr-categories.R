#' What are categories?
#'
#' _These_ are collections of five clues related by subject matter.
#'
#' @inheritParams whatr_scores
#' @return Tidy tibble of category titles.
#' @format A tibble with (up to) 13 rows and 3 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{category}{Category title, often humorous or with instructions.}
#' }
#' @examples
#' whatr_categories(game = 6304)
#' @importFrom rlang .data
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @importFrom dplyr mutate select
#' @export
whatr_categories <- function(game) {
  game <- whatr_html(game, "showgame")
  cats <- game %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text(trim = TRUE) %>%
    entity_clean() %>%
    tibble::enframe(name = NULL, value = "category") %>%
    dplyr::mutate(
      round = c(rep(1L, 6), rep(2L, 6), 3L),
      col = c(1L:6L, 1L:6L, 1L)
    ) %>%
    dplyr::select(.data$round, .data$col, .data$category)
  return(cats)
}
