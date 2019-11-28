#' Scrape Jeopardy game contestant info
#'
#' For a given episode, find the J! Archive's record of each contestant's name,
#' occupation, and home town as they are introduced on the show.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A tidy tibble of player info.
#' @examples
#' whatr_players(game = 6304)
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_table
#' @importFrom stringr str_replace_all str_remove str_split str_to_title str_trim word
#' @importFrom tidyr drop_na
#' @importFrom tibble enframe
#' @importFrom tidyr separate
#' @importFrom dplyr mutate pull
#' @export
whatr_players <- function(game = NULL, date = NULL, show = NULL) {
  data <- showgame(game, date, show)
  data %>%
    rvest::html_node("#contestants_table") %>%
    rvest::html_table(fill = TRUE) %>%
    dplyr::pull(2) %>%
    stringr::str_split(pattern = "\n") %>%
    base::unlist() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "text") %>%
    tidyr::separate(
      col = text,
      into = c("name", "bio"),
      sep = ",\\s",
      extra = "merge"
    ) %>%
    dplyr::mutate(name = stringr::str_trim(name)) %>%
    tidyr::separate(
      col = name,
      into = c("first", "last"),
      sep = "\\s"
    ) %>%
    dplyr::mutate(bio = stringr::str_remove(bio, "\\s\\(.*")) %>%
    tidyr::separate(
      col = bio,
      sep = "\\s(from)\\s",
      into = c("occupation", "from")
    ) %>%
    dplyr::mutate(
      occupation = occupation %>%
        stringr::word(2, -1) %>%
        stringr::str_to_title()
    ) %>%
    tidyr::separate(
      col = "from",
      sep = ",\\s",
      into = c("city", "state")
    )
}
