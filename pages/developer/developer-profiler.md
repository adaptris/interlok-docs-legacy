---
title: Interlok Profiler for developers
keywords: interlok,profiler
tags: [developer]
sidebar: home_sidebar
permalink: developer-profiler.html
summary: Guide for developers on Interlok profile events
---

# Interlok Profiler for developers

A guide for Java developers who want to work with Interlok profiling events for your own monitoring/alerting system.

## Starting the profiler

Before we get into the technical bits, let us show you how to start an instance of Interlok with the profiler.

You'll need a couple of additional Interlok jar files, that can be found here;
 - [interlok-monitor-agent](https://nexus.adaptris.net/nexus/content/repositories/releases/com/adaptris/interlok-monitor-agent/)
 - [interlok-profiler](https://nexus.adaptris.net/nexus/content/repositories/releases/com/adaptris/interlok-profiler/)

You'll also need the following external jars;
 - aspectjrt 1.9.2
 - aspectjweaver 1.9.2
 - aspectjtools 1.9.2

Drop these into your interlok __lib__ directory.

When running the profiler it is always suggested to create your own script to launch the Interlok process.  Essentially we need to start the Java process with a javaagent, with the profiling configuration.  Here is a windows batch script (start-interlok-with-profiler.bat) that does the necessary;
```
setlocal ENABLEDELAYEDEXPANSION

set CLASSPATH=.
set INTERLOK_HOME=C:\Adaptris\3.10
set JAVA_HOME=C:\Java\Zulu\zulu-8\bin

set CLASSPATH=%CLASSPATH%;%INTERLOK_HOME%\lib\*;%INTERLOK_HOME%\config

set ASPECT_OPTIONS=-Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml

%JAVA_HOME%\java -cp %CLASSPATH% -javaagent:lib/aspectjweaver.jar %ASPECT_OPTIONS% -jar ./lib/interlok-boot.jar
```
There are two important parts to this script, both of which are Java JVM switches.  The first is the use of the __-javaagent__ and the second is the setting of the following environment property __-Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml__.  

If you drop this batch file into the root of your Interlok installation,  you should only need to change the __JAVA_HOME__ and the __INTERLOK_HOME__ properties to match your correct paths.  There is one more final thing to check however, the final line specifies a jar file named __aspectweaver.jar__ in the __lib__ directory of your Interlok installation.  Make sure your script has the same name of the actual aspectweaver jar in your lib directory, just in case the jar file is named something slightly different.

Now we need a new file in your __config__ directory of your Interlok installation named __interlok-profiler.properties__.  The content of this file should be the following;
```
com.adaptris.profiler.plugin.factory=com.adaptris.monitor.agent.InterlokMonitorPluginFactory
com.adaptris.monitor.agent.EventPropagator=JMX
```

## Working with the events

The profiler generates an object named [__ProcessStep__](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html) for every message event.  

Events are generated for each of the following;
 - An Interlok [Consumer](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/AdaptrisMessageConsumer.html) consumes a message from your data-source such as a JMS queue, file-system, HTTP request etc.
 - A [Service](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/Service.html) processes a message, such as AddMetadataService, JdbcDataQueryService etc
 - A [Producer](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/AdaptrisMessageProducer.html) produces your message to your chosen endpoint such as JMS queue, file-system, HTTP response etc.
 - A [Workflow](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/Workflow.html) has finished processing a message from the Consumer, though all configured services all the way to the Producer.

The important fields for a [__ProcessStep__](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html) are;

| Field | Description |
|----|----|
| [Step Instance ID](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html#getStepInstanceId--) | This field will match the Consumer, Service, Producer or Workflow's configured unique-id. |
| [Step Type](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html#getStepType--) | Will be one of either; [Consumer](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/StepType.html#CONSUMER), [Producer](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/StepType.html#PRODUCER), [Service](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/StepType.html#SERVICE) or [Workflow](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/StepType.html#WORKFLOW) |
| [Failed](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html#isFailed--) | A boolean value, TRUE if this step has caused an error. |
| [Time Taken Millis](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html#getTimeTakenMs--) | Simply the amount of time in milliseconds the component took to process. |
| [Time Taken Nanos](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html#getTimeTakenNanos--) | Simply the amount of time in nanoseconds the component took to process. |


There are currently three ways to consume profiling events, two of which take the raw profiling events and sort them into an [ActivityMap](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-monitor-agent/3.10-SNAPSHOT/com/adaptris/monitor/agent/activity/ActivityMap.html) object, designed to make the process or reading profiling events easier.  The third way is to consume the raw events which are the [ProcessStep](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/ProcessStep.html)'s described above.

### Working with Raw events

You'll need to create your own Java project and make sure you have the interlok-profiler as a dependency.  Assuming you're working with gradle and you've set-up the [Adaptris nexus](https://nexus.adaptris.net/nexus/content/groups/public) as a repository;

```
dependencies {
...
  compile ("com.adaptris:interlok-profiler:3.10.0-RELEASE")
}
```

To consume the raw events you will need to create a Java profiler plugin.  The plugin is then registered as the main destination of any Interlok generated profiling events.

#### Creating a profiler plugin

There are three steps, create a plugin factory class that extends [PluginFactory](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/PluginFactory.html), create a plugin that implements [ClientPlugin](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/ClientPlugin.html) and finally create an [EventReceiver](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/EventReceiver.html) class to receive the raw events.

The plugin factory will be configured in the __interlok-profiler.properties__ as shown in the above sections;

```
com.adaptris.profiler.plugin.factory=<MY NEW PLUGIN FACTORY>
```

You plugin factory will create an instance of the [ClientPlugin](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/ClientPlugin.html), much like this one taken from the interlok-monitor-agent project;

```java
package com.adaptris.monitor.agent;

import com.adaptris.profiler.client.ClientPlugin;
import com.adaptris.profiler.client.PluginFactory;

public class InterlokMonitorPluginFactory extends PluginFactory {

  private ClientPlugin plugin;

  @Override
  public ClientPlugin getPlugin() {
    if (this.plugin == null)
      this.plugin = new InterlokMonitorProfilerPlugin();
    return this.plugin;
  }

}
```

As you see above the factory creates a ClientPlugin, which you will also need to create.  This one below has been taken again from the interlok-monitor-agent project.  For ease of understanding the method detail has been removed.

```java
package com.adaptris.monitor.agent;

import java.util.ArrayList;
import java.util.List;

import com.adaptris.core.Adapter;
import com.adaptris.profiler.client.ClientPlugin;
import com.adaptris.profiler.client.EventReceiver;

public class InterlokMonitorProfilerPlugin implements ClientPlugin {
  
  public InterlokMonitorProfilerPlugin() {
  }

  @Override
  public void close(Object object) {
  }

  @Override
  public void init(Object object) {
  }

  @Override
  public void start(Object object) {
  }

  @Override
  public void stop(Object object) {
  }

  @Override
  public List<EventReceiver> getReceivers() {
  }
}

```

The life-cycle methods; init, start, stop and close will be called for you when the Interlok instance initialises, starts, stops and shuts down.  The most important method here however is the [getReceivers()](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/ClientPlugin.html#getReceivers--) method. 
In this method you will return a list of at least one [EventReceiver](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/EventReceiver.html).

The final step is to create that receiver;

```java
import com.adaptris.profiler.ProcessStep;
import com.adaptris.profiler.client.EventReceiver;

public class MyEventReceiver implements EventReceiver {

  @Override
  public void onEvent(ProcessStep processStep) {
    
  }

}

```

Once you have created these classes and configured the plugin factory in the __interlok-profiler.properties__, your new event receiver will have it's [onEvent()](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-profiler/3.10-SNAPSHOT/com/adaptris/profiler/client/EventReceiver.html#onEvent-com.adaptris.profiler.ProcessStep-) method called every time a new profiling event is generated in Interlok.  It's that simple to consume the raw events.

### Working with the ActivityMap

You'll need to create your own Java project and make sure you have the interlok-profiler and monitor-agent project as dependencies.  Assuming you're working with gradle and you've set-up the [Adaptris nexus](https://nexus.adaptris.net/nexus/content/groups/public) as a repository;

```
dependencies {
...
  compile ("com.adaptris:interlok-profiler:3.10.0-RELEASE")
  compile ("com.adaptris:interlok-monitor-agent:3.10.0-RELEASE")
}
```

The [interlok-monitor-agent](https://github.com/adaptris/interlok-monitor-agent) project has been built as a profiler plugin exactly as described above.  This project receives the raw profiler events and sorts them into a full map of activity, which can then be traversed.  More importantly, each time a producer, service or workflow event is found the [ActivityMap](https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-monitor-agent/3.10-SNAPSHOT/com/adaptris/monitor/agent/activity/ActivityMap.html) calculates the average amount of time in both milliseconds and nanoseconds that this step takes to process.  You can gain access to these activity maps through one of two ways; multicast and JMX.

#### ActivityMap through Multicast

Configure your __interlok-profiler.properties__ like this to turn on multicast;

```
com.adaptris.profiler.plugin.factory=com.adaptris.monitor.agent.InterlokMonitorPluginFactory
com.adaptris.monitor.agent.EventPropagator=MULTICAST
```

For a full running example of consuming ActivityMap objects over multicast see the following sample in the interlok-monitor-agent project; [TestClientStart](https://github.com/adaptris/interlok-monitor-agent/blob/develop/src/main/java/com/adaptris/monitor/agent/TestClientStart.java).

You will need to make a small adjustment however.  The TestClientStart class will receive ActivityMap events, but won't actually do anything with them.  So let's create an event listener and register it in our TestClientStart class.
The listener will be notified every time ActivityMap is consumed through multicast.

First the listener;

```java
import com.adaptris.monitor.agent.activity.ActivityMap;

public interface EventReceiverListener {

  public void eventReceived(ActivityMap activityMap);
  
}
``` 
Simply create a class that implements this interface and handle the ActivityMap objects as you wish.

Now we register your new listener in your version of the TestClientStart class;

```java
import com.adaptris.monitor.agent.multicast.MulticastEventReceiver;

public class TestClientStart {
  public static void main(String args[]) {
    EventReceiverListener listener = new MyNewEventListener();
    MulticastEventReceiver receiver = new MulticastEventReceiver();
    
    receiver.addEventReceiverListener(listener);
    receiver.start();
  }
}
```

In this example, we've created a new class __MyNewEventLister__ explained above, then before we start the MulticastEventReceiver we register our new listener.  Now your new listener will be notified every time an ActivityMap object is consumed over multicast.

#### ActivityMap through JMX

Again using the interlok-monitor-agent project as the profiling plugin we can set our __interlok-profiler.properties__ like this to make sure ActivityMap's are published to JMX rather than multicast;
 
 ```
com.adaptris.profiler.plugin.factory=com.adaptris.monitor.agent.InterlokMonitorPluginFactory
com.adaptris.monitor.agent.EventPropagator=JMX
```

We'll create our own client to connect to the running instance of Interlok's JMX server, proxy the profiling object and then simply pull the ActivityMap data as and when it arrives. 

```java
public void getAndProcessActivityMapFromJMX() {
  // define the profiler mbean object name.
  private static final String METRICS_OBJECT_NAME = "com.adaptris:type=Profiler";
  // First get the local MBean server
  MBeanServer mBeanServer = MBeanServerFactory.findMBeanServer(null);
  // Now simply proxy the profiler mbean
  ObjectName profilerMbean = new ObjectName(METRICS_OBJECT_NAME);
  ProfilerEventClientMBean profilerEventClientMBean = JMX.newMBeanProxy(mBeanServer, profilerMbean, ProfilerEventClientMBean.class);

  // Now simply ask the mbean if it has an ActivityMap for us to process
  ActivityMap eventActivityMap = profilerEventClientMBean.getEventActivityMap();
}
```

The MBean client uses a queue mechanism to store ActivityMap objects in a "first in, first out" mechanism.  Every  time you call __getEventActivityMap()__ if there is an ActivityMap available it will be returned and removed from the queue.

This means you can call __getEventActivityMap()__ until it returns null to consume all queued ActivityMap's.  Then simply continue to call __getEventActivityMap()__ method periodically to get the latest ActivityMap's.

For a full example of a project consuming profiling ActivityMap's from JMX see our [interlok-profiler-prometheus](https://github.com/adaptris/interlok-profiler-prometheus) project, which essentially pulls ActivityMap's from JMX and publishes them to your Prometheus installation. 