
##___________________________________________________
##
## Script name: create_catalog.R
##
## Purpose of script:
## create catalog from las files files and store on disk for faster loading
##
##
## Author: Jens Wiesehahn
## Copyright (c) Jens Wiesehahn, 2021
## Email: wiesehahn.jens@gmail.com
##
## Date Created: 2021-11-05
##
## Notes:
## The catalog can be read from R file using `load(here("data/interim/lidr-catalog.RData"))`
## The projection has to be set afterwards using `projection(ctg) <- 25832`
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


file <- here("data/interim/lidr-catalog.RData")

folder1 <- here("K:/aktiver_datenbestand/ni/lverm/las/stand_2021_0923/daten/3D_Punktwolke_Teil1")
folder2 <- here("K:/aktiver_datenbestand/ni/lverm/las/stand_2021_0923/daten/3D_Punktwolke_Teil2")
ctg = readLAScatalog(c(folder1, folder2))
st_crs(ctg) <- 25832

info <- sf::st_read("K:/aktiver_datenbestand/ni/lverm/las/stand_2021_0923/doku/3D_Punktwolke_gesamtÜbersicht.shp") %>%
  mutate(Data.Year = as.integer(A_JAHR),
         Data.Month = as.integer(A_MONAT)) %>%
  select(Data.Year, Data.Month) %>%
  st_centroid()
ctg@data <- ctg@data %>% st_join(info)


save(ctg, file = file)



