#' Who are the players?
#'
#' These individuals compete to score the most points and win the game.
#'
#' @param html An HTML document from [read_scores()].
#' @param game The J-Archive! game ID number.
#' @return A tidy tibble of player info.
#' @examples
#' whatr_players(game = 6304)
#' read_game(6304) %>% whatr_players()
#' @importFrom dplyr mutate pull
#' @importFrom rlang .data
#' @importFrom rvest html_node html_table
#' @importFrom stringr str_replace_all str_remove str_split str_to_title
#'   str_trim word
#' @importFrom tidyr drop_na
#' @importFrom tibble enframe
#' @importFrom tidyr separate
#' @export
whatr_players <- function(html = NULL, game = NULL) {
  # read showgame html
  if (is.null(html)) {
    showgame <- read_game(game)
  } else {
    showgame <- html
  }

  # enframe and split cols
  players <- showgame %>%
    rvest::html_node("#contestants_table") %>%
    rvest::html_table(fill = TRUE) %>%
    dplyr::pull(2) %>%
    stringr::str_split(pattern = "\n") %>%
    base::unlist() %>%
    stringr::str_trim(side = "both") %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "text") %>%
    tidyr::separate(
      col = .data$text,
      into = c("name", "bio"),
      sep = ",\\s",
      extra = "merge"
    ) %>%
    tidyr::separate(
      col = .data$name,
      into = c("first", "last"),
      sep = "\\s"
    ) %>%
    dplyr::mutate(bio = stringr::str_remove(.data$bio, "\\s\\(.*")) %>%
    tidyr::separate(
      col = .data$bio,
      sep = "\\s(from)\\s",
      into = c("occupation", "from")
    ) %>%
    dplyr::mutate(
      occupation = .data$occupation %>%
        stringr::word(2, -1) %>%
        stringr::str_to_title()
    ) %>%
    tidyr::separate(
      col = "from",
      sep = ",\\s",
      into = c("city", "state")
    )
  return(players)
}
