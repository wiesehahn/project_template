##___________________________________________________
##
## Script name: save_rgbchm.R
##
## Purpose of script:
## Create a Canopy Height Model and store the RGB encoded version.
##
##
## Author: Jens Wiesehahn
## Copyright (c) Jens Wiesehahn, 2022
## Email: wiesehahn.jens@gmail.com
##
## Date Created: 2022-06-01
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
source("code/functions/las_to_rgbchm.R")

##___________________________________________________


#### apply function

load(here::here("data/interim/lidr-catalog.RData"))


storage_path <- here("data/processed/rgbchm_old")
opt_output_files(ctg) <- paste0(storage_path, "/{XLEFT}_{YBOTTOM}_rgbchm")
opt_chunk_buffer(ctg) <- 10
opt_chunk_size(ctg) <- 0
opt_merge(ctg) <- FALSE
opt_stop_early(ctg) <- FALSE


# run for tiles in certain area
aoi <- sf::st_read("K:/aktiver_datenbestand/ni/lverm/las/stand_2022_0513/doku/lasboundary_merged.gpkg") %>%
  sf::st_zm() %>%
  sf::st_as_sfc() %>%
  sf::st_union() %>%
  sf::st_transform(st_crs(ctg))

# dont run for tiles already processed
processed_images <- list.files(storage_path, pattern = ".tif")
processed_images <- substr(processed_images, 1, 14)

ctg@data <- ctg@data %>%
  mutate(processed = case_when(sf::st_intersects(ctg@data, aoi, sparse = FALSE) ~ TRUE,
                               TRUE ~ FALSE))

# mapview::mapview(ctg@data, zcol="processed")
 summary(as.factor(ctg@data$processed))

# set up parallel processing
library(future)
plan(multisession, workers = 6L)

start_time <- Sys.time()
create_terrainrgb(ctg, 0.25)
end_time <- Sys.time()
print(end_time - start_time)









