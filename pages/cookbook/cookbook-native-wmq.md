---
title: Integrating with Native WebsphereMQ
keywords: interlok wmq WebsphereMQ
tags: [cookbook, messaging]
sidebar: home_sidebar
permalink: cookbook-native-wmq.html
summary: This document summarises configurations for consuming and producing messages using the native IBM WebsphereMQ API.
---

{% include important.html content="in 3.8.0; adp-webspheremq was renamed to interlok-webspheremq" %}

This document summarises configurations for consuming and producing messages using the native IBM WebsphereMQ API. If you are attaching to WebsphereMQ via JMS, then the [JMS Guide][] contains specifics for that. It assumed that you have a passing knowledge of Interlok and its configuration. This guide has been built with MQSeries version 7.5 in mind.  However if you happen to be using another version, the only changes should be to the java archive files you will need to copy from your MQSeries installation to your Interlok installation, mentioned later in this guide.


----

## Getting Started ##

### Interlok Pre-requisites ###

Before you can start Interlok that is able to consume or produce from or to MSMQ, you must first install the Interlok MSMQ sub component into your Interlok installation. All available Interlok sub components are shipped with the standard Interlok installation.  Simply navigate to the _optional_ directory at the root of your Interlok installation and from there the `webspheremq` subdirectory.   Copy the java archive file named `interlok-webspheremq.jar` to your _lib_ directory in the root of your Interlok installation.  Finally you will also need to copy any required java archives for client access from your MQSeries installation into the _lib_ directory of your Interlok installation directory. Generally speaking this will be all `com.ibm.*.jar files`, along with `dhbcore.jar`, however additional jars may be required depending on the connection method. All configuration examples for can be found in the _docs/optional/example-xml_ directory as normal.

----

## Native Consumer / Producer ##

In some situations, it is preferable to use the native API for accessing WebsphereMQ, perhaps because not all of the available fields from MQMessage are mapped when using the JMS API.

### Connections ###

There are two types of connection available to use: [wmq-attached-connection][] and [wmq-detached-connection][]. Both types of connection have exactly the same configuration. The key difference between the two connections is that an [wmq-attached-connection][] reuses the same `MQQueueManager` instance for the lifecycle of the connection. [wmq-detached-connection][] creates a new MQQueueManager instance every time it is required. [wmq-attached-connection][] may have added performance benefits, if `MQQueueManager` is a resource hungry component; however, in testing, using [wmq-attached-connection][] stopped WebsphereMQ from performing a controlled shutdown, and caused additional issues when attempting to recover from an uncontrolled shutdown.


| Name | Description |
|----|----|
|queue-manager|The name of the queue manager within WebsphereMQ to connect to|
|redirect-exception-logging|Defaults to false. MQException exposes a static field log which receives additional logging information when an MQException is encountered. Set this to be true, if you wish for that additional logging to be redirected from stderr to the log4j logging system.
|environment-properties|A [KeyValuePairSet][] that contains additional properties that are provided to the MQQueueManager constructor. This exposes primitive values (such as String, Boolean, Integer) so that the default WebsphereMQ Client settings can be overridden. Consult the javadocs for [NativeConnection][] for additional information|

<br/>

### Sending and Receiving Messages ###

Both the [wmq-native-producer][] and [wmq-native-consumer][] implementations have broadly the same type of configuration. The standard implementation for consuming messages from WebsphereMQ is a [PollingConsumer][] implementation. There is no facility within the WebsphereMQ API to register a listener, so we physically poll the MQQueueManager for any new messages and process them upon each poll trigger. Each implementation contains a list of `field-mapper` elements that are responsible for mapping each MQMessage field to and from the AdaptrisMessage. Additionally, each implementation has a number of configurable options available so that the MQQueue is accessible with a variety of options.

### Mapping Fields ###

There are a number of ways you can map specific MQMessage fields into AdaptrisMessage and vice versa. All field mapper instances contain some common configuration elements:

| Name | Description |
|----|----|
|mq-field-name|This refers to the specific field within the MQMessage that you wish to map. Refer to the javadocs for [FieldMapper][] to see the supported fields.
|byte-translator|Some MQMessage fields are byte[] fields. The byte-translator is responsible for mapping the byte[] into Strings and vice versa.|
|convert-null|Whenever a null value is encountered, and this field is true, an attempt is made to convert the null into something meaningful.|

The supported types of field mapper are [wmq-metadata-field-mapper][], [wmq-message-id-mapper][], [wmq-configured-field][], [wmq-xpath-field][] and [wmq-uuid-field-mapper][].

|Mapper Type| Description|
|----|----|
| [wmq-metadata-field-mapper][] |This maps an item of AdaptrisMessage metadata to a specific MQMessage field (and vice versa). The metadata-key element determines the metadata key that will be used to derive the content of the mapping.|
|[wmq-message-id-mapper][]|This maps the AdaptrisMessage unique id into a specific MQMessage field (and vice versa)|
|[wmq-configured-field]|This simply sets a specific MQMessage field to the configured value. MQMessage fields may not be mapped into AdaptrisMessage using this FieldMapper instance.|
|[wmq-xpath-field][]|This resolves an XPath against the AdaptrisMessage payload and sets a specific MQMessage field based on this value. MQMessage fields may not be mapped into AdaptrisMessage instances using this instance
|[wmq-uuid-field-mapper][]|This field mapper sets the configured field to a freshly generated UUID. This is primarily only of use when using `pre-get-field-mapper` instances. There are occasions when the recipient has to specify the correlation ID of the message.

<br/>

### Translating Bytes ###

There are currently 4 different byte translator implementations: [charset-byte-translator][], [simple-byte-translator][], [base64-byte-translator][] and [hex-string-byte-translator][]. These are described in their associated javadocs.

### Message Format and Queue Options ###

The options on the consumer and producer control the behaviour when you

- Open the queue
- Close the queue
- Message Type that is sent/received from the queue
- Specific message options that control the behaviour of `MQQueue.put()` and `MQQueue.get()`.

All the options available are text values that match the MQC constant name; the corresponding integer value is derived through reflection. What this means is that if you have specific options (other than the default) which need to be applied, you will have to check the notes in the information centre for those values and to use the constant name as a comma separated string. (e.g. `MQOO_INPUT_AS_Q_DEF,MQOO_OUTPUT` - no spaces!); alternatively you could use the literal integer value of 17 (MQOO_INPUT_AS_Q_DEF = 1 and MQOO_OUTPUT = 16). The default values are fairly sensible, and you should not have to modify these in most situations. If the options you have specified do not enable features that are specifically required by the Producer or Consumer at runtime, they may be added dynamically and a log message will be displayed indicating the option that was missing.

|Option | Description |
|----|----|
|queue-open-options|Sets the open options on the queue when accessing the Queue. Any or none of the literal values associated with the following MQC fields may be used. If more than one option is required, then values can separated using a , (make sure there are no spaces). `MQOO_INQUIRE`,`MQOO_BROWSE`, `MQOO_INPUT_AS_Q_DEF`, `MQOO_INPUT_SHARED`, `MQOO_INPUT_EXCLUSIVE`, `MQOO_OUTPUT`, `MQOO_SAVE_ALL_CONTEXT`, `MQOO_PASS_IDENTITY_CONTEXT`, `MQOO_PASS_ALL_CONTEXT`, `MQOO_SET_IDENTITY_CONTEXT`, `MQOO_SET_ALL_CONTEXT`, `MQOO_ALTERNATE_USER_AUTHORITY`, `MQOO_FAIL_IF_QUIESCING` |
|queue-close-options|Set the specific options to be used when closing a queue. The default value is `MQCO_NONE`, but you may opt to use `MQCO_DELETE` or `MQCO_DELETE_PURGE` if you are working with permanent dynamic queues|
|message-format|Specify the format of the message. Valid values are __Text__, __String__, __Bytes__, and __Object__. They correspond to the values `MQC.MQFMT_STRING`, `MQC.MQFMT_STRING`, `MQC.MQFMT_NONE` and `java.lang.Object` respectively. Bear in mind that Text implies UTF-8, so if you wish to use the platform default encoding, then use the __String__ type.|
|message-options|This controls the options that are used when invoking `MQQueue.put()` and `MQQueue.get()`. Depending on whether it is the consumer or producer, you will need to use different values. If the context of the message options is part of a producer, then the following values have meaning: `MQPMO_SYNCPOINT`, `MQPMO_NO_SYNCPOINT`, `MQPMO_NO_SYNCPOINT`, `MQPMO_NO_CONTEXT`, `MQPMO_DEFAULT_CONTEXT`, `MQPMO_SET_IDENTITY_CONTEXT`, `MQPMO_SET_ALL_CONTEXT`, `MQPMO_FAIL_IF_QUIESCING`, `MQPMO_NEW_MSG_ID`, `MQPMO_NEW_CORREL_ID`, `MQPMO_LOGICAL_ORDER`, `MQPMO_ALTERNATE_USER_AUTHORITY`, and `MQPMO_RESOLVE_LOCAL_Q`. If the context of the message options is part of a consumer, then the following values have meaning: `MQGMO_WAIT`, `MQGMO_NO_WAIT`, `MQGMO_SYNCPOINT`, `MQGMO_NO_SYNCPOINT`, `MQGMO_BROWSE_FIRST`, `MQGMO_BROWSE_NEXT`, `MQGMO_BROWSE_MSG_UNDER_CURSOR`, `MQGMO_MSG_UNDER_CURSOR`, `MQGMO_LOCK MQGMO_UNLOCK`, `MQGMO_ACCEPT_TRUNCATED_MSG`, `MQGMO_FAIL_IF_QUIESCING`, and `MQGMO_CONVERT`|

----

## Error Handling ##

It is possible that messages that have been consumed from WebsphereMQ cannot be translated into an AdaptrisMessage object. Common causes for this would be:

- Incorrect mapping configuration
- Incorrect message type configuration

In both of these cases, an error will be logged; but the message may appear to have been discarded. WebsphereMQ queue has removed the message from the queue because it is considered as _delivered_. The adapter has indeed consumed this message but cannot continue to process the message if there are translation errors. If this situation is possible (because you are not in control of the sending application, or testing has not been sufficient) you need to configure a [wmq-forwarding-native-consumer-error-handler][] which simply forwards the message that was consumed to another configured queue. The WebsphereMQ connection details are taken from the parent consumer, you can only configure a new queue to produce the error messages to. Also, the message options described previously will be inherited from the parent consumer, although you may override these if needed.

```xml
<consumer class="wmq-native-consumer">
  <error-handler class="wmq-forwarding-native-consumer-error-handler">
    <destination class="configured-produce-destination">
      <destination>The_Error_Queue</destination>
    </destination>
    <options>
      <queue-open-options>MQOO_INPUT_AS_Q_DEF,MQOO_OUTPUT,MQOO_BROWSE</queue-open-options>
      <queue-close-options>MQCO_NONE</queue-close-options>
      <message-options>MQPMO_NO_SYNCPOINT</message-options>
      <message-format>Text</message-format>
    </options>
  </error-handler>
  ... // Other configuration skipped.
</consumer>
```

The configuration above is a minimal configuration needed to forward a message that generates an error at the point when the adapter tries to translate the message from WebsphereMQ. We have overridden the message options from the consumer itself.


[JMS Guide]: cookbook-jms.html
[wmq-attached-connection]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/AttachedConnection.html
[wmq-detached-connection]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/DetachedConnection.html
[KeyValuePairSet]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/util/KeyValuePairSet.html
[NativeConnection]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/NativeConnection.html
[wmq-native-producer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/NativeProducer.html
[wmq-native-consumer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/NativeConsumer.html
[wmq-forwarding-native-consumer-error-handler]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/ForwardingNativeConsumerErrorHandler.html
[PollingConsumer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisPollingConsumer.html
[FieldMapper]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/mapping/FieldMapper.html
[wmq-metadata-field-mapper]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/mapping/MetadataFieldMapper.html
[charset-byte-translator]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/util/text/CharsetByteTranslator.html
[simple-byte-translator]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/util/text/SimpleByteTranslator.html
[base64-byte-translator]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/util/text/Base64ByteTranslator.html
[hex-string-byte-translator]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/util/text/HexStringByteTranslator.html
[wmq-message-id-mapper]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/mapping/MessageIdMapper.html
[wmq-configured-field]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/mapping/ConfiguredField.html
[wmq-xpath-field]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/mapping/XpathField.html
[wmq-uuid-field-mapper]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-webspheremq/3.8-SNAPSHOT/com/adaptris/core/wmq/mapping/UuidFieldMapper.html
