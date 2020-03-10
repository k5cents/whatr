#' What are the answers?
#'
#' _These_ must be given by the contestants in the form of a question as a
#' response to the clues given.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of answer text.
#' @format A tibble with (up to) 61 rows and 5 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{i}{The order of clue chosen.}
#'   \item{answer}{The _correct_ answer to a clue.}
#' }
#' @examples
#' whatr_answers(game = 6304)
#' @importFrom xml2 read_html
#' @importFrom rvest html_attr html_nodes html_text
#' @importFrom stringr str_split str_extract str_to_title
#'   str_replace_all fixed str_which str_remove_all
#' @importFrom magrittr extract
#' @importFrom purrr map_chr
#' @importFrom dplyr add_row bind_cols
#' @importFrom tibble enframe
#' @export
whatr_answers <- function(game) {
  game <- whatr_html(game, "showgame")
  extract_answer <- function(node) {
    answer <- node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text() %>%
      entity_clean()
  }
  final_answer <- game %>%
    rvest::html_node(".final_round tr td div") %>%
    rvest::html_attr("onmouseover") %>%
    stringr::str_remove_all(fixed("\\")) %>%
    xml2::read_html() %>%
    rvest::html_node("body") %>%
    rvest::html_node("em.correct_response") %>%
    rvest::html_text() %>%
    entity_clean()
  answers <- game %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    base::unlist() %>%
    entity_clean() %>%
    base::append(final_answer) %>%
    tibble::enframe(name = NULL, value = "answer")
  answers <- dplyr::bind_cols(whatr_order(game = game), answers)
  return(answers)
}
