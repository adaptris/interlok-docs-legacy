---
title: Performance Metrics
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-performance.html
---

One of the things that we're always asked is to provide some performance metrics for the adapter. The answer here, is that __it depends__. Raw performance numbers are almost always meaningless in the real world; it depends on too many things, the complexity of your environment, the quality of the network, what type of processing that you're actually doing.

Internally we do have some performance metrics about the adapter, gathered using [Perf4J][] running in AOP mode (using the `@Profiled` annotation). So here are some of the simpler results.  For the purposes of the tests we're using 2 JMS Brokers (SonicMQ 8.5) in their out of the box configuration; one is local and the other is remote (they're both just DomainManagers). The adapter is a single channel adapter (local->remote), with defaults for everything; we used [jmsloadtester][] to drive the initial message delivery.

The two machine's in question are :

- From: L502X, i7-2670QM, Windows 7, Java 1.7.0_60, 8Gb RAM
- To: Core2 Duo E6750, CentOS 5.8, Java 1.7.0_60, 2Gb RAM,

And they are connected via our internal infrastructure (so it could be anywhere between 100Mbps and 1000Mbps).


## Methodology ##

1. Disable all management components
1. Start interlok and wait until no more output is happening in the logfile (to ensure full startup)
1. Run load tester software, 20 threads sending 500 messages to consumer queue with a small (1k) testfile.
1. Wait just over 3 mins (This is what we set our [Perf4J][] TimeSlice period to) and send 1 message more.
    - This flushes remaining results to stats.log


## Results ##

Not all results are recorded, tests were run numerous times and the median result set taken. The variance between result sets was small.

### StandardWorkflow ###

This test sees a [standard-workflow][] with no services; and with message lifecycle events turned on.

```
Performance Statistics   10:24:00 - 10:27:00
Tag                          Avg(ms)         Min        Max     Std Dev       Count
PtpProducer.produce()           3.4           1         481         8.5       10000
StandardWorkflow()              4.7           2         483         8.6       10000
sendMessageLifecycleEvent()     1.1           0           8         0.7       10000
```


### StandardWorkflow send-events = false ###

This test sees a [standard-workflow][] with no services; and with message lifecycle events turned off.

```
Performance Statistics   11:09:00 - 11:12:00
Tag                         Avg(ms)         Min        Max     Std Dev       Count
PtpProducer.produce()          3.8           1         568        12.7       10000
StandardWorkflow()             4.2           2         571        12.7       10000
sendMessageLifecycleEvent()    0.0           0           5         0.6       10000
```


### PoolingWorkflow ###

This test sees a [pooling-workflow][] with no services; and with message lifecycle events turned on.


```
Performance Statistics   10:39:00 - 10:42:00
Tag                         Avg(ms)         Min        Max     Std Dev       Count
PtpProducer.produce()          3.5           1         310         6.0       10000
PoolingWorkflow()              4.8           2         312         6.2       10000
sendMessageLifecycleEvent()    0.7           0           7         0.6       10000
```

### PoolingWorkflow send-events=false ###

This test sees a [pooling-workflow][] with no services; and with message lifecycle events turned off.

```
Performance Statistics   11:06:00 - 11:09:00
Tag                         Avg(ms)         Min        Max     Std Dev       Count
PtpProducer.produce()          3.1           1         308         9.1       10000
PoolingWorkflow()              3.3           1         309         9.1       10000
sendMessageLifecycleEvent()    0.0           0           8         0.1       10000
```

## Analysis ##

From the results we can see that the overhead of converting to internal adapter format to process a message is tiny.

- `PtpProducer.produce()` shows us the communication time with destination broker
- `StandardWorkflow()` shows us the total time within workflow

The difference between these two is the time added by the adapter. Removing the _lifecycle event message_ the overhead ranges from *0.2 milliseconds to 0.6 milliseconds per message*.

Sending lifecycle events (denoted by `sendMessageLifecycleEvent()`) has quite a significant impact on performance, so you can immediately improve performance by setting `<send-events>false</send-events>` within a workflow if it is not required. This is because the event is marshalled out to XML before being sent, and there is a significant cost associated with that.

Finally under current testing configurations there is no significant difference between [pooling-workflow][] and [standard-workflow][]; this is because the workflows themselves are not doing anything. If some services were introduced then we might see some performance improvements from [pooling-workflow][].

## Summary ##

Using the adapter in its very simplest form adds an overhead of approximately 0.3 milliseconds to do a glorified JMS copy. We would be able to get some more performance gains by doing JVM tuning and using other configuration options; most of the time though, the adapter *isn't* your bottleneck; it's what you're doing.

1. If you don't care about events then make sure `send-events` is false.
1. Using [pooling-workflow][] will give you a performance benefit if you have complex services like transforms or database lookups, however, it gives you only marginal performance gain if there are no services to be executed.
1. Engage our consultancy team to give you a pro-active health/performance check; they're the people that know how to tune the adapter.





[Perf4J]: http://perf4j.codehaus.org
[jmsloadtester]: https://github.com/niesfisch/jmsloadtester
[standard-workflow]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/StandardWorkflow.html
[pooling-workflow]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/PoolingWorkflow.html

