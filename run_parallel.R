
##-----------------------------------------------------------------------------------------------------------------------------------------------------
rff <- sprintf("/(%s)", paste0(c("Amundsen",  "Antarctic3125NoLandMask", "AntarcticPeninsula",  "Casey-Dumont", "DavisSea", "McMurdo", "Neumayer", "NeumayerEast",
                                "Polarstern", "RossSea", "ScotiaSea", "WeddellSea", "WestDavisSea", "netcdf"), collapse = "|"))


## args to method = list() accept_follow, accept_download, etc
## here we collect everything a dataset needs, including user/pass, tokens and c
## if we use a date regex, first check the cache and insert the latest date (or latest months at minimum)
reqs <- tibble::tribble(
  ~name,
       ~method,
  "NOAA OI 1/4 Degree Daily SST AVHRR",
      list(accept_download = ".*nc$", accept_follow = default_recent_regex(mindate = as.Date("2025-06-01"))),
  "Artist AMSR2 near-real-time 3.125km sea ice concentration",
  list(accept_download = "Antarctic3125/asi.*\\.tif",
       accept_follow = c("(/|\\.html?)$", default_recent_regex(mindate = as.Date("2025-01-01"), fmt = "%Y")),
       reject_follow = rff)
  )





srcs <- dplyr::group_map(dplyr::group_by(reqs, dplyr::row_number()), \(.x, ...)
                 blueant::sources(.x$name) |> bowerbird::bb_modify_source(method = .x$method[[1]]))
## source name, and use a sanitized ID for the file name (hopefully we can do better, or store the IDs and random file name)

## then sync in parallel, and now and then do a full clobber
mirai::daemons(0)
mirai::daemons(min(c(length(srcs), parallelly::availableCores())))
fun <- purrr::in_parallel(function(.x) {
  cf <- bowerbird::bb_config(local_file_root = tempdir())

    cf <- try(bowerbird::bb_add(cf, .x))
   if (inherits(cf, "try-error")) return(NULL) #stop(sprintf("bowerbird config failed, abandon %s", name))

   sync <- try(bowerbird::bb_sync(cf, confirm_downloads_larger_than = NULL, dry_run = TRUE, verbose = TRUE))
   if (inherits(sync, "try-error")) return(NULL) #stop("bowerbird sync failed, abandon noaa_oi_025_degree_daily_sst_avhrr")
 sync
})
purrr::map(srcs, fun)

