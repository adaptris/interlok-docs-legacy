---
title: "When to use a TriggeredChannel"
keywords: interlok, integration, triggered
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-triggered-channel.html
summary: A TriggeredChannel is one that requires an external trigger; this can be useful in certain situations
---

The [TriggeredChannel][] is available as part of the [optional packages](adapter-optional-components.html) packages and is something that has a very specific use case. It is a channel where the workflows are only started when an external event occurs; hence the name. Once the trigger is received, workflows are started, the channel waits for the workflows to do their thing, and then stops them afterwards and is then ready for the next trigger. It is designed to be wholly asynchronous, so no information is returned back to the trigger.

There are some subtle differences between a TriggeredChannel and a normal channel; the consumers inside each workflow should really be based around things that actively poll (i.e. [AdaptrisPollingConsumer][] implementations) rather than consumers that wait for activity (like a JmsConsumer or the like, if you need JMS behaviour, there is [JmsPollingConsumer][]). The polling implementation for each consumer should be a _OneTimePoller_ rather than one of the other implementations. This type of channel also handles errors and events slightly differently. By default, the channel will supply its own message error handling implementation, rather than using the Adapter's (in this case a `com.adaptris.core.triggered.RetryMessageErrorHandler`, infinite retries at 30 second intervals); you can change it if you want, but it must still be an instance of `com.adaptris.core.triggered.RetryMessageErrorHandler`. The trigger itself could be anything you want, it has a consumer/producer/connection element, so you could listen for an HTTP request, or use a `JmxChannelTrigger` which registers itself as a standard MBean, so you can trigger it remotely via jconsole or the like.

## Example ##

If for instance, an adapter is running on a remote machine, and you don't have the capability to login to the filesystem and retry failed messages then you could use a TriggeredChannel to copy all the files from the _bad_ directory into a _retry_ directory so that the [FailedMessageRetrier][] is triggered. This is obviously a contrived use case; if you have the type of failure where messages can be automatically retried without manual intervention then a normal [RetryMessageErrorHandler][] will probably be a better bet. Alternatively, just use the UI to retry the message(s).

In this instance we'll make the trigger a message on a JMS Topic; any message received on the topic _retry-failed-messages_ will start the channel, files will be copied from the bad directory to the retry directory and then the channel will stop.

```xml
<channel class="triggered-channel">
  <unique-id>RETRY_FAILED_MESSAGES</unique-id>
  <trigger>
    <connection class="jms-connection">
       ... config skipped for brevity
    </connection>
    <consumer class="jms-topic-consumer">
      <destination class="configured-consume-destination">
        <destination>retry-failed-messages</destination>
        <configured-thread-name>JMS RETRY Trigger</configured-thread-name>
      </destination>
    </consumer>
  </trigger>
  <workflow-list>
    <standard-workflow>
      <consumer class="fs-consumer">
        <destination class="configured-consume-destination">
          <destination>/path/to/bad/directory</destination>
        </destination>
        <poller class="triggered-one-time-poller"/>
        <create-dirs>true</create-dirs>
        <reset-wip-files>true</reset-wip-files>
      </consumer>
      <producer class="fs-producer">
        <destination class="configured-produce-destination">
          <destination>/path/to/retry/directory</destination>
        </destination>
        <create-dirs>true</create-dirs>
      </producer>
    </standard-workflow>
  </workflow-list>
</channel>
```

{% include links.html %}


[TriggeredChannel]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-triggered/
[AdaptrisPollingConsumer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisPollingConsumer.html
[JmsPollingConsumer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/jms/JmsPollingConsumer.html
[FailedMessageRetrier]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/FailedMessageRetrier.html
[RetryMessageErrorHandler]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/RetryMessageErrorHandler.html
