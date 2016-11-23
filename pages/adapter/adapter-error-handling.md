---
title: Error Handling
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-error-handling.html
summary: This document describes the error handling that can be configured within Interlok
---
Error handling in Interlok consists of 2 components that are related to each other: [FailedMessageRetrier][] and [ProcessingExceptionHandler][]. The [ProcessingExceptionHandler][] component is used to handle messages which encounter problems as they are being processed. The [FailedMessageRetrier][] is responsible for retrying messages that have failed (as the name suggests).

## Handling Exceptions ##

The [ProcessingExceptionHandler][] component can be configured at [part of a Workflow][], [part of a Channel][] or [globally at the Adapter][] level which means that you can have specific error handling behaviour on a per-channel or per-workflow basis. Most of the time we can just write the original file out to something that can't fail (well, unlikely to fail in the context of things) like the file system.

A [ProcessingExceptionHandler] which writes all messages causing an exception to the local file system can be be configured by adding a `message-error-handler` element to the `adapter` Of course, the [ProcessingExceptionHandler][] is not limited to the local file-system; you can use any [Service] implementation to compose specific behaviour.  The local file-system is the recommended option, as you can be certain that this exists, and doesn’t require additional network connectivity.  If the services that you applying as part of the [ProcessingExceptionHandler] chain fail, then there is no fall back, the message will be lost. You need to make sure that the first thing you do is to __archive__ the file so that can be reprocessed.

> If the services that you applying as part of the [ProcessingExceptionHandler] chain fail, then there is no fall back, the message will be lost. You need to make sure that the first thing you do is to __archive__ the file so that can be reprocessed.

As part of a standard installation, you get access to [standard-processing-exception-handler][] and [retry-message-error-handler][]. [retry-message-error-handler][] will attempt to periodically retry a failed message a configurable number of times before finally considering the message failed, and triggering the configured `processing-exception-service`.

```xml
<message-error-handler class="standard-processing-exception-handler">
 <processing-exception-service class="service-list">
  <services>
   <standalone-producer>
    <producer class="fs-producer">
     <destination class="configured-produce-destination">
      <destination>/path/to/bad-directory</destination>
     </destination>
     <encoder class="mime-encoder"/>
    </producer>
   </standalone-producer>
  </services>
 </processing-exception-service>
</message-error-handler>
```

- Here we are writing files to the `/path/to/bad-directory` when an exception is encountered.
- The [AdaptrisMessage] object will be MIME encoded (due to the `encoder`)
    - Encoding the file is required; this will ensure that it contains information about which workflow caused the failure.

## Chaining Exception Handlers ##

Because it is possible to configure an exception handler as [part of a Workflow][], [part of a Channel][] or [globally at the Adapter][]; it becomes possible to chain together multiple exception handlers. Each of the configured exception handlers will be notified of the failed message, and the message will be propagated outwards until it reaches the exception handler at the adapter level; by default, the parent handlers will simply notify its own parent of the failed message without doing anything with the message; it is possible to change this behaviour by configuring [always-handle-exception][] on the exception handler.

This is useful if you want to have the same _final home_ for failed messages, but be able to configure different behaviours at the workflow and channel level. So in the following configuration :

- workflow1-exception-handler : send a HTTP 500 response.
- workflow2-exception-handler : none.
- channel-exception-handler : send a HTTP 404 response; always-handle-exception=false
- adapter-exception-handler : write to filesystem /opt/adaptris/bad; always-handle-exception=true

The exception handling behaviour for `workflow1` will be :

1. Return a `500 Server Error` to the client; notify the parent handler.
1. The channel level exception handler notifies the parent handler
1. The adapter level exception handler writes the original message to `/opt/adaptris/bad`.

The exception handling behaviour for `workflow2` will be :

1. Return a `404 Not Found` to the client (The closest exception handler at the channel level.)
1. The adapter level exception handler writes the original message to `/opt/adaptris/bad`.

If you configure multiple [retry-message-error-handler][] instances, all with `always-handle-exception=true` then you can get some behavioural oddities. The number of attempts that each configured [retry-message-errorhandler][] will attempt to retry the message may vary (if you inspect the log files closely), however, the total number of attempts will not exceed the highest configured max-retry-count on any individual [retry-message-error-handler][]


## Retrying Messages ##

The [FailedMessageRetrier] component allows messages that have failed, to be retried. Each [FailedMessageRetrier] is similar to [ProcessingExceptionHandler] in that it wraps other standard components to fulfil a specialised role within Interlok. It may only be configured [at the Adapter][] level.

```xml
<failed-message-retrier class="default-failed-message-retrier">
 <standalone-consumer>
  <consumer class="fs-consumer">
   <destination class="configured-consume-destination">
    <destination>/path/to/retry-directory</destination>
   </destination>
   <poller class="quartz-cron-poller">
    <cron-expression>0 */5 * * * ?</cron-expression>
   </poller>
   <encoder class="mime-encoder">
     <retain-unique-id>true</retain-unique-id>
   </encoder>
  </consumer>
 </standalone-consumer>
</failed-message-retrier>
```

- [default-failed-message-retrier][] polls a directory for messages to resubmit for processing again.
- The message is expected to have been encoded when it was written out to bad, therefore an encoder is configured.
    - We use `retain-unique-id=true` to preserve the unique ID of the message that failed.
- The directory which is polled by [default-failed-message-retrier][] could be the same directory where failed messages are written by the [ProcessingExceptionHandler] (you may as well just use a [retry-message-error-handler][]); but this is not advised.


[AdaptrisMessage]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessage.html
[FailedMessageRetrier]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/FailedMessageRetrier.html
[ProcessingExceptionHandler]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ProcessingExceptionHandler.html
[part of a Workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/WorkflowImp.html#setMessageErrorHandler-com.adaptris.core.ProcessingExceptionHandler-
[part of a Channel]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Channel.html#setMessageErrorHandler-com.adaptris.core.ProcessingExceptionHandler-
[globally at the Adapter]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Adapter.html#setMessageErrorHandler-com.adaptris.core.ProcessingExceptionHandler-
[service-list]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ServiceList.html
[Service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html
[standard-processing-exception-handler]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/StandardProcessingExceptionHandler.html
[retry-message-error-handler]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/RetryMessageErrorHandler.html
[at the Adapter]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Adapter.html#setFailedMessageRetrier-com.adaptris.core.FailedMessageRetrier-
[default-failed-message-retrier]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/DefaultFailedMessageRetrier.html
[always-handle-exception]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/RootProcessingExceptionHandler.html#setAlwaysHandleException-java.lang.Boolean-
