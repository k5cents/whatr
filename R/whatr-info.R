#' Scrape Jeopardy game air data
#'
#' @param game A J-Archive! game ID number
#' @return Tibble of a Jeopardy! episode air information
#' @export

whatr_info <- function(game = NULL, date = NULL, show = NULL) {

  # import pipe opperator
  `%>%` <- magrittr::`%>%`

  # create url and read html -------------------------------------------------------------------

  # define the initial URL based on the aegument type
  base_url <-
    if (!is.null(game)) {
      stringr::str_c("http://www.j-archive.com/showgame.php?game_id=", game)
    } else {
      if (!is.null(date)) {
        stringr::str_c("http://www.j-archive.com/search.php?search=date:", as.Date(date))
      } else {
        if (!is.null(show)) {
          stringr::str_c("www.j-archive.com/search.php?search=show:", show)
        } else {
          stop("A game identifyer is needed")
        }
      }
    }

  # date and show arguments redirect to game url
  response <- httr::GET(base_url)

  # extract the redirected url if needed
  final_url <- if (is.null(game)) response$url else base_url

  # create INFO table --------------------------------------------------------------------------

  # extract the game id from end of final url
  game <- stringr::str_extract(final_url, "\\d+$")

  # read the redirected page content as html
  showgame <- xml2::read_html(response$content)

  # extract html title as string
  title <- showgame %>%
    rvest::html_node("title") %>%
    rvest::html_text()

  # extract air date from end of title string
  date <- as.Date(stringr::str_extract(title, "\\d+-\\d+-\\d+$"))

  # extract show number from start of title string
  show <- as.integer(stringr::str_extract(title, "(\\d+)"))

  # define the INFO table
  info <- tibble::tibble(
    game = game,
    show = show,
    date = date
  )

  return(info)
}
