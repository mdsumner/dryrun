noaa_oi_025_degree_daily_sst_avhrr <- function(clobber = FALSE) {
  file <- "./data-raw/noaa_oi_025_degree_daily_sst_avhrr.parquet"

  year00 <- sprintf("/(%s|%s)", format(Sys.Date()-180, "%Y%m"), format(Sys.Date(), "%Y%m"))

  method <- list(accept_follow = year00, accept_download = ".*nc$",
       no_host = FALSE)

  if (clobber) {
    method <- list(accept_follow = ".*", accept_download = ".*nc$",
                   no_host = FALSE)

  } else {
   if (fs::file_exists(file)) {
     ## read the file and determine start and end
     files <- arrow::read_parquet(file)
     startdate <- try(as.Date(max(files$date)))
     if (inherits(startdate, "try-error")) {
       method <- list(accept_download = ".*nc$",
                      no_host = FALSE)
     } else {
     enddate <- Sys.Date()
     seqdate <- seq(as.Date(format(startdate, "%Y-%m-01")), enddate, by = "1 month")
     year00 <- sprintf("/(%s)", paste0(format(seqdate, "%Y-%m"), collapse = "|"))
     method <- list(accept_follow = year00, accept_download = ".*nc$",
                    no_host = FALSE)
     }
   }
  }
  src <- try(blueant::sources("NOAA OI 1/4 Degree Daily SST AVHRR"))
  if (inherits(src, "try-error")) stop("blueant sources failed, abandon 'NOAA OI 1/4 Degree Daily SST AVHRR' noaa_oi_025_degree_daily_sst_avhrr")
  ##accept_follow <- sprintf("/%s", format(seq(as.Date("1981-09-01"), Sys.Date(), by = "1 month"), "%Y%m"))
  #accept_download <- ".*nc$"

  cf <- bowerbird::bb_config(local_file_root = tempdir())
  src_i <- src |> bowerbird::bb_modify_source(method = method)
  cf <- try(bowerbird::bb_add(cf, src_i))
  if (inherits(cf, "try-error")) stop("bowerbird config failed, abandon noaa_oi_025_degree_daily_sst_avhrr")

  sync <- try(bowerbird::bb_sync(cf, confirm_downloads_larger_than = NULL, dry_run = TRUE, verbose = TRUE))
  if (inherits(sync, "try-error")) stop("bowerbird sync failed, abandon noaa_oi_025_degree_daily_sst_avhrr")

  files <- do.call(rbind, sync[["files"]])
  files$date <- as.Date(stringr::str_extract(fs::path_file( files$url), "[0-9]{8}"), "%Y%m%d")
  arrow::write_parquet(files, file)
  saveRDS(cf, "data-raw/config-noaa_oi_025_degree_daily_sst_avhrr.rds")

  files
}
