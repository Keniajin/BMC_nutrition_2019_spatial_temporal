#########################################################################################################################################################
################## Script for extracting MODIS vegetation indices for analysis##########################################################################
#######################   processing MODIS EVI to get EVI data   ###########################################################################################
##***********************     remotely-sensed data in R.    #############################################################################################
#######################################################Author: KM Wambui ####################################################### 

set.seed(1221223)
library(MODIS)
library(dplyr)
library(foreign)
library(tidyr)

##read in the data with locations from KHDSS
##  1km by 1km latitude and longitude for the 1 by 1 km locations
## this file contains the dat[1] latitude and dat[2] longitude for the 1km by 1km locations 
dat <- foreign::read.dta("data/KHDSS_1km_1km.DTA")

#'         \\\_Extract the rainfall data process_\\\         #
#'#'\\_________Starting the extract of data_______________________\\


##identify the folder with the monthly  tiff data for EVI
## the files were downloaded earlier and saved 
## https://modis.gsfc.nasa.gov/data/dataprod/mod13.php 
##https://www.rdocumentation.org/packages/MODIS/versions/1.1.5/topics/runGdal

## alink that can help https://conservationecology.wordpress.com/2014/08/11/bulk-downloading-and-analysing-modis-data-in-r/

#'install https://www.gdal.org/
#'library(MODIS)
#'runGdal(product="MOD13Q1",begin=as.Date("01/02/2002",format = "%d/%m/%Y") ,
#'      end = as.Date("31/12/2015",format = "%d/%m/%Y"),extent="Kenya")
#'      
#'      'getTile("Kenya")  for tile specific
#'        ,tileH = 21:22,tileV = 8:9 
#'

#'(this process takes some time and needs 30 GB of space free to generate data for the whole admission period
vi <- preStack(path = "modis/monthly_data/", pattern = "*.tif$")

### stack the data to data frame
s <- stack(vi)
s <-  s * 0.0001 # Rescale the downloaded Files with the scaling factor (from modis) EVI

#'#'\\_________extracting for the 1km by 1km data_________\\
# And extract the mean value for our point from before.
# First Transform our coordinates from lat-long to to the MODIS sinus Projection
## method='bilinear' used for extraction 
## If 'simple' values for the cell a point falls in are returned.
## If 'bilinear' the returned values are interpolated from the values of the four nearest raster cells.

sp <-  SpatialPoints(coords = cbind(dat[2], dat[1]),
    proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84") )
sp <- spTransform(sp, CRS(proj4string(s)))
dataExtract <- raster::extract(s, sp , df=T, method="bilinear") # Extract the EVI
write.csv(dataExtract , "data/modis_data_2001_2015.csv")

#'@_______________________________________________________________
#'         \\\_End Extract data process_\\\         #
#'         


####
#'#'\\_________Extracting the rainfall data_________\\
###Extracting the rainfall data
##identify the folder with the monthly  tiff data for EVI
vi2 <- preStack(path = "modis/rainfall/", pattern = "resampledchirps-v2.0.20*")

### stack the data to data frame
si2 <- stack(vi2)

#'#'\\_________extracting for the admissions data_________\\
sp2_b <-  SpatialPoints(coords = cbind(dat[2], dat[1]),
                        proj4string = CRS("+proj=longlat +datum=WGS84 +ellps=WGS84"))
sp2_b <- spTransform(sp2_b, CRS(proj4string(si2)))
dataExtractAdm2 <- raster::extract(si2, sp2_b , df=T, method="bilinear") # Extract the rainfall
write.csv(dataExtractAdm2 , "dataExtractADM_rainfall.csv")
#'@_______________________________________________________________
#'
#'
###change the path name for temporary file
#load("I:/Project/admissionExtract.Rdata")
#s2@file@name <- "G:\\Rtmp8WMcwe\\raster\\r_tmp_2017-03-07_094800_1668_02103.gr"

# library("multidplyr")
# cluster <- create_cluster(2)
# #> Initialising 2 core cluster.
# cluster



