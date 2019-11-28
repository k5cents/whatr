#' Scrape Jeopardy game board
#'
#' This joins together the results of [whatr_categories()], [whatr_clues()] and
#' [whatr_answers] to return a single tibble with all clue/answer combinations.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tibble of categories and positions.
#' @examples
#' whatr_board(game = 6304)
#' @importFrom xml2 read_html
#' @importFrom rvest html_nodes html_text html_attr
#' @importFrom stringr str_to_title str_replace_all str_extract str_split str_remove_all
#' @importFrom tibble enframe
#' @importFrom dplyr mutate select recode add_row bind_cols left_join
#' @importFrom tidyr separate
#' @export
whatr_board <- function(game = NULL, date = NULL, show = NULL) {
  data <- showgame(game, date, show)
  categories <- data %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text(trim = TRUE) %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(name = NULL, value = "category") %>%
    dplyr::mutate(
      round = c(rep(1L, 6), rep(2L, 6), 3L),
      col = c(1L:6L, 1L:6L, 0L)
    ) %>%
    dplyr::select(round, col, category)
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
  extract_answer <- function(node) {
    node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text()
  }
  clues <- data %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::bind_cols(order) %>%
    dplyr::select(round, col, row, n, clue)
  final_answer <- data %>%
    rvest::html_node(".final_round") %>%
    base::as.character() %>%
    stringr::str_split("class") %>%
    base::unlist() %>%
    magrittr::extract(stringr::str_which(., "correct_response")) %>%
    stringr::str_extract(";&gt;(.*)&lt;/") %>%
    stringr::str_remove(";&gt;") %>%
    stringr::str_remove("&lt;/") %>%
    stringr::str_to_title()
  answers <- data %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    base::unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer) %>%
    dplyr::bind_cols(order) %>%
    dplyr::select(round, col, row, n, answer)
  categories %>%
    dplyr::left_join(clues, by = c("round", "col")) %>%
    dplyr::left_join(answers, by = c("round", "col", "row", "n")) %>%
    dplyr::select(n, category, clue, answer)
}
