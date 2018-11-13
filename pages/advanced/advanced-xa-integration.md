---
title: XA transaction management
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-xa-integration.html
summary: This page describes how to configure XA transaction management for JMS bridging.

---

## XA Transaction Management ##

__Since 3.4.0__

The Interlok-XA component is built against the ASL version of Atomikos (3.8.0).

XA stands for "eXtended Architecture" and is an X/Open group standard for executing a "global transaction" that accesses, in our case, one or more JMS endpoints.

XA specifies how a transaction manager will roll up the transactions against the different data-stores into an "atomic" transaction and execute this with the two-phase commit (2PC) protocol for the transaction.

During runtime there are 5 possible steps that a transaction manager will add to normal message processing, in order these are;

|Step| Description| Optional|
|----|----|----
|Begin transaction| Enables message transaction for messages processed| No|
|Enlisting a resource| Every transaction requires the participants to be known, enlisting performs that function.| No|
|Delisting a resource| Once a resource is finished with in the current transaction, it needs to be de-listed.| No|
|Commit| Successfully completes a transaction.| Yes, only commits on success|
|Rollback| Completes a transaction rolling back all messages after a failure.| Yes, only on failure|

## Installation ##

For each Interlok instance you wish to activate XA transactions, you will need only one additional component; "interlok-xa".

Simply copy the java archive files from the "/optional/interlok-xa" directory into your "lib" directory at the root of your installation.

### Configuring XA transaction management ###

There are several components ranging from the required to the optional.  Each will be discussed below.

#### The properties file ####

A new "transactions.properties" file should be created and added to the classpath of your Interlok instance.

If you're using the standard Interlok start-up mechanisms, then dropping this file into the "config" directory at the root of your Interlok installation will suffice.

The following properties are required, however the values may change depending on configuration discussed later;

|Property| Description| Value|
|----|----|----
|com.atomikos.icatch.automatic_resource_registration| Allows us to dynamically register JMS resources. |true |
|com.atomikos.icatch.max_timeout| Specifies the maximum timeout (in milliseconds) that can be allowed for transactions. | Set to a value of 5 minutes or more.|
|com.atomikos.icatch.default_jta_timeout| Specifies the maximum timeout (in milliseconds) for JTA transactions. | Set to a value of 5 minutes or more.|
|com.atomikos.icatch.service| The transaction manager implementation | com.atomikos.icatch.standalone.UserTransactionServiceFactory|

#### Interlok component configuration ####

Currently the only XA transaction participants supported by Interlok are JMS endpoints, for both consumers and producers.

The most basic XA pattern would simply consume from a JMS endpoint; should your service list fail, we rollback the transaction and any messages contained in the transaction, but should your service list succeed we commit the transaction removing all consumed messages from the consume source.

The next step would be to move messages from one JMS endpoint to another; both endpoints participating in the transaction.  Should one fail, we rollback.

The Interlok components required are the transaction manager, the consumer and if required a producer.

#### The transaction manager ####

Per instance of Interlok, only one transaction manager instance is permitted, therefore you configure the transaction manager in the shared components;

```xml

  <shared-components>
    <transaction-manager class="xa-cached-jms-transaction-manager">
      <unique-id>xa-transaction-manager</unique-id>
    </transaction-manager>
  </shared-components>

```

The _unique-id_, much the same as _shared-connections_ is used as the internal JNDI name which pairs up with the _shared-transaction-managers_, spoken about later.

There are currently 2 transaction manager implementations;

- __xa-jms-transaction-manager__

The base implementation, which will enlist and delist both the consumer and producer for each message.  A good solution for low activity workflows, where message batching (discussed later) is not required.

When using this transaction manager, you must set the transactions.properties property _com.atomikos.icatch.automatic_resource_registration_ to __true__.

- __xa-cached-jms-transaction-manager__

Built upon the base implementation, but will only enlist/delist resources once for each unique resource per transaction.  Use this transaction manager for higher throughput workflows where message batching is required.

When using this transaction manager, you must set the transactions.properties property _com.atomikos.icatch.automatic_resource_registration_ to __true__.

#### The consumer/produce connections ####

Should you have acesss to a JNDI store for your chosen broker then the connection can be configured almost exactly as any other Interlok JMS JNDI connection;

```xml

  <xa-jms-connection>
    <vendor-implementation class="xa-jndi-implementation">
      <jndi-params>
        <key-value-pair>
          <key>java.naming.factory.initial</key>
          <value>...</value>
        </key-value-pair>
        <key-value-pair>
          <key>java.naming.provider.url</key>
          <value>...</value>
        </key-value-pair>
      </jndi-params>
    </vendor-implementation>
  </xa-jms-connection>

```

__ As of Interlok 3.8.2__ 

You may also configure specific vendor implementations such as for Solace, WebsphereMQ and Tibco EMS.  Examples of each below;

Solace.  We have both the basic and advanced implementations, the basic one show below.:

```xml
  <xa-jms-connection>
    <unique-id>xa-solace-connection</unique-id>
    <user-name>admin</user-name>
    <password>admin</password>
    <vendor-implementation class="xa-basic-solace-implementation">
      <broker-url>hostname:55555</broker-url>
      <message-vpn>default</message-vpn>
    </vendor-implementation>
  </xa-jms-connection>
```

Websphere MQ.  We have both the basic and advanced implementations, the advanced one show below.:

```xml
  <xa-jms-connection>
    <unique-id>xa-wmq-connection</unique-id>
    <vendor-implementation class="xa-advanced-mq-series-implementation">
	  <connection-factory-properties>
	    <key-value-pair>
		  <key>Channel</key>
		  <value>ServerConnectionChan</value>
		</key-value-pair>
		<key-value-pair>
		  <key>Port</key>
		  <value>1414</value>
		</key-value-pair>
		<key-value-pair>
		  <key>TransportType</key>
		  <value>MQJMS_TP_BINDINGS_MQ</value>
		</key-value-pair>
		<key-value-pair>
		  <key>HostName</key>
		  <value>localhost</value>
		</key-value-pair>
		<key-value-pair>
		  <key>QueueManager</key>
		  <value>MyQM</value>
		</key-value-pair>
	  </connection-factory-properties>
    </vendor-implementation>
  </xa-jms-connection>
```

Tibco EMS:

```xml
  <xa-jms-connection>
    <unique-id>xa-tibco-connection-1</unique-id>
    <vendor-implementation class="xa-basic-tibco-ems-implementation">
      <broker-url>tcp://localhost:7222</broker-url>
    </vendor-implementation>
  </xa-jms-connection>
```

#### Connection error handling ####

Inside your connection configuration you may use either the standard _xa-jms-connection-error-handler_ which registers itself with the connection and relies on the JMS onException() method to trigger component restarts, or
you can use the _xa-active-jms-connection-error-handler_ which will peridically use the connection to attempt a message send to a temporary topic.  If the send fails the connection is deemed to have been lost.

If you use the active error handler (which is the suggested error handler in almost all cases) there is some additional configuration;

```xml

  <connection-error-handler class="xa-active-jms-connection-error-handler">
    <additional-logging>true</additional-logging>
    <xa-resource-name>testResource</xa-resource-name>
    <transaction-manager class="shared-transaction-manager">
      <lookup-name>xa-transaction-manager</lookup-name>
    </transaction-manager>
  </connection-error-handler>

```

Should you set the _additional-logging_ to true, debug messages will appear in the log file upon every attempt to verify the connection.

The _xa-resource-name_ is an Interlok wide unique name that identifies this connection error handler to the transaction manager.  Any unique string is fine.

Finally, because the active error handler uses the XA connection, we need to know about the transaction manager, which can be referenced with the _shared-transaction-manager_.

#### The consumer ####

The XA compliant consumer is built upon the standard jms-consumer, therefore all configuration is inherited from the standard jms consumer with the addition of two items; the transaction manager and the resource name.

```xml

  <consumer class="xa-jms-consumer">
    <unique-id>JMS-Consumer</unique-id>
    <destination class="configured-consume-destination">
      <destination>jms:queue:myQueue</destination>
    </destination>
    <message-translator class="text-message-translator">
      <move-metadata>false</move-metadata>
      <move-jms-headers>false</move-jms-headers>
    </message-translator>
    <correlation-id-source class="null-correlation-id-source"/>
    <transaction-manager class="shared-transaction-manager">
      <lookup-name>xa-transaction-manager</lookup-name>
    </transaction-manager>
    <xa-resource-name>xa-consumer-resource</xa-resource-name>
  </consumer>

```

The transaction manager is looked up from the shared components and the _xa-resource-name_ is an Interlok instance wide unique chosen name for this particular consumer that enables the transaction manager to manage this instance of the consumer.

Should messages fail and be rolled back, we can configure a time period through the _xa-exception-handler_ that Interlok will wait before attempting to continue consuming;

```xml

  <consumer class="xa-jms-consumer">
    ...
    <xa-exception-handler class="xa-wait-exception-handler">
      <wait-period>
        <unit>SECONDS</unit>
        <interval>30</interval>
      </wait-period>
    </xa-exception-handler>
    ...
  </consumer>

```

The default wait period is 30 seconds.

Finally, you can also choose to recreate the session and consumer on any error.  Once the above error-handler has been executed and if you set this option to true, we will close the current consumer and session recreating them both.

This option can be useful on some rare issues with the JMS vendor specific client libraries.  Such as overloading the message performance capability of some vendors, seems to close the client session.

The default for this option is false, but you can override like this;

```xml

  <consumer class="xa-jms-consumer">
    ...
    <recreate-consumer-on-error>true</recreate-consumer-on-error>
    ...
  </consumer>

```

#### The producer ####

The XA compliant producer is also built upon the standard _jms-producer_, therefore inherits all of it's properties.  But as with the XA compliant consumer, we must configure the transaction manager and assign a unique resource name.
We also must configure the session-factory, all shown below.

```xml

  <producer class="xa-jms-producer">
    <destination class="configured-produce-destination">
      <destination>jms:queue:myQueue</destination>
    </destination>
    <message-translator class="text-message-translator">
      <move-metadata>false</move-metadata>
      <move-jms-headers>false</move-jms-headers>
    </message-translator>
    <correlation-id-source class="null-correlation-id-source"/>
    <delivery-mode>PERSISTENT</delivery-mode>
    <priority>4</priority>
    <session-factory class="jms-default-producer-xa-session"/>
    <xa-resource-name>wmq-xa-producer-resource</xa-resource-name>
    <transaction-manager class="shared-transaction-manager">
      <lookup-name>xa-transaction-manager</lookup-name>
    </transaction-manager>
  </producer>

```

## Performance considerations ##

Transactions can add time to your message processing, consider the following options when you require workflows with high throughput.

### Events ###

In your workflow set the _send-events_ to false;

```xml

  <workflow-list>
    <standard-workflow>
      <send-events>false</send-events>
      ...
    </standard-workflow>
  </workflow-list>

```

### JMS headers / Interlok metadata ###

If you don't need to copy consumed JMS headers to the produced messages, then consider setting this functionality to false in both your consumer and producer;

```xml

  <consumer class="xa-jms-consumer">
    ...
    <message-translator class="text-message-translator">
      <move-metadata>false</move-metadata>
      <move-jms-headers>false</move-jms-headers>
    </message-translator>
  </consumer>

  <producer class="xa-jms-producer">
    ...
    <message-translator class="text-message-translator">
      <move-metadata>false</move-metadata>
      <move-jms-headers>false</move-jms-headers>
    </message-translator>
  </producer>

```

### Per-message-properties ###

If you configure the JMS _delivery-mode_, _time-to-live_ and the _priority_ in your producer and require the same values for every message produced turn off per-message-properties in your producer;

```xml

  <producer class="xa-jms-producer">
    ...
    <per-message-properties>false</per-message-properties>
  </producer>

```

### Destination caching ###

If every message you consume is to be sent to the same destination (queue or topic), then set the destination caching to true.  This will stop Interlok re-creating the destination object for every message and instead use a cached version.

```xml

  <producer class="xa-jms-producer">
    ...
    <cache-destination>true</cache-destination>
  </producer>

```

### Message batching ###

Adding transactions to your message processing will add processing time, so we have introduced message batching.

This allows us to consume, process and produce multiple messages all within the same transaction.

The downside to this of course is that should you configure a message batch of 100 messages for example and the 100th message fails, then all 100 messages will be rolled back.

In your XA compliant JMS consumer, simply set the _max-batch_ property;

```xml

  <consumer class="xa-jms-consumer">
    ...
    <max-batch>250</max-batch>
  </consumer>

```

While batching is in effect you will want your transactions to complete (commit/rollback) in a timely manner should you not consume the maximum configured messages.

We do this by configuring the max-transaction-time on the consumer;

```xml

  <consumer class="xa-jms-consumer">
    ...
    <max-transaction-time>
      <unit>MILLISECONDS</unit>
      <interval>100</interval>
    </max-transaction-time>
  </consumer>

```

The way this is implemented, is that a consumer will attempt to consume a message from the queue, but will only wait for this configured time period.  If there is no message, then the transaction is deemed complete.


If there is a message available to consume, then we process the message and try again for the same configured time.

Eventually, you will either consume the maximum configured messages for your batched transaction, or a message will not be available and your transaction will end.

### Multi-channel/workflow ###

Consider scaling up by duplicating workflows and/or channels.

The downside to this is that you cannot guarantee message order.  If you require message order you can use a global lock on your consumers.

{% include warning.html content="Be careful when using this performance enhancement when you require guaranteed ordering, consuming from a JMS vendor that cannot guarantee message delivery order from multiple consumer threads.  This is exactly the case with a standard build of Solace, who assign a number of messages to a consumer thread regardless of whether you consume them all or not. Please consult your JMS vendor support to make sure multiple consumer threads will guarantee message delivery order." %}

Some background;  When we consume messages, we first need to create a new transaction.  Then once a message is consumed and processed/produced, we will commit the transaction, before starting over.

Creating a new transaction and commiting/rolling back a transaction can take time.  Therefore we have introduced consumer global locking.

The idea of global locking is that only one consumer may pull messages from a JMS endpoint at a time and once it is ready to commit it will release a lock which will allow a second consumer to pull and process messages.

With consumer global locking we effectively still guarantee order, but do not have to wait for a commit and then begin transaction operation to complete before processing messages.

To configure global locking, simply have two or more channels configured identically, but setting the _global-lock_ configuration property in each consumer to _true_.

```xml

  <consumer class="xa-jms-consumer">
    ...
    <global-lock>true</global-lock>
  </consumer>

```

## Performance tests ##

__Environment__

Windows 7 (64 bit)   :::   Intel Core i7-5600U CPU @2.60Ghz   :::  RAM: 16Gb

Solace VMR - 7.1.1.345

Interlok 3.4.0

### Single threaded ###

A single channel/workflow with a transaction batch size of 250, consuming from a Solace queue and producing to another queue.

200,000 messages at a steady rate of __4,000 msg / sec__.

### Multi-channel with locking ###

Three identical channels, locked so that only one is active at a time, with a transaction batch size of 250, consuming from a Solace queue and producing to another queue.

200,000 messages at a steady rate of __6,000 msg / sec__.

### Test configurations used ###

#### Single threaded test configuration ####

```xml

<adapter>
  <unique-id>Solace-XA-Adapter</unique-id>

  <shared-components>
    <transaction-manager class="xa-cached-jms-transaction-manager">
      <unique-id>transaction-manager</unique-id>
    </transaction-manager>
  </shared-components>

  <channel-list>
    <channel>

      <consume-connection class="xa-jms-connection">
        <connection-error-handler class="xa-jms-connection-error-handler"/>
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </consume-connection>

      <produce-connection class="xa-jms-connection">
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </produce-connection>

      <unique-id>Channel1</unique-id>

      <workflow-list>
        <standard-workflow>

          <consumer class="xa-jms-consumer">
            <unique-id>JMS-Consumer</unique-id>
            <max-batch>250</max-batch>
            <destination class="configured-consume-destination">
              <destination>jms:queue:Q1</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <xa-resource-name>wmq-xa-consumer-resource</xa-resource-name>
          </consumer>

          <producer class="xa-jms-producer">
            <destination class="configured-produce-destination">
              <destination>jms:queue:Q2</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <delivery-mode>PERSISTENT</delivery-mode>
            <priority>4</priority>
            <session-factory class="jms-default-producer-xa-session"/>
            <xa-resource-name>wmq-xa-producer-resource</xa-resource-name>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <cache-destination>true</cache-destination>
            <per-message-properties>false</per-message-properties>
          </producer>

          <send-events>false</send-events>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>Workflow1</unique-id>

        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>

```

#### Multi-channel test configuration ####

```xml

<adapter>
  <unique-id>Solace-XA-Adapter</unique-id>

  <shared-components>
    <transaction-manager class="xa-cached-jms-transaction-manager">
      <unique-id>transaction-manager</unique-id>
    </transaction-manager>
  </shared-components>

  <channel-list>
    <channel>

      <consume-connection class="xa-jms-connection">
        <connection-error-handler class="xa-jms-connection-error-handler"/>
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </consume-connection>

      <produce-connection class="xa-jms-connection">
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </produce-connection>

      <unique-id>Channel1</unique-id>

      <workflow-list>
        <standard-workflow>

          <consumer class="xa-jms-consumer">
            <unique-id>JMS-Consumer</unique-id>
            <max-batch>250</max-batch>
            <destination class="configured-consume-destination">
              <destination>jms:queue:Q1</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <xa-resource-name>wmq-xa-consumer-resource</xa-resource-name>
            <global-lock>true</global-lock>
          </consumer>

          <producer class="xa-jms-producer">
            <destination class="configured-produce-destination">
              <destination>jms:queue:Q2</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <delivery-mode>PERSISTENT</delivery-mode>
            <priority>4</priority>
            <session-factory class="jms-default-producer-xa-session"/>
            <xa-resource-name>wmq-xa-producer-resource</xa-resource-name>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <cache-destination>true</cache-destination>
            <per-message-properties>false</per-message-properties>
          </producer>

          <send-events>false</send-events>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>Workflow1</unique-id>

        </standard-workflow>
      </workflow-list>
    </channel>
    <channel>

      <consume-connection class="xa-jms-connection">
        <connection-error-handler class="xa-jms-connection-error-handler"/>
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </consume-connection>

      <produce-connection class="xa-jms-connection">
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </produce-connection>

      <unique-id>Channel3</unique-id>

      <workflow-list>
        <standard-workflow>

          <consumer class="xa-jms-consumer">
            <unique-id>JMS-Consumer</unique-id>
            <max-batch>250</max-batch>
            <destination class="configured-consume-destination">
              <destination>jms:queue:Q1</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <xa-resource-name>wmq-xa-consumer-resource</xa-resource-name>
            <global-lock>true</global-lock>
          </consumer>

          <producer class="xa-jms-producer">
            <destination class="configured-produce-destination">
              <destination>jms:queue:Q2</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <delivery-mode>PERSISTENT</delivery-mode>
            <priority>4</priority>
            <session-factory class="jms-default-producer-xa-session"/>
            <xa-resource-name>wmq-xa-producer-resource</xa-resource-name>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <cache-destination>true</cache-destination>
            <per-message-properties>false</per-message-properties>
          </producer>

          <send-events>false</send-events>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>Workflow3</unique-id>

        </standard-workflow>
      </workflow-list>
    </channel>
    <channel>

      <consume-connection class="xa-jms-connection">
        <connection-error-handler class="xa-jms-connection-error-handler"/>
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </consume-connection>

      <produce-connection class="xa-jms-connection">
        <vendor-implementation class="xa-jndi-implementation">
          <jndi-params>
            <key-value-pair>
              <key>java.naming.factory.initial</key>
              <value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.provider.url</key>
              <value>smf://192.168.132.128:55555</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.principal</key>
              <value>admin</value>
            </key-value-pair>
            <key-value-pair>
              <key>java.naming.security.credentials</key>
              <value>admin</value>
            </key-value-pair>
          </jndi-params>
          <jndi-name>xa-factory</jndi-name>
        </vendor-implementation>
      </produce-connection>

      <unique-id>Channel2</unique-id>

      <workflow-list>
        <standard-workflow>

          <consumer class="xa-jms-consumer">
            <unique-id>JMS-Consumer2</unique-id>
            <max-batch>250</max-batch>
            <destination class="configured-consume-destination">
              <destination>jms:queue:Q1</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <xa-resource-name>wmq-xa-consumer-resource</xa-resource-name>
            <global-lock>true</global-lock>
          </consumer>

          <producer class="xa-jms-producer">
            <destination class="configured-produce-destination">
              <destination>jms:queue:Q2</destination>
            </destination>
            <message-translator class="text-message-translator">
              <move-metadata>false</move-metadata>
              <move-jms-headers>false</move-jms-headers>
            </message-translator>
            <correlation-id-source class="null-correlation-id-source"/>
            <delivery-mode>PERSISTENT</delivery-mode>
            <priority>4</priority>
            <session-factory class="jms-default-producer-xa-session"/>
            <xa-resource-name>wmq-xa-producer-resource</xa-resource-name>
            <transaction-manager class="shared-transaction-manager">
              <lookup-name>transaction-manager</lookup-name>
            </transaction-manager>
            <cache-destination>true</cache-destination>
            <per-message-properties>false</per-message-properties>
          </producer>

          <send-events>false</send-events>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>Workflow2</unique-id>

        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>


```