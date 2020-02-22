#' What are the clues?
#'
#' Return
#'
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
#' @return A list of tibbles.
#' @examples
#' whatr_data(game = 6304)
#' @importFrom dplyr bind_cols mutate  select
#' @importFrom rvest html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @export
whatr_data <- function(game) {
  showgame <- read_game(game)
  showscores <- read_scores(game)
  data <- list(
    info = whatr_info(showgame),
    summary = whatr_summary(showgame),
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
#' @param html An HTML document from [read_game()].
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
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
whatr_board <- function(html = NULL, game = NULL) {
  if (is.null(html)) {
    showgame <- read_game(game)
  } else {
    showgame <- html
  }
  cats <- whatr_categories(showgame)
  clues <- whatr_clues(showgame)
  answers <- whatr_answers(showgame)
  board <- cats %>%
    dplyr::left_join(clues, by = c("round", "col")) %>%
    dplyr::left_join(answers, by = c("round", "col", "row", "n")) %>%
    dplyr::select(1, 2, 4, 5, 3, 6, 7)
  return(board)
}
