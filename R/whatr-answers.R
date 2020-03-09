#' What are the answers?
#'
#' _These_ must be given by the contestants in the form of a question in
#' response to the clues asked.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of clue text.
#' @format A tibble with (usually) 61 rows and 5 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{n}{The order of clue chosen.}
#'   \item{answer}{The _correct_ answer to a clue.}
#' }
#' @examples
#' whatr_answers(game = 6304)
#' whatr_html(6304) %>% whatr_answers()
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
      rvest::html_text()
  }
  final_answer <- game %>%
    rvest::html_node(".final_round") %>%
    base::as.character() %>%
    stringr::str_split("class") %>%
    base::unlist() %>%
    stringr::str_subset("correct_response") %>%
    entity_clean()
  answers <- game %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    base::unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer)
  answers <- dplyr::bind_cols(whatr_order(game = game), answers)
  return(answers)
}
