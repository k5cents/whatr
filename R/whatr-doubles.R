#' Get the clue numbers that coorespond to the daily doubles
#'
#' @param html An HTML document from [read_scores()].
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
#' @return a list containing the question indices of the daily doubles
#' in the first and second rounds
#' @format a named list
#' \describe{
#'  \item{single}{The index of the daily double in the first round}
#'  \item{double}{The indices of the two daily doubles in the second round}
#' }
#' @examples
#' whatr_doubles(game = 6304)
#' read_scores(6304) %>% whatr_douibles()
#' @export
whatr_doubles <- function(html = NULL, game = NULL){
  if (!is.null(html)){
    data <- html
  } else data <- read_scores(game = game)

  single_doubles <- data %>%
    rvest::html_node("#jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer()

  double_doubles <- data %>%
    rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer() %>%
    base::unique()

  return(list(single = single_doubles, double = double_doubles))
}
