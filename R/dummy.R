#' Dummy, test
#'
#' Just a test
#' @returns numbers in a list
#' @export
#'
#' @examples
#' dummy()
dummy <- function() {
  if (!requireNamespace("carrier", quietly = TRUE)) stop("need carrier package for dummy() run")
  mirai::daemons(parallelly::availableCores())
  src <- blueant::sources("NOAA OI 1/4 Degree Daily SST AVHRR")
  out <- bowerbird::bb_config(tempdir())
  on.exit(mirai::daemons(0))
  purrr::map(1:3, purrr::in_parallel(function(x) x + 1))

}
