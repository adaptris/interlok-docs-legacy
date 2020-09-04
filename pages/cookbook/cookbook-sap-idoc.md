---
title: SAP IDoc Integration
keywords: interlok sap
tags: [cookbook,]
sidebar: home_sidebar
permalink: cookbook-sap-idoc.html
summary: This is a brief checklist and documentation of what you have to do to configure Interlok to send and receive IDocs with SAP over ALE. The bulk of the SAP configuration should already be done by the in-house SAP team so they will tell you what you need to know. You will be already familiar with Interlok and its underlying concepts. No SAP knowledge is assumed. Interlok uses SAP JCo Standalone in order to achieve the desired integration (3.x).
---

{% include note.html content="This depends on the artifact com.adaptris:interlok-sap. This will require a license." %}

## Software Pre-requisites ##

Interlok does not ship with the specific jars required to connect to SAP via ALE. You will have to download these directly from SAP. They are free to download provided you have a login to their support center. You will need the following software packages for your platform:

- SAP Java Connector (we build against 3.0.12) : `sapjco3-linuxintel-3.0.12.tgz`
- SAP Java IDoc Class Library (we build against 3.0P11) : `sapjidoc30P_11-10009485.zip`

Follow the instructions for installing the packages for the platform in question, but in brief, make sure that all the jar files are in the ${adapter}/lib directory, and the native libraries are available to the JVM

- Windows : Make sure that the directory containing any DLLs from SAP Java Connector is on the PATH (or put them all into \windows\system32 perhaps).
- Linux : Make sure that the environment variable LD_LIBRARY_PATH also contains the directory where any shared objects from the SAP Java Connector download can be found.

----

## Sending and receiving IDocs ##

### SAP Configuration ###

Basically, the SAP team should know how to do this, so this is a very simple overview of what needs to be done. If you are migrating from a Business Connector enabled SAP system, then it should be as simple as finding out the information required, stopping the Business Connector, and making sure that the Adapter registers as same registered program id as the Business Connector.
In more detail, there are three SAP transactions that come into play: SM59, WE21, and WE20 in that order.

- SM59 : Create a TCP/IP connection based RFC Destination, the connection type is ‘T’ (On the technical settings tab, the activation type is a __Registered Server Program__. You will also need to supply a Program ID - You will need this later)
- WE21 : Create a new transactional RFC port that points to the RFC destination created in SM59. Let the system create a new port name or not according to the enterprise policy.
- WE20 : Essentially you are using this transaction to bind particular partner/message types to the transactional RFC port created in WE21.
After that configuration, they should be able to use their business processes normally and process an order (for instance).


### Transaction IDs ###

Every time an IDoc is sent from/received by SAP, it is assigned a transaction ID. This is a 25 character long alphanumeric string that is guaranteed to be unique across SAP systems. If a document is resent, then it should be sent with the same Transaction ID, to indicate that it is a resent document. In most cases, you can resend the document with a new TID as the business process will detect from the internal document headers is a duplicate (or you are in test phase and it doesn’t matter). If you have a requirement to track the TIDs to and from SAP, then consider using the [sap-xml-tid-repository][] where appropriate. This allows you to cross-reference the AdaptrisMessage ID against the SAP Transaction ID with a date/time stamp and status.

### Interlok Workflow Design ###

We recommend that the Adapter registers as a single program and all IDocs (to all partners, and of all message types) are consumed via that single point. This means that you need to devise a strategy to control the behaviour of the workflow for different partners and message types. You can do this by extracting the required metadata and then using a [dynamic-service-locator][] to control the required services that are invoked. Use a [pooling-workflow][] to increase throughput.

### Receiving an IDoc ###

You'll need to configure an [sapjco3-idoc-consume-connection][] along with a [sapjco3-idoc-consumer][] which will register as the __Program ID__ that was configured as part of _SM59_

```xml
 <connection class="sapjco3-idoc-consume-connection">
  <connection-error-handler class="sapjco3-connection-error-handler-logging"/>
  <destination-provider-info>
   <connection-properties>
    <key-value-pair>
     <key>jco.client.lang</key>
     <value>EN</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.user</key>
     <value>ADAPTRIS</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.passwd</key>
     <value>ADAPTRIS</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.sysnr</key>
     <value>00</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.ashost</key>
     <value>192.168.72.136</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.client</key>
     <value>810</value>
    </key-value-pair>
   </connection-properties>
   <connection-id>IDESVR</connection-id>
  </destination-provider-info>
  <transaction-id-repository class="sap-noop-tid-repository"/>
  <server-provider-info>
   <connection-properties>
    <key-value-pair>
     <key>jco.server.gwserv</key>
     <value>3300</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.server.connection_count</key>
     <value>2</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.server.gwhost</key>
     <value>192.168.72.136</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.server.progid</key>
     <value>adaptris.adapter</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.server.repository_destination</key>
     <value>IDESVR</value>
    </key-value-pair>
   </connection-properties>
   <connection-id>IdocConsumer</connection-id>
  </server-provider-info>
 </connection>
 <consumer class="sapjco3-idoc-consumer">
  <idoc-xml-format>SAP_RELEASE_46</idoc-xml-format>
  <rendering-options>RENDER_EMPTY_TAGS</rendering-options>
 </consumer>
```

The [sapjco3-idoc-consume-connection][] has to provide a `ServerDataProvider` for the underlying connection instance. This means that a Channel containing an [sapjco3-idoc-consume-connection][] should only have a single Workflow within that channel. This avoids having multiple listeners registered with the same `jco.server.progid`. As a result, any configured [sapjco3-idoc-consumer][] will ignore any configured [ConsumeDestination][] implementation, though you may wish to configure one to have a unique thread name for logging purposes. SAP [destination-provider-info][] and [server-provider-info][] properties are documented in the API docs for JCO3 but listed in our own documentation as a quick reference.

The output of the consumer is an IDoc (possibly more than one) in XML format. You can then use something like [xpath-metadata-service][] to extract the parts you need for performing a dynamic service lookup. Suggested fields you extract from the control record are SNDPRN for the sending partner (which may always be fixed but not always) RCVPRN for the receiving partner, and perhaps MESTYP for the message type.

### Sending an IDoc ###

[sapjco3-idoc-producer][] is used to send IDocs into SAP, and uses an [sapjco3-idoc-produce-connection][] to handle the ALE connection. The input to [sapjco3-idoc-producer][] is expected to be a single IDoc in XML format that matches the configured `idoc-xml-format`. There is no requirement to specify the type of IDoc that is being sent to SAP, it is inferred from the XML document, and looked up from metadata in the SAP system. Accordingly, custom IDoc implementations are supported provided that the associated metadata is available in the system.

```xml
 <connection class="sapjco3-idoc-produce-connection">
  <destination-provider-info>
   <connection-properties>
    <key-value-pair>
     <key>jco.client.lang</key>
     <value>EN</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.user</key>
     <value>ADAPTRIS</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.passwd</key>
     <value>ADAPTRIS</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.sysnr</key>
     <value>00</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.ashost</key>
     <value>192.168.72.136</value>
    </key-value-pair>
    <key-value-pair>
     <key>jco.client.client</key>
     <value>810</value>
    </key-value-pair>
   </connection-properties>
   <connection-id>MyClientUniqueId</connection-id>
  </destination-provider-info>
  <transaction-id-repository class="sap-noop-tid-repository"/>
 </connection>
 <producer class="sapjco3-idoc-producer">
  <idoc-xml-format>SAP_46</idoc-xml-format>
  <parsing-options>PARSE_WITH_IGNORE_UNKNOWN_FIELDS</parsing-options>
 </producer>
```

----

## Troubleshooting ##

### RFC Trace ###

Turn on rfc trace by adding `jco.client.trace=1` to the [destination-provider-info][] (and `jco.server.trace=1` in [server-provider-info][]). This will create a lot of rfc_XXX.trc files; you may wish to automatically delete them after a period of time by configuring a [sapjco3-automatic-trace-file-delete][] on the connection. This will show some low level diagnostic trace information generated by the SAP libraries. Without additional configuration, they will be written out to the current user directory (generally the root of the Interlok installation).

### Tracking in SAP ###

You can track IDocs going into and out of the SAP system using _BD87_ to see all the inbound and outbound IDocs. Other transactions that do similar things are _WE02_ and _WE07_. You can also test initial connectivity directly from _SM59_ using the _Test Connection_ button. This performs a ping on the adapter, and you see the average response times for that program.



[sap-xml-tid-repository]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/XmlFileRepository.html
[dynamic-service-locator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/services/dynamic/DynamicServiceLocator.html
[sapjco3-idoc-consume-connection]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/idoc/IdocConsumeConnection.html
[sapjco3-idoc-consumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/idoc/IdocConsumer.html
[pooling-workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/PoolingWorkflow.html
[destination-provider-info]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/JcoConnection.html#setDestinationProviderInfo-com.adaptris.core.sap.jco3.ProviderInfo-
[server-provider-info]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/idoc/IdocConsumeConnection.html#setServerProviderInfo-com.adaptris.core.sap.jco3.ProviderInfo-
[xpath-metadata-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/services/metadata/xpath/XpathMetadataQuery.html
[ConsumeDestination]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/ConsumeDestination.html
[sapjco3-idoc-producer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/idoc/IdocProducer.html
[sapjco3-automatic-trace-file-delete]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/AutomaticTraceFileDelete.html
[sapjco3-idoc-produce-connection]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-sap/3.11-SNAPSHOT/com/adaptris/core/sap/jco3/idoc/IdocProduceConnection.html
