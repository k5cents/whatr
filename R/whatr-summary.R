#' What is the information?
#'
#' _These_ must be given by the contestants in the form of a question in
#' response to the clues asked.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of clue text.
#' @format A tibble with (usually) 3 row and 5 variables:
#' \describe{
#'   \item{name}{The contestant's given name.}
#'   \item{coryat}{Score if all wagering is disregarded.}
#'   \item{final}{Final score after Double Jeopardy.}
#'   \item{right}{Number of correct answers.}
#'   \item{wrong}{Number of incorrect answers.}
#' }
#' @examples
#' whatr_summary(game = 6304)
#' whatr_html(6304) %>% whatr_summary()
#' @export
whatr_summary <- function(game) {
  if (is(game, "xml_document") & grepl("ddred", as.character(game), )) {
    stop("a 'showgame' HTML input is needed")
  } else if (!is(game, "xml_document")) {
    game <- whatr_html(x = game, out = "showgame")
  }

  coryat_final <- game %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather("name", "coryat") %>%
    dplyr::mutate(
      coryat = .data$coryat %>%
        stringr::str_remove("\\$") %>%
        stringr::str_remove(",") %>%
        base::as.integer()
    )
  final_final <- game %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(4)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather("name", "final") %>%
    dplyr::mutate(
      final = .data$final %>%
        stringr::str_remove("\\$") %>%
        stringr::str_remove(",") %>%
        base::as.integer()
    )
  right_wrong <- game %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(2) %>%
    tidyr::gather("name", "details") %>%
    tidyr::separate(
      col = .data$details,
      into = c("right", "wrong"),
      sep = ","
    ) %>%
    dplyr::mutate(
      right = .data$right %>%
        stringr::str_extract("(\\d+)") %>%
        base::as.integer()
    ) %>%
    dplyr::mutate(
      wrong = .data$wrong %>%
        stringr::str_extract("(\\d+)") %>%
        base::as.integer()
    )
  summary_scores <- coryat_final %>%
    dplyr::left_join(final_final, by = "name") %>%
    dplyr::left_join(right_wrong, by = "name")
  return(summary_scores)
}
