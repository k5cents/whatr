#' What is the air date?
#'
#' _This_ date identifies when an episode was first viewed on television.
#'
#' @inheritParams whatr_scores
#' @return A tidy tibble of clue text.
#' @format A tibble with 1 row and 3 variables:
#' \describe{
#'   \item{game}{The non-sequential J! Archive game ID.}
#'   \item{show}{The sequential show number of an episode.}
#'   \item{date}{The air date of an episode.}
#' }
#' @examples
#' whatr_airdate(game = 6304)
#' @importFrom rvest html_node html_text
#' @importFrom stringr str_extract
#' @importFrom tibble tibble
#' @export
whatr_airdate <- function(game) {
  game <- whatr_html(game, "showgame")
  c <- as.character(game)
  id <- stringr::str_extract(c, "(?<=chartgame.php\\?game_id\\=)\\d+")
  title <- rvest::html_text(rvest::html_node(game, "title"))
  info <- tibble::tibble(
    game = as.integer(id),
    show = as.integer(stringr::str_extract(title, "(\\d+)")),
    date = as.Date(stringr::str_extract(title, "\\d+-\\d+-\\d+$"))
  )
  return(info)
}
