#' Scrape Jeopardy game correct responses
#'
#' In this context, the "answers" are the "questions" given by the contentsants
#' in response to a clue. This function only returns the _correct_ response
#' to a clue, not all responses given by contestants.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tidy tibble or correct answers.
#' @examples
#' whatr_responses(game = 6304)
#' @importFrom httr GET
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_split str_extract str_remove str_to_title str_replace_all fixed str_which
#' @importFrom magrittr extract
#' @importFrom purrr map
#' @importFrom dplyr add_row bind_cols select
#' @export
whatr_responses <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  extract_answer <- function(node) {
    node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text()
  }
  final_answer <- showgame %>%
    rvest::html_node(".final_round") %>%
    base::as.character() %>%
    stringr::str_split("class") %>%
    base::unlist() %>%
    magrittr::extract(stringr::str_which(., "correct_response")) %>%
    stringr::str_extract(";&gt;(.*)&lt;/") %>%
    stringr::str_remove(";&gt;") %>%
    stringr::str_remove("&lt;/") %>%
    stringr::str_to_title()
  showgame %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    base::unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer) %>%
    dplyr::bind_cols(whatr_order(game)) %>%
    dplyr::select(round, clue, col, row, answer)
}
