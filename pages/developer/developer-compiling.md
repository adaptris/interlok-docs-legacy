---
title: Compiling against Interlok
keywords: interlok
sidebar: home_sidebar
permalink: developer-compiling.html
tags: [developer]
summary: This is here to help you get started writing your own services and what not.
---

The simplest scenario is to have a local adapter installation and make sure all the jars in the `lib` directory are present in your classpath when you come to compile your classes (either by having a script that sets up the classpath, or making sure `${adapter}/lib/*.jar` is included into your classpath when you invoke the `javac` task.

However, that doesn't need to be the case; all our public artefacts are available in our [maven compatible repository](https://nexus.adaptris.net/nexus/content/repositories/releases/). This means that, you can use your preferred build tool to manage dependencies be it gradle, maven or otherwise.

{% include tip.html content="An example quickstart project on github : [https://github.com/adaptris/interlok-custom-component-example](https://github.com/adaptris/interlok-custom-component-example)" %}

Unless you're in an environment where you must use an alternative build toolchain; we recommend that you use gradle since this gives you good flexibility along with standardised conventions. If you just want to get started hacking code then go straight to our github example project : [https://github.com/adaptris/interlok-custom-component-example](https://github.com/adaptris/interlok-custom-component-example).


## A short excursion into the whys and wherefores of dependency management

Like the argument about whether or not your VCS is better than my VCS. What matters the most is that you aren't using CVS (where CVS is the equivalent of makding all the jars in `{adapter}/lib` present on the classpath.). Without dependency management there is a very real possibility that you end up in the equivalent of _DLL Hell_ where you have jackson-databind-2.10.1.jar trying to use jackson-core-2.9.jar for some of its baseline operations.

Previously we used ant+ivy to handle dependency management; we've moved to gradle for almost everything now. Examples remain in the public github example repository for the different build tools that we've built components with.

