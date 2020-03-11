#' Return the right J! Archive HTML document
#'
#' To avoid downloading and reading the J! Archive over and over, this function
#' can be used to return an HTML document from one of four types of input:
#' 1. Game ID (6304)
#' 2. Show number ("#8006")
#' 3. Air date ("2019-06-03")
#' 4. HTML document itself
#'
#' @param x Any kind of J! Archive game identifier.
#' @param out One of "showscores" or "showgame" used for [whatr_scores()] or
#'   [whatr_clues()], etc. respectively. Either document can be returned from
#'   the input of the other.
#' @return A J! Archive `html_document`.
#' @examples
#' whatr_html(x = 6304, out = "showscores")
#' whatr_html(x = "2019-06-03", out = "showgame")
#' whatr_html("#8006", "showgame") %>% whatr_clues()
#' @importFrom httr GET content
#' @importFrom methods is
#' @importFrom stringr str_extract str_detect
#' @export
whatr_html <- function(x, out = c("showgame", "showscores")) {
  out <- match.arg(out, c("showgame", "showscores"))
  if (is.numeric(x)) {
    html <- httr::GET(
      url = sprintf("https://www.j-archive.com/%s.php", out),
      query = list(game_id = x)
    )
    # message(sprintf("in:  id %s\nout: %s", x, out))
    httr::content(html)
  } else if (is(x, "xml_document")) {
    c <- as.character(x)
    if (stringr::str_detect(c, "ddred") & out == "showscores") {
      # message("in:  showscores\nout: showscores")
      return(x)
    } else if (stringr::str_detect(c, "ddred") & out == "showgame") {
      # message("in:  showscores\nout: showgame")
      showscores_to_game(html = x)
    } else if (!stringr::str_detect(c, "ddred") & out == "showgame") {
      # message("in:  showgame\nout: showgame")
      return(x)
    } else if (!stringr::str_detect(c, "ddred") & out == "showscores") {
      # message("in:  showgame\nout: showscores")
      showgame_to_scores(html = x)
    }
  } else if (stringr::str_detect(x, "^#\\d+$")) {
    if (out == "showgame") {
      # message(sprintf("in:  show %s\nout: showgame", x))
      show_to_game(show = x)
    } else if (out == "showscores") {
      # message(sprintf("in:  show %s\nout: showscores", x))
      show_to_scores(show = x)
    }
  } else if (stringr::str_detect(x, "^\\d{4}-\\d+-\\d+$")) {
    if (out == "showgame") {
      # message(sprintf("in:  %s\nout: showgame", x))
      date_to_game(date = x)
    } else if (out == "showscores") {
      # message(sprintf("in:  %s\nout: showscores", x))
      date_to_scores(date = x)
    }
  } else {
    stop("not able to determine input type, see ?whatr_html")
  }
}

showgame_to_scores <- function(html) {
  id <- html %>%
    rvest::html_node(".game_dynamics") %>%
    rvest::html_attr("src") %>%
    stringr::str_extract("\\d+$")
  data <- httr::GET(
    url = "https://www.j-archive.com/showscores.php",
    query = list(game_id = id)
  )
  return(httr::content(data))
}

showscores_to_game <- function(html) {
  id <- html %>%
    rvest::html_node("#game_title") %>%
    rvest::html_node("a") %>%
    rvest::html_attr("href") %>%
    stringr::str_extract("\\d+$")
  data <- httr::GET(
    url = "https://www.j-archive.com/showgame.php",
    query = list(game_id = id)
  )
  httr::content(data)
}

date_to_game <- function(date) {
  data <- httr::GET(
    url = "https://www.j-archive.com/search.php",
    query = list(search = paste("date", date, sep = ":"))
  )
  httr::content(data)
}

date_to_scores <- function(date) {
  redirect <- httr::HEAD(
    url = "https://www.j-archive.com/search.php",
    query = list(search = paste("date", date, sep = ":"))
  )
  id <- stringr::str_extract(redirect$url, "\\d+$")
  data <- httr::GET(
    url = "https://www.j-archive.com/showscores.php",
    query = list(game_id = id)
  )
  httr::content(data)
}

show_to_game <- function(show) {
  data <- httr::GET(
    url = "https://www.j-archive.com/search.php",
    query = list(search = paste("show", gsub("#", "", show), sep = ":"))
  )
  httr::content(data)
}

show_to_scores <- function(show) {
  redirect <- httr::HEAD(
    url = "https://www.j-archive.com/search.php",
    query = list(search = paste("show", gsub("#", "", show), sep = ":"))
  )
  id <- stringr::str_extract(redirect$url, "\\d+$")
  data <- httr::GET(
    url = "https://www.j-archive.com/showscores.php",
    query = list(game_id = id)
  )
  httr::content(data)
}
