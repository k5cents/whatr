#' Scrape Jeopardy game meta data
#'
#' @param game A J-Archive! game ID number
#' @return List of a available data on a Jeopardy game
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

  # create INFO table --------------------------------------------------------------------------

  # extract the game id from end of final url
  game <- stringr::str_extract(final_url, "\\d+$")

  # read the redirected page content as html
  showgame <- xml2::read_html(response$content)

  # read the showscores page
  showscores <- xml2::read_html(stringr::str_c("http://www.j-archive.com/showscores.php?game_id=", game))

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

  # create PLAYERS table -----------------------------------------------------------------------

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

  # create SCORES table --------------------------------------------------------------------

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

  # create CLUE ORDER table --------------------------------------------------------------------

  # define the typical order of clues listed left-right
  listed_order <- c(rep(1, 6), rep(2, 6), rep(3, 6), rep(4, 6), rep(5, 6))

  # read left-right order of clues chosen
  single_order <- showgame %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    as.integer() %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::mutate(row = listed_order[1:nrow(.)]) %>%
    dplyr::mutate(col = rep(1:6, 5)[1:nrow(.)]) %>%
    dplyr::mutate(round = 1)

  # repeat for double jeopardy round
  double_order <- showgame %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    as.integer() %>%
    magrittr::add(nrow(single_order)) %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::mutate(row = listed_order[1:nrow(.)]) %>%
    dplyr::mutate(col = rep(1:6, 5)[1:nrow(.)]) %>%
    dplyr::mutate(round = 2)

  # bind all three round clue locations
  clue_order <- single_order %>%
    dplyr::bind_rows(double_order) %>%
    dplyr::select(round, clue, col, row) %>%
    dplyr::add_row(
      round = 3,
      clue = nrow(.) + 1,
      col = NA,
      row = NA
    )

  # create DOUBLES table -------------------------------------------------------------------

  doubles <- scores %>%
    dplyr::filter(double == TRUE) %>%
    dplyr::left_join(clue_order, by = c("clue")) %>%
    tidyr::drop_na() %>%
    dplyr::select(clue, name, correct, change)

  # create the BOARDS table --------------------------------------------------------------------

  # create CATEGORY sub-table
  categories <- showgame %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(value = "category", name = NULL) %>%
    dplyr::mutate(round = c(rep(1, 6), rep(2, 6), 3)) %>%
    dplyr::mutate(col = c(1:6, 1:6, NA)) %>%
    dplyr::select(round, col, category)

  # create QUESTIONS sub-table
  questions <- showgame %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "question") %>%
    dplyr::mutate(clue = clue_order$clue) %>%
    dplyr::left_join(clue_order, question_text, by = "clue") %>%
    dplyr::select(round, col, row, clue, question)

  # create the table of answer locations
  # can't remember if this is neccesary
  # answers are listed left-right top-bottom
  # might differ if answers aren't revealed
  answer_locations <- showgame %>%
    rvest::html_nodes("table tr td div") %>%
    rvest::html_attr("onmouseover") %>%
    stringr::str_extract("(?<=clue_)(.*)(?=_stuck)") %>%
    tibble::enframe(name = NULL) %>%
    tidyr::separate(
      col = value,
      sep = "', '",
      into = c("one", "two")
    ) %>%
    dplyr::select(one) %>%
    tidyr::separate(
      col = one,
      sep = "_",
      into = c("round", "col", "row"),
      convert = TRUE,
      fill = "right"
    ) %>%
    dplyr::mutate(
      round = round %>%
        dplyr::recode(
          "J"  = "1",
          "DJ" = "2",
          "FJ" = "3"
        ) %>% as.integer()
    )

  # create sub-function to extract mouseover text
  extract_answer <- function(node) {
    node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text()
  }

  # extract the final jeopardy answer from character string
  # has to be a way to do with rvest
  final_answer <- showgame %>%
    rvest::html_node(".final_round") %>%
    as.character() %>%
    stringr::str_split("class") %>%
    unlist() %>%
    magrittr::extract(stringr::str_which(., "correct_response")) %>%
    stringr::str_extract(";&gt;(.*)&lt;/") %>%
    stringr::str_remove(";&gt;") %>%
    stringr::str_remove("&lt;/") %>%
    stringr::str_to_title()

  # create ANSWERS sub-table
  answers <- showgame %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer) %>%
    dplyr::mutate(clue = c(single_order$clue, double_order$clue, nrow(double_order) + 1)) %>%
    dplyr::bind_cols(answer_locations) %>%
    dplyr::select(round, clue, col, row, answer)

  # bind all sub-BOARD tables
  board <- questions %>%
    dplyr::left_join(answers, by = c("round", "col", "row", "clue")) %>%
    dplyr::left_join(categories, by = c("round", "col")) %>%
    dplyr::select(clue, category, question, answer) %>%
    dplyr::arrange(clue)

  # create SUMMARY table -----------------------------------------------------------------------

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


  # create DATA list ---------------------------------------------------------------------------

  # list all sub-DATA tables
  game_data <- list(
    info    = info,
    players = players,
    order   = clue_order %>% dplyr::arrange(clue),
    board   = board,
    doubles = doubles,
    scores  = scores,
    summary = summary_scores
  )

  # return final list
  return(game_data)
}
