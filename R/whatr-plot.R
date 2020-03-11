#' What is a plot?
#'
#' _This_ type of graphic presents data in a visual manner.
#'
#' @inheritParams whatr_scores
#' @return A ggplot object.
#' @examples
#' whatr_plot(game = 6304)
#' @importFrom xml2 read_html
#' @importFrom rvest html_node html_text
#' @importFrom stringr str_extract str_remove
#' @importFrom tidyr drop_na
#' @importFrom dplyr filter mutate
#' @importFrom ggplot2 ggplot aes_string geom_vline geom_line scale_y_continuous
#'   scale_x_continuous scale_color_brewer labs scale_shape_discrete
#' @export
whatr_plot <- function(game) {
  game <- whatr_html(game, "showscores")
  id <- as.character(game) %>%
    stringr::str_extract("(?<=chartgame.php\\?game_id\\=)\\d+")
  scores <- whatr_scores(game) %>%
    dplyr::group_by(.data$name) %>%
    dplyr::mutate(run = cumsum(.data$score)) %>%
    dplyr::ungroup()
  subtitle <- game %>%
    rvest::html_node("title") %>%
    rvest::html_text() %>%
    stringr::str_remove(".*-\\s")
  finals <- dplyr::filter(scores, .data$round == 3)
  doubles <- dplyr::filter(scores, .data$double)
  finals$i <- finals$i + 2
  plot <- scores %>%
    dplyr::filter(.data$round != 3) %>%
    ggplot2::ggplot(mapping = ggplot2::aes_string(x = "i", y = "run")) +
    ggplot2::geom_vline(xintercept = max(scores$i[scores$round == 1]),
                        linetype = 2) +
    ggplot2::geom_vline(xintercept = max(scores$i[scores$round == 2]),
                        linetype = 2) +
    ggplot2::geom_line(mapping = ggplot2::aes_string(color = "name"),
                       size = 2) +
    ggplot2::geom_point(data = doubles, size = 3,
                        mapping = ggplot2::aes_string(shape = "name")) +
    ggplot2::geom_point(data = finals, size = 6, shape = 18,
                        mapping = ggplot2::aes_string(color = "name")) +
    ggplot2::scale_y_continuous(labels = scales::dollar) +
    ggplot2::scale_x_continuous(breaks = seq(0, 60, 10)) +
    ggplot2::scale_color_brewer(palette = "Dark2") +
    ggplot2::scale_shape_discrete(guide = FALSE) +
    ggplot2::labs(
      title = "Jeopardy! Game Score History",
      subtitle = subtitle,
      caption = paste0("Souce: J! Archive/", id),
      color = "Contestant",
      y = "Score",
      x = "Clue"
    )
  return(plot)
}
