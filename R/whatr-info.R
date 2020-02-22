#' What is the information?
#'
#' _These_ must be given by the contestants in the form of a question in
#' response to the clues asked.
#'
#' @param html An HTML document from [read_game()].
#' @param game The J-Archive! game ID number, possibly from [whatr_id()].
#' @return A tidy tibble of clue text.
#' @format A tibble with 1 row and 3 variables:
#' \describe{
#'   \item{game}{The non-sequential J! Archive game ID.}
#'   \item{show}{The sequential show number of an episode.}
#'   \item{date}{The air date of an episode.}
#' }
#' @examples
#' whatr_info(game = 6304)
#' read_game(6304) %>% whatr_info()
#' @importFrom rvest html_node html_text
#' @importFrom stringr str_extract
#' @importFrom tibble tibble
#' @export
whatr_info <- function(html = NULL, game = NULL) {
  if (is.null(html)) {
    showgame <- read_game(game)
  } else {
    showgame <- html
    game <- as.character(html) %>%
      str_extract("(?<=chartgame.php\\?game_id\\=)\\d+")
  }

  title <- rvest::html_text(rvest::html_node(showgame, "title"))
  info <- tibble::tibble(
    game = as.integer(game),
    show = as.integer(stringr::str_extract(title, "(\\d+)")),
    date = as.Date(stringr::str_extract(title, "\\d+-\\d+-\\d+$"))
  )
  return(info)
}
