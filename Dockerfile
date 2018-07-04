FROM rocker/geospatial:3.5.0

# dependencies for imager package (may already be covered by rocker/geospatial):
RUN apt-get install -y\
  libxt-dev\
  libx11-dev\
  libfftw3-dev\
  libtiff5-dev\
  libcairo2-dev

WORKDIR /home/required-packages
COPY ./packrat/init.R ./packrat/init.R
COPY ./packrat/packrat.lock ./packrat/packrat.lock
COPY ./packrat/packrat.opts ./packrat/packrat.opts
COPY ./packrat/src ./packrat/src
COPY ./.Rprofile ./.Rprofile
RUN R -e "0" --args --bootstrap-packrat

WORKDIR /
RUN rm -r /home/required-packages
RUN mkdir /home/rstudio/docker-dev
VOLUME /home/rstudio/docker-dev
