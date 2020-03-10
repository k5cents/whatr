#' What are player scores?
#'
#' _This_ data describes how players performed over the course of a game.
#'
#' @param game One of four types of input, all passed to [whatr_html()]:
#' 1. A numeric game ID.
#' 2. Either a 'showgame' or 'showscores' HTML document.
#' 3. A show number character starting with "#".
#' 4. An air date like "yyyy-mm-dd".
#' @return Tidy tibble of clue scores.
#' @format A tibble with (up to) 61 rows and 5 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{i}{The order of clue chosen.}
#'   \item{name}{First name of player responding.}
#'   \item{score}{Change in score from this clue.}
#'   \item{double}{Is the clue a daily double.}
#' }
#' @examples
#' whatr_scores(game = 6304)
#' @importFrom dplyr arrange bind_rows group_by lag mutate row_number select
#'   slice ungroup
#' @importFrom rlang .data
#' @importFrom rvest html_node html_nodes html_table html_text
#' @importFrom stringr str_remove_all
#' @importFrom tibble as_tibble
#' @importFrom tidyr drop_na pivot_longer
#' @export
whatr_scores <- function(game) {
  game <- whatr_html(game, "showscores")
  single_doubles <- game %>%
    rvest::html_node("#jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer()
  single_score <- game %>%
    rvest::html_node("#jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(fill = TRUE, header = TRUE) %>%
    magrittr::extract(, 2:4) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(i = dplyr::row_number(), round = 1L) %>%
    tidyr::pivot_longer(
      cols = -c(.data$i, .data$round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(.data$score, "[^\\d]")),
      double = (.data$i %in% single_doubles)
    )
  double_doubles <- game %>%
    rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer() %>%
    base::unique()
  double_score <- game %>%
    rvest::html_node("#double_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(fill = TRUE, header = TRUE) %>%
    tidyr::drop_na() %>%
    magrittr::extract(, 2:4) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(i = dplyr::row_number(), round = 2L) %>%
    tidyr::pivot_longer(
      cols = -c(.data$i, .data$round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(.data$score, "[^\\d]")),
      double = (.data$i %in% double_doubles),
      i = .data$i + max(single_score$i)
    )
  final_scores <- game %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    dplyr::slice(1) %>%
    tibble::as_tibble() %>%
    dplyr::mutate(i = max(double_score$i) + 1L, round = 3L) %>%
    tidyr::pivot_longer(
      cols = -c(.data$i, .data$round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(.data$score, "[^\\d]")),
      double = FALSE
    )
  scores <- single_score %>%
    dplyr::bind_rows(double_score) %>%
    dplyr::bind_rows(final_scores) %>%
    dplyr::group_by(.data$name) %>%
    dplyr::mutate(score = dplyr::if_else(
      condition = .data$i == 1,
      true = .data$score,
      false = .data$score - dplyr::lag(.data$score))
    ) %>%
    dplyr::ungroup() %>%
    dplyr::filter(.data$score != 0) %>%
    dplyr::arrange(.data$round, .data$i) %>%
    dplyr::select(.data$round, .data$i, .data$name, .data$score, .data$double)
  return(scores)
}
