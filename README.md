<style>
win7 {
    color: blue;
} 
</style>

# Developing your docker image

If you're developing a docker image for a new vizzy or analysis project, copy this repo somewhere new. Repos will differ in which packages are installed in their packrat folder.

Open a bash shell. <win7>In Windows 7, run Docker Quickstart Terminal <em>as administrator.</em></win7>

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
docker push USGS-VIZLAB/my-vizzy-env
```
(Replace `USGS-VIZLAB/my-vizzy-env` with your actual image repository name.)


# Using your Docker image

## Preparing your project repository to work with Docker

To developy your vizzy or analysis in RStudio on the Docker image, first copy example-repo/docker-compose.yml into your project directory, then modify the `volumes` line to map your project directory (`.`) into an aptly named folder within `/home/rstudio/` on the Docker image, e.g., `/home/rstudio/your-project-name`.

win7>In Windows 7, with docker-machine on VirtualBox, volume sharing is tricky. It might work to open Oracle Virtual Box as administrator, add a Shared Folder to the `default` machine, and then restart `docker-machine`. The volume you map with docker-compose.yml will need to be within that shared folder and should use that mapped-drive name in its file path. For example, my mapped drive is `/D_DRIVE` and the path I use in this practice repo is `/D_DRIVE/APAData/Github/Pipeline/docker-practice`.</win7>

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
packrat::init(options=list(ignored.packages='packrat', ignored.directories=c('example-repo','packrat')))
```

Next install a starter set of packages (whatever you already know you need). Use any of the usual installation commands - `install.packages`, `install_github`, `install_version`, etc. Work at the command line rather than creating an R script, because packrat.lock will document everything we need to know about how the packages were installed.

When you're ready, call
```r
packrat::snapshot()
```
to update the `packrat` directory with information about the packages you've installed.

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
