#' What are daily doubles?
#'
#' _These_ types of clues have no dollar value. Players wager some of their
#' score before hearing the clue. In the first round, one such clue is present;
#' in the second round, there are two.
#'
#' @inheritParams whatr_scores
#' @return a list containing the question indices of the daily doubles
#' in the first and second rounds
#' @format a named list
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{i}{The order of clue chosen.}
#'   \item{clue}{The clue read to the contestants.}
#'   \item{score}{The amount won or lost on the wager.}
#' }
#' @examples
#' whatr_doubles(game = 6304)
#' @export
whatr_doubles <- function(game) {
  showgame <- whatr_html(game, out = "showgame")
  showscores <- whatr_html(game, out = "showscores")
  order <- whatr_order(showgame)
  doubles <- whatr_scores(showscores) %>%
    dplyr::filter(double) %>%
    dplyr::select(-5)
  doubles <- dplyr::inner_join(order, doubles, by = c("round", "i"))
  return(doubles)
}
