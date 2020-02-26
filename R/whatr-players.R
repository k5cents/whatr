#' Who are the players?
#'
#' These individuals compete to score the most points and win the game.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of player info.
#' @format A tibble with 52 rows and 8 variables:
#' \describe{
#'   \item{first}{The contestant's given name.}
#'   \item{last}{The contestant's surname name.}
#'   \item{occupation}{A short description of what the contestant does.}
#'   \item{city}{The first part of the contestants home, usually a city.}
#'   \item{state}{The second part of the contestants home, usually a state.}
#' }
#' @examples
#' whatr_players(game = 6304)
#' whatr_html(6304) %>% whatr_players()
#' @importFrom dplyr mutate pull
#' @importFrom rlang .data
#' @importFrom rvest html_node html_table
#' @importFrom stringr str_replace_all str_remove str_split str_to_title
#'   str_trim word
#' @importFrom tibble enframe
#' @importFrom tidyr separate
#' @export
whatr_players <- function(game) {
  if (is(game, "xml_document") & grepl("ddred", as.character(game), )) {
    stop("a 'showgame' HTML input is needed")
  } else if (!is(game, "xml_document")) {
    game <- whatr_html(x = game, out = "showgame")
  }

  # enframe and split cols
  players <- game %>%
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
