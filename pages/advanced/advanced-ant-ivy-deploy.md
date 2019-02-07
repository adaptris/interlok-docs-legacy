---
title: Deploy using dependency management.
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-ant-ivy-deploy.html
summary: Using a dependency management system to deploy your Interlok instance can make deployments a little bit easier as you can collect and download the required libraries automatically without having to do any post-installation steps
---

All the cool kids are using [gradle][] or [kobalt][] (probably [gradle][] right...), so describing dependency management using ant+ivy is a bit of an anachronism. Since ant provides very little magic or opinion around _how you do things_, it's a good learning tool.

The concepts are the same across all the build tools, build up your dependency tree, download them, copy them somewhere. Internally we still use ant for a lot of things because it allows us to have a generic build script and then control behaviour with different ivy descriptor files. Conversely, when your dependencies are tightly coupled with the project build file, you don't get that luxury without having to jump through some hoops.

{% include note.html content="[Interlok install builder][] is in github if you want to get straight to the meat and bones; choose a branch that fits your tool" %}

## Initial Setup ##

In this worked example we will be using [Apache Ant][] and [Apache Ivy][] to manage our dependencies. Checkout the [Interlok install builder (ant+ivy)][] variant of [Interlok install builder][] which we will use as the basis for our example. You will need to have installed:

- Ant 1.9+
- JDK 8 (as you'll need this to run Interlok from 3.8 onwards)

The files are:

- `ivy/ivy-settings.xml` : contains resolvers and settings for your build.
- `ivy/ivy-interlok.xml` : An Ivy descriptor file that contains your dependencies and configurations.
- `ivy/ivy-ui.xml` : An Ivy descriptor file that contains the dependency and configuration for the Interlok UI
- `build.xml` : A standard build.xml file that can be tailored for your requirements.
- `src/main/interlok` : Interlok configuration.
- `build.properties` : You'll need to create one and add overrides if you don't like the defaults...

This example will download and install the nightly snapshot. You can of course change it to download and install a formal release (beta or otherwise) by explicitly setting additional properties in `build.properties`

## Running the Example ##

There are only a couple of public targets defined in build.xml which are:

```
This project is for generating an environment ready to run Interlok.

Pre-requisites: ant-1.9+

Main targets:

 clean         Clean up build artifacts
 cleanInstall  Delete the installation directory
 deploy        Download and Deploy
Default target: deploy
$
```

`ant clean` will do exactly as described. The target that does the work is clearly `deploy`. If we run `ant deploy`; then it will go and do some stuff; provided there are no errors then you should end up with the directory structure similar to:

```
build/install/interlok-install-builder
 | -config
 |-docs
   |- javadocs
 |-lib
 |-webapps
 |-tmp
```

The directory structure closely mirrors that of a standard installation, but will not contain the binary executables; so `cd ${interlokInstallDirectory} && java -jar lib/interlok-boot.jar` is the way to go.

### Build.xml sequence ###

1. Download `ivy.jar` and put it into the `ivy` directory.
1. Resolves the `ivy-interlok.xml` file and updates the ivy cache.
1. Downloads all of the dependencies specified in the `ivy-interlok.xml` file and copies them into the `${interlokInstallDirectory}/lib` directory.
1. Downloads all of the javadoc dependencies specified in the `ivy-interlok.xml` file and copies them into the `${interlokInstallDirectory}/docs/javadocs` directory.
1. Downloads all of the dependencies specified in the `ivy-ui.xml` file and copies them into the `${interlokInstallDirectory}/webapps` directory.
1. Copies everything from `src/main/interlok` into the installation directory.


## Customising your dependencies ##

If you wanted to enable certain optional components, then all you need to do is to add a dependency into `ivy-interlok.xml`; for instance, if we know that we will be wanting to do some CSV and JSON transformations we can add in.

```xml
<dependency org="com.adaptris" name="interlok-csv" rev="${interlokCoreVersion}" changing="true"/>
<dependency org="com.adaptris" name="interlok-json" rev="${interlokCoreVersion}" changing="true"/>
```

Subsequently, whenever `ant deploy` is invoked; then the `interlok-csv` and `interlok-json` components will be automatically downloaded, and put directly into the lib directory ready for use.

{% include important.html content="If you are using service-tester along with JSON assertions then you should exclude `com.vaadin.external.google:android-json` from the dependency tree. This can cause conflicts with normal Interlok JSON processing." %}

{% include note.html content="Some components (such as SAP) may have dependencies that are not publicly available; you should exclude them explicitly in the ivy file, or build your own repository to host them." %}

[Apache Ant]: http://ant.apache.org
[Apache Ivy]: http://ant.apache.org/ivy/
[gradle]: https://gradle.org
[kobalt]: https://beust.com/kobalt/plug-ins/index.html
[Interlok install builder]: https://github.com/adaptris-labs/interlok-install-builder
[Interlok install builder (ant+ivy)]: https://github.com/adaptris-labs/interlok-install-builder/tree/ant+ivy