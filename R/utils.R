rand_wait <- function(min = 1, max = 5) {
  Sys.sleep(stats::runif(1, min, max))
}
