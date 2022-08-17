##___________________________________________________
##
## Script name: las_to_iupper.R
##
## Purpose of script:
## Function to calculate mean Intensity raster of upper quantile points
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

myMetric<-function(i, z){

  # select upper 25% and 
  q75=quantile(z,probs=c(0.75))
  aboveq75= z>q75

  # calculate mean intensity
  zq75 = i[aboveq75]
  imeanq75=mean(zq75, na.rm=TRUE)

  return(imeanq75)
  }


create_imean <- function(las, resolution = 1)
{
  if (is(las, "LAScatalog"))  {
    options <- list(automerge = FALSE, need_buffer = TRUE)
    opt_select(las) <- "xyzci"
    opt_filter(las) <- "-keep_class 2 -keep_class 13 -keep_class 20"
    return(catalog_apply(las, create_imean, resolution=resolution, .options = options))
  }
  else if (is(las, "LAScluster")) {
    las <- readLAS(las)
    if (is.empty(las)) return(NULL) 
    imean <- create_imean(las, resolution=resolution)
    imean <- terra::crop(imean, ext(chunk))
    return(imean)
  }
  else if (is(las, "LAS")) {
    # normalize
    nlas <- normalize_height(las, tin())
    # select above DBH
    noground <- filter_poi(nlas, Classification != 2, Z >1.3)
    
    imean <- pixel_metrics(noground, ~myMetric(Intensity, Z), res = resolution)
    
    return(imean)
  }
  else {
    stop("This type is not supported.")
  }
}
