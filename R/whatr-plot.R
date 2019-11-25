#' Visualize a Jeopardy game history
#'
#' @param game_id A J-Archive! game ID number
#' @return Return ggplot of a Jeopardy! game score history
#' @importFrom ggplot2 ggplot geom_vline geom_line geom_point
#' @importFrom ggplot2 scale_y_continuous scale_x_continuous labs
#' @importFrom scales dollar
#' @importFrom dplyr mutate pull slice select bind_rows arrange group_by ungroup lag
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_text html_table
#' @importFrom tibble tibble enframe as_tibble
#' @importFrom stringr str_split str_remove str_c str_extract str_to_lower
#' @importFrom lubridate as_date
#' @importFrom tidyr gather separate
#' @importFrom httr GET
#' @importFrom magrittr add
#' @importFrom magrittr "%>%"
#' @importFrom purrr is_null as_vector
#' @export

whatr_plot <- function(game = NULL, date = NULL, show = NULL) {

  base_url <-
    if (!is_null(game)) {
      str_c("http://www.j-archive.com/showgame.php?game_id=", game)
    } else {
      if (!is_null(date)) {
        str_c("http://www.j-archive.com/search.php?search=date:", as_date(date))
      } else {
        str_c("www.j-archive.com/search.php?search=show:", show)
      }
    }

  response <- GET(base_url)

  final_url <- if (is_null(game)) response$url else base_url

  game <- str_extract(final_url, "\\d+$")

  showscores <- read_html(str_c("http://www.j-archive.com/showscores.php?game_id=", game))

  subtitle <- showscores %>%
    html_node("title") %>%
    html_text() %>%
    str_extract("-(.*)") %>%
    str_remove("-\\s")

  scores_noisy <- function(showscores) {
    single_score <- showscores %>%
      html_node("#jeopardy_round > table:nth-child(2)") %>%
      html_table(fill = TRUE, header = TRUE) %>%
      as_tibble(.name_repair = "unique") %>%
      select(2:4) %>%
      mutate(clue = row_number()) %>%
      mutate(round = 1) %>%
      gather(name, score, -c(round, clue)) %>%
      mutate(score = parse_number(score))

    single_doubles <- showscores %>%
      html_nodes("#jeopardy_round > table td.ddred") %>%
      html_text() %>%
      magrittr::extract(1) %>%
      enframe(name = NULL, value = "clue") %>%
      mutate(round = 1) %>%
      mutate(clue = as.integer(clue)) %>%
      mutate(double = TRUE) %>%
      select(round, clue, double)

    single_score2 <- single_score %>%
      left_join(single_doubles, by = c("clue", "round")) %>%
      mutate(double = !is.na(double))

    double_score <- showscores %>%
      html_node("#double_jeopardy_round > table:nth-child(2)") %>%
      html_table(header = TRUE, fill = TRUE) %>%
      drop_na() %>%
      as_tibble(.name_repair = "unique") %>%
      select(2:4) %>%
      mutate(clue = row_number() + (nrow(single_score)/3)) %>%
      mutate(round = 2) %>%
      gather(name, score, -c(round, clue)) %>%
      mutate(score = parse_number(score))

    double_doubles <- showscores %>%
      html_nodes("#double_jeopardy_round > table td.ddred") %>%
      html_text() %>%
      magrittr::extract(c(1, 3)) %>%
      enframe(name = NULL, value = "clue") %>%
      mutate(round = 2) %>%
      mutate(clue = as.integer(clue) + nrow(single_score)/3) %>%
      mutate(double = TRUE) %>%
      select(round, clue, double)

    double_score2 <- double_score %>%
      left_join(double_doubles, by = c("clue", "round")) %>%
      mutate(double = !is.na(double))

    final_scores <- showscores %>%
      html_node("#final_jeopardy_round > table:nth-child(2)") %>%
      html_table(header = TRUE, fill = TRUE) %>%
      slice(1) %>%
      as_tibble(.name_repair = "unique") %>%
      mutate(clue = max(double_score2$clue) + 1) %>%
      mutate(round = 3) %>%
      gather(name, score, -c(round, clue)) %>%
      mutate(score = parse_number(score))

    scores <- single_score2 %>%
      bind_rows(double_score2) %>%
      bind_rows(final_scores) %>%
      arrange(round, clue) %>%
      group_by(name) %>%
      mutate(change = if_else(
        condition = clue == 1,
        true  = score,
        false = score - lag(score, 1))
      ) %>%
      mutate(correct = ifelse(change == 0, NA, ifelse(change > 0, T, F))) %>%
      ungroup() %>%
      select(round, clue, name, score, change, correct, double)

    return(scores)
  }

  scores <- suppressMessages(scores_noisy(showscores))

  doubles <- scores %>%
    filter(double == TRUE) %>%
    drop_na()

  plot <- scores %>%
    ggplot(mapping = aes(x = clue, y = score)) +
    geom_vline(xintercept = max(scores$clue[scores$round == 1])) +
    geom_vline(xintercept = max(scores$clue[scores$round == 2])) +
    geom_line(mapping = aes(color = name), size = 2) +
    geom_point(data = doubles, size = 3) +
    scale_y_continuous(labels = sdollar) +
    scale_x_continuous(breaks = seq(0, 60, 10)) +
    labs(
      title = "Jeopardy! Game Score History",
      subtitle = subtitle,
      caption = "Souce: J! Archive",
      color = "Contestant",
      y = "Score",
      x = "Clue"
    )

  return(plot)
}
