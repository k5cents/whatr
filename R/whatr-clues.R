#' What are the clues?
#'
#' Confusingly, _these_ are posed to contestants in the form of an answer.
#'
#' @param html An HTML document from [read_game()].
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
#' @return A tidy tibble of clue text.
#' @format A tibble with (usually) 61 rows and 4 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{clue}{The clue read to the contestants.}
#' }
#' @examples
#' whatr_clues(game = 6304)
#' read_game(6304) %>% whatr_clues()
#' @importFrom dplyr bind_cols mutate  select
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @export
whatr_clues <- function(html = NULL, game = NULL) {
  if (is.null(html)) {
    showgame <- read_game(game)
  } else {
    showgame <- html
    game <- as.character(html) %>%
      str_extract("(?<=chartgame.php\\?game_id\\=)\\d+")
  }

  clues <- showgame %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::bind_cols(whatr_order(game = game)) %>%
    dplyr::select(.data$round, .data$col, .data$row, .data$n, .data$clue)
  return(clues)
}
