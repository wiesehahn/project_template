## `Lidar to Raster`

Use ALS derived Point Cloud to derive the Terrain Model (DTM) and a normalized Surface Model / Canopy Height Model (CHM). 

Data is processed by tile from Point CLoud to Raster data in R with the lidR package. Tiles are further merged to Cloud Optimized Geotiffs via GDAL. 