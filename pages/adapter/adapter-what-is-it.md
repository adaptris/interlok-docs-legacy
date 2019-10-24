---
title: What is Interlok
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-what-is-it.html
toc: false
---

<a href="#" data-toggle="tooltip" data-original-title="{{site.data.glossary.interlok}}">Adaptris Interlok</a> is an event-based framework designed to enable architects to rapidly connect different applications, communications standards and data standards to deliver an integrated solution.

The key design philosophy of the Interlok framework is the ability to apply the right amount of integration technology in the appropriate place. It offers complete flexibility to embed custom application connections and services within the framework. You can either compose services into your integration solution; or you can write custom code. Sometimes custom code is better, sometimes it isn't.


## The main components ##

An Interlok container contains one or more [Adapter][] instances (for now, we can treat them as having a one-to-one relationship, so Adapter/Interlok may be used interchangeably). An [Adapter][] is made up of one or more [channels][Channel], each of which has two optional [connections][AdaptrisConnection] of arbitrary types, for producing and consuming messages. Each [channel][Channel] has one or more [workflows][Workflow], each of those will have a [consumer][AdaptrisMessageConsumer] and a [producer][AdaptrisMessageProducer] and a [collection of services][Service] which interact with the [message][AdaptrisMessage].

[Consumers][AdaptrisMessageConsumer] read data and create a message with that data as its payload. A [message][AdaptrisMessage] is generally made up of a payload and metadata. [Producers][AdaptrisMessageProducer] produce that data somewhere. [Services][Service] act upon the message and do things to it (like transformations, validation, encryption, content enrichment; all the usual EIP that you might find).

The simplest [Adapter][] will contain a single channel with a single workflow.

```xml
<adapter>
  <unique-id>getting-started</unique-id>
  <channel-list>
    <channel>
      <auto-start>true</auto-start>
      <workflow-list>
        <standard-workflow>
          <consumer class="fs-consumer">
            <destination class="configured-consume-destination">
              <destination>./msgs/in</destination>
            </destination>
            <poller class="fixed-interval-poller"/>
            <create-dirs>true</create-dirs>
          </consumer>
          <service-collection class="service-list">
            <services>
            </services>
          </service-collection>
          <producer class="fs-producer">
            <destination class="configured-produce-destination">
              <destination>./msgs/out</destination>
            </destination>
            <create-dirs>true</create-dirs>
          </producer>
        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>
```

- All this adapter does is a glorified file copy from `./msgs/in` to `./msgs/out`
- There is an empty [service-list][ServiceList] configured; so no services are applied.

That's it in a nutshell and if we wanted a pretty picture :

{% include image.html file="user-guide/adapter-overview.png" caption="Adapter with 2 channels"%}

{% include tip.html content="You are not restricted to having only 2 connections in a channel; any [Service][] could contain a connection; but this is simpler to visualise when starting off. Complex workflows can be composed by having services that interact with other systems to enrich the content" %}

## Understanding adapter.xml ##

The configuration file `adapter.xml` an XML representation of a graph of Java objects, created using a Java to XML marshalling framework called _XStream_. All element names will follow JavaBeans style properties of a Java object. For example, instances of class adapter have a `String` property `uniqueId` with a corresponding `setUniqueId(String)` and `getUniqueId()` which means:

```xml
<adapter>
  <unique-id>getting-started</unique-id>
  ...
</adapter>
```

{% include note.html content="The standard camel case java naming convention is converted to use a `-` in XML element names, so `uniqueId` becomes `<unique-id>`" %}

The standard camel case java naming convention is converted to use a `-` in XML element names, so `uniqueId` becomes `<unique-id>`; all string and primitive types are expressed as elements in XML and conversion is handled automatically. In cases where the property being set is an interface or abstract type, it is necessary to supply the runtime type of the implementation to use; which is where the `class=` attribute comes in (you can see this in the example above).

All standard classes are [annotated with an alias](developer-annotations.htmlmd#class-level-annotations) which gives you a friendly name to use rather than the fully qualified class name. You can still use the fully qualified classname if you wish; but package/class names do change from time to time so using the friendly name is preferred. In the example above `fs-consumer` is the friendly name for the class `com.adaptris.core.fs.FsConsumer`.

## What is a Connection ##

An [AdaptrisConnection][] object tends to wrap any behaviour that is required to setup a persistent connection an application; such as making a connection over a socket, or making a connection to a JMS Provider or Database. Some [AdaptrisConnection][] instances may not make a connection but instead encapusulate common configuration options that can be overriden.

## What is a Workflow ##

A [workflow][Workflow] is a container for a [consumer][AdaptrisMessageConsumer], a [producer][AdaptrisMessageProducer] and a [collection of services][Service] which will interact with the [message][AdaptrisMessage]. Various types of workflow are available, and each will have slightly different behaviour. The ones that you're likely to use are [standard-workflow][], [pooling-workflow] and [jms-transacted-workflow].

## What is a Producer ##

An [AdaptrisMessageProducer][] is responsible for sending the message to the target system (that may already have been connected to by an [AdaptrisConnection][]). Typical types of producer are [FTP][FtpProducer], [Email][DefaultSmtpProducer], [HTTP][JdkHttpProducer], [JMS][JmsProducer], along with many more available in the `optional` directory.

## What is a Consumer ##

An [AdaptrisMessageConsumer][] is responsible for receiving messages from the target system. You need to decide on how the consumer will be triggered. Some consumers such as [FTP][FtpConsumer] or [Email][DefaultMailConsumer] are timer based (i.e. they poll on a schedule); some like [JMS][JmsConsumer] are passive and notified about incoming messages.

## What is a Service ##

[Services][Service] are a means of applying arbitrary functionality to messages and as such are the key low-level building block in Interlok. Examples of services included encrypting message payloads, applying XSLT transformations and extracting metadata using XPath or regular expressions. It is straightforward to create custom services if no existing off the shelf service meets a particular requirement (see [Custom Services](developer-services.html)).

Services are often grouped into collections. Simple collections allow a linear list of services to be applied one after the other. More complex collections allow services to be applied conditionally based on configurable criteria, allowing complex processes to be modelled.

## What components are standard ##

How then can we find what connections/producers/consumers/services there are and understand the configuration they require?

The definitive source of information describing how to configure any component are available is the Javadoc documentation in `docs/api` available as part of your installation. You can also find them online : [https://development.adaptris.net/javadocs/](https://development.adaptris.net/javadocs/).

{% include tip.html content="Look at the javadocs for the class in question; any public setter/getter combination means you can configure it in XML e.g. `getUniqueId()` + `setUniqueId()` means that you can configure a `<unique-id>myUniqueId</unique-id>`." %}

Secondly, examples of all standard components are included in directory `docs/example-xml`. If you look in this directory find the one called `com.adaptris.core.ServiceList.xml` which contains example configuration for a [service-list][ServiceList]. A [service-list][ServiceList] is just a container for one or more services. By convention a [NullService][] is shown as a placeholder where any service may be configured.

```xml
  <service-list>
   <services>
    <null-service/>
    <null-service/>
    <null-service/>
   </services>
  </service-list>
```


Your example may not be exactly the same; it is likely to have `unique-id` elements. These are generated by default to allow referencing by the UI; they are not strictly required, and will be re-created with a new unique-id if you do not configure one.

## What about "my-backend-system" ##

The Adaptris Interlok installer ships with a number of modular components that can be dropped into the lib directory to be enabled. The ones that are delivered with the installer are the most popular and frequently requested components; however, due to various licensing restrictions it may have been impossible to bundle all the dependent jars and native libraries required. For those components (such as [SAP](cookbook-sap-idoc.html), [WebsphereMQ](cookbook-native-wmq.html), [Oracle AQ](cookbook-oracleaq.html) you may need to source some additional binaries; which are discussed in their respective Integration Guides. They are discussed more fully in the [list of optional components](adapter-optional-components.html)

[Adapter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Adapter.html
[Channel]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Channel.html
[AdaptrisConnection]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/AdaptrisConnection.html
[Workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Workflow.html
[AdaptrisMessageConsumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/AdaptrisMessageConsumer.html
[AdaptrisMessageProducer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/AdaptrisMessageProducer.html
[Service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Service.html
[AdaptrisMessage]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/AdaptrisMessage.html
[ServiceList]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/ServiceList.html
[FtpProducer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/ftp/FtpProducer.html
[DefaultSmtpProducer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/DefaultSmtpProducer.html
[JdkHttpProducer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/http/JdkHttpProducer.html
[JmsProducer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/jms/JmsProducer.html
[FtpConsumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/ftp/FtpConsumer.html
[DefaultMailConsumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/DefaultMailConsumer.html
[JmsConsumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/jms/JmsConsumer.html
[NullService]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/NullService.html
[standard-workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/StandardWorkflow.html
[pooling-workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/PoolingWorkflow.html
[jms-transacted-workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/jms/JmsTransactedWorkflow.html

{% include links.html %}
