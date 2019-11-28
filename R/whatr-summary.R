#' Return a J! Archive game summary
#'
#' This small tibble summaries the various scoring metrics for each player.
#'
#' @details
#' There are three scoring types presented in this summary:
#' 1. The ["coryat" score](https://j-archive.com/help.php#coryatscore): a
#' player's score if all wagering is disregarded. In the Coryat score, there is
#' no penalty for forced incorrect responses on Daily Doubles, but correct
#' responses on Daily Doubles earn only the natural values of the clues, and any
#' gain or loss from the Final Jeopardy! Round is ignored.
#' 2. The final score.
#' 3. The number of clues answered correctly and incorrectly.
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return The J-Archive! game ID number.
#' @examples
#' whatr_summary(game = 6304)
#' @export
whatr_summary <- function(game = NULL, date = NULL, show = NULL) {
  data <- showgame(game, date, show)
  coryat_final <- data %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather(name, coryat) %>%
    dplyr::mutate(
      coryat = coryat %>%
        stringr::str_remove("\\$") %>%
        stringr::str_remove(",") %>%
        base::as.integer()
    )
  final_final <- data %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(4)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather(name, final) %>%
    dplyr::mutate(
      final = final %>%
        stringr::str_remove("\\$") %>%
        stringr::str_remove(",") %>%
        base::as.integer()
    )
  right_wrong <- data %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(2) %>%
    tidyr::gather(name, details) %>%
    tidyr::separate(
      col = details,
      into = c("right", "wrong"),
      sep = ","
    ) %>%
    dplyr::mutate(
      right = right %>%
        stringr::str_extract("(\\d+)") %>%
        base::as.integer()
    ) %>%
    dplyr::mutate(
      wrong = wrong %>%
        stringr::str_extract("(\\d+)") %>%
        base::as.integer()
    )
  summary_scores <- coryat_final %>%
    dplyr::left_join(final_final, by = "name") %>%
    dplyr::left_join(right_wrong, by = "name")
  return(summary_scores)
}
