#' What is the order?
#'
#' Scrapes clue order left-to-right, top-to-bottom.
#'
#' @param html An HTML document from [read_game()].
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
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
whatr_order <- function(html = NULL, game = NULL) {
  if (is.null(html)) {
    showgame <- read_game(game)
  } else {
    showgame <- html
    game <- as.character(html) %>%
      str_extract("(?<=chartgame.php\\?game_id\\=)\\d+")
  }

  single_order <- showgame %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  double_order <- showgame %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  order <- showgame %>%
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
      n = c(
        single_order,
        double_order + max(single_order),
        max(single_order) + max(double_order) + 1L
      )
    )
  order$row[length(order$row)] <- 1L
  order$col[length(order$col)] <- 1L
  return(order)
}
