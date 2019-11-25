#' Scrape Jeopardy game score history
#'
#' Return the tidy tibble of contestant scores over the course of the game.
#' The tibble indicates what questions were answered correctly and the change
#' in score from each answer.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return Tidy tibble of an episode score history.
#' @family J! scrapers
#' @examples
#' whatr_scores(game = 6304)
#' whatr_scores(date = "2019-06-03")
#' whatr_scores(show = 8006)
#' @importFrom dplyr arrange bind_rows group_by left_join mutate row_number select slice starts_with ungroup
#' @importFrom httr GET
#' @importFrom readr parse_number
#' @importFrom rvest html_node html_nodes html_table html_text
#' @importFrom stringr str_c str_extract str_remove
#' @importFrom tibble as_tibble enframe
#' @importFrom tidyr drop_na pivot_longer
#' @importFrom xml2 read_html
#' @export
whatr_scores <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  showscores <- xml2::read_html(paste0("http://www.j-archive.com/showscores.php?game_id=", game))

  single_doubles <- showscores %>%
    rvest::html_node("#jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer()

  tibble_uniqe <- function(x) {
    suppressMessages(tibble::as_tibble(x, .name_repair = "unique"))
  }

  single_score <- showscores %>%
    rvest::html_node("#jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(fill = TRUE, header = TRUE) %>%
    tibble_uniqe() %>%
    dplyr::select(-dplyr::starts_with("...")) %>%
    dplyr::mutate(clue = dplyr::row_number(), round = 1L) %>%
    tidyr::pivot_longer(
      cols = -c(clue, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(readr::parse_number(score)),
      double = (clue == single_doubles)
    )

  double_doubles <- showscores %>%
    rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::unique() %>%
    base::as.integer()

  double_score <- showscores %>%
    rvest::html_node("#double_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tidyr::drop_na() %>%
    tibble_uniqe() %>%
    dplyr::select(-dplyr::starts_with("...")) %>%
    dplyr::mutate(clue = dplyr::row_number(), round = 2) %>%
    tidyr::pivot_longer(
      cols = -c(clue, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(readr::parse_number(score)),
      double = (clue == double_doubles),
      clue = clue + max(single_score$clue)
    )

  final_scores <- showscores %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    dplyr::slice(1) %>%
    tibble_uniqe() %>%
    dplyr::mutate(
      clue = max(double_score$clue) + 1L,
      round = 3L
    ) %>%
    tidyr::pivot_longer(
      cols = -c(clue, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(score = as.integer(readr::parse_number(score)))

  scores <- single_score %>%
    dplyr::bind_rows(double_score) %>%
    dplyr::bind_rows(final_scores) %>%
    dplyr::arrange(round, clue) %>%
    dplyr::select(round, clue, name, score, double)

  return(scores)
}
