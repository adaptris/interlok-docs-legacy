---
title: Profiling with Stackify
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-stackify-profiling.html
summary: This page describes how to profile Interlok and inject statistics into Stackify
---

> If you don't know what [Stackify][] is then you can blithely ignore  this document.

## Installation ##

The `com.adaptris:adp-profiler` and `com.adaptris:adp-stackify` artefacts are not normally shipped as part of a traditional installer; you can download them directly from our [public repository] or use [Ant+Ivy](advanced-ant-ivy-deploy.html) to deploy them.


## Enabling the profiler ##

`com.adaptris:adp-profiler` uses AOP to fire events when the appropriate methods of [Workflow][], [AdaptrisMessageProducer][] or [Service][] are triggered. It requires `aspjectjweaver` as a java agent when starting the JVM. The recommendation is to not use the bundled Interlok wrapper executables, and to roll your own scripts which can provide the correct startup parameters to the JVM. The aspects themselves are stored in `META-INF/profiler-aop.xml` which means that you need to set the appropriate aspectj system property to enable the aspects. To get meaningful information you need a concrete implementation of `com.adaptris.profiler.client.PluginFactory` which is where `com.adaptris:adp-stackify` comes in.

> __Note__: Currently, it is only possible to profile classes that live in a `com.adaptris..*` package, to avoid additional overhead in the Aspects.

You will need to have an `adp-profiler.properties` in your classpath which contains a single property `com.adaptris.profiler.plugin.factory=`. The profiler
plugins available for [Stackify] are:

- `com.adaptris.stackify.StackifyPluginFactory`: Generates custom metrics for all workflows, services, and producers.
- `com.adaptris.stackify.WorkflowProfiler`: Generates custom metrics for all workflows
- `com.adaptris.stackify.ServiceProfiler`: Generates custom metrics for all services.
- `com.adaptris.stackify.ProducerProfiler`: Generates custom metrics for all producers.

In this example we only want to profile [Workflow][] activity so we would use `com.adaptris.profiler.plugin.factory=com.adaptris.stackify.WorkflowProfiler`.

## Enabling Stackify ##

You will need to install the [Stackify Agent][]. In addition to providing metrics for for your server hardware; this also allows you to have a custom instrumentation specifically for Interlok.

Next you will need the stackify properties file, which must be included in your Interlok classpath.  You should simply be able to create this file and drop it into the Interlok "config" directory.

The properties file must be so named; `stackify-api.properties` and only needs two properties;
```
stackify.apiKey=8Eh6Nv5GxxxxJy5Ej4Iv0Li4xxxxx8Io4Kr1Xj
stackify.application=InterlokForStackify
```

The `stackify.apiKey` key is supplied by Stackify when you sign up.  The `stackify.application` is an arbitrary chosen name that will be used to group your metrics on the dashboard.


## The Wrapper Script ##

It's up to you how you build up the classpath; but you will need to manually include all the jars as part of the classpath; on Unix style systems, it will be as simple as:

```bash
MYCLASSPATH="./config"
COREJARS=`ls -1 lib/*.jar`
for jar in $COREJARS
do
  MYCLASSPATH=$MYCLASSPATH:$jar
done
```
After that you need to specify the `-javaagent` parameter before using [SimpleBootstrap][] to start Interlok.

```bash
$JAVA_HOME/bin/java -javaagent:/home/adaptris/adapter/lib/aspectjweaver.jar -Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml -cp "$MYCLASSPATH" $JAVA_ARGS com.adaptris.core.management.SimpleBootstrap bootstrap.properties
```


# Runtime Logging #

Once you have put it all together; then when you start the adapter, you will get additional logging at `TRACE` level in the adapter log file.

```
TRACE [<PollingTrigger-null-null> delivery thread] [WorkflowAspect] Before Workflow (StandardWorkflow(Workflow1)) : 7b7bfcf1-b65f-4d60-9ddb-335b101b1a05
...
TRACE [<PollingTrigger-null-null> delivery thread] [WorkflowAspect] After Workflow (StandardWorkflow(Workflow1)) : 21fbb273-fd64-4d0e-8a83-aef0b3d92736
```

If you wish to see more verbose logging and enable the stackify logging, you will make a change to your `log4j.xml` file to add the relevant logger level;

```
<logger name="com.stackify">
  <level value="TRACE"/>
</logger>
```

After about 15-20 minutes, then you will see your Interlok metric groups listed in your [Stackify][] dashboard.

![Dashboard](./images/stackify/StackifyDash.png)

And should you drill down into the groups you can see the metrics over a period of time;

![FSProducer](./images/stackify/FSProducer.png)



[Stackify]: http://stackify.com/
[public repository]: http://development.adaptris.net/nexus/content/groups/public/com/adaptris/
[SimpleBootstrap]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/management/SimpleBootstrap.html
[Stackify Agent]: https://stackify.screenstepslive.com/s/3095/m/7787/l/119709-installation-for-linux
[Workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageListener.html#onAdaptrisMessage-com.adaptris.core.AdaptrisMessage-
[AdaptrisMessageProducer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageSender.html#produce-com.adaptris.core.AdaptrisMessage-com.adaptris.core.ProduceDestination-
[Service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html#doService-com.adaptris.core.AdaptrisMessage-
