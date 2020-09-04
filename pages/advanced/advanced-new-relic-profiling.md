---
title: Profiling with New Relic
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-new-relic-profiling.html
summary: This page describes how to profile Interlok and inject statistics into New Relic
---

{% include note.html content="If you don't know what [New Relic][] is then you can blithely ignore  this document." %}

{% include important.html content="in 3.8.0; adp-profiler and adp-new-relic were renamed to interlok-profiler and interlok-new-relic respectively" %}


## Installation ##

The `com.adaptris:interlok-profiler` and `com.adaptris:interlok-new-relic` artefacts are not normally shipped as part of a traditional installer; you can download them directly from our [public repository] or use [Ant+Ivy](advanced-ant-ivy-deploy.html) to deploy them.


## Enabling the profiler ##

`com.adaptris:interlok-profiler` uses AOP to fire events when the appropriate methods of [Workflow][], [AdaptrisMessageProducer][] or [Service][] are triggered. It requires `aspjectjweaver` as a java agent when starting the JVM. The recommendation is to not use the bundled wrapper executables, and to roll your own scripts which can provide the correct startup parameters to the JVM. The aspects themselves are stored in `META-INF/profiler-aop.xml` which means that you need to set the appropriate aspectj system property to enable the aspects. To get meaningful information you need a concrete implementation of `com.adaptris.profiler.client.PluginFactory` which is where `com.adaptris:interlok-new-relic` comes in.

{% include important.html content="Currently, it is only possible to profile classes that live in a `com.adaptris..*` package, to avoid additional overhead in the Aspects." %}

You will need to have an `interlok-profiler.properties` in your classpath which contains a single property `com.adaptris.profiler.plugin.factory=[your choice of plugin]`. The profiler
plugins available for [New Relic][] are:

- `com.adaptris.newrelic.NewRelicInterlokPluginFactory`: Generates custom metrics for all workflows, services, and producers.
- `com.adaptris.newrelic.WorkflowProfiler`: Generates custom metrics for all workflows
- `com.adaptris.newrelic.ServiceProfiler`: Generates custom metrics for all services.
- `com.adaptris.newrelic.ProducerProfiler`: Generates custom metrics for all producers.

In this example we only want to profile [Workflow][] activity so we would use `com.adaptris.profiler.plugin.factory=com.adaptris.newrelic.WorkflowProfiler`.

## Enabling New Relic ##

You may want to install the [New Relic Java Agent][]. In addition to providing metrics for standard components like JMS / JDBC; this also allows you to have a custom instrumentation extension file providing additional metrics about specific methods.

{% include tip.html content="If you are using the [New Relic Java Agent][] (and why wouldn't you) then it should be the first `javaagent` specified on the commandline." %}

### Custom New Relic extensions ###

You can create an `extensions` directory where the [New Relic Java Agent][] is installed; and provide a named extension file. In our case we want to explicitly monitor one of the Cirrus services so we will call ours `cirrus-services.xml`. The file might contain something like (you need to read the [New Relic Agent Documentation][New Relic Java Agent]!):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- This is an example of a custom instrumentation extension XML file. -->
<extension xmlns="https://newrelic.com/docs/java/xsd/v1.0"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xsi:schemaLocation="newrelic-extension extension.xsd " name="cirrus-services"
	version="1.0" enabled="true">
	<instrumentation metricPrefix="Cirrus">

		<pointcut transactionStartPoint="true">
		  <className>com.adaptris.hub.services.MessageRoutingService</className>
		  <method>
		    <name>doService</name>
		    <parameters>
		      <type>com.adaptris.core.AdaptrisMessage</type>
		    </parameters>
		  </method>
    </pointcut>
...
	</instrumentation>
</extension>

```


# The Wrapper Script #

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
$JAVA_HOME/bin/java -javaagent:/home/adaptris/newrelic/newrelic.jar -javaagent:/home/adaptris/adapter/lib/aspectjweaver.jar  -Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml -cp "$MYCLASSPATH" $JAVA_ARGS com.adaptris.core.management.SimpleBootstrap bootstrap.properties
```


# Runtime Logging #

Once you have put it all together; then when you start the adapter, you will get additional logging at `TRACE` level in the adapter log file. You may also get logging in the [New Relic][] logfile.

```
2015-02-09 20:00:50,941 DEBUG [MessageRouting@T-1f2333e] [UnmanagedRoutingSystem] Finding route for [LexcorpEngineering/*][TyrellEngineering/*][ORDER/*]
2015-02-09 20:00:51,013 DEBUG [MessageRouting@T-1f2333e] [MessageRoutingService] Found route for [*/*][TyrellEngineering/*][*/*] going to Adapter TyrellAdapter [client.TyrellAdapter.receive]
2015-02-09 20:00:51,013 DEBUG [MessageRouting@T-1f2333e] [MessageRoutingService] Destination is client.TyrellAdapter.receive
2015-02-09 20:00:51,016 DEBUG [MessageRouting@T-1f2333e] [ServiceList] service [MessageRoutingService(MessageRouting)] applied
2015-02-09 20:00:51,016 DEBUG [MessageRouting@T-1f2333e] [MetadataDestination] dynamic destination [client.TyrellAdapter.receive]
2015-02-09 20:00:51,017 DEBUG [MessageWarehouse@T-1634414] [ServiceList] service [MessageStatisticsUpdateService(MessageStatisticsUpdate)] applied
2015-02-09 20:00:51,017 INFO  [MessageWarehouse@T-1634414] [PoolingWorkflow] message [fe69f84f-131e-4ffb-9c7c-d8d7a2d98165] processed in [79] ms
2015-02-09 20:00:51,027 INFO  [MessageRouting@T-1f2333e] [PasProducer] msg produced to destination [client.TyrellAdapter.receive]
2015-02-09 20:00:51,027 DEBUG [MessageRouting@T-1f2333e] [ServiceList] service [StandaloneProducer] applied
2015-02-09 20:00:51,027 INFO  [MessageRouting@T-1f2333e] [PoolingWorkflow] message [fe69f84f-131e-4ffb-9c7c-d8d7a2d98165] processed in [87] ms
2015-02-09 20:00:51,027 TRACE [Profiler-Event@25093142] [WorkflowStatsCompiler] Increment Counter for Custom/Interlok/Workflow/MessageRouting
2015-02-09 20:00:51,028 TRACE [Profiler-Event@25093142] [WorkflowStatsCompiler] Record ReponseTimeMetric Custom/Interlok/Workflow/MessageRouting=87
```

After about 15-20 minutes, then you will see additional custom metrics available in your [New Relic][] dashboard. Here we would see some custom metrics associated with `Custom/Interlok/Workflow/MessageRouting`.


[New Relic]: http://newrelic.com
[public repository]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/
[SimpleBootstrap]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/management/SimpleBootstrap.html
[New Relic Java Agent]: https://docs.newrelic.com/docs/agents/java-agent
[Workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/AdaptrisMessageListener.html#onAdaptrisMessage-com.adaptris.core.AdaptrisMessage-
[AdaptrisMessageProducer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/AdaptrisMessageSender.html#produce-com.adaptris.core.AdaptrisMessage-com.adaptris.core.ProduceDestination-
[Service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/Service.html#doService-com.adaptris.core.AdaptrisMessage-
