---
title: Interlok in Docker
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-docker.html
---

There is now a public docker image for [Interlok](https://hub.docker.com/r/adaptris/interlok/) hosted on [hub.docker.com](https://hub.docker.com) This is a cut-down standard installation that exposes the ports 5555 (for JMX) and 8080 (for the web UI). If you have docker installed, then you can run it simply by doing `docker run -p 8080:8080 adaptris/interlok` and point your browser to `http://localhost:8080` once it has started up. This is the stock adapter that you would get if you didn't make any changes after installation.

You'll still need to build your own docker images, but what you want to do is customize the basic installation with your _own dependencies_ and _configuration_. We have an example project hosted on [github.com](https://github.com/adaptris-labs/docker-interlok-template) that you can fork to bootstrap your own image. Branches exist within the project to demonstrate different build tools (ant, gradle, maven) building the resulting docker image. If you just want to get started, go ahead and clone [https://github.com/adaptris-labs/docker-interlok-template](https://github.com/adaptris-labs/docker-interlok-template); all of this should be pretty obvious already to someone familiar with docker. Pull requests are always welcome.

## docker-interlok-template

The [docker-interlok-template](https://github.com/adaptris-labs/docker-interlok-template) project contains 4 branches; each of those branches should have a sufficient README that you can ignore the rest of this document. However, we will briefly describe each of the branches.

{% include important.html content="Internally we use gradle to manage our configurations so the `gradle-docker-build` is the preferred branch and the one that gets the most love" %}

* The default branch is `gradle-docker-build` which uses gradle to build the docker image; basically `./gradlew docker`. This matches our UI project build system, so is the one that we'll be updating.
* `ant-ivy-build` uses [ant+ivy](advanced-ant-ivy-deploy.html) to resolve dependencies and then a command exec to create the docker image
* `docker-build` can be executed using a standard docker build command (e.g. `docker build . --tag myimage`) but ultimately still uses ant+ivy to manage your dependencies.
* `mvn-docker-build` uses maven with the spotify docker maven plugin; it use usable, but make sure you inspect the pom.xml since there may be exceptions arising from how maven-metadata is handled by maven.

## Doing it from scratch, because I'm old skool

I've prepared my local environment using [ant+ivy](advanced-ant-ivy-deploy.html) to get all the required jar files I needed, and resulting file structure of it looks like this :

```
DockerFile
config
  |- adapter.xml and other things
lib
  |- All the jars that you need (full replace or incremental)
```

Then the contents of your DockerFile can by relatively simple

```

FROM adaptris/interlok

MAINTAINER My Name <email@address.com>

ADD lib /opt/interlok/lib
ADD config /opt/interlok/config

# since 3.6.2 we have switched to /docker-entrypoint.sh as the entrypoint...
# ENTRYPOINT ["/opt/interlok/bin/adapter"]
ENTRYPOINT ["/docker-entrypoint.sh"]


```

To build the container based on the *above file structure*, build as you would any other docker image `docker build --tag myinterlok .` This will build the docker container in your local Docker storage. Run it like you would any other container `docker run -p 8080:8080 myinterlok` and you should be able to connect to the UI using `http://localhost:8080`. Check the docker-entrypoint.sh in the main [github project][] to see how to customise various startup options.

## Misc ##

While constructing a container, you will often want to inspect the container file system to see whether things are as you expect. Here are some useful commands to use when debugging:

```
docker run --rm -i -t --entrypoint=/bin/bash myinterlok
```

This will run a new instance of the `interlok` container but instead of starting the adapter, it will run the bash shell. You can use bash to inspect the container, run the adapter, whichever you want to do. When you shut down this container, the entire contents of the file system will be removed (due to --rm).

```bash
docker ps -a | awk '{print $1}' | xargs docker rm -f
docker images | grep "<none>" | awk '{print $3}' | xargs docker rmi
```

These commands will clean up any non-tagged containers and all images used by them. This frees up the disk space that would otherwise be used by the many temporary containers created while testing the Dockerfile and installation script.

[github project]: https://github.com/adaptris/docker-interlok/