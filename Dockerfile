FROM rocker/geospatial:3.5.0

# dependencies for imager package (may already be covered by rocker/geospatial):
RUN apt-get install -y\
  libxt-dev\
  libx11-dev\
  libfftw3-dev\
  libtiff5-dev\
  libcairo2-dev

# for use when building the docker image:
# use packrat and file.copy to add packages to the image
RUN mkdir /home/rstudio/docker-practice
VOLUME /home/rstudio/docker-practice
RUN cd "/home/rstudio/docker-practice"
RUN R --args --bootstrap-packrat -e\
  "packrat::packrat_mode(on=TRUE);\
  usrlib <- tail(.libPaths(), 1);\
  packrat::restore(overwrite.dirty=TRUE, prompt=FALSE);\
  srclib <- packrat::lib_dir();\
  pkgs <- dir(srclib, full.names=TRUE);\
  lapply(pkgs, function(pkg) {\
    file.copy(pkg, usrlib, recursive=TRUE, overwrite=TRUE);\
  });\
  setwd('..');"

# for use when developing the vizzy project: volume mapping
# allows you to directly edit the project files on your computer
RUN mkdir /home/rstudio/vizlab-GIF
VOLUME /home/rstudio/vizlab-GIF
