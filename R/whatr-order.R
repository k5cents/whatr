#' What is the order?
#'
#' Scrapes clue order left-to-right, top-to-bottom.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of player info.
#' @format A tibble with (usually) 61 rows and 4 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#' }
#' @return A tidy tibble of clue orders.
#' @importFrom dplyr mutate select
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_extract
#' @importFrom tibble enframe
#' @importFrom tidyr separate
whatr_order <- function(game) {
  game <- whatr_html(game, "showgame")
  single_order <- game %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  double_order <- game %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer() %>%
    `+`(max(single_order))
  order <- game %>%
    rvest::html_nodes("table tr td div") %>%
    rvest::html_attr("onmouseover") %>%
    stringr::str_extract("(?<=clue_)(.*)(?=_stuck)") %>%
    tibble::enframe(name = NULL) %>%
    tidyr::separate(
      col = .data$value,
      sep = "', '",
      into = c("one", "two")
    ) %>%
    dplyr::select(.data$one) %>%
    tidyr::separate(
      col = .data$one,
      sep = "_",
      into = c("round", "col", "row"),
      convert = TRUE,
      fill = "right"
    ) %>%
    dplyr::mutate(
      round = as.integer(
        .data$round %>%
          dplyr::recode(
            "J"  = "1",
            "DJ" = "2",
            "FJ" = "3"
          )
      ),
      i = c(
        single_order,
        double_order,
        max(double_order) + 1L
      )
    )
  order$row[length(order$row)] <- 1L
  order$col[length(order$col)] <- 1L
  return(order)
}
