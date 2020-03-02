## code to prepare `jarchive` dataset goes here
library(tidyverse)
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

# compress dirs -----------------------------------------------------------

withr::with_dir(
  new = game_dir,
  code = tar(
    tarfile = "../showgame.tar.xz",
    compression = "xz",
    compression_level = 9
  )
)

withr::with_dir(
  new = score_dir,
  code = tar(
    tarfile = "../showscores.tar.xz",
    compression = "xz",
    compression_level = 9
  )
)

# dir_delete(game_dir)
# dir_delete(score_dir)

# bind and save -----------------------------------------------------------

all_data <- transpose(compact(discard(all_data, ~all(is.na(.)))))

info <- bind_rows(all_data$info)
usethis::use_data(info,    overwrite = TRUE)
write_csv(info, "data-raw/info.csv")

summary <- bind_rows(all_data$summary)
usethis::use_data(summary, overwrite = TRUE)
write_csv(summary, "data-raw/summary.csv")

players <- bind_rows(all_data$players)
usethis::use_data(players, overwrite = TRUE)
write_csv(players, "data-raw/players.csv")

scores <- bind_rows(all_data$scores)
usethis::use_data(scores,  overwrite = TRUE)
write_csv(scores, "data-raw/scores.csv")

boards <- bind_rows(all_data$board)
usethis::use_data(boards,  overwrite = TRUE)
write_csv(boards, "data-raw/boards.csv")
