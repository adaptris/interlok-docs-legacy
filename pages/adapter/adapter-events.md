---
title: Events in Interlok
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-events.html
---
Event handling in Interlok consists of a single component [default-event-handler][] which is responsible for publishing [AdapterLifecycleEvents][] and [MessageLifecycleEvents][] events when appropriate. [default-event-handler][] wraps other standard components to fulfil its specialised role within Interlok, so where the event eventually goes is up your configuration.

When a standard lifecycle happens (e.g. `init()`, `start()`, `stop()`, `close()`) then an associated [AdapterLifecycleEvent][] is generated and published. These events are generated regardless of how the lifecycle is invoked, so JVM startup and JMX operations (e.g. via the UI) will cause the lifecycle event to be published.

As a [message][AdaptrisMessage] passes through a [workflow][Workflow] and has various [services][Service] operating on the contents, each [Service][] will generate a [marker event][] which is added to a [MessageLifecycleEvent][]; this marker event captures the name of the [Service][] and whether it was successful or not. At the end of the [Workflow][], this event is published as a record of the operations that happened on the [Message][AdaptrisMessage] in that workflow.

## Sending Events ##

The [default-event-handler][] may only be configured as [part of the Adapter][] object; but will be injected into any [Services][Service] that implement the [EventHandlerAware][] interface. For our example we will configure a [default-event-handler][] that publishes events to a JMS Topic called `events`.

```xml
<adapter>
  <event-handler class="default-event-handler">
    <connection class="jms-connection">
      .. skipped for brevity.
    </connection>
    <producer class="jms-topic-producer">
      <destination class="configured-produce-destination">
        <destination>events</destination>
      </destination>
    </producer>
  </event-handler>
  ... Other configuration skipped.
</adapter>
```

- In this example the event is marshalled using the default marshaller (as defined by your [bootstrap.properties](adapter-bootstrap.html); which is generally XML.
    - You could explicitly configure an [xstream-json-marshaller][] implementation, if you wanted your events to be JSON format

## Adapter Lifecycle Events ##

The following list of standard [AdapterLifecycleEvents][AdapterLifecycleEvent] are built into a standard distribution. Of these, [standard-adapter-start-up-event][] and [heartbeat-event][] may be overridden in configuration at the adapter level.

| Event | Description |
|----|----|
|[adapter-init-event][]| Fired when `init()` is called.|
|[adapter-start-event][]| Fired when `start()` is called.|
|[adapter-stop-event][]| Fired when `stop()` is called.|
|[adapter-close-event][]| Fired when `close()` is called.|
|[adapter-shutdown-event][]| Fired when the adapter is terminated (usually by CTRL-C).|
|[standard-adapter-start-up-event][]| Fired when the `init()` is called, and may optionally contain information extracted from the `Adapter` object.|
|[heartbeat-event][]| Fired on a [periodic schedule][] and contains some information about various states|
|[license-expiry-warning-event][]| Fired on a [periodic schedule][] to indicate that the license is about to expire.|

## Message Lifecycle Events ##

A [MessageLifecycleEvent][] is always created whenever the [message][AdaptrisMessage] is created and will contain the message's unique id. [Marker Events][marker event] are added to the [MessageLifecycleEvent][] as [services][Service] work on it; the [MessageLifecycleEvents][MessageLifecycleEvent] is published asynchronously at the end of the [workflow][Workflow], and errors during the publishing phase are simply logged and will not cause a failure of the message. If you have multiple workflows acting upon the same [message][AdaptrisMessage] then [MessageLifecycleEvents][MessageLifecycleEvent] can be correlated together via the message unique-id.

Each [marker event] will have a creation time (ms since the epoch) associated with it; and also a sequence number. Using the creation time is the preferred method of sorting, but we know that clocks are never in sync, so the sequence number is available as a fallback. Note that the sequence number will be unreliable if the message is retried; or if you publish the [message][AdaptrisMessage] to multiple other workflows simultaneously.

If you do not care about these types of events, then you can turn them off on a per workflow basis by setting `send-events=false` on the workflows. Doing this may have a marginal performance improvement as the act of turning the internal object into a `String` has some cost associated with it.

[marker event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/MleMarker.html
[Workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Workflow.html
[EventHandlerAware]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/EventHandlerAware.html
[default-event-handler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/DefaultEventHandler.html
[AdapterLifecycleEvents]: #adapter-lifecycle-events
[AdapterLifecycleEvent]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/AdapterLifecycleEvent.html
[MessageLifecycleEvents]: #message-lifecycle-events
[MessageLifecycleEvent]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/MessageLifecycleEvent.html
[AdaptrisMessage]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/AdaptrisMessage.html
[part of the Adapter]:https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Adapter.html#setEventHandler-com.adaptris.core.EventHandler-
[Service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Service.html
[xstream-json-marshaller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/XStreamJsonMarshaller.html
[adapter-close-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/AdapterCloseEvent.html
[adapter-init-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/AdapterInitEvent.html
[periodic schedule]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Adapter.html#setHeartbeatEventInterval-com.adaptris.util.TimeInterval-
[adapter-shutdown-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/AdapterShutdownEvent.html
[adapter-start-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/AdapterStartEvent.html
[standard-adapter-start-up-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/StandardAdapterStartUpEvent.html
[adapter-stop-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/AdapterStopEvent.html
[heartbeat-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/HeartbeatEvent.html
[license-expiry-warning-event]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/event/LicenseExpiryWarningEvent.html
