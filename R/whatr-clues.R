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
#'   \item{n}{The order of clue chosen.}
#'   \item{clue}{The clue read to the contestants.}
#' }
#' @examples
#' whatr_clues(game = 6304)
#' whatr_html(6304) %>% whatr_clues()
#' @importFrom dplyr bind_cols mutate  select
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @export
whatr_clues <- function(game) {
  if (is(game, "xml_document") & grepl("ddred", as.character(game), )) {
    stop("a 'showgame' HTML input is needed")
  } else if (!is(game, "xml_document")) {
    game <- whatr_html(x = game, out = "showgame")
  }

  clues <- game %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::bind_cols(whatr_order(game = game)) %>%
    dplyr::select(.data$round, .data$col, .data$row, .data$n, .data$clue)
  return(clues)
}
