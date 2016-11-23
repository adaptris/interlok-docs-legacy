---
title: Message Aggregation
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-aggregating-messages.html
summary: From time to time you may need to aggregate messages based on a trigger message that indicates some processing as been completed.
---

> You might want to use [split-join-service](cookbook-split-join.html) to perform an inline split + aggregate.

There are currently 2 [AggregatingConsumeService][] implementations : [aggregating-fs-consume-service][] and [aggregating-jms-consume-service][] which work with the filesystem and a JMS Queue respectively. Both will perform aggregation based on a [custom destination implementation][ConsumeDestinationGenerator] which allows you to dynamically control where the messages are aggregated from.


## Aggregator implementations ##

|Aggregator Type| Description|
|----|----
|[mime-aggregator][]| Creates a new MIME part for each message that is aggregated; the original message is the first MIME Part|
|[ignore-original-mime-aggregator][]| As per [mime-aggregator][] but ignores the original message, so the aggregated message only contains the results of processing|
|[replace-with-first-message-aggregator][]| Replaces the message payload with the _first processed message_.|
|[xml-document-aggregator][]| Merges each processed message into the original document.|
|[ignore-original-xml-document-aggregator][]| Merges each processed message into the configured template, ignoring the original document.|

<br/>

## Example ##

We receive a message via JMS on `SampleQ1`; the _JMSMessageID_ for this message is used in some other messages (waiting on `SampleQ2`) as the _JMSCorrelationID_. When we receive this message, we need to receive only those messages on _SampleQ2_ that have the corresponding _JMSCorrelationID_. Each of the messages received should be inserted into the original document and written back to `JMSReplyTo`.

We can use a combination of [aggregating-jms-consume-service][] and [replace-metadata-value][] to handle this:

```xml
<standard-workflow>
  <consumer class="jms-queue-consumer">
    <destination class="configured-produce-destination">
       <destination>SampleQ1</destination>
    </destination>
    <message-translator class="text-message-translator">
      <move-jms-headers>true</move-jms-headers>
    </message-translator>
  </consumer>
  <service-collection class="service-list">
    <services>
      <copy-metadata-service>
       <metadata-keys>
        <key-value-pair>
         <key>JMSMessageID</key>
         <value>filterSelectorKey</value>
        </key-value-pair>
       </metadata-keys>
      </copy-metadata-service>
      <replace-metadata-value>
        <metadata-key-regexp>filterSelectorKey</metadata-key-regexp>
        <search-value>(.*)</search-value>
        <replacement-value>JMSCorrelationID = '$1'</replacement-value>
      </replace-metadata-value>
      <aggregating-jms-consume-service>
       <connection class="shared-connection">
          <lookup-name>sharedJMS</lookup-name>
       </connection>
       <jms-consumer class="aggregating-queue-consumer">
         <destination class="consume-destination-from-metadata">
           <default-destination>SampleQ2</default-destination>
           <filter-metadata-key>filterSelectorKey</filter-metadata-key>
         </destination>
         <aggregator class="xml-document-aggregator">
          <merge-implementation class="xml-insert-node">
           <xpath-to-parent-node>/envelope/aggregated</xpath-to-parent-node>
          </merge-implementation>
         </aggregator>
       </jms-consumer>
      </aggregating-jms-consume-service>
    </services>
  </service-collection>
  <producer class="jms-queue-producer">
    <destination class="jms-reply-to-destination"/>
  </producer>
</standard-workflow>
```

- We set `move-jms-headers=true` to capture _JMSMessageID_.
- We create a valid filter expression and store it against the metadata key `filterSelectorKey`.
> You don't need to use a [copy-metadata-service][], you could work directly with _JMSMessageID_ with the corresponding changes to config.
- Because `SampleQ2` is fixed; we just use a `default-destination=SampleQ2`.
- We have not explicitly configured a timeout on [aggregating-queue-consumer][]; the default is 30 seconds.
    - If no message was received then an exception will be thrown in 30 seconds.
    - In a worst case scenario we might wait for 60 seconds for this service to complete; we wait 29 seconds for the first message, and then another 30 seconds before the timeout is exceeded; and continuing.
- Each message that has the corresponding _JMSCorrelationID_ is inserted as a new node under `/envelope/aggregated`.

[AdaptrisMessage]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessage.html
[Service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html
[MessageAggregator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/MessageAggregator.html
[AggregatingConsumeService]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/AggregatingConsumeService.html
[mime-aggregator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/MimeAggregator.html
[ignore-original-mime-aggregator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/IgnoreOriginalMimeAggregator.html
[replace-with-first-message-aggregator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/ReplaceWithFirstMessage.html
[xml-document-aggregator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/XmlDocumentAggregator.html
[ignore-original-xml-document-aggregator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/IgnoreOriginalXmlDocumentAggregator.html
[split-join-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/splitter/SplitJoinService.html
[copy-metadata-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/metadata/CopyMetadataService.html
[aggregating-jms-consume-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/AggregatingJmsConsumeService.html
[replace-metadata-value]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/metadata/ReplaceMetadataValue.html
[aggregating-fs-consume-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/fs/AggregatingFsConsumeService.html
[ConsumeDestinationGenerator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/aggregator/ConsumeDestinationGenerator.html
[aggregating-queue-consumer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/AggregatingQueueConsumer.html