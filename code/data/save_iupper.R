##___________________________________________________
##
## Script name: save_iupper.R
##
## Purpose of script:
## Calculate and save mean Intensity raster of upper quantile points
##
##
## Author: Jens Wiesehahn
## Copyright (c) Jens Wiesehahn, 2022
## Email: wiesehahn.jens@gmail.com
##
## Date Created: 2022-06-14
##
## Notes:
##
##
##___________________________________________________

## use renv for reproducability

## run `renv::init()` at project start inside the project directory to initialze 
## run `renv::snapshot()` to save the project-local library's state (in renv.lock)
## run `renv::history()` to view the git history of the lockfile
## run `renv::revert(commit = "abc123")` to revert the lockfile
## run `renv::restore()` to restore the project-local library's state (download and re-install packages) 

## In short: use renv::init() to initialize your project library, and use
## renv::snapshot() / renv::restore() to save and load the state of your library.

##___________________________________________________

## install and load required packages

## to install packages use: (better than install.packages())
# renv::install("packagename") 

renv::restore()
library(here)
library(lidR)
library(dplyr)

##___________________________________________________

## load functions into memory
source(here("code/functions/las_to_iupper.R"))

##___________________________________________________


#### apply function

load(here::here("data/interim/lidr-catalog-new.RData"))

storage_path <- here("data/processed/imean/upper")
opt_output_files(ctg) <- paste0(storage_path, "/{XLEFT}_{YBOTTOM}_iupper")
 ctg@output_options$drivers$SpatRaster$param$gdal = c("COMPRESS=DEFLATE", "PREDICTOR=2")
 ctg@output_options$drivers$SpatRaster$param$datatype = "INT2U"


opt_chunk_buffer(ctg) <- 10
opt_chunk_size(ctg) <- 0
opt_merge(ctg) <- FALSE
opt_stop_early(ctg) <- FALSE

# run for tiles in certain area
aoi <- sf::st_bbox(c(xmin = 6, xmax = 12, ymax = 54, ymin = 51), crs = st_crs(4326)) %>%
  sf::st_as_sfc() %>%
  sf::st_transform(st_crs(ctg))

# dont run for tiles already processed
processed_images <- list.files(storage_path, pattern = ".tif")
processed_images <- substr(processed_images, 1, 14)

ctg@data <- ctg@data %>%
  mutate(processed = case_when(paste0(as.integer(Min.X), "_", as.integer(Min.Y)) %in% processed_images ~ FALSE,
                               sf::st_intersects(ctg@data, aoi, sparse = FALSE) ~ TRUE,
                               TRUE ~ FALSE))

 # mapview::mapview(ctg@data, zcol="processed")
  summary(as.factor(ctg@data$processed))

# set up parallel processing
library(future)
plan(multisession, workers = 12L)

start_time <- Sys.time()
create_imean(ctg, 0.5)
end_time <- Sys.time()
print(end_time - start_time)




