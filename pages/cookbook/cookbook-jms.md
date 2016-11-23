---
title: JMS Integration
keywords: interlok
tags: [cookbook, messaging]
sidebar: home_sidebar
permalink: cookbook-jms.html
summary: This document summarises various configurations and concepts for handling various types of JMS messaging platforms using Interlok. Interlok can be configured for the more popular flavours of JMS Provider. In most cases you will be required to add the vendor specific Interlok component to your Interlok installation.
---

Each of the sub components are vendor specific and are known to work in most standard configuration instances. Installation of a sub component is very straight forward, simply drop the java archive files into your Interlok "lib" directory. However, it is recommended that you replace any vendor specific java archive files in your Interlok installation with those shipped with your JMS specific vendor.  This ensures that you get the best performance and reliability with Interlok.

----

## Standard Messaging ##

The basic connection is [jms-connection][] which supports both Queues and Topics. The alternative is [failover-jms-connection][] which is a proxy for one or more [jms-connection][] instances. The rationale behind [failover-jms-connection][] is to transparently support failover for those JMS providers whose APIs don't support seamless failover to backup brokers. In most cases [failover-jms-connection][] is or marginal benefit but when you are faced with a particularly recalcitrant JMS provider that won't give you the failover that you need; it is definitely one to look at. Connections to the JMS Providers are handled by the provider specific [VendorImplementation][] instances. If one isn't available for your preferred messaging platform (we support [ActiveMQ][basic-active-mq-implementation], [SonicMQ][basic-sonic-mq-implementation], [WebsphereMQ][basic-mq-series-implementation], [OracleAQ][oracleaq-implementation], [Tibco EMS][basic-tibco-ems-implementation] and [HornetQ][basic-hornetq-implementation] as native JMS implementations) then it's possible to use a [JNDI implementation][standard-jndi-implementation] which simply retrieves the appropriate connection factory from JNDI.

The basic error handling mechanism in JMS is the `ExceptionListener` interface; if you specify the _ExceptionListener_ for a connection, this will be notified when the connection goes away at any point. So, generally, you'd want to have a [jms-connection-error-handler][] (which implements the _ExceptionListener_ interface) configured on the appropriate connection which will end up restarting the channel if and when the connection is terminated. Alternatively use an [active-jms-connection-error-handler][] which actively tries to send a message every 'n' milliseconds (5000 by default) onto a temporary destination. The message is marked as NON_PERSISTENT and has a TTL of 5 seconds so _shouldn't_ affect performance. If the send fails, then the broker is deemed to have died, and the component is restarted.

{% include tip.html content="In some cases you might have to use an [active-jms-connection-error-handler][], some JMS providers don't always seem to honour the _ExceptionListener_ contract." %}

There is one situation where you can't have a [jms-connection-error-handler][] configured on each and every connection; that is when you are physically connecting to the same broker for both ends of a channel. Some very interesting things used to happen if you did; in the end we couldn't reliably guarantee restarts of the affected channel so we put a check so that it caused an error upon initialisation. If this is the case then the exception _"com.adaptris.core.CoreException: This channel has been configured with 2 ErrorHandlers that are incompatible with each other"_ is reported.


### JMS Topics ###
You should use the generic [jms-connection][] and then the topic specific [jms-topic-producer][] and [jms-topic-consumer][]. Example configuration for all these classes is available in the docs/example-xml directory

### JMS Queues ###
You should use the generic [jms-connection][] and the queue specific [jms-queue-producer][] and [jms-queue-consumer][]. Example configuration for all these classes is available in the docs/example-xml directory.

### Can't Decide? ###

Since 3.0.4 we have had the capability to define a destination using RFC6167 as a syntax. The syntax is supported by the more generic [jms-producer][] and [jms-consumer][]; for instance `jms:queue:MyQueueName` will target a queue called _MyQueueName_, `jms:topic:MyTopicName` will target a topic called _MyTopicName_. RFC6167 also allows you to additional parameters such as _replyTo_, _priority_ and _timeToLive_ as part of the destination string; this are all supported, however, the ability to specify a destination hosted on a JNDI server is not supported (the 'jndi' variant section in the RFC).

----

## Polling Consumers ##

There are two alternative implementations for consuming JMS messages: [jms-topic-poller][], [jms-queue-poller][] and [jms-poller][]. The use case for these implementations is generally in response to a situation where existing JMS consumers operate sub-optimally in certain high network latency environments. The main reason for switching to a polling implementation is to force a reconnection to the broker each time the poll interval is triggered rather than relying on the JMS provider proactively maintaining the connection. This style of consumer can be used to mitigate firewall (automatic port closure on inactivity) issues, and also some types of network connectivity issues.

Sample configuration for these consumers can be found in the docs/example-xml directory. Please refer to Javadocs for full configuration details.

### Choosing a Poller Implementation ###

There are two standard implementations to choose from: fixed interval polling and cron style scheduling.

The [fixed-interval-poller][] implementation works as follows: the consumer polls and processes the first available message if one exists; it continues processing messages until none are available. Once no further messages are available for processing, the consumer sleeps for the configured fixed interval. For example: a consumer with a fixed-interval-poller with a configured poll interval of 10 seconds connects to the broker and processes 12 messages in 22 seconds. Once 12 messages have been processed and there are no further messages to process the poller waits for 10 seconds and is triggered again.

The [quartz-cron-poller][] implementation allows polling to be scheduled using cron-style expressions. It is multithreaded  and where message processing takes longer than the interval between two scheduled polls, the later poll attempt will not execute. For example: a consumer with a quartz-cron-poller is scheduled to poll every 10 seconds from on the minute. It connects to the broker on the minute and processes 12 messages in 22 seconds. The poll scheduled to execute at 10 seconds past cannot execute as the previous poll is still executing. Same thing happens at 20 seconds past. The poll attempt at 30 seconds past will execute as the original poll has finished.

Where message volume is high and / or fairly constant fixed-interval-poller is probably preferred. As the examples above show, in a high volume environment poll intervals can quickly become arbitrary with quartz-cron-poller.


### Error Handling ###

All JMS Polling consumers will create a connection to the JMS broker each time they receive messages and disconnect when there are no more messages to process. They therefore have six stages of operation. Stages 3 to 5 are repeated until there are no further messages to process.

| Stage         | Activity  |
| ------------- |-------------|
| 1 Waiting to connect | No JMS Connection exists, do nothing. |
| 2 Connecting | JMS Connection, Session and MessageConsumer objects are created. (It is a simplification to lump these activities together) |
| 3 Receiving message | Call to receive() on MessageConsumer |
| 4 Processing message | Message is processed by Workflow. |
| 5 Acknowledging message | Call to acknowledge() on Message. |
| 6 Disconnecting | The JMS Connection is closed. |

Two main errors may occur in each of the above stages: The network connection to the broker may be lost or The broker may stop running. Both are functionally equivalent for the adapter and the behaviour in each stage for each error type is described below.

Our standard reconnection behaviour means the following: the consumer is not connected to broker. The configured poller will try to connect to the broker based on its configured schedule until the configured connection-attempts limit is reached. If connection-attempts is set to -1, connection attempts will continue indefinitely. In the event that the maximum number of connections attempts is reached, then the poll fails, and will wait for the next poll to fire before making a new attempt. There should be no need to configure a specific `connection-error-handler`.

#### Network connection lost while waiting to connect ####

In this situation; nothing is apparent immediately until a poll event is fired; an exception is likely to be raised and standard reconnection behaviour will apply.

####  Network connection lost while connecting ####

Connecting to the broker (including creating the Session and MessageConsumer) takes around 5 to 10 seconds for a remote broker accessed over the internet. If the network connection is lost while connecting, behaviour looks different in terms of logging depending on the polling implementation used.
If a [fixed-interval-poller][] is configured, the adapter appears to just hang. This occurs because FixedIntervalPoller has a single thread which is blocked trying to connect to the broker. After some time, depending on configuration (for instance if you have not specified a SocketTimeout, then it will wait forever attempting to connect). Once any socket timeouts have been exceeded, then an exception will be thrown and standard reconnection behaviour kicks in.

The same fundamental things happen if [quartz-cron-poller][] is configured, however because it is multi-threaded, future polling attempts will still occur as scheduled but will log 'unable to get lock in run', indicating that other threads are still active. Once any socket timeouts have been exceeded then an exception will be thrown and standard reconnection behaviour kicsk in.

#### Network connection lost while processing a message ####

Workflow processing time depends on configured services and control is not passed back to the consumer implementation until the workflow has produced the message to its destination. After control is passed back to the consumer, it acknowledges the JMS message. While an adapter is processing many messages with minimal configured services, around 90% of processing time is spent in the call to acknowledge and it is thus normally hit when randomly dropping the network connection. Two different types of behaviour have been seen when the connection is dropped during acknowledge, relating to the exact timing of the connection loss in acknowledge. Behaviour is very similar to that described in above: the consume thread will apparently hang, then after some time an Exception will be logged and the poller will try to reconnect in the normal way. When the network connection returns, duplicate message(s) may be redelivered depending on the Quality of Service for the JMS Environment.

----

## JMS Specific Workflows ##

### JMS ReplyTo Workflow ###

[jms-reply-to-workflow][] is an extension to `standard-workflow` and works simply by overriding any configured destination, and using the `JMSReplyTo` destination set on the JMS message that was originally consumed. This allows the messaging platform to set a JMS reply to destination on a message it is processing, and then send it to a [jms-reply-to-workflow][] for further processing. The requesting entity can choose to wait synchronously for a reply or to handle the reply asynchronously as appropriate.

Note that this workflow requires both consumer and producer to be in the same JMS messaging domain and will not initialise if this is not the case. It also requires the JMSReplyTo Destination to be in the same domain as the configured producer.

{% include tip.html content="Rather than using a JmsReplyToWorkflow it is generally preferable to use a [jms-reply-to-destination][] as the destination for a JMS producer. This allows the producer to be included at any point of a workflow (or even as part of error-handling). This allows more flexibility in workflow design." %}

### JMS Transacted Workflow ###

[jms-transacted-workflow][] is an extension to `standard-workflow` and uses a transacted JMS Session. In the event of any exceptions being thrown by the services/producer in the workflow then the transaction is rolled back. A configurable timeout is available to stop immediate re-processing of messages as most JMS Providers will make the same message available again due to the rollback.

----

## JMS Message Translation ##

Interlok allows a number of ways to convert JMS Messages into the internal representation and vice versa.

| Translator Type         | Description  |
| ------------- |-------------|
| [text-message-translator][] | This is the default translator for all producers, if no translator is specified. It translates to and from javax.jms.TextMessage and assumes default platform encoding.|
| [bytes-message-translator][] | This translates to and from javax.jms.BytesMessage. |
| [object-message-translator][] | This translates to and from javax.jms.ObjectMessage. The internal message format will be a byte array representation of the serialized object. |
| [map-message-translator][] | This translates to and from javax.jms.MapMessage. The internal representation of the AdaptrisMessage is stored against a configured key in the MapMessage. AdaptrisMessage metadata may be sent as standard JMS Properties or as part of the MapMessage itself. |
| [auto-convert-message-translator][] | This is the default translator for all consumers if no translator is specified. This implementation silently converts the standard javax.jms.Message sub-types into the required AdaptrisMessage. When converting from an AdaptrisMessage it can be configured to convert to any one of the standard sub-types according to configuration |
| [basic-javax-jms-message-translator][] | This is an implementation of last resort used by `auto-convert-message-translator`. It will simply move metadata and headers, and do nothing with the payload. |

----

## JMS Fields ##

### JMSCorrelationID ###

The JMSCorrelationID header field is used for linking one message with another. It typically links a reply message with its requesting message. This can be preserved across Interlok workflows by using an implementation of [CorrelationIdSource][] such as [metadata-correlation-id-source][].

### JMSReplyTo ###

If you use [jms-reply-to-destination][] as the destination, then any _JMSReplyTo_ specified by the message will be used. This type of destination only works if the producer is in the same workflow as the JMS consumer as the javax.jms.Destination is stored in object metadata which does not lend itself to being transported across workflows. If you have `move-jms-headers` set to be true, then the string representation of the temporary destination will be stored as part standard metadata under the key _JMSReplyTo_; some JMS providers will allow you to use this as the destination, so in certain situations you can simply use a metadata-destination instead. Alternatively, if the workflow type is a [jms-reply-to-workflow][] then is handled for you automatically.

If the adapter is initiating a request and then waiting for a reply, then the _JMSReplyTo_ header has a temporary destination associated with it. The expectation being that whatever is responding to the request will just use the JMSReplyTo header when replying to the request. Sometimes it doesn't work, perhaps the back-end application doesn't handle temporary destinations very well, or they don't translate well into whatever underlying message system the JMS layer sits on tops of (back-end apps that use IBM MQSeries seem quite prone to this). In situations like this we can specify a static reply to destination that already exists. Our JMS Producers can be told to _not generate a temporary destination_ and to use a fixed _JMSReplyTo_ destination by using the metadata key `JMSAsyncStaticReplyTo`; this will cause it to set whatever value stored against the metadata key as the _JMSReplyTo header_.

```xml
<add-metadata-service>
  <metadata-element>
    <key>JMSAsyncStaticReplyTo</key>
    <value>MyReplyToDestination</value>
  </metadata-element>
</add-metadata-service>
<standalone-requestor>
  <connection class="jms-connection">
     ... boring config skipped
  </connection>
  <producer class="jms-queue-producer">
     ... boring config skipped
    <destination class="configured-produce-destination">
      <destination>SampleQ1</destination>
    </destination>
  </producer>
</standalone-requestor>
```

- We specify the _JMSReplyTo_ as `MyReplyToDestination`
- Because it is a `standalone-requestor` instance; we wait for replies coming back on `MyReplyToDestination`

{% include tip.html content="`JMSAsyncStaticReplyTo` is processed whenever a message is produced to JMS, so it can be applied even if the workflow not trying to do a synchronous request reply (you might be making a request in one workflow, and having a different workflow handling the reply)." %}


### JMS Priority, Delivery Mode, Expiration ###

It is usually the case that the JMS Producer is configured with a specific Priority, Delivery mode and Expiration; however, in some cases you may wish to control this on a message by message basis. In order to do this you must set the field `per-message-properties=true` on the JMS Producer. Once this has been done, then the following metadata keys will override the corresponding configured value.

| Metadata Key        | Description  |
| ------------- |-------------|
| JMSPriority | This overrides the configured priority of the message; use an integer value generally between 1-9|
| JMSDeliveryMode | This overrides the configured delivery mode; it could be `PERSISTENT`, `NON_PERSISTENT` or an integer value supported by the JMS Provider |
| JMSExpiration | This overrides the configured expiration time. If this metadata key is used, it should be either a long value that specifies the time in milliseconds at which the message expires. or a date in the format `yyyy-MM-dd'T'HH:mm:ssZ`. This will be used to calculate the appropriate time to live. |

<br/>

```xml
<add-metadata-service>
  <metadata-element>
    <key>JMSPriority</key>
    <value>9</value>
  </metadata-element>
  <metadata-element>
    <key>JMSDeliveryMode</key>
    <value>NON_PERSISTENT</value>
  </metadata-element>
</add-metadata-service>
<add-timestamp-metadata-service>
  <metadata-key>JMSExpiration</metadata-key>
  <date-format>yyyy-MM-dd'T'HH:mm:ssZ</date-format>
  <!-- Message expires in one hour -->
  <offset>+PT1H</offset>
</add-timestamp-metadata-service>
<standalone-producer>
  <connection class="jms-connection">
     ... boring config skipped
  </connection>
  <producer class="jms-queue-producer">
    <destination class="configured-produce-destination">
      <destination>SampleQ1</destination>
    </destination>
    <priority>4</priority>
    <delivery-mode>PERSISTENT</delivery-mode>
    <time-to-live>0</time-to-live>
    <per-message-properties>true</per-message-properties>
  </producer>
</standalone-producer>
```

- Delivery mode has been changed from `PERSISTENT` to `NON_PERSISTENT`
- JMS Priority has bee changed from 4 to 9
- The message expires 1 hour in the future.

----

## JMS using JNDI ##


All providers of JMS are required to support JNDI; which allows distributed applications to lookup services in an abstract, resource independent way. This is the standard way in which you would connector to a JMS provider without having a specific implementation. Managing your resources can be much easier if your client applications simply make a request to a JNDI server and simply ask for a resource.  It means that should you modify the location or other detail of a resource, in our case a JMS implementation, you only need to update your JNDI store and not then re-configure all client applications. If you have a deployment sequence where environments move from testing to production, you can use the same JNDI name in each environment and hide the actual JMS details being used. Applications don't have to change as they migrate between environments.
When using the JNDI vendor implementation it is important to note that all of the connection configuration other than username and password in the [jms-connection][] class will be ignored. Connection information will be provided by the connection factory found in the JNDI Context.

Interlok provides 2 JNDI implementations: [standard-jndi-implementation][] and [cached-destination-jndi-implementation][].

### Standard JNDI Implementation ###

To use any JNDI store you will need to provide standard JNDI parameters as of the configuration; the exact settings will be largely dependent on your JMS providers JNDI implementation. The example shown here is simply for reference for some standard settings.

```xml
<jndi-params>
 <key-value-pair>
  <key>java.naming.factory.initial</key>
  <value>com.sonicsw.jndi.mfcontext.MFContextFactory</value>
 </key-value-pair>
 <key-value-pair>
  <key>java.naming.provider.url</key>
  <value>tcp://localhost:2506</value>
 </key-value-pair>
 <key-value-pair>
  <key>java.naming.security.principal</key>
  <value>Administrator</value>
 </key-value-pair>
 <key-value-pair>
  <key>java.naming.security.credentials</key>
  <value>Administrator</value>
 </key-value-pair>
</jndi-params>
```


The following table shows some of the more common JNDI parameters you may need to set.

| Element | Description |
| ------------- |-------------|
|java.naming.factory.initial | This will be set to the fully qualified java class name of your chosen JMS vendors context factory.
|java.naming.provider.url | The value set here is the network location of the JNDI store.
|java.naming.security.credentials | Specifies the credentials of the user/program doing the authentication.
|java.naming.security.principal | Specifies the name of the user/program that is doing the authentication.


In addition to standard JNDI parameters there are some additional elements supported:

| Element | Description |
| ------------- |-------------|
|jndi-name | This is the name that will be looked up by Interlok when attempting to locate a connection factory. The resulting object will be cast into a TopicConnectionFactory or QueueConnectionFactory as appropriate.
|jndi-params | The jndi-params contains key value pairs which will govern how to connect to JNDI context (check javax.naming.Context for possible keys and values)
| use-jndi-for-queues | Setting this to be true forces the lookup of the queue destination to be done via JNDI; if false, the queue is created directly from the JMS session.
| use-jndi-for-topics | Setting this to be true forces the lookup of the topic destination to be done via JNDI; if false, the topic is created directly from the JMS Session
| enable-encoded-passwords | If set to true, then the entry within the jndi-params matching Context#SECURITY_CREDENTIALS will be parsed decoded using an available Password implementation. If set to false, the password is passed through to the context as is.
| extra-factory-configuration | Concrete implementations of [ExtraFactoryConfiguration][] can be used to apply arbitrary configuration to the ConnectionFactory after it is retrieved from the JNDI Store. The default [no-op-jndi-factory-configuration][] does nothing.

<br/>

### Cached Destination JNDI Implementation ###

The cached destination JNDI implementation extends the functionality of the standard implementation above.  The details described above are also applicable to the cached destination JNDI implementation. In addition to the above, this implementation, as the name suggests, will allow us to cache destinations. Caching destinations has the added benefit of not needing to perform a JNDI lookup when attempting to access a JMS destination. This is very useful if one of your concerns are the sheer number of requests into your JNDI server. If a queue or topic request is made, this implementation will check the cache of previously used objects.  If we have the queue or topic cached, then this is returned, if not then a JNDI lookup is performed, the resulting queue or topic is then cached before being returned. The object cache is a LRU cache, if you breach the maximum number of entries in the cache, then the oldest item will be removed before the newest item is then added. To change the number of items in the cache then set `max-destination-cache-size`.

----

## SonicMQ ##

Once you have acquired the Interlok SonicMQ sub component you can simply copy the java archive file named `adp-jms-sonicmq.jar` from the sub component directory to your `./lib/` directory in the root of your Interlok installation. Note, that all configuration examples can be found in the `./docs/example-xml/optional/jms-sonicmq` directory.
Unlike most Interlok sub components the base Interlok installation contains all of the required 3rd party java archive files to instantly allow access to SonicMQ 8.6 for very basic client usage.  There may be additional java archive files required depending on your intended SonicMQ usage; for example if you wish to use SonicMQ as a JNDI store then you will also require the `mfcontext.jar` from your SonicMQ installation. Any additional java archive files you do require from your SonicMQ installation will need to be copied into the `./lib/` directory at the root of your Interlok installation.

### Vendor Implementations ###

The associated vendor implementation class that should be used is [basic-sonic-mq-implementation][] or, if you want to control the connection factory properties more explicitly, [advanced-sonic-mq-implementation][]. You can always use the more generic JNDI implementation to connect to SonicMQ.


### Translators ###

Custom Translators allows support for the SonicMQ extensions to the standard javax.jmx.Message interface; the following translators are specific to SonicMQ.


| Translator Type         | Description  |
| ------------- |-------------|
| [sonic-multipart-message-translator][] | This is a SonicMQ specific translator that handles progress.message.jclient.MultipartMessage objects. Converting from the internal representation always results in a MultipartMessage. TextMessage, BytesMessage, ObjectMessage and MultipartMessage objects will be transparently converted to the internal representation if this translator type is used.|
| [sonic-xml-message-translator][] | This is a SonicMQ specific translator that handles progress.message.jclient.XMLMessage objects. Converting from the internal representation always results in an XMLMessage. TextMessage, BytesMessage, ObjectMessage objects will be transparently converted to the internal representation if this translator type is used.|

### SonicMQ Continuous availability ###

Known as Sonic MQ CAA, SonicMQ natively supports failover. If you have CAA enabled within your MQ environment, then you can enable automatic failover by using the connection-urls element within [BasicSonicMQImplementation][]. This is a comma delimited string of additional connection strings that will be appended the main connection URL when creating the appropriate JMS connection factory.

### SonicMQ + SSL ###

It is beyond the scope of this document to discuss what needs to be done in order to enable SSL within a SonicMQ broker environment. However, in addition to the standard SonicMQ jars you will need some additional jars from your SonicMQ installation. As well as the additional jars, you also need to set some additional Sonic specific system properties before starting the adapter.
The system properties that will need to be defined are: _SSL_CA_CERTIFICATES_DIR_, _SSL_CERTIFICATE_CHAIN_, _SSL_PRIVATE_KEY_, _SSL_PRIVATE_KEY_PASSWORD_ and _SSL_CERTIFICATE_CHAIN_FORM_. A full description of the steps that are required to implement SSL within SonicMQ can be found within the SonicMQ Deployment manual (Chapter 18: SSL and HTTPS Tunneling Protocols). Before attempting to use your own certificates / certificate authority; we recommend that you try and configure SonicMQ using the standard certificates that are shipped with SonicMQ.

### Large Message Support ###

Interlok supports SonicMQ _Recoverable File Channels for Large Messages_. This allows large messages (many megabytes) to be produced and consumed using Interlok and SonicMQ.
Chapter 11 of SonicMQ Application Programming Guide provides a full description of this SonicMQ functionality. The vendor implementation associated with the connection must be [advanced-sonic-mq-implementation][]. [sonic-large-message-producer][] treats the payload of the AdaptrisMessage it is processing as the large message. It first writes the message to the local file system then sends a JMS message with a Channel attached to initiate the large file transfer. The transfer will either be accepted by the receiver or time out. If it times out, the configured [ProduceExceptionHandler][] will be triggered. If the transfer is accepted, SonicMQ takes over delivery of the message. This approach is different from most of the other producers and consumers in the sense that while the workflow thread set up message delivery, delivery itself is handled in separate SonicMQ threads.  After sending the message which initiates file transfer, [sonic-large-message-producer][] blocks waiting for SonicMQ to deliver the message. This makes the behaviour fit the standard message delivery pattern but has some implications; the producer ignores Sonic LMS support for continuing aborted transfers. Either the large message is successfully produced or it is handled by the configured [ProduceExceptionHandler][] and may be manually (or automatically) retried. Another consequence of this approach is that the JMS message sent to inform the receiver of the large file transfer has a finite expiry. This expiry should be the same as the `RecoverableFileChannel` timeout. This means that if a producer sends such a message and the consumer is not running, the message informing the receiver that a large file is available for transfer will expire at approximately the same time that the producer stops making the file available.

[sonic-large-message-consumer][] acknowledges the original JMS message to initiate transfer, and then waits for SonicMQ to complete the large message transfer. Once this happens, the message is read from the local file system and set as the payload of a new AdaptrisMessage.

This functionality has been tested with SonicMQ versions 7.6 and 8.5. It is essential that producer and consumer client libraries and broker are all the same version for large message functionality to work.

----

## WebsphereMQ JMS ##

Once you have acquired the Interlok MQSeries sub component you can simply copy the java archive file named `adp-jms-webspheremq.jar` from the sub component directory to your `./lib/` directory in the root of your Interlok installation. Note that all configuration examples can be found in the `./docs/example-xml/optional/webspheremq/` directory.

Interlok does not come supplied with any of the required MQSeries java archive files.  You will need to copy the required java archives for client access from your MQSeries installation into the `./lib/` directory at the root of your Interlok installation. At the very least the required java archive files from your MQSeries installation will be; com.ibm.mq*.jar and dhbcore.jar.


### Vendor Implementations ###

The associated vendor implementation class that should be used is [basic-mq-series-implementation][] or, if you want to control the connection factory properties more explicitly, [advanced-mq-series-implementation][]. As well as setting the JMS vendor implementation with the above to options you can also use the native consumer/producer, detailed separately. You can always use the more generic JNDI implementation to connect to IBM MQSeries.

The standard configuration table is as follows :

|Element|Description|
|-------------|-------------|
|ccsid | Character set of the destination.  See the MQSeries documentation for more info.
|transport-type|The transport type is used to determine the exact mechanism used to connect to MQSeries. By default this is set to _client_ mode.
|queue-manager|A connection is established to this WebSphere MQ resource to send or receive messages.
|channel|The WebSphere MQ server connection channel name used when connecting to WebSphere MQ.
|temporary-model|Sets the name of a WebSphere MQ model queue used when creating JMS temporary destinations.
|broker-host|The name of the host running WebSphere MQ.
|broker-port|The connection port of the running WebSphereMQ instance.


In addition to the features exposed by the [basic-mq-series-implementation][], the [advanced-mq-series-implementation][] exposes far more options for the session and the connection factory. For a full list of available properties, see the javadoc for the session properties and the connection factory properties.

----

## OracleAQ JMS ##

Once you have acquired the Interlok Oracle AQ sub component you can simply copy the java archive file named `adp-jms-oracleaq.jar` from the sub component directory to your `./lib/` directory in the root of your Interlok installation. Note that all configuration examples can be found in the `./docs/example-xml/jms-oracleaq/` directory. Depending on your Oracle installation specifics, you will need to copy the aqapi.jar and the jdbc14.jar from your Oracle installation into the Interlok `./lib` directory so that the required classes are available to Interlok during runtime.

### Vendor Implementations ###

The associated vendor implementation class that should be used is [oracleaq-implementation][]. You will need to Ensure that the broker URL is the full JDBC connection string and that the user associated with the connection has the correct access rights.

### Recipient Lists ###

A feature of using Topics is that you can restrict the delivery of the message to a subset of listeners on the topic. This is achieved within Oracle AQ though the use of recipient lists. As this feature deviates from the standard JMS API; you have to use a different producer [oracleaq-topic-producer][] which understands the concept of AQjmsAgent. The provided implementation allows you to specify a [RecipientList][] implementation which then provides the AQjmsAgent instance which can be used in `AQjmsTopicPublisher#publish()`. The default implementation of [RecipientList][oracleaq-simple-recipient-list] allows you to configure multiple nested ConfiguredRecipient and MetadataRecipient instances. If this type of behaviour is not suitable for your purposes, then you will need to build a custom class that implements the RecipientList interface. However, in most cases, provided you can extract the required information as metadata, the standard implementation should be sufficient.


[CorrelationIdSource]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/CorrelationIdSource.html
[jms-reply-to-workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsReplyToWorkflow.html
[ExtraFactoryConfiguration]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/jndi/ExtraFactoryConfiguration.html
[no-op-jndi-factory-configuration]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/jndi/NoOpFactoryConfiguration.html
[basic-sonic-mq-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-sonicmq/com/adaptris/core/jms/sonic/BasicSonicMqImplementation.html
[advanced-sonic-mq-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-sonicmq/com/adaptris/core/jms/sonic/AdvancedSonicMqImplementation.html
[text-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/TextMessageTranslator.html
[bytes-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/BytesMessageTranslator.html
[object-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/ObjectMessageTranslator.html
[map-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/MapMessageTranslator.html
[auto-convert-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/AutoConvertMessageTranslator.html
[basic-javax-jms-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/BasicJavaxJmsMessageTranslator.html
[sonic-multipart-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-sonicmq/com/adaptris/core/jms/sonic/MultipartMessageTranslator.html
[sonic-xml-message-translator]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-sonicmq/com/adaptris/core/jms/sonic/XmlMessageTranslator.html
[sonic-large-message-producer]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-sonicmq/com/adaptris/core/jms/sonic/LargeMessageProducer.html
[ProduceExceptionHandler]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ProduceExceptionHandler.html
[sonic-large-message-consumer]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-sonicmq/com/adaptris/core/jms/sonic/LargeMessageConsumer.html
[advanced-mq-series-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/optional/webspheremq/com/adaptris/core/jms/wmq/AdvancedMqSeriesImplementation.html
[basic-mq-series-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/optional/webspheremq/com/adaptris/core/jms/wmq/BasicMqSeriesImplementation.html
[oracleaq-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-oracleaq/com/adaptris/core/jms/oracle/OracleAqImplementation.html
[oracleaq-topic-producer]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-oracleaq/com/adaptris/core/jms/oracle/OracleAqPasProducer.html
[RecipientList]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-oracleaq/com/adaptris/core/jms/oracle/RecipientList.html
[oracleaq-simple-recipient-list]: http://development.adaptris.net/javadocs/v3-snapshot/optional/jms-oracleaq/com/adaptris/core/jms/oracle/SimpleRecipientList.html
[standard-jndi-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/jndi/StandardJndiImplementation.html
[cached-destination-jndi-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/jndi/CachedDestinationJndiImplementation.html
[jms-connection]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsConnection.html
[jms-topic-producer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/PasProducer.html
[jms-topic-consumer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/PasConsumer.html
[jms-queue-producer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/PtpProducer.html
[jms-queue-consumer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/PtpConsumer.html
[quartz-cron-poller]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/QuartzCronPoller.html
[fixed-interval-poller]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/FixedIntervalPoller.html
[jms-reply-to-workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsReplyToWorkflow.html
[jms-transacted-workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsTransactedWorkflow.html
[jms-reply-to-destination]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsReplyToDestination.html
[VendorImplementation]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/VendorImplementation.html
[failover-jms-connection]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/FailoverJmsConnection.html
[basic-active-mq-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/activemq/BasicActiveMqImplementation.html
[basic-tibco-ems-implementation]: http://development.adaptris.net/javadocs/v3-snapshot/optional/tibco/com/adaptris/core/jms/tibco/BasicTibcoEmsImplementation.html
[metadata-correlation-id-source]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/MetadataCorrelationIdSource.html
[jms-connection-error-handler]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsConnectionErrorHandler.html
[active-jms-connection-error-handler]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/ActiveJmsConnectionErrorHandler.html
[jms-topic-poller]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/PasPollingConsumer.html
[jms-queue-poller]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/PtpPollingConsumer.html
[jms-producer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsConsumer.html
[jms-consumer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsProducer.html
[jms-poller]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsPollingConsumer.html

{% include links.html %}