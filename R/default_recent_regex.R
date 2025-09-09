## default_recent_months(Sys.Date()-200)
default_recent_regex <- function(mindate = NULL, fmt = "%Y%m", pattern = "/(%s)") {
  if (!is.null(mindate)) {
    start <- as.Date(mindate)
  } else {
    start <- seq(Sys.Date(), length.out = 2, by = "-1 month" )[2L]
  }
  end <- Sys.Date()
  Ym <- format(seq(start, end, by = "1 month"), fmt)
  sprintf(pattern, paste0(Ym, collapse = "|"))
}
