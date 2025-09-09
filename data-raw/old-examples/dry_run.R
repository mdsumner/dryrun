library(purrr)
mirai::daemons(parallelly::availableCores())

fun <- in_parallel(function(x) {
  bowerbird::bb_sync(x, confirm_downloads_larger_than = NULL, dry_run = TRUE, verbose = FALSE)
})

library(bowerbird)
library(blueant)

datadir <- file.path(tempdir(), "bowerbird_files")
if (!file.exists(datadir)) dir.create(datadir)

srcset <- NULL

src <- blueant::sources("NOAA OI 1/4 Degree Daily SST AVHRR")
accept_follow <- sprintf("/%s", format(seq(as.Date("2024-09-01"), Sys.Date(), by = "1 month"), "%Y%m"))
accept_download <- ".*nc$"

cf <- bowerbird::bb_config(local_file_root = tempdir())
src_i <- src |> bowerbird::bb_modify_source(method = list(accept_follow = "/(2025)", accept_download = ".*nc$",
                               no_host = FALSE))
cf <- bowerbird::bb_add(cf, src_i)
sync <- bowerbird::bb_sync(cf, confirm_downloads_larger_than = NULL, dry_run = TRUE, verbose = TRUE)

https://www.ncei.noaa.gov/data/sea-surface-temperature-optimum-interpolation/v2.1/access/avhrr/202508/l <- vector("list", length(accept_follow))
for (i in seq_along(accept_follow)) {
 src_i <- src |>
  bb_modify_source(method = list(accept_follow = accept_follow[i], accept_download = ".*nc$",
                                 no_host = FALSE))
 cf <- bb_config(local_file_root = datadir)
 l[[i]] <- bb_add(cf, src_i)
}




statuses <- map(l, fun)
mirai::daemons(0)

saveRDS(statuses, "~/dryrun.rds")




year00 <- sprintf("/(%s|%s)", format(Sys.Date(), "%Y/%m"), format(Sys.Date()-30, "%Y/%m"))
secret00 <- structure(list(type = "cmems", user = "braymond", password = "5%=rDMIjk]*F>~oGY52ye+F^>"), row.names = 2L, class = "data.frame")
library(bowerbird)
library(blueant)

datadir <- file.path(tempdir(), "bowerbird_files")
if (!file.exists(datadir)) dir.create(datadir)

srcset <- NULL


rf <- sprintf("/(%s)", paste0(c("Amundsen",  "Antarctic3125NoLandMask", "AntarcticPeninsula",  "Casey-Dumont", "DavisSea",
                                "DumontdUrvilleSea", "McMurdo", "Neumayer", "NeumayerEast",
                                "Polarstern", "PrydzBay", "RossSea", "ScotiaSea", "ToPrydzBay", "WeddellSea", "WestDavisSea",
                                "netcdf", "nobootstrap"), collapse = "|"))

##just this year's data
#source_url = paste0("https://seaice.uni-bremen.de/data/amsr2/asi_daygrid_swath/s3125/", format(Sys.Date(), "%Y"), "/"),

src0 <- blueant::sources("Artist AMSR2 near-real-time 3.125km sea ice concentration") |>
  bb_modify_source(      source_url = "https://seaice.uni-bremen.de/data/amsr2/asi_daygrid_swath/s3125/",
                         method = list(
                           #accept_follow = "/Antarctic3125",
                           reject_follow = rf,
                           accept_download = ".*tif$",
                           no_host = FALSE))



library(bowerbird)
secret00 <- structure(list(type = "cmems", user = "braymond", password = "5%=rDMIjk]*F>~oGY52ye+F^>"), row.names = 2L, class = "data.frame")
srcset <- NULL
src0 <- blueant::sources("CMEMS global gridded SSH reprocessed (1993-ongoing)") |>
   bb_modify_source(user = secret00$user, password = secret00$password,
 method = list(accept_download = ".*nc$", no_host = FALSE))
srcset <- rbind(srcset, src0)

cf <- bb_config(local_file_root = datadir)
cf <- bb_add(cf, srcset)
system.time({
  sync <- bb_sync(cf, confirm_downloads_larger_than = NULL, dry_run = TRUE, verbose = TRUE)
})


