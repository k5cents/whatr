#' Scrape Jeopardy game clues order
#'
#' Contestants are free to chose clues from the board in whatever order they
#' want. This function returns the position of each clue on the board and the
#' order in which they are chosen.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tidy tibble of clue orders.
#' @examples
#' whatr_order(game = 6304)
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_to_title str_replace_all
#' @importFrom tibble enframe
#' @importFrom dplyr mutate left_join select bind_rows add_row
#' @importFrom magrittr add
#' @importFrom tidyr separate
whatr_order <- function(game = NULL, date = NULL, show = NULL) {
  data <- showgame(game, date, show)
  single_order <- data %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  double_order <- data %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  order <- data %>%
    rvest::html_nodes("table tr td div") %>%
    rvest::html_attr("onmouseover") %>%
    stringr::str_extract("(?<=clue_)(.*)(?=_stuck)") %>%
    tibble::enframe(name = NULL) %>%
    tidyr::separate(
      col = value,
      sep = "', '",
      into = c("one", "two")
    ) %>%
    dplyr::select(one) %>%
    tidyr::separate(
      col = one,
      sep = "_",
      into = c("round", "col", "row"),
      convert = TRUE,
      fill = "right"
    ) %>%
    dplyr::mutate(
      round = as.integer(
        round %>%
          dplyr::recode(
            "J"  = "1",
            "DJ" = "2",
            "FJ" = "3"
          )
      ),
      n = c(
        single_order,
        double_order + max(single_order),
        max(double_order) + 1L
      )
    )
  order$row[length(order$row)] <- 0
  order$col[length(order$col)] <- 0
  return(order)
}
