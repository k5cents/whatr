#' Scrape Jeopardy game meta data
#'
#' @param game_id A J-Archive! game ID number
#' @return Tibble of a Jeopardy game player names
#' @importFrom dplyr mutate pull slice select bind_rows arrange group_by ungroup lag everything
#' @export

whatr_players <- function(game = NULL, date = NULL, show = NULL) {

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

  # extract the game id from end of final url
  game <- stringr::str_extract(final_url, "\\d+$")

  # read the redirected page content as html
  showgame <- xml2::read_html(response$content)

  # extract html title as string
  title <- showgame %>%
    rvest::html_node("title") %>%
    rvest::html_text()

  # extract contestants html table
  players <- showgame %>%
    rvest::html_node("#contestants_table") %>%
    rvest::html_table(fill = TRUE) %>%
    dplyr::pull(2) %>%
    stringr::str_split(pattern = "\n") %>%
    unlist() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "text") %>%
    # seperate the string into name, occupation, city, and state
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
    dplyr::mutate(occupation = occupation %>%
                    stringr::word(2, -1) %>%
                    stringr::str_to_title()
    ) %>%
    tidyr::separate(
      col = "from",
      sep = ",\\s",
      into = c("city", "state")
    )

  # return final table
  return(players)
}
