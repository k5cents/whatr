#' Scrape Jeopardy game score history
#'
#' @param game A J-Archive! game ID number
#' @return Tidy tibble of a Jeopardy! episode's score history
#' @export

whatr_scores <- function(game = NULL, date = NULL, show = NULL) {

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

  # read the showscores page
  showscores <- xml2::read_html(stringr::str_c("http://www.j-archive.com/showscores.php?game_id=", game))

  # create sub-function to scrape scores html table
  scores_noisy <- function(showscores) {

    # single jeopardy round scores table
    single_score <- showscores %>%
      rvest::html_node("#jeopardy_round > table:nth-child(2)") %>%
      rvest::html_table(fill = TRUE, header = TRUE) %>%
      tibble::as_tibble(.name_repair = "unique") %>%
      dplyr::select(2:4) %>%
      dplyr::mutate(clue = dplyr::row_number()) %>%
      dplyr::mutate(round = 1) %>%
      # tidy the table
      tidyr::gather(name, score, -c(round, clue)) %>%
      dplyr::mutate(score = score %>%
                      stringr::str_remove("\\$") %>%
                      stringr::str_remove(",") %>%
                      as.numeric())

    # single jeopardy round double jeopardy location
    single_doubles <- showscores %>%
      rvest::html_nodes("#jeopardy_round > table td.ddred") %>%
      rvest::html_text() %>%
      magrittr::extract(1) %>%
      tibble::enframe(name = NULL, value = "clue") %>%
      dplyr::mutate(round = 1) %>%
      dplyr::mutate(clue = as.integer(clue)) %>%
      dplyr::mutate(double = TRUE) %>%
      dplyr::select(round, clue, double)

    # add double jeopardy location to scores table
    single_score <- single_score %>%
      dplyr::left_join(single_doubles, by = c("clue", "round")) %>%
      dplyr::mutate(double = !is.na(double))

    # repeat for double jeopardy round
    double_score <- showscores %>%
      rvest::html_node("#double_jeopardy_round > table:nth-child(2)") %>%
      rvest::html_table(header = TRUE, fill = TRUE) %>%
      tidyr::drop_na() %>%
      tibble::as_tibble(.name_repair = "unique") %>%
      dplyr::select(2:4) %>%
      dplyr::mutate(clue = dplyr::row_number() + (nrow(single_score)/3)) %>%
      dplyr::mutate(round = 2) %>%
      tidyr::gather(name, score, -c(round, clue)) %>%
      dplyr::mutate(score = score %>%
                      stringr::str_remove("\\$") %>%
                      stringr::str_remove(",") %>%
                      as.numeric())

    double_doubles <- showscores %>%
      rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
      rvest::html_text() %>%
      magrittr::extract(c(1, 3)) %>%
      tibble::enframe(name = NULL, value = "clue") %>%
      dplyr::mutate(round = 2) %>%
      dplyr::mutate(clue = as.integer(clue) + nrow(single_score)/3) %>%
      dplyr::mutate(double = TRUE) %>%
      dplyr::select(round, clue, double)

    double_score <- double_score %>%
      dplyr::left_join(double_doubles, by = c("clue", "round")) %>%
      dplyr::mutate(double = !is.na(double))

    # repeat for final jeopardy scores table
    final_scores <- showscores %>%
      rvest::html_node("#final_jeopardy_round > table:nth-child(2)") %>%
      rvest::html_table(header = TRUE, fill = TRUE) %>%
      dplyr::slice(1) %>%
      tibble::as_tibble(.name_repair = "unique") %>%
      dplyr::mutate(clue = max(double_score$clue) + 1) %>%
      dplyr::mutate(round = 3) %>%
      tidyr::gather(name, score, -c(round, clue)) %>%
      dplyr::mutate(score = score %>%
                      stringr::str_remove("\\$") %>%
                      stringr::str_remove(",") %>%
                      as.numeric())

    # combine scores of all rounds
    scores <- single_score %>%
      dplyr::bind_rows(double_score) %>%
      dplyr::bind_rows(final_scores) %>%
      dplyr::arrange(round, clue) %>%
      dplyr::group_by(name) %>%
      dplyr::mutate(change = dplyr::if_else(
        condition = clue == 1,
        true  = score,
        false = score - dplyr::lag(score, 1))
      ) %>%
      dplyr::mutate(correct = ifelse(change == 0, NA, ifelse(change > 0, T, F))) %>%
      dplyr::ungroup() %>%
      dplyr::select(round, clue, name, score, change, correct, double)

    return(scores)
  }

  # supress the tibble name warnings
  scores <- suppressMessages(scores_noisy(showscores))

  # return final list
  return(scores)
}
