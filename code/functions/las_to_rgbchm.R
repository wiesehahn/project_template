##___________________________________________________
##
## Script name: las_to_rgbchm.R
##
## Purpose of script:
## Function to create a Canopy Height Model and store data as RGB encoded Raster
## 
##
## Author: Jens Wiesehahn
## Copyright (c) Jens Wiesehahn, 2022
## Email: wiesehahn.jens@gmail.com
##
## Date Created: 2022-06-05
##
## Notes:
##
##
##___________________________________________________

library(lidR)

#### function to write dtm as rgb encoded raster

to_terrainrgb <- function(dtm)
{
  startingvalue <- 10000
  precision <- 0.01
  rfactor <- 256*256 * precision
  gfactor <- 256 * precision
  
  r <- floor((startingvalue +dtm)*(1/precision) / 256 / 256)
  g <- floor((startingvalue +dtm - r*rfactor)*(1/precision) / 256) 
  b <- floor((startingvalue +dtm - r*rfactor - g*gfactor)*(1/precision))
  
  terrainrgb <- c(r,g,b)
  
  return(terrainrgb)
  rm("r","g", "b", "terrainrgb")
}



write_rast = function(rast, file)
{
  file1 = tools::file_path_sans_ext(file)
  file1 = paste0(file1, "_temp.tif")
  terra::writeRaster(rast, file1, datatype="INT1U", NAflag=NA, gdal=c("COMPRESS=DEFLATE", "PREDICTOR=2"))
  
  # with overviews
  #gdalUtils::gdaladdo(paste0(file, "_temp.tif"), r="nearest", levels=c(2,4,8,16,32))
  
  gdalUtils::gdal_translate(paste0(file, "_temp.tif"),
                            paste0(file, ".tif"),
                            of="GTiff",
                            co=c("TILED=YES", "COMPRESS=WEBP", "WEBP_LOSSLESS=True", "NUM_THREADS=4", "COPY_SRC_OVERVIEWS=YES", "DISCARD_LSB=0,0,4", "BLOCKXSIZE=512", "BLOCKYSIZE=512"))

  file.remove(paste0(file, "_temp.tif"))
}


create_terrainrgb <- function(las, resolution = 1)
{
  if (is(las, "LAScatalog"))  {
    las@output_options$drivers$SpatRaster = list(
      write = write_rast,
      object = "rast",
      path = "file",
      extension = "",
      param = list())
    options <- list(automerge = FALSE, need_buffer = TRUE)
    #opt_select(las) <- "xyzc"
    opt_filter(las) <- "-drop_class 7 -drop_class 15"
    return(catalog_apply(las, create_terrainrgb, resolution=resolution, .options = options))
  }
  else if (is(las, "LAScluster")) {
    las <- readLAS(las)
    if (is.empty(las)) return(NULL) 
    terrainrgb <- create_terrainrgb(las, resolution=resolution)
    terrainrgb <- terra::crop(terrainrgb, ext(chunk))
    return(terrainrgb)
  }
  else if (is(las, "LAS")) {
    # normalize
    nlas <- normalize_height(las, tin())
    dtm <- rasterize_canopy(las=nlas, res=resolution, algorithm=p2r(subcircle =0.1, na.fill = tin())
                            #dsmtin()
                            #pitfree(thresholds = c(0, 2, 5, 10, 20), max_edge = c(0, 1), subcircle = 0.2)
                              , pkg = "terra")
    
    terrainrgb <- to_terrainrgb(dtm)
    
    return(terrainrgb)
  }
  else {
    stop("This type is not supported.")
  }
}

