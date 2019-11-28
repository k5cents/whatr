#' Scrape Jeopardy game correct responses
#'
#' In this context, the "answers" are the "questions" given by the contentsants
#' in response to a clue. This function only returns the _correct_ response
#' to a clue, not all responses given by contestants.
#'
#' @details
#' From the [J! Archive glossary](https://j-archive.com/help.php#response):
#' \[Responses are\] a contestant's "answer" to a clue, phrased in the form of a
#' question. A correct response results in the addition to a player's score the
#' value of the clue... an incorrect response results in the subtraction from
#' the player's score the clue's value (or the wager). A clue may have multiple
#' different acceptable correct responses or correct response variations, some
#' of them unanticipated by the writers and judges...
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tidy tibble or correct answers.
#' @examples
#' whatr_answers(game = 6304)
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_split str_extract str_remove str_to_title str_replace_all fixed str_which str_remove_all
#' @importFrom magrittr extract
#' @importFrom purrr map
#' @importFrom dplyr add_row bind_cols select
#' @importFrom tibble enframe
#' @export
whatr_answers <- function(game = NULL, date = NULL, show = NULL) {
  data <- showgame(game, date, show)
  extract_answer <- function(node) {
    node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text()
  }
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
  data %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    base::unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer) %>%
    dplyr::bind_cols(whatr_order(game)) %>%
    dplyr::select(round, col, row, n, answer)
}
