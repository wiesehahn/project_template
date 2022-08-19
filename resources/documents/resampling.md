## Resampling

When image overviews are generated (which is the case when COGs are created) a resampling strategy is applied. The implications of different resampling methods were tested.


### Method

A RGB-encoded canopy height model was translated to COG with different resampling strategies using GDAL:
```
cd C:\Users\jwiesehahn\Downloads\temp

gdal_translate 595000_5853000_chm_2017.tif  595000_5853000_chm_2017_nearest.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=NEAREST -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES

gdal_translate 595000_5853000_chm_2017.tif  595000_5853000_chm_2017_average.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=average -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES

gdal_translate 595000_5853000_chm_2017.tif  595000_5853000_chm_2017_bilinear.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=bilinear -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES

gdal_translate 595000_5853000_chm_2017.tif  595000_5853000_chm_2017_cubic.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=cubic -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES

gdal_translate 595000_5853000_chm_2017.tif  595000_5853000_chm_2017_lanczos.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=lanczos -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES

gdal_translate 595000_5853000_chm_2017.tif  595000_5853000_chm_2017_mode.tif -ot byte -of COG -co COMPRESS=WEBP -co QUALITY=100 -co RESAMPLING=mode -a_nodata "0 0 0" -co NUM_THREADS=ALL_CPUS -co BIGTIFF=YES
```

### Results 

#### Visaual appearance
Visually inspecting the resulting CHMs at different zoom levels showed that all methods resulted in appropriate overviews. However, some images looked more noisy than others. Especially *nearest* resampling resulted in a noisy surface. 

#### File size
File sizes of the resulting COGs (including overviews) differed between ~140% and 180% of the original (already compressed) image size.

#### Speed
Another factor in some cases might be the time it takes to calculate the overviews with different resampling methods. Although no accurate measurements were made, it is clear that advanced methods such as *lancos* require more computational efford than e.g. *nearest* resampling.

### Conclusion
*Mode* resampling method had a smooth visaul appearance and also the smallest file size in the test. 