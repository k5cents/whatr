#' What are player scores?
#'
#' This data frame has data on the performance of each contestant.
#'
#' @param html An HTML document from [read_scores()].
#' @param game The J-Archive! game ID number.
#' @return Tidy tibble of clue scores.
#' @format A tibble with 52 rows and 8 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{n}{The order of clue chosen.}
#'   \item{name}{First name of player responding.}
#'   \item{score}{Change in score from this clue.}
#'   \item{double}{Is the clue a daily double.}
#' }
#' @examples
#' whatr_scores(game = 6304)
#' read_scores(6304) %>% whatr_scores()
#' @importFrom dplyr arrange bind_rows group_by mutate select slice ungroup lag
#' @importFrom rvest html_node html_nodes html_table html_text
#' @importFrom stringr str_remove_all
#' @importFrom tibble as_tibble
#' @importFrom tidyr drop_na pivot_longer
#' @export
whatr_scores <- function(html = NULL, game = NULL) {
  # read showscore html
  if (is.null(html)) {
    showscores <- read_scores(game)
  } else {
    showscores <- html
  }

  # find round 1 doubles location
  single_doubles <- showscores %>%
    rvest::html_node("#jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer()

  # pivot round 1 scores
  single_score <- showscores %>%
    rvest::html_node("#jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(fill = TRUE, header = TRUE) %>%
    magrittr::extract(, 2:4) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(n = seq(1L, nrow(.)), round = 1L) %>%
    tidyr::pivot_longer(
      cols = -c(n, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(score, "[^\\d]")),
      double = (n == single_doubles)
    )

  # find round 2 doubles location
  double_doubles <- showscores %>%
    rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer() %>%
    base::unique()

  # pivot round 2 scores
  double_score <- showscores %>%
    rvest::html_node("#double_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(fill = TRUE, header = TRUE) %>%
    tidyr::drop_na() %>%
    magrittr::extract(, 2:4) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(n = seq(1L, nrow(.)), round = 1L) %>%
    tidyr::pivot_longer(
      cols = -c(n, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(score, "[^\\d]")),
      double = (n %in% double_doubles),
      n = n + max(single_score$n)
    )

  # pivot round 3 scores
  final_scores <- showscores %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    dplyr::slice(1) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(
      n = max(double_score$n) + 1L,
      round = 3L
    ) %>%
    tidyr::pivot_longer(
      cols = -c(n, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(score, "[^\\d]")),
      double = FALSE
    )

  # bind all scores and tidy
  scores <- single_score %>%
    dplyr::bind_rows(double_score) %>%
    dplyr::bind_rows(final_scores) %>%
    dplyr::group_by(name) %>%
    dplyr::mutate(score = ifelse(n == 1, score, score - dplyr::lag(score))) %>%
    dplyr::ungroup() %>%
    dplyr::filter(score != 0 | n == 1) %>%
    dplyr::arrange(round, n) %>%
    dplyr::select(round, n, name, score, double)

  return(scores)
}
