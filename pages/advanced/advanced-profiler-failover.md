---
title: Interlok Failover with AspectJ
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-profiler-failover.html
summary: This page describes how to configure multiple Interlok instances to start up in failover mode (since 3.0.6)
---

## Failover Mode ##

When multiple instances of Interlok start in failover mode, only one single instance, known as the master, will fully start up ready to process messages.  All other Interlok instances in the cluster will sit and wait in a dormant state (slave) until they are promoted to the master.

Each instance in the cluster constantly communicates with every other instance in the cluster via multicast.  Should the master stop communicating with the other instances it is then assumed the master instance has gone down, in which case as soon as each slave recognises the lack of communication from the master, each slave will attempt to broadcast itself as the master.

The first slave to successfully broadcast itself as the master will then be promoted to the master and all other running slave instances will be notified of the new master.

Please note, some environments do not enable multicast broadcasting by default, therefore you may require additional networking configuration before Interlok failover clusters can be configured.

### Installation ###

For each Interlok instance you wish to join the failover cluster, you will need three additional optional components;
- adp-failover
- adp-profiler
- ehcache

Each component will have a set of java library files (*.jar), each of which must be dropped into the lib directory of each Interlok instance in the failover cluster.

## Configuring Basic Interlok Failover ##

Each of the optional components mentioned above require their own configuration which is detailed below.

### Configuring the Profiling Component ###

`com.adaptris:adp-profiler` uses AOP to fire events when the appropriate methods of [Workflow][], [AdaptrisMessageProducer][] or [Service][] are triggered. It requires `aspjectjweaver` as a java agent when starting the JVM. The recommendation is to not use the bundled wrapper executables, and to roll your own scripts which can provide the correct startup parameters to the JVM.

An example windows script to start an Interlok instance in failover mode;

```
setlocal ENABLEDELAYEDEXPANSION

set CLASSPATH=.
set ADAPTRIS_HOME=C:\Adaptris\Interlok3.0.6
set JAVA_HOME=C:\Java\jdk1.7.0_55\bin

set ASPECT_OPTIONS=-Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml

set CLASSPATH=%CLASSPATH%;%ADAPTRIS_HOME%\lib\adp-core.jar;%ADAPTRIS_HOME%\config
for /R %ADAPTRIS_HOME%\lib %%H in (*.jar) do set CLASSPATH=!CLASSPATH!;..\Interlok3.0.6\lib\%%~nxH

%JAVA_HOME%\java -cp %CLASSPATH% -javaagent:lib/aspectjweaver-1.7.4.jar %ASPECT_OPTIONS% -Xmx1024m com.adaptris.core.management.SimpleBootstrap

```

The three important parts of the script above are;

- Setting the `org.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml`.  This tells the profiler where to find the AOP file for instrumentation.
- Specifying the javaagent; `-javaagent:lib/aspectjweaver-1.7.4.jar`
- Starting Interlok using the class `com.adaptris.core.management.SimpleBootstrap`.  Instrumentation will not work correctly if you use the `java -jar` switch.

A unix system example;

It's up to you how you build up the classpath; but you will need to manually include all the jars as part of the classpath; on Unix style systems, it will be as simple as:

```bash
MYCLASSPATH="./config"
COREJARS=`ls -1 lib/*.jar`
for jar in $COREJARS
do
  MYCLASSPATH=$MYCLASSPATH:$jar
done
```

After that you need to specify the `-javaagent` parameters before using [SimpleBootstrap][] to start Interlok.

```bash
$JAVA_HOME/bin/java -javaagent:/home/adaptris/adapter/lib/aspectjweaver.jar -Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml -cp "$MYCLASSPATH" $JAVA_ARGS com.adaptris.core.management.SimpleBootstrap bootstrap.properties
```

Finally, you will also need to have an `adp-profiler.properties` in your classpath (config directory is pretty standard) which contains a single property `com.adaptris.profiler.plugin.factory=com.adaptris.failover.plugin.FailoverInterlokPluginFactory`.

### Configuring the EHCache Component ###

From your Interlok installation, you'll find an ehcache jar (ehcache-core.jar) in the optional directory under ehcache.  Simply drop this jar file into your lib directory of each Interlok instance in the failover cluster.

Then you simply need an `ehcache.xml` file in your classpath (config directory is pretty standard) for each Interlok instance in the failover cluster.

EHCache uses a distributed cache also using multicast to update each Interlok slave instance of the exact messaging state of the master Interlok instance.

A simple example `ehcache.xml`;

```xml
<?xml version="1.0" encoding="UTF-8"?>

<ehcache xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="ehcache.xsd"
         updateCheck="true" monitoring="autodetect"
         dynamicConfig="true">

    <cacheManagerPeerProviderFactory
       class="net.sf.ehcache.distribution.RMICacheManagerPeerProviderFactory"
       properties="peerDiscovery=automatic,
                   multicastGroupAddress=230.0.0.1,
                   multicastGroupPort=4446"/>

    <cacheManagerPeerListenerFactory
       class="net.sf.ehcache.distribution.RMICacheManagerPeerListenerFactory"
       properties="socketTimeoutMillis=200"/>

    <cache name="FAILOVER_CACHE"
          maxEntriesLocalHeap="10"
          eternal="true"
          timeToIdleSeconds="0"
          timeToLiveSeconds="0">
       <cacheEventListenerFactory
          class="net.sf.ehcache.distribution.RMICacheReplicatorFactory"
          properties="replicateAsynchronously=false,
                      replicatePuts=true,
                      replicateUpdates=true,
                      replicateRemovals=true"/>
    </cache>

</ehcache>
```

### Configuring the Failover ###

The failover component will configure itself with some standard default values.  The following properties can be overridden in the bootstrap.properties;

- failover.group
- failover.port
- failover.delay
- failover.retries

The `failover.group` is the multicast address used by Interlok instances to communicate with each other.  The default value is `230.0.0.1`.

The `failover.port` is the multicast port, again used by each instance to communicate.  The default value is `2710`.

The `failover.delay` is the milliseconds delay for each communication status update between your Interlok instances.  The default value is `1000` (1 second).

The `failover.retries` is the number of failed or missing communication updates a slave will tolerate from the master before attempting to promote itself to the master.  The default value is `5`.


## Runtime Logging ##

Once you have put it all together; then when you start your Interlok instances, you will get additional logging at `INFO` level in the log file.

All Interlok instances in the failover cluster will include the following log lines;

```
Sep 15, 2015 10:12:11 AM com.adaptris.failover.ListenService <init>
INFO: Creating listener...
Sep 15, 2015 10:12:11 AM com.adaptris.failover.BroadcastService <init>
INFO: Creating broadcaster...
Sep 15, 2015 10:12:11 AM com.adaptris.failover.ListenService run
INFO: Started listener
Sep 15, 2015 10:12:16 AM com.adaptris.failover.BroadcastService run
INFO: Started broadcaster
Failover Manager has started
```

Only the master instance (the instance started and to broadcast first) will additionally show the following lines in the log file;

```
Sep 15, 2015 10:12:19 AM com.adaptris.failover.FailoverManager promoteToMaster
INFO: Promoted to Master node
Failover Manager has been promoted
```

While all slave instances sit in a dormant state, no additional logging will be seen until that slave is promoted to the master.  In which case you will be notified of the state change and logging for the instance starting up.  Although the example logging below will not match yours entirely, which will depend on your Interlok configuration, it simply demonstrates that the slave instance will not start up and process messages until it is promoted to master.

```
Sep 15, 2015 10:17:11 AM com.adaptris.failover.FailoverManager promoteToMaster
INFO: Promoted to Master node
Failover Manager has been promoted
TRACE [SimpleBootstrap] [InitialisedState] Started [NullProcessingExceptionHandler]
TRACE [SimpleBootstrap:Channel1.START] [InitialisedState] Started [NullConnection]
TRACE [SimpleBootstrap:Channel1.START] [InitialisedState] Started [MessageMetricsInterceptor(Workflow1)]
TRACE [SimpleBootstrap:Channel1.START] [InitialisedState] Started [ServiceList]
TRACE [SimpleBootstrap:Channel1.START] [FixedIntervalPoller] Scheduled java.util.concurrent.ScheduledThreadPoolExecutor$ScheduledFutureTask@3d635385
TRACE [SimpleBootstrap:Channel1.START] [InitialisedState] Started [StandardWorkflow(Workflow1)]
TRACE [SimpleBootstrap:Channel1.START] [InitialisedState] Started [NullConnection]
TRACE [SimpleBootstrap:Channel1.START] [InitialisedState] Started [Channel(Channel1)]
TRACE [SimpleBootstrap] [ClosedState] Started [Adapter(FS-FS-Adapter)]
```

[Workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageListener.html#onAdaptrisMessage-com.adaptris.core.AdaptrisMessage-
[Service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html#doService-com.adaptris.core.AdaptrisMessage-
[AdaptrisMessageProducer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageSender.html#produce-com.adaptris.core.AdaptrisMessage-com.adaptris.core.ProduceDestination-
[SimpleBootstrap]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/management/SimpleBootstrap.html