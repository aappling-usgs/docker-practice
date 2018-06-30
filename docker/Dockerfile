FROM rocker/tidyverse:3.5.0
RUN apt-get install -y\
  libxt-dev\
  libx11-dev\
  libfftw3-dev\
  libtiff5-dev\
  libcairo2-dev
RUN Rscript -e "install.packages('imager')"
RUN Rscript -e "devtools::install_github('USGS-R/grithub')"
RUN Rscript -e "devtools::install_github('richfitz/remake')"
RUN Rscript -e "devtools::install_github('USGS-VIZLAB/vizlab')"
