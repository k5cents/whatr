#' Repair the text from J! Archive HTML
#'
#' @param string Some text, usually from [rvest::html_text()].
#' @return Normalize character vectors.
#' @importFrom stringr str_replace_all str_remove_all str_to_title str_to_upper
#'   str_trim str_squish
entity_clean <- function(string) {
  string %>%
    stringr::str_squish() %>%
    stringr::str_trim() %>%
    stringr::str_replace_all("\"", "\'") %>%
    stringr::str_remove_all(stringr::fixed("\\")) %>%
    stringr::str_remove_all("&Lt;/I&Gt;") %>%
    stringr::str_remove_all("&Lt;I&Gt;") %>%
    stringr::str_remove_all("&Lt;") %>%
    stringr::str_remove_all("&Gt;") %>%
    stringr::str_replace_all("&Quot;", "'") %>%
    stringr::str_replace_all("&Amp;", "&") %>%
    stringr::str_to_title() %>%
    stringr::str_replace_all("(?<=\\S)(:)(?=\\S)", "\\1 ") %>%
    stringr::str_replace_all("(?:[A-z]\\.)+", stringr::str_to_upper) %>%
    stringr::str_replace_all(
      pattern = stringr::regex("\\bM{0,4}(CM|CD|D?C{0,3})(XC|XL|L?X{0,3})(IX|IV|V?I{0,3})\\b", ignore_case = TRUE),
      replacement = stringr::str_to_upper
    )
}
