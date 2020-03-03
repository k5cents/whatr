#' 2019 Jeopardy! episodes
#'
#' The episodes in the 2019 season of
#'
#' @format A tibble with 218 rows and 3 variables:
#' \describe{
#'   \item{game}{The non-sequential J! Archive game ID.}
#'   \item{show}{The sequential show number of an episode.}
#'   \item{date}{The air date of an episode.}
#' }
#' @source \url{http://www.j-archive.com/}
"episodes"

#' 2019 Jeopardy! contestants
#'
#' @format A tibble with 672 rows and 6 variables:
#' \describe{
#'   \item{game}{The J! Archive game ID.}
#'   \item{show}{The sequential episode show number.}
#'   \item{date}{The date each episodes initially aired.}
#' }
#' @source \url{http://www.j-archive.com/}
"players"

#' 2019 Jeopardy! game synopses
#'
#' @format A tibble with 654 rows and 6 variables:
#' \describe{
#'   \item{name}{The contestant's given name.}
#'   \item{coryat}{Score if all wagering is disregarded.}
#'   \item{final}{Final score after Double Jeopardy.}
#'   \item{right}{Number of correct answers.}
#'   \item{wrong}{Number of incorrect answers.}
#' }
#' @source \url{http://www.j-archive.com/}
"synopses"

#' 2019 Jeopardy! game scores
#'
#' @format A tibble with 13,261 rows and 6 variables:
#' \describe{
#'   \item{round}{The round a clue is chosen.}
#'   \item{n}{The order of clue chosen.}
#'   \item{name}{First name of player responding.}
#'   \item{score}{Change in score from this clue.}
#'   \item{double}{Is the clue a daily double.}
#' }
#' @source \url{http://www.j-archive.com/}
"scores"

#' 2019 Jeopardy! game boards
#'
#' @format A tibble with 13,261 rows and 8 variables:
#' \describe{
#'   \item{game}{The J! Archive game ID.}
#'   \item{round}{The round a clue is chosen.}
#'   \item{col}{The column position left-to-right.}
#'   \item{row}{The row position top-to-bottom.}
#'   \item{n}{The order of clue chosen.}
#'   \item{category}{Category title, often humorous or with instructions.}
#'   \item{clue}{The clue read to the contestants.}
#'   \item{answer}{The _correct_ answer to a clue.}
#' }
#' @source \url{http://www.j-archive.com/}
"boards"
