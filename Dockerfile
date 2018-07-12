FROM rocker/geospatial:3.5.0

# dependencies for imager package (may already be covered by rocker/geospatial):
RUN apt-get install -y\
  libxt-dev\
  libx11-dev\
  libfftw3-dev\
  libtiff5-dev\
  libcairo2-dev

COPY ./packrat/init.R /home/required-packages/packrat/init.R
COPY ./packrat/packrat.lock /home/required-packages/packrat/packrat.lock
COPY ./packrat/packrat.opts /home/required-packages/packrat/packrat.opts
COPY ./packrat/src /home/required-packages/packrat/src
COPY ./.Rprofile /home/required-packages/.Rprofile
RUN R --args --bootstrap-packrat -e\
  "libpath <- .libPaths();\
  setwd('/home/required-packages');\
  packrat::restore();\
  pkdir <- dir('./packrat/lib/x86_64-pc-linux-gnu/', full.names=TRUE);\
  pkgs <- dir(pkdir);\
  lapply(pkgs, function(pkg) {\
    unlink(file.path(libpath, pkg));\
    file.copy(file.path(pkdir, pkg), libpath, recursive=TRUE, overwrite=TRUE)\
  });\
  setwd('/');\
  unlink('/home/required-packages', recursive=TRUE)"

RUN mkdir /home/rstudio/docker-practice
VOLUME /home/rstudio/docker-practice
RUN mkdir /home/rstudio/gage-conditions
VOLUME /home/rstudio/gage-conditions
