#' Return all a game's data from the J! Archive
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A list of tibbles each containing a data type.
#' @examples
#' whatr_data(game = 6304)
#' @export
whatr_data <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  response <- httr::GET(paste0("http://www.j-archive.com/showgame.php?game_id=", game))
  showgame <- xml2::read_html(response$content)
  showscores <- xml2::read_html(paste0("http://www.j-archive.com/showscores.php?game_id=", game))
  title <- rvest::html_text(rvest::html_node(showscores, "title"))
  info <- tibble::tibble(
    game = as.integer(game),
    show = as.integer(stringr::str_extract(title, "(\\d+)")),
    date = as.Date(stringr::str_extract(title, "\\d+-\\d+-\\d+$"))
  )
  # create PLAYERS table -----------------------------------------------------------------------
  players <- showgame %>%
    rvest::html_node("#contestants_table") %>%
    rvest::html_table(fill = TRUE) %>%
    dplyr::pull(2) %>%
    stringr::str_split(pattern = "\n") %>%
    base::unlist() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "text") %>%
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
    dplyr::mutate(
      occupation = occupation %>%
        stringr::word(2, -1) %>%
        stringr::str_to_title()
    ) %>%
    tidyr::separate(
      col = "from",
      sep = ",\\s",
      into = c("city", "state")
    )
  # create SCORES table --------------------------------------------------------------------
  single_doubles <- showscores %>%
    rvest::html_node("#jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::as.integer()
  tibble_uniqe <- function(x) {
    suppressMessages(tibble::as_tibble(x, .name_repair = "unique"))
  }
  single_score <- showscores %>%
    rvest::html_node("#jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(fill = TRUE, header = TRUE) %>%
    tibble_uniqe() %>%
    dplyr::select(-dplyr::starts_with("...")) %>%
    dplyr::mutate(n = dplyr::row_number(), round = 1L) %>%
    tidyr::pivot_longer(
      cols = -c(n, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(score, "\\$|\\,")),
      double = (n == single_doubles)
    )
  double_doubles <- showscores %>%
    rvest::html_nodes("#double_jeopardy_round > table td.ddred") %>%
    rvest::html_text() %>%
    base::unique() %>%
    base::as.integer()
  double_score <- showscores %>%
    rvest::html_node("#double_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tidyr::drop_na() %>%
    tibble_uniqe() %>%
    dplyr::select(-dplyr::starts_with("...")) %>%
    dplyr::mutate(n = dplyr::row_number(), round = 2L) %>%
    tidyr::pivot_longer(
      cols = -c(n, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(
      score = as.integer(stringr::str_remove_all(score, "\\$|\\,")),
      double = (n %in% double_doubles),
      n = n + max(single_score$n)
    )
  final_scores <- showscores %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(2)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    dplyr::slice(1) %>%
    tibble_uniqe() %>%
    dplyr::mutate(
      n = max(double_score$n) + 1L,
      round = 3L
    ) %>%
    tidyr::pivot_longer(
      cols = -c(n, round),
      names_to = "name",
      values_to = "score"
    ) %>%
    dplyr::mutate(score = as.integer(stringr::str_remove_all(score, "\\$|\\,")))
  scores <- single_score %>%
    dplyr::bind_rows(double_score) %>%
    dplyr::bind_rows(final_scores) %>%
    dplyr::arrange(round, n) %>%
    dplyr::select(round, n, name, score, double) %>%
    dplyr::group_by(name) %>%
    dplyr::mutate(
      change = ifelse(n == 1, score, score - dplyr::lag(score)),
      correct = ifelse(change == 0, NA, change > 0)
    ) %>%
    dplyr::ungroup()
  # create CLUE ORDER table --------------------------------------------------------------------
  single_order <- showgame %>%
    rvest::html_nodes("#jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  double_order <- showgame %>%
    rvest::html_nodes("#double_jeopardy_round > table td.clue_order_number") %>%
    rvest::html_text() %>%
    base::as.integer()
  order <- showgame %>%
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
      round = as.integer(
        round %>%
          dplyr::recode(
            "J"  = "1",
            "DJ" = "2",
            "FJ" = "3"
          )
      ),
      n = c(
        single_order,
        double_order + max(single_order),
        max(double_order) + 1L
      )
    )
  order$row[length(order$row)] <- 0L
  order$col[length(order$col)] <- 0L
  # create DOUBLES table -------------------------------------------------------------------
  doubles <- scores %>%
    dplyr::filter(double) %>%
    dplyr::left_join(order, by = c("round", "n")) %>%
    tidyr::drop_na() %>%
    dplyr::select(n, name, correct, change)
  # create the BOARDS table --------------------------------------------------------------------
  categories <- showgame %>%
    rvest::html_nodes("table td.category_name") %>%
    rvest::html_text(trim = TRUE) %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "'") %>%
    tibble::enframe(name = NULL, value = "category") %>%
    dplyr::mutate(
      round = c(rep(1L, 6), rep(2L, 6), 3L),
      col = c(1L:6L, 1L:6L, 0L)
    ) %>%
    dplyr::select(round, col, category)
  questions <- showgame %>%
    rvest::html_nodes("table td.clue_text") %>%
    rvest::html_text() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    tibble::enframe(name = NULL, value = "clue") %>%
    dplyr::bind_cols(whatr_order(game)) %>%
    dplyr::select(round, col, row, n, clue)
  extract_answer <- function(node) {
    node %>%
      rvest::html_attr("onmouseover") %>%
      xml2::read_html() %>%
      rvest::html_nodes("em.correct_response") %>%
      rvest::html_text()
  }
  final_answer <- showgame %>%
    rvest::html_node(".final_round") %>%
    base::as.character() %>%
    stringr::str_split("class") %>%
    base::unlist() %>%
    magrittr::extract(stringr::str_which(., "correct_response")) %>%
    stringr::str_extract(";&gt;(.*)&lt;/") %>%
    stringr::str_remove(";&gt;") %>%
    stringr::str_remove("&lt;/") %>%
    stringr::str_to_title()
  answers <- showgame %>%
    rvest::html_nodes("table tr td div") %>%
    purrr::map(extract_answer) %>%
    base::unlist() %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    tibble::enframe(name = NULL, value = "answer") %>%
    dplyr::add_row(answer = final_answer) %>%
    dplyr::bind_cols(whatr_order(game)) %>%
    dplyr::select(round, col, row, n, answer)
  board <- questions %>%
    dplyr::left_join(answers, by = c("round", "col", "row", "n")) %>%
    dplyr::left_join(categories, by = c("round", "col")) %>%
    dplyr::select(n, category, clue, answer) %>%
    dplyr::arrange(n)
  # create SUMMARY table -----------------------------------------------------------------------
  coryat_final <- showgame %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(8)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather(name, coryat) %>%
    dplyr::mutate(
      coryat = coryat %>%
        stringr::str_remove("\\$") %>%
        stringr::str_remove(",") %>%
        base::as.integer()
    )
  final_final <- showgame %>%
    rvest::html_node("#final_jeopardy_round > table:nth-child(4)") %>%
    rvest::html_table(header = TRUE, fill = TRUE) %>%
    tibble::as_tibble() %>%
    dplyr::slice(1) %>%
    tidyr::gather(name, final) %>%
    dplyr::mutate(
      final = final %>%
        stringr::str_remove("\\$") %>%
        stringr::str_remove(",") %>%
        base::as.integer()
    )
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
    dplyr::mutate(
      right = right %>%
        stringr::str_extract("(\\d+)") %>%
        base::as.integer()
    ) %>%
    dplyr::mutate(
      wrong = wrong %>%
        stringr::str_extract("(\\d+)") %>%
        base::as.integer()
    )
  summary_scores <- coryat_final %>%
    dplyr::left_join(final_final, by = "name") %>%
    dplyr::left_join(right_wrong, by = "name")
  # create DATA list ---------------------------------------------------------------------------
  all_data <- list(
    info    = info,
    players = players,
    order   = dplyr::arrange(order, n),
    board   = board,
    doubles = doubles,
    scores  = scores,
    summary = summary_scores
  )
  return(all_data)
}
