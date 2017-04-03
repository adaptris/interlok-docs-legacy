---
title: Compiling against Interlok
keywords: interlok
sidebar: home_sidebar
permalink: developer-compiling.html
tags: [developer]
summary: This is here to help you get started writing your own services and what not.
---

The simplest scenario is to have a local adapter installation and make sure all the jars in the `lib` directory are present in your classpath when you come to compile your classes (either by having a script that sets up the classpath, or making sure `${adapter}/lib/*.jar` is included into your [ANT](http://ant.apache.org) classpath when you invoke the `javac` task.

However, that doesn't need to be the case; we've moved to [Apache Ivy](http://ant.apache.org/ivy/) for dependency management purposes and [Sonatype Nexus](http://www.sonatype.org/nexus/) as our artefact repository. This means that, once you explicitly name all your dependencies, some magic happens, and files appear in your `~/.ivy2` directory; very similar to what happens with [Apache Maven](http://maven.apache.org).

By default we prefer to use [Apache Ant](http://ant.apache.org) because it allows us more flexibility in how we tailor our builds. You can use [Apache Maven](http://maven.apache.org) if you prefer their conventions. Cool kids use [Gradle](https://gradle.org/).

You will need to have installed :

- ANT 1.9+
- JDK 7

## Quick and Dirty Ivy ##

You really should consult the [Apache Ivy Documentation](http://ant.apache.org/ivy/history/latest-milestone/index.html) to get a better understanding of how ivy works; but an [example project](https://github.com/adaptris/service-example) is available on github to get you started; you will need to modify it to suit your environment, we will use it as the basis of this document

- ivy.properties : contains default properties that could be overwritten in your build.properties (such as the version of core you depend on etc).
- ivy-settings.xml : contains resolvers and settings for your build
- ivy.xml : An Ivy descriptor file that contains your dependencies and configurations.
- build.xml : A standard build.xml file that can be tailored for your requirements.

### ivy-settings.xml ##

This contains all the repositories that are available through our Sonatype Nexus installation.

- nexus-public : pretty much proxies everything that is public like M1/java.net/codehaus which hopefully means that you won't need anything other than nexus-public to get any open source package.
- nexus-releases: The repository where Interlok releases are stored (i.e. adp-core-3.0B12-RELEASE).
- nexus-snapshots: The repository where Interlok snapshots are stored (e.g. adp-core-3.0-SNAPSHOT).

It is possible that certain dependencies can fail; this is because they are not made publicly available by the maintainers and we are hosting them in our internal non-public facing repository. You can either source these files directory from your Interlok installation or have an explicit exclusion for them in your ivy.xml file. The exclusion should be sufficient unless you are referring to them expliclitly in your custom clases.

{% include note.html content="Certain dependencies may fail, such as `javax.management.jmxremote:jmxremote`. This is because they are not made available publicly by the maintainers and we have to host them in our internal non-public facing repository.<br/>- You can source these files from your Interlok installation.<br/>- Alternatively you can `exclude` them in your ivy file unless you are referring to them explicitly in your custom classes." %}

### ivy.xml ###

The supplied ivy.xml contains a default set of suggested dependencies; some are explicitly excluded as we are relying on a number of opensource packages and their dependency tree includes dependencies that are not required for minimal runtime.

The two key dependencies for compilation are `com.adaptris:adp-core` and `com.adaptris:adp-core-apt`; adp-core is the framework itself which has a list of transitive depencencies; adp-core-apt is the annotation processor which provides some additional functionality during the compilation stage (this is discussed more fully in [Annotating Your Components](developer-annotations.html). `com.adaptris:adp-core-apt` contains  generalised junit extensions that simplify tests that you write (it auto-tests XML roundtripping, generates examples etc.).

### Additional ivy configurations ###

We have added an additional configuration inside the supplied ivy.xml:

```xml
<configurations>
...
  <conf name="ant" visibility="private" description="Scope for downloading various jars required to support the build.xml"/>

</configurations>
```

The _ant_ configuration is the scope we use for dependencies that are only required to provide additional features that we use in ant. If we wanted to use the [ant-contrib](http://ant-contrib.sourceforge.net/) tasks then we could

```xml
<dependency org="ant-contrib" name="ant-contrib" rev="1.0b3" conf="ant->default" transitive="false"/>
```

And make sure that we can resolve this dependency and cache the classpath. The supplied `build.xml` actually does this for you so you can use the `<if>` task if that's your bag; however, the [Build Doctor](http://build-doctor.com/2009/09/21/ant-contrib-the-power-and-the-pain/) will not be happy.


