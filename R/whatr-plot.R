#' Plot Jeopardy game score history
#'
#' Pass the tidy tibble from [whatr_scores()] to [ggplot2::ggplot()] and
#' highlight the contestant scores, double jeopardy questions, and round
#' breaks.
#'
#' @param game The J-Archive! game ID number.
#' @param date The original date an episode aired.
#' @param show The sequential show number.
#' @return A ggplot object.
#' @examples
#' whatr_plot(game = 6304)
#' whatr_plot(date = "2018-01-01")
#' whatr_plot(show = 8004)
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_text
#' @importFrom stringr str_extract str_remove
#' @importFrom tidyr drop_na
#' @importFrom dplyr filter mutate
#' @importFrom ggplot2 ggplot aes geom_vline geom_line scale_y_continuous scale_x_continuous scale_color_brewer labs scale_shape_discrete
#' @export
whatr_plot <- function(game = NULL, date = NULL, show = NULL) {
  game <- whatr_id(game, date, show)
  scores <- whatr_scores(game)
  subtitle <-
    xml2::read_html(paste0("http://www.j-archive.com/showscores.php?game_id=", game)) %>%
    rvest::html_node("title") %>%
    rvest::html_text() %>%
    stringr::str_extract("-(.*)") %>%
    stringr::str_remove("-\\s")
  doubles <- tidyr::drop_na(dplyr::filter(scores, double == TRUE))
  finals <- dplyr::filter(scores, round == 3)
  finals$n <- finals$n + 2
  plot <- scores %>%
    dplyr::filter(round != 3) %>%
    ggplot2::ggplot(mapping = ggplot2::aes(x = n, y = score)) +
    ggplot2::geom_vline(xintercept = max(scores$n[scores$round == 1]), linetype = 2) +
    ggplot2::geom_vline(xintercept = max(scores$n[scores$round == 2]), linetype = 2) +
    ggplot2::geom_line(mapping = ggplot2::aes(color = name), size = 2) +
    ggplot2::geom_point(data = doubles, size = 3, mapping = ggplot2::aes(shape = name)) +
    ggplot2::geom_point(data = finals, size = 6, shape = 18, mapping = ggplot2::aes(color = name)) +
    ggplot2::scale_y_continuous(labels = scales::dollar) +
    ggplot2::scale_x_continuous(breaks = seq(0, 60, 10)) +
    ggplot2::scale_color_brewer(palette = "Dark2") +
    ggplot2::scale_shape_discrete(guide = FALSE) +
    ggplot2::labs(
      title = "Jeopardy! Game Score History",
      subtitle = subtitle,
      caption = paste("Souce: J! Archive - ", game),
      color = "Contestant",
      y = "Score",
      x = "Clue"
    )
  return(plot)
}
