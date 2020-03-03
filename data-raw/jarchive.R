## code to prepare `jarchive` dataset goes here
library(tidyverse)
library(lubridate)
library(magrittr)
library(rvest)
library(whatr)
library(httr)
library(fs)

# get most recent episode show number
latest_show <- "http://www.j-archive.com/" %>%
  read_html() %>%
  html_node(".splash_clue_footer") %>%
  html_text() %>%
  str_extract("(?<=#)\\d+") %>%
  as.integer()

game_dir <- dir_create(here::here("data-raw", "games"))
score_dir <- dir_create(here::here("data-raw", "scores"))
pb <- txtProgressBar(1, latest_show, style = 3)
for (i in seq(1, latest_show)) {
  r <- GET(
    # download showgame from search
    url = "http://www.j-archive.com/search.php",
    query = list(search = paste("show", i, sep = ":")),
    write_disk(path(game_dir, sprintf("showgame-%s.html", i)))
  )
  GET(
    # download showscores from showgame id
    url = "http://www.j-archive.com/showscores.php",
    query = list(game_id = stringr::str_extract(r$url, "\\d+$")),
    write_disk(path(score_dir, sprintf("showscores-%s.html", i)))
  )
  setTxtProgressBar(pb, i)
}


# remove empty files ------------------------------------------------------

# small showgame html files
game_info <- file_info(dir_ls(game_dir))
game_info %>%
  ggplot(aes(x = size)) +
  geom_histogram(bins = 10) +
  scale_x_continuous(labels = scales::number_bytes) +
  scale_y_continuous(labels = scales::comma)

game_info %>%
  filter(size < 4000) %>%
  pull(path) %>%
  file_delete()

# small showscores html files
score_info <- file_info(dir_ls(score_dir))
score_info %>%
  ggplot(aes(x = size)) +
  geom_histogram(bins = 10) +
  scale_x_continuous(labels = scales::number_bytes) +
  scale_y_continuous(labels = scales::comma)

score_info %>%
  filter(size < 4000) %>%
  pull(path) %>%
  file_delete()

# read html ---------------------------------------------------------------

  dat <- game_info$path %>%
    map(read_html) %>%
    map(safely(whatr_data)) %>%
    transpose() %>%
    use_series("result") %>%
    compact() %>%
    discard(~all(is.na(.)))

  for (i in seq_along(dat)) {
    dat[[i]] <- dat[[i]] %>%
      map(~select(mutate(., game = dat[[i]]$info$game), game, everything()))
  }

dat <- dat %>%
  transpose() %>%
  map(bind_rows)

# bind and save -----------------------------------------------------------

info <- dat$info %>%
  filter(year(date) == 2019) %>%
  arrange(date)
usethis::use_data(info, overwrite = TRUE)
write_csv(info, "data-raw/info.csv")

# remove dates for others
dat <- map(dat, ~filter(., game %in% info$game))

players <- dat$players
usethis::use_data(players, overwrite = TRUE)
write_csv(players, "data-raw/players.csv")

synopses <- dat$summary
usethis::use_data(synopses, overwrite = TRUE)
write_csv(synopses, "data-raw/synopses.csv")

scores <- dat$scores
usethis::use_data(scores, overwrite = TRUE)
write_csv(scores, "data-raw/scores.csv")

boards <- dat$board
boards$clue <- str_remove(boards$clue, "^\\(.*\\)(\\s|[:punct:])")
usethis::use_data(boards, overwrite = TRUE, compress = "xz")
write_csv(boards, "data-raw/boards.csv")

# clean up ----------------------------------------------------------------

dir_delete(game_dir)
dir_delete(score_dir)
