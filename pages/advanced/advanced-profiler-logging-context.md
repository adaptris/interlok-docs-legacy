---
title: Automagically adding mapped diagnostic context data for logging
keywords: interlok,profiler,logging
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-profiler-logging-context.html
summary: Automatically added message-id to logging context.
---

**Since 3.10** the [interlok-profiler](https://github.com/adaptris/interlok-profiler) has an additional aspect available to it (you should be able to use it with previous versions of Interlok since this is a pure aspect with few dependencies) which adds the _messageId_ and the _parentMessageId_ to your logging context (the _parentMessageId_ might be useful if you are using a splitter). Since logging contexts are thread-based, depending on where in your processing chain you are and what service combinations your workflow contains, you can lose the logging context or gain an unwanted logging context. With this in mind, you can view the profiling logging context as a way of guaranteeing that you have the correct logging context via the use of an AspectJ aspect rather than being frustrated because your workflow design isn't suitable for [add-logging-context-service][] or [logging-context-workflow-interceptor][]

## Getting started

The easiest way is to use dependency management to and include [interlok-profiler][] as a dependency; once you have the appropriate jar file then you can start Interlok with the appropriate runtime configuration.

```
JAVA_ARGS="-javaagent:./lib/aspectjweaver.jar -Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-logging-context.xml"
java $JAVA_ARGS -jar lib/interlok-boot.jar
```

Note that there are 3 profiler configurations available in the [interlok-profiler][] jar file. You can of course write your own if your requirements don't match what's available

* META-INF/profiler-aop.xml - this provides performance metrics data that you can use with [prometheus](advanced-profiler-prometheus.html)
* META-INF/profiler-logging-context.xml - Just includes the aspect for adding the logging context
* META-INF/profiler-interlok-all.xml - All of the above.

## What it does

Before every invocation of the methods `doService(), onAdaptrisMessage()` within the _com.adaptris..*_ package namespace it will add the current message's uniqueId and if available, the parentMessageId against the keys `messageId` and `parentMessageId` respectively. We restrict the package check to avoid excessive loadtime when starting the application. If you do have a custom code, and it's in your own package namespace then just compile something similar : you can find the source code on [github](https://github.com/adaptris/interlok-profiler) - [LoggingContextAspect][])

## Log4j2 configuration

You can now use _%X_ to grab contextual information out of the diagnostic context and use that as part of your log4j2 pattern.

```xml
<Console name="Console" target="SYSTEM_OUT">
  <PatternLayout>
    <Pattern>%-5p [%t] [%c{1.}] [%X{parentMessageId}].[%X{messageId}] %m%n</Pattern>
  </PatternLayout>
</Console>
```

which leads to logging like this (since this particular example isn't inside a splitter, we don't get anything for the `parentMessageId`)

```
TRACE [JMX-Request-0:fervent-tesla.START] [c.a.c.u.LifecycleHelper] [].[] Executing Start(): EmbeddedConnection(jetty)
TRACE [JMX-Request-0] [c.a.c.u.LifecycleHelper] [].[] Executing Start(): NoRetries(jolly-ptolemy)
TRACE [JMX-Request-0] [c.a.c.u.LifecycleHelper] [].[] Executing Start(): SharedComponentList
INFO  [JMX-Request-0] [c.a.c.Adapter] [].[] Adapter(MyInterlokInstance) Started
DEBUG [gigantic-davinci@fervent-tesla] [c.a.c.StandardWorkflow] [].[868e716f-e960-4c68-be5f-94fd099b15d6] start processing msg [DefaultAdaptrisMessageImp[uniqueId=868e716f-e960-4c68-be5f-94fd099b15d6,metadata=[[jettyURI]=[/api/logging], [httpmethod]=[GET], [jettyURL]=[http://localhost:8080/api/logging], [_interlokMessageConsumedFrom]=[/api/logging]]]]
DEBUG [gigantic-davinci@fervent-tesla] [c.a.c.ServiceList] [].[868e716f-e960-4c68-be5f-94fd099b15d6] Executing doService on [EmbeddedScriptingService(select-failure)]
DEBUG [gigantic-davinci@fervent-tesla] [c.a.c.ServiceList] [].[868e716f-e960-4c68-be5f-94fd099b15d6] Executing doService on [IfElse(shall-i-fail)]
TRACE [gigantic-davinci@fervent-tesla] [c.a.c.s.c.IfElse] [].[868e716f-e960-4c68-be5f-94fd099b15d6] Running logical 'IF', with condition class ConditionMetadata
TRACE [gigantic-davinci@fervent-tesla] [c.a.c.s.c.c.ConditionMetadata] [].[868e716f-e960-4c68-be5f-94fd099b15d6] Testing metadata condition with key: failure
TRACE [gigantic-davinci@fervent-tesla] [c.a.c.s.c.IfElse] [].[868e716f-e960-4c68-be5f-94fd099b15d6] Logical 'IF' evaluated to true, running service.
DEBUG [gigantic-davinci@fervent-tesla] [c.a.c.ServiceList] [].[868e716f-e960-4c68-be5f-94fd099b15d6] Executing doService on [AlwaysFailService(failure-triggered)]
```

The project used to create the logging extract can be found on [github](https://github.com/adaptris-labs/interlok-logging-context)

[interlok-profiler]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-profiler/
[add-logging-context-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/services/AddLoggingContext.html
[logging-context-workflow-interceptor]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/interceptor/LoggingContextWorkflowInterceptor.html
[LoggingContextAspect]: https://github.com/adaptris/interlok-profiler/blob/develop/src/main/java/com/adaptris/profiler/aspects/LoggingContextAspect.java