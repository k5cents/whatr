#' Who are the players?
#'
#' _These_ individuals compete to score the most points and win the game.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of player info.
#' @format A tibble with (usually) 3 rows and 4 variables:
#' \describe{
#'   \item{first}{The contestant's given name.}
#'   \item{last}{The contestant's surname name.}
#'   \item{occupation}{A short description of what the contestant does.}
#'   \item{from}{The city or institution from where the contestant comes.}
#' }
#' @examples
#' whatr_players(game = 6304)
#' @importFrom dplyr mutate pull
#' @importFrom rlang .data
#' @importFrom rvest html_node html_table
#' @importFrom stringr str_replace_all str_remove str_split str_to_title
#'   str_trim word
#' @importFrom tibble enframe
#' @importFrom tidyr separate
#' @export
whatr_players <- function(game) {
  game <- whatr_html(game, "showgame")
  players <- game %>%
    rvest::html_node("#contestants_table") %>%
    rvest::html_table(fill = TRUE) %>%
    dplyr::pull(2) %>%
    stringr::str_split(pattern = "\n") %>%
    base::unlist() %>%
    entity_clean() %>%
    stringr::str_remove("\\s\\(.*") %>%
    stringr::str_remove("(?<=,\\s)A\\s") %>%
    stringr::str_subset("^Team\\s", negate = TRUE) %>%
    stringr::str_remove("Playing(.*)Round:\\s") %>%
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
      sep = "\\s",
      extra = "merge"
    ) %>%
    tidyr::separate(
      col = .data$bio,
      sep = "\\sFrom\\s",
      into = c("occupation", "from"),
      extra = "merge"
    )
  return(players)
}
