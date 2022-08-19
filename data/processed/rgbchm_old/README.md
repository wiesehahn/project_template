

1. Individual tiles were created with [save_rgbchm_old.R](../../../code/data/save_rgbchm_old.R).

2. *rgbchm_old.tif* was created with GDAL:

```
cd data/processed/rgbchm_old

gdalbuildvrt rgbchm_old.vrt *.tif
gdal_translate rgbchm_old.vrt  rgbchm_old.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=bilinear -a_nodata none -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES
```