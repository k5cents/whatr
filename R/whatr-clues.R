#' What are the clues?
#'
#' Confusingly, _these_ are posed to contestants in the form of an answer.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of clue text.
#' @format A tibble with (usually) 61 rows and 4 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{i}{The order of clue chosen.}
#'   \item{clue}{The clue read to the contestants.}
#' }
#' @examples
#' whatr_clues(game = 6304)
#' @importFrom dplyr bind_cols mutate  select
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @export
whatr_clues <- function(game) {
  game <- whatr_html(game, "showgame")
  clues <- game %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    entity_clean() %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::bind_cols(whatr_order(game = game)) %>%
    dplyr::select(.data$round, .data$col, .data$row, .data$i, .data$clue)
  return(clues)
}
