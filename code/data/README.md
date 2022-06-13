## `code\data`

The code for all kinds of data processing is saved here and the result are stored under `..\data\processed`.

---

run `save_rgbdtm.R` and `save_rgbchm.R` to create Digital Terrain Model and Canopy Height Model for Lidar tiles.


run the following gdal processes to merge tiles in Cloud Optimized Geotiffs.
(this can be done e.g. by OSGeo4W Shell which comes with QGIS)
```
cd *path to project*\data\processed

gdalbuildvrt rgbdtm.vrt rgbdtm\*.tif
gdal_translate rgbdtm.vrt  rgbdtm\rgbdtm.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=NEAREST -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES

gdalbuildvrt rgbchm.vrt rgbchm\*.tif
gdal_translate rgbchm.vrt  rgbchm\rgbchm.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=NEAREST -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES
```