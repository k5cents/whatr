#' Jeopardy! episode air information.
#'
#' A dataset containing Jeopardy! episode air information
#'
#' @format A data frame with 6125 rows and 3 variables:
#' \describe{
#'   \item{game}{A J! Archive game ID}
#'   \item{show}{The sequential show number}
#'   \item{date}{The origiate date of episode air}
#'   ...
#' }
#' @source \url{http://www.j-archive.com/}
"info"

#' Jeopardy! episode contestant information.
#'
#' A dataset containing Jeopardy! contestant biographical information
#'
#' @format A data frame with 18402 rows and 6 variables:
#' \describe{
#'   \item{game}{A J! Archive game ID}
#'   \item{first}{Contestant's first name}
#'   \item{last}{Contestant's last name}
#'   \item{occupation}{Contestant's occupation}
#'   \item{city}{Contestant's home city}
#'   \item{state}{Contestant's home state}
#'   ...
#' }
#' @source \url{http://www.j-archive.com/}
"players"

#' Jeopardy! episode score summaries.
#'
#' A dataset containing Jeopardy! episode game score summaries
#'
#' @format A data frame with 18384 rows and 6 variables:
#' \describe{
#'   \item{game}{A J! Archive game ID}
#'   \item{name}{Contestant's first name}
#'   \item{coryat}{Final 'Coryat' score, a player's score if all wagering is disregarded}
#'   \item{final}{The final officialt score}
#'   \item{right}{Number of correct responses given}
#'   \item{wrong}{Number of incorrect responses given}

#'   ...
#' }
#' @source \url{http://www.j-archive.com/}
"summary"

#' Jeopardy! episode game boards.
#'
#' A dataset containing Jeopardy! episode categories, questions (clues), and answers (responses)
#'
#' @format A data frame with 363365 rows and 5 variables:
#' \describe{
#'   \item{game}{A J! Archive game ID}
#'   \item{clue}{The order a question/clue is chosen in a game}
#'   \item{category}{A collection of five clues, usually related by subject matter}
#'   \item{question}{A "question" posed to Jeopardy! contestants, phrased as an answer}
#'   \item{answer}{A contestant's "answer" to a clue, phrased in the form of a question}
#'   ...
#' }
#' @source \url{http://www.j-archive.com/}
"board"

#' Jeopardy! episode clue choice order.
#'
#' A dataset containing Jeopardy! episode clue locations (col and row) and order of choice
#'
#' @format A data frame with 363363 rows and 5 variables:
#' \describe{
#'   \item{game}{A J! Archive game ID}
#'   \item{round}{The round (1-3) in which a clue is chosen}
#'   \item{clue}{The order (1-61) a clue is chosen}
#'   \item{col}{The column (category) position of a clue on the round's board}
#'   \item{row}{The row (value) position of a clue on the round's board}
#'   ...
#' }
#' @source \url{http://www.j-archive.com/}
"order"

#' Jeopardy! episode score history.
#'
#' A dataset containing Jeopardy! episode score history
#'
#' @format A data frame with 363363 rows and 5 variables:
#' \describe{
#'   \item{game}{A J! Archive game ID}
#'   \item{round}{The round (1-3) in which a clue is chosen}
#'   \item{clue}{The order (1-61) a clue is chosen}
#'   \item{name}{Contestant's first name}
#'   \item{score}{Each contestant's score _after_ each clue is answered}
#'   ...
#' }
#' @source \url{http://www.j-archive.com/}
"order"