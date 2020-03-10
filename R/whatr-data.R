#' What is the board?
#'
#' _This_ is the name for game mechanic displaying all categories and clues.
#'
#' @inheritParams whatr_scores
#' @return A list of tibbles.
#' @examples
#' whatr_data(game = 6304)
#' @importFrom dplyr bind_cols mutate  select
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @export
whatr_data <- function(game) {
  showgame <- whatr_html(game, out = "showgame")
  showscores <-  whatr_html(game, out = "showscores")
  data <- list(
    info = whatr_airdate(showgame),
    summary = whatr_synopsis(showgame),
    players = whatr_players(showgame),
    scores = whatr_scores(showscores),
    board = whatr_board(showgame)
  )
  return(data)
}

#' What is the board?
#'
#' _This_ grid contains all the categories, clues, and answers in a game.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of clue text.
#' @format A tibble with (usually) 61 rows and 4 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{n}{The order of clue chosen.}
#'   \item{category}{Category title, often humorous or with instructions.}
#'   \item{clue}{The clue read to the contestants.}
#'   \item{answer}{The _correct_ answer to a clue.}
#' }
#' @examples
#' whatr_board(game = 6304)
#' @importFrom dplyr left_join
#' @export
whatr_board <- function(game) {
  game <- whatr_html(game, "showgame")
  cats <- whatr_categories(game)
  clues <- whatr_clues(game)
  answers <- whatr_answers(game)
  board <- cats %>%
    dplyr::left_join(clues, by = c("round", "col")) %>%
    dplyr::left_join(answers, by = c("round", "col", "row", "i")) %>%
    dplyr::select(1, 2, 4, 5, 3, 6, 7)
  return(board)
}
