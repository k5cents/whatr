#' Scrape Jeopardy game summary scores
#'
#' @param game A J-Archive! game ID number
#' @return Tibble of Jeopardy! episode summary scores
#' @export

whatr_data <- function(game = NULL, date = NULL, show = NULL) {

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

  # read the redirected page content as html
  showgame <- xml2::read_html(response$content)

  # extract the coryat scores html table
  coryat_final <- showgame %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather(name, coryat) %>%
    dplyr::mutate(coryat = coryat %>%
                    stringr::str_remove("\\$") %>%
                    stringr::str_remove(",") %>%
                    as.numeric())

  # extract the final scores html table
  final_final <- showgame %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(4)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather(name, final) %>%
    dplyr::mutate(final = final %>%
                    stringr::str_remove("\\$") %>%
                    stringr::str_remove(",") %>%
                    as.numeric())

  # create a table of right & wrong responses
  right_wrong <- showgame %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(2) %>%
    tidyr::gather(name, details) %>%
    tidyr::separate(
      col = details,
      into = c("right", "wrong"),
      sep = ","
    ) %>%
    dplyr::mutate(right = right %>%
                    stringr::str_extract("(\\d+)") %>%
                    as.integer()
    ) %>%
    dplyr::mutate(wrong = wrong %>%
                    stringr::str_extract("(\\d+)") %>%
                    as.integer()
    )

  # bind all sub-SUMMARY tables
  summary_scores <- coryat_final %>%
    dplyr::left_join(final_final, by = "name") %>%
    dplyr::left_join(right_wrong, by = "name")

  # return final list
  return(summary_scores)
}
