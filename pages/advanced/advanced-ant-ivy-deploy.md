---
title: Deploy using ANT
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-ant-ivy-deploy.html
summary: Using a dependency management system to deploy your Interlok instance can make deployments a little bit easier as you can collect and download the required libraries automatically without having to do any post-installation steps
---


This page describes how you can go about deploying Interlok using [Apache Ant][] and a dependency management system such as [Apache Ivy]. Using a dependency management system to deploy your Interlok instance can make deployments a little bit easier as you can collect and download the required libraries automatically without having to do any post-installation steps (such as copying files from `optional/`).

## Initial Setup ##

In this example we will be using [Apache Ant][] and [Apache Ivy][] to manage our dependencies. An [ant-ivy-deploy.zip](./files/ant-ivy-deploy.zip) is provided for you to get started, which we will use as the basis for our example.
You will need to have installed:

- Ant 1.9+
- JDK 8 (recommended; the snapshot adapter requires the built-in nashorn engine)

The files in the zip file are:

- `build.properties` - contains all the properties that control behaviour.
- `resources/ivy-settings.xml` : contains resolvers and settings for your build.
- `resources/ivy-interlok.xml` : An Ivy descriptor file that contains your dependencies and configurations.
- `build.xml` : A standard build.xml file that can be tailored for your requirements.

This example will download and install the nightly snapshot. You can of course change it to download and install a formal release (beta or otherwise); this is left as an exercise for you, but it is likely to mean changing the property `interlok.download.baseurl` and `interlok-core-version` explicitly for the version you wish to install.


## Running the Example ##

There are only two public targets defined in build.xml which are:

```
$ ant -projecthelp
Buildfile: ./ant-ivy-deploy/build.xml

This project is for generating an environment ready to run an Interlok Build.

Pre-requisites: ant-1.9+

Main targets:

 clean   Clean up deployed artifacts
 deploy  Download and Deploy
Default target: deploy

$
```

`ant clean` will do exactly as described; it will delete the entire directory tree, leaving you with just the bare files from [ant-ivy-deploy.zip](files/ant-ivy-deploy.zip). The target that does the work is clearly `deploy`. If we run `ant deploy`; then it will go and do some stuff; provided there are no errors then you should end up with the directory structure similar to:

```
ant-ivy-deploy
 |-build (can be deleted).
 |-config
 |-docs
   |- javadocs
   |- example-xml
 |-lib
 |-logs
 |-optional
 |-webapps
```

The directory structure closely mirrors that of a standard installation, but will not contain the binary executables.

### Build.xml sequence ###

1. Download `ivy.jar` and put it into the `resources` directory.
1. Resolves the `ivy-interlok.xml` file and updates the ivy cache.
1. Download each of the _manual installation_ distributables (`runtime-libraries.zip`, `base-filesystem.zip`, `javadocs.zip`, `example-xml.zip`) and extracts them to the correct location
1. Downloads all of the dependencies specified in the `ivy-interlok.xml` file and copies them into the `lib` directory.


## Customising your dependencies ##

If you wanted to enable certain optional components, then all you need to do is to add a dependency into `ivy-interlok.xml`; for instance, if we know that we will be wanting to do some CSV and JSON transformations we can add in.

```xml
<dependency org="com.adaptris" name="interlok-csv" rev="${interlok-core-version}" changing="true" conf="runtime->default"/>
<dependency org="com.adaptris" name="interlok-json" rev="${interlok-core-version}" changing="true" conf="runtime->default"/>
```

Subsequently, whenever `ant deploy` is invoked; then the `interlok-csv` and `interlok-json` components will be automatically downloaded, and put directly into the lib directory ready for use.

{% include note.html content="Some components (such as SAP) may have dependencies that are not publicly available; you should exclude them explicitly in the ivy file, or build your own repository to host them." %}

[Apache Ant]: http://ant.apache.org
[Apache Ivy]: http://ant.apache.org/ivy/