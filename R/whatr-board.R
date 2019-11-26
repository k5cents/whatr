#' Scrape Jeopardy game meta data
#'
#' @param game A J-Archive! game ID number
#' @return Tibble of a Jeopardy! episode categories, questions, and answers
#' @export

whatr_data <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)

  # define the typical order of clues listed left-right
  listed_order <- c(rep(1, 6), rep(2, 6), rep(3, 6), rep(4, 6), rep(5, 6))

  # read left-right order of clues chosen
  single_order <- showgame %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    as.integer() %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::mutate(row = listed_order[1:nrow(.)]) %>%
    dplyr::mutate(col = rep(1:6, 5)[1:nrow(.)]) %>%
    dplyr::mutate(round = 1)

  # repeat for double jeopardy round
  double_order <- showgame %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    as.integer() %>%
    magrittr::add(nrow(single_order)) %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::mutate(row = listed_order[1:nrow(.)]) %>%
    dplyr::mutate(col = rep(1:6, 5)[1:nrow(.)]) %>%
    dplyr::mutate(round = 2)

  # bind all three round clue locations
  clue_order <- single_order %>%
    dplyr::bind_rows(double_order) %>%
    dplyr::select(round, clue, col, row) %>%
    dplyr::add_row(
      round = 3,
      clue = nrow(.) + 1,
      col = NA,
      row = NA
    )

  # create CATEGORY sub-table
  categories <- showgame %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(value = "category", name = NULL) %>%
    dplyr::mutate(round = c(rep(1, 6), rep(2, 6), 3)) %>%
    dplyr::mutate(col = c(1:6, 1:6, NA)) %>%
    dplyr::select(round, col, category)

  # create QUESTIONS sub-table
  questions <- showgame %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "question") %>%
    dplyr::mutate(clue = clue_order$clue) %>%
    dplyr::left_join(clue_order, question_text, by = "clue") %>%
    dplyr::select(round, col, row, clue, question)

  # create the table of answer locations
  # can't remember if this is neccesary
  # answers are listed left-right top-bottom
  # might differ if answers aren't revealed
  answer_locations <- showgame %>%
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
      round = round %>%
        dplyr::recode(
          "J"  = "1",
          "DJ" = "2",
          "FJ" = "3"
        ) %>% as.integer()
    )

  # create sub-function to extract mouseover text
  extract_answer <- function(node) {
    node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text()
  }

  # extract the final jeopardy answer from character string
  # has to be a way to do with rvest
  final_answer <- showgame %>%
    rvest::html_node(".final_round") %>%
    as.character() %>%
    stringr::str_split("class") %>%
    unlist() %>%
    magrittr::extract(stringr::str_which(., "correct_response")) %>%
    stringr::str_extract(";&gt;(.*)&lt;/") %>%
    stringr::str_remove(";&gt;") %>%
    stringr::str_remove("&lt;/") %>%
    stringr::str_to_title()

  # create ANSWERS sub-table
  answers <- showgame %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer) %>%
    dplyr::mutate(clue = c(single_order$clue, double_order$clue, nrow(double_order) + 1)) %>%
    dplyr::bind_cols(answer_locations) %>%
    dplyr::select(round, clue, col, row, answer)

  # bind all sub-BOARD tables
  board <- questions %>%
    dplyr::left_join(answers, by = c("round", "col", "row", "clue")) %>%
    dplyr::left_join(categories, by = c("round", "col")) %>%
    dplyr::select(clue, category, question, answer) %>%
    dplyr::arrange(clue)

  # return final list
  return(board)
}
