<style>
win7 {
    color: blue;
} 
</style>

# Using the docker image created here

Open a bash shell. <win7>In Windows 7, run Docker Quickstart Terminal <em>as administrator, with VPN off.</em></win7>

Navigate to this project directory.

To build or rebuild the docker image:
```
docker-compose build
```
(You can edit docker-compose.yml to rename the service. The example name used here is `my-vizzy-env`.)

To view the image in coarse and fine detail, respectively:
```
docker image ls
docker image inspect my-vizzy-env
```

Push your image to Docker Hub as soon as you're ready for others to access it.
```
docker push USGS-VIZLAB/my-vizzy-env:0.1.0
```
(Replace `USGS-VIZLAB/my-vizzy-env` with your actual image repository name, and remember to update the tag number each time you build a changed version.)


<win7>
# Setting up VirtualBox for Docker image development and use (Windows 7)

All of the following things need to happen running Oracle VirtualBox and/or the windows command prompt *as administrator*. Don't forget or it won't work.

You'll need to configure the docker-machine VirtualBox image to share a directory or two with you. Because it's all happening on your local machine anyway, I think it's fine to share an entire drive via VirtualBox and then just map specific folders from within the docker-compose.yml file. I have `D_DRIVE` shared. To do the same: right click on VirtualBox, open as administrator. Right click on the `default` machine, select Settings, select Shared Folders, click the icon with the plus sign to add a folder. Name it `D_DRIVE` and map it to `D:\`, or use whatever comparable mapping is appropriate to your computer.

Packrat needs to be able to create symlinks in your shared folders. To enable this, follow the instructions here: http://jessezhuang.github.io/article/virtualbox-tips/. For example, if you have the usual docker-machine VM named `default` and a shared drive named `D_DRIVE`, you should open a Windows command prompt, navigate to the folder containing `VBoxManage.exe` (probably Program Files/Oracle/VirtualBox or similar), and then run
```
VBoxManage setextradata default VBoxInternal2/SharedFoldersEnableSymlinksCreate/D_DRIVE 1
```
This symlink stuff may be mysterious but is super important - without it, packrat is unwilling to reuse the packages already installed on `rocker/geospatial`.

You will probably want more memory and cores than the `default` machine comes with, especially once you get into running your project. From within VirtualBox Manager, right click on the `default` machine, select Settings, select System, and add more memory and more processors. I currently max out the green areas and might eventually even push into the red areas on days when I'm putting all my processing power into the Docker container.

</win7>

# Developing your Docker image

If you're developing a docker image for a new vizzy or analysis project, copy this repo somewhere new. Repos will differ in which packages are installed in their packrat folder.

## Preparing your project repository to work with Docker

To developy your vizzy or analysis in RStudio on the Docker image, first copy example-repo/docker-compose.yml into your project directory, then modify the `volumes` line to map your project directory (`.`) into an aptly named folder within `/home/rstudio/` on the Docker image, e.g., `/home/rstudio/your-project-name`.

<win7>In Windows 7, with docker-machine on VirtualBox, volume sharing is tricky. It might work to open Oracle Virtual Box as administrator, add a Shared Folder to the `default` machine, and then restart `docker-machine`. The volume you map with docker-compose.yml will need to be within that shared folder and should use that mapped-drive name in its file path. For example, my mapped drive is `/D_DRIVE` and the path I use in this practice repo is `/D_DRIVE/APAData/Github/Pipeline/docker-practice`.</win7>

## Working with Docker in your project repository

If you don't have the docker image locally already, run
```
docker pull USGS-VIZLAB/my-vizzy-env
```
(Replace `USGS-VIZLAB/my-vizzy-env` with your actual image repository name.)

From within your vizzy or analysis project, run the following to spin up a Docker image that's aware of your local project files.

Once docker-compose.yml is configured to your liking, run:
```
docker-compose up
```

Next, in your browser, navigate to `localhost:8787` <win7>In Windows 7, replace `localhost` with the specific IP given by `docker-machine ip default`. Still affix the colon and port number 8787, e.g., `http://192.168.99.100:8787`.</win7>

Login with username=`rstudio` and password=`rstudio`.

In the RStudio Files pane, click on your project directory and then on the project .proj file to open your project as an RStudio project.


# Modifying the shared image

Strategy: Use packrat with Git LFS to sync a set of tar.gz package bundles in this Git repository. Then whenever we need to rebuild the Docker image, we can pull from the versioned bundles to reproducibly set up all the R packages. This only helps with R packages, not other software, but is a darn good start.


## When creating a docker repo

### Initializing packrat

In a fresh R session in this repository:
```r
install.packages('packrat')
packrat::init()
```
It's also a good idea to ignore all packages that are already installed on the Docker image we'll be using, at least until we discover that we need a different version of one of those packages. As of 8/7/2018, the R packages already available on the `rocker/geospatial` image are:
```
# I got this list for copy-pasting by launching a container from rocker/geospatial and then running
# cat(paste0("'", rownames(installed.packages()), "'", collapse=', '))
rocker_pkgs <- c('abind', 'assertive', 'assertive.base', 'assertive.code', 'assertive.data', 'assertive.data.uk', 'assertive.data.us', 'assertive.datetimes', 'assertive.files', 'assertive.matrices', 'assertive.models', 'assertive.numbers', 'assertive.properties', 'assertive.reflection', 'assertive.sets', 'assertive.strings', 'assertive.types', 'assertthat', 'backports', 'base64enc', 'BH', 'bindr', 'bindrcpp', 'BiocInstaller', 'bit', 'bit64', 'bitops', 'blob', 'bookdown', 'boot', 'brew', 'broom', 'callr', 'caTools', 'cellranger', 'class', 'classInt', 'cli', 'clipr', 'coda', 'codetools', 'colorspace', 'commonmark', 'concaveman', 'covr', 'crayon', 'crosstalk', 'curl', 'data.table', 'DBI', 'dbplyr', 'deldir', 'desc', 'devtools', 'dichromat', 'digest', 'docopt', 'dplyr', 'DT', 'dtplyr', 'e1071', 'evaluate', 'expm', 'fansi', 'feather', 'FNN', 'forcats', 'foreach', 'foreign', 'formatR', 'future', 'gdalUtils', 'gdata', 'gdtools', 'geometry', 'geoR', 'geosphere', 'ggplot2', 'git2r', 'globals', 'glue', 'gmailr', 'gmodels', 'goftest', 'gridExtra', 'gstat', 'gtable', 'gtools', 'haven', 'hdf5r', 'highr', 'hms', 'htmltools', 'htmlwidgets', 'httpuv', 'httr', 'hunspell', 'igraph', 'intervals', 'iterators', 'jsonlite', 'KernSmooth', 'knitr', 'labeling', 'Lahman', 'later', 'lattice', 'lazyeval', 'leaflet', 'leaflet.extras', 'LearnBayes', 'lidR', 'lintr', 'listenv', 'littler', 'lubridate', 'lwgeom', 'magic', 'magrittr', 'manipulateWidget', 'mapdata', 'mapedit', 'maps', 'maptools', 'mapview', 'markdown', 'MASS', 'Matrix', 'memoise', 'mgcv', 'microbenchmark', 'mime', 'miniUI', 'mockery', 'modelr', 'munsell', 'ncdf4', 'nlme', 'nycflights13', 'openssl', 'packrat', 'pillar', 'pingr', 'pkgbuild', 'pkgconfig', 'pkgload', 'PKI', 'plogr', 'plyr', 'png', 'polyclip', 'praise', 'prettyunits', 'processx', 'proj4', 'promises', 'purrr', 'R.methodsS3', 'R.oo', 'R.utils', 'R6', 'RandomFields', 'RandomFieldsUtils', 'RANN', 'raster', 'RColorBrewer', 'Rcpp', 'RCurl', 'readr', 'readxl', 'rematch', 'remotes', 'reprex', 'reshape2', 'rex', 'rgdal', 'rgeos', 'rgl', 'rhdf5', 'Rhdf5lib', 'RJSONIO', 'rlang', 'rlas', 'rmarkdown', 'rmdshower', 'RMySQL', 'RNetCDF', 'roxygen2', 'rpart', 'RPostgreSQL', 'rprojroot', 'rsconnect', 'RSQLite', 'rstudioapi', 'rticles', 'rversions', 'rvest', 'satellite', 'scales', 'selectr', 'servr', 'settings', 'sf', 'shiny', 'sourcetools', 'sp', 'spacetime', 'spatstat', 'spatstat.data', 'spatstat.utils', 'spData', 'spdep', 'splancs', 'stringdist', 'stringi', 'stringr', 'svglite', 'tensor', 'testit', 'testthat', 'tibble', 'tidyr', 'tidyselect', 'tidyverse', 'tinytex', 'tmap', 'tmaptools', 'tufte', 'units', 'utf8', 'uuid', 'V8', 'viridis', 'viridisLite', 'webshot', 'whisker', 'withr', 'xfun', 'XML', 'xml2', 'xtable', 'xts', 'yaml', 'zoo', 'base', 'compiler', 'datasets', 'graphics', 'grDevices', 'grid', 'methods', 'parallel', 'splines', 'stats', 'stats4', 'tcltk', 'tools', 'utils')
```
Now you can update the options as follows:
```
packrat::set_opts(
  ignored.packages=rocker_pkgs,
  external.packages=rocker_pkgs,
  load.external.packages.on.startup=FALSE)
```

Next, build the bare-bones image.
```
docker-compose build
```

Run the image with this repository bind-mounted to the container.
```
docker-compose up
```

From within the container, first open the packrat project by clicking on docker-practice/docker-practice.Rproj. Then run `install.packages()` or `devtools::install_github()` and add calls to `library(pkg)` to required-packages.R for each package you want to make available. Then call
```r
packrat::snapshot()
```
to update the `packrat` directory with information about the packages you've installed.

Once you've run `packrat::snapshot()` from within the container, stop the container.

### Initializing Git LFS

Install Git LFS from https://git-lfs.github.com/. This allows us to store more on GitHub. We get 1GB storage and 1GB downloads free per user, and it's only $5/mo to add additional increments of 50GB storage and 50GB bandwidth. To install, (1) download the executable from the above website, then (2) run `git lfs install`.

If you're the first one setting up a docker-image-creating repo like this one, run:
```
git lfs track "packrat/src/*"
git add .gitattributes
```

### Initializing packrat+docker

These lines need to go in the Dockerfile, and then all the package installation will be taken care of by packrat rather than package-specific calls in the Dockerfile.
```bash
# inspired by https://github.com/rstudio/packrat/issues/373#issue-229641017 and https://stackoverflow.com/questions/39009579/using-r-package-source-files-in-packrat-rather-than-cran-with-travis-ci:
RUN R -e "0" --args --bootstrap-packrat
#RUN R -e "packrat::restore(restart = FALSE, overwrite.dirty = TRUE)"
```

## When modifying a docker repo

### Working with packrat

### Working with Git LFS

If you've already followed the directions for Initializing Git LFS (above), or if you're just using a repo that someone else created, you shouldn't need to do anything special. Just git commit, push, and pull as usual.

## Working with packrat+docker

Nothing should need to change in the Dockerfile once the directions for Initializing packrat+docker (above) have been followed.
