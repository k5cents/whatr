#' Get the clue numbers that coorespond to the daily doubles
#'
#' @inheritParams whatr_scores
#' @return a list containing the question indices of the daily doubles
#' in the first and second rounds
#' @format a named list
#' \describe{
#'  \item{single}{The index of the daily double in the first round}
#'  \item{double}{The indices of the two daily doubles in the second round}
#' }
#' @examples
#' whatr_doubles(game = 6304)
#' @export
whatr_doubles <- function(game) {
  if (is(game, "xml_document") & !grepl("ddred", as.character(game), )) {
    stop("a 'showscores' HTML input is needed")
  } else if (!is(game, "xml_document")) {
    game <- whatr_html(x = game, out = "showscores")
  }

  single_doubles <- game %>%
    rvest::html_node("#jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer()

  double_doubles <- game %>%
    rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer() %>%
    base::unique()

  return(list(single = single_doubles, double = double_doubles))
}
