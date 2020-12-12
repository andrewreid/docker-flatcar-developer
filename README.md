# Flatcar Container Linux Development Container

This repository automatically builds a Docker container of the Flatcar Container
Linux Development image.

The development image contains a more complete linux including a full compiler
toolchain. It allows to modify, extend or build custom binaries, drivers or libraries
for Flatcar Linux that are not included in the production image.

Here we automatically turn the raw developer image into a Docker container. It
allows us to use the familiar Docker workflow. It is especially nice in
combination with multi-stage Docker builds, which allows to create minimal
transport images without the build chain overhead.

## Kernel Sources

In addition to the "base" development container, we will also create a "sources" version, which extends the "base" image
with kernel sources stored in `/usr/src/linux`. This provides developers with a starting-point for building kernel modules
and drivers that  are guaranteed to work with their Flatcar kernel.

## Github Actions Configuration

The build is using a cron job that executes the build daily. It creates alpha,
beta and stable images. It first pulls the current versions of each Flatcar
release channel. Then it checks if the corresponding image already exists on
Dockerhub. Only then rebuild the image.

This makes the build indempotent and avoids daily churn on Github Actions.

With the way Flatcar is promoting versions through the channels, this will
usually only build new alpha versions. There's a maximum latency from release
to availability of this Docker image.

## Docker Images

Find the image on Docker Hub: https://hub.docker.com/r/mediadepot/flatcar-developer/

```
docker pull mediadepot/flatcar-developer:1576.5.0
```


# References

- https://github.com/BugRoger/coreos-developer-docker
