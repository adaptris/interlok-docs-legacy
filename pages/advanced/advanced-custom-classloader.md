---
title: Enabling a Custom Class Loader for Jetty
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-custom-classloader.html
summary: This page describes how to configure a custom class loader for use with Jetty (since 3.5.1).
---

## Default Behaviour##

By default the current threads class loader is used to load management
components.

## Configuring a Custom Class Loader ##

The class loader can be changed by setting the `classloader` property in
the Jetty configuration file
`…/META-INF/com/adaptris/core/management/components/jetty`, for
example:

```nohighlight
classloader=com.adaptris.core.management.classloader.BlacklistingFactory
```

## Configuring JAR Blacklisting ##

With the custom BlacklistingFactory in use, the
`classloader.blacklist.filenames` property value in
`bootstrap.properties` can be used to exclude JAR and WAR files from the
classpath of the custom class loader. Its format is a comma-separated
list of files/folders to remove from the classpath.

```nohighlight
classloader.blacklist.filenames=jersey-client.jar,jersey-common.jar,jersey-entity-filtering.jar,jersey-guava.jar,jersey-media-json-jackson.jar,hk2-api.jar,hk2-locator.jar,hk2-utils.jar
```

## Runtime Logging ##

There is minimal logging within the `BlacklistingFactory` that can be
used to determine which classes have been blacklisted and which haven't.
This is all preceded by the log message indicating that a custom class
loader is being used:

```nohighlight
DEBUG [main] [ManagementComponentFactory] Using custom class loader com.adaptris.core.management.classloader.BlacklistingFactory
```

Followed by a list of blacklisted/whitelisted JAR files:

```nohighlight
TRACE [main] [BlacklistingFactory] Whitelisting hibernate-validator.jar
DEBUG [main] [BlacklistingFactory] Blacklisting hk2-api.jar file://Projects/odin-interlok/packager/build/openfield/lib/hk2-api.jar
DEBUG [main] [BlacklistingFactory] Blacklisting hk2-locator.jar file://Projects/odin-interlok/packager/build/openfield/lib/hk2-locator.jar
DEBUG [main] [BlacklistingFactory] Blacklisting hk2-utils.jar file://Projects/odin-interlok/packager/build/openfield/lib/hk2-utils.jar
TRACE [main] [BlacklistingFactory] Whitelisting hppc.jar
```

Log messages concerning blacklisted JAR files include both the file name
and the full path, whereas whitelisted items only indicate the JAR file
name. Also note that whitelisting messages only occur when logging is
enabled and set to `TRACE` instead of `DEBUG`.
