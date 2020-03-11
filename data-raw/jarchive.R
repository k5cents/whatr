## code to prepare `jarchive` dataset goes here
library(tidyverse)
library(lubridate)
library(magrittr)
library(rvest)
library(whatr)
library(httr)
library(fs)

game_dir <- dir_create(here::here("data-raw", "games"))
score_dir <- dir_create(here::here("data-raw", "scores"))
pb <- txtProgressBar(7816, 8045, style = 3)
for (i in 7816:8045) {
  r <- GET(
    # download showgame from search
    url = "https://www.j-archive.com/search.php",
    query = list(search = paste("show", i, sep = ":")),
    write_disk(path(game_dir, sprintf("showgame-%s.html", i)))
  )
  GET(
    # download showscores from showgame id
    url = "https://www.j-archive.com/showscores.php",
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

for (x in seq_along(dat)) {
  id <- dat[[x]]$info$game
  dat[[x]] <- dat[[x]] %>%
    map(~select(mutate(., game = id), game, everything()))
}

dat <- dat %>%
  transpose() %>%
  map(bind_rows)

# bind and save -----------------------------------------------------------

episodes <- filter(dat$info, show %>% between(7816, 8045))
usethis::use_data(episodes, overwrite = TRUE, compress = "xz")
write_csv(episodes, "data-raw/episodes.csv")

# remove dates for others
dat <- map(dat, ~filter(., game %in% episodes$game))

players <- dat$players
usethis::use_data(players, overwrite = TRUE, compress = "xz")
write_csv(players, "data-raw/players.csv")

synopses <- dat$summary
usethis::use_data(synopses, overwrite = TRUE, compress = "xz")
write_csv(synopses, "data-raw/synopses.csv")

scores <- dat$scores
usethis::use_data(scores, overwrite = TRUE, compress = "xz")
write_csv(scores, "data-raw/scores.csv")

boards <- dat$board
boards$clue <- str_remove(boards$clue, "^\\(.*\\)(\\s|[:punct:])")
usethis::use_data(boards, overwrite = TRUE, compress = "xz")
write_csv(boards, "data-raw/boards.csv")

# clean up ----------------------------------------------------------------

usethis::use_git_ignore("*.tar.xz")

withr::with_dir(
  new = game_dir,
  code = tar(
    tarfile = "../showgames-35.tar.xz",
    compression = "xz",
    compression_level = 9
  )
)

dir_delete(game_dir)

withr::with_dir(
  new = score_dir,
  code = tar(
    tarfile = "../showscores-35.tar.xz",
    compression = "xz",
    compression_level = 9
  )
)

dir_delete(score_dir)
