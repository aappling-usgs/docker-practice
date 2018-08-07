# This file should contain a library call to each R package, and only those R
# packages, that you want installed on the Docker image. Dependencies of the
# listed packages will also be installed.

# Above each library() call, include comments describing anything nonstandard
# about how you installed the package - this will help anybody in the future
# who's installing a new version of the library or creating a new docker repo
# like this one.

library(magrittr)
library(sf)

# devtools::install_github('richfitz/remake')
# devtools::install_github('USGS-R/grithub')
# install.packages('imager') # requires libxt-dev, libx11-dev, libfftw3-dev, libtiff5-dev, and libcairo2-dev
# devtools::install_github('USGS-VIZLAB/vizlab')
#library(vizlab)

# library(dataRetrieval)
# library(dplyr)
# library(tidyr)
# library(imager)
