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
#' @export
whatr_order <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  listed_order <- c(rep(1, 6), rep(2, 6), rep(3, 6), rep(4, 6), rep(5, 6))
  single_order <- showgame %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    as.integer() %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::mutate(row = listed_order[1:nrow(.)]) %>%
    dplyr::mutate(col = rep(1:6, 5)[1:nrow(.)]) %>%
    dplyr::mutate(round = 1)
  double_order <- showgame %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    as.integer() %>%
    magrittr::add(nrow(single_order)) %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::mutate(row = listed_order[1:nrow(.)]) %>%
    dplyr::mutate(col = rep(1:6, 5)[1:nrow(.)]) %>%
    dplyr::mutate(round = 2)
  clue_order <- single_order %>%
    dplyr::bind_rows(double_order) %>%
    dplyr::select(round, clue, col, row) %>%
    dplyr::add_row(
      round = 3,
      clue = nrow(.) + 1,
      col = 1,
      row = 1
    )
  return(clue_order)
}
