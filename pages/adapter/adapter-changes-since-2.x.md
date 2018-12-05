---
title: What's changed since 2.x
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-changes-since-2.x.html
summary: This is a brief guide about what's changed in the adapter..
---

- It requires Java 7
- There is now a web based UI
- The underlying XML has been migrated from Castor to XStream
- The XPath / XSLT engine has switched from Xalan to Saxon-HE
- Some features have been removed from the core distribution and moved into __optional__
- **Your existing v2 license is NOT compatible**.

## Getting Started ##

Download the adapter for your preferred platform and install it. This will install the adapter with a pre-built adapter XML that showcases some of the features now available in the web UI.
The docs/example-xml directory contains example XML configuration for each of the components, as before. It is now separated out into the base deliverable and "optional" components. The installation comes with basic (i.e. non-SSL) SonicMQ support built into the main distribution.
If you want to use any of the optional components, then copy the corresponding jars (from the `${adapter.home}/optional` directory) into the main lib directory along with any external dependencies that are not distributed as required (e.g. SAP libraries)

### The Web UI ###

`${adapter.home}/config/jetty.xml` contains the settings for the embedded web server. This can be modified if port 8080 is in-use on the adapter machine. Start the adapter, and the embedded webserver will automatically start. You can access the UI using [http://localhost:8080/adapter-web-gui/](http://localhost:8080/adapter-web-gui/) from your browser. The default credentials are admin / admin. The underlying web application communicates with the adapter via JMX, so you can attach to the adapter using any JMX tool you prefer (e.g. jconsole) provided your classpath contains all the correct libraries.

### License ###

The adapter installer no longer requires a license when you install it. If there is no license available, then the adapter starts up in "restricted mode". What that means is that for the first 10 minutes messages are processed normally; after this period messages are throttled on a per-workflow basis to a max rate of 1 per hour. This allows you to preview / try things without having a valid license. __Your existing v2 license is NOT compatible__.


## Migrating your configuration ##

If you have existing configuration that you want to re-use then it needs to be modified so that it is suitable for v3. There are few key steps to achieving this. Someone should write a mapping to handle most of this.
You should be making heavy use of the examples that can be found in the docs directory.


### Find / Replace ###

You need to replace all the `xsi:type="java:` with `class="`. You don't have to use qualified class name anymore, aliases have been setup for each of the configurable classes; however, the fully qualified class names will still work, so this is a good way to get migrated. Each configurable class should have a note in the javadocs about what the preferred alias is in future.
You need to modify all your existing PtpConnection / PasConnection instances to be [JmsConnection][] as JMS has been migrated from 1.0 to 1.1 which means that the same connection can be used for both queues and topics.

### Workflows / List Handling ###

Rather than using `<workflow xsi:type=`; each workflow type has an alias associated with it e.g. `<standard-workflow>` for a com.adaptris.core.StandardWorkflow. This needs to replace the corresponding `<workflow xsi:type=` tag.
Similarly, for some services that contain lists of objects that implement a common interface you will find that you need to specify them directly using their alias name as the XML tag. For instance for SyntaxRoutingService `<routing-xpath-node-syntax-identifier>` would be correct; `<syntax-identifier class="routing-xpath-node-syntax-identifier">` would not be valid.

### List Handling re-visited ###

Components which have child list items may now require an additional wrapping element. Where possible the previous configuration behaviour has been preserved, however there will be some elements where it has not been possible to do this because of the way lists are generated out of the resulting XML.
For instance: all service collections (e.g. ServiceList, BranchingServiceCollection) require a `<services>` element to wrap the nested `<service>` elements. Some other components will require the same modification to have a wrapper element. We have tried to limit those only to where it has been absolutely necessary; check the example XML that is provided for more details.

### JMS ###

The broker-url has moved into each of the vendor implementations; this is because for some vendors a broker URL makes no sense, so for Websphere MQ (amongst others), the vendor implementation has a configurable broker-host and broker-port setting.
Note that in most instances, you should consider migrating to using a shared-connection as your JMS Connection for efficiency so the tediousness of this change is mitigated somewhat.

### Timeouts ###

Timeouts / retries used to be specified in milliseconds. These have now been converted to be a TimeInterval which allows you to specify it in units of your choosing. The safest course of action is to delete all the entries in your config that refer to milliseconds (e.g. connection-wait in JdbcConnection); this will revert to using the default. The default might not be totally appropriate but will get you over the configuration pain in the short term. Check the examples and javadocs for more information about how to configure the new time intervals.

### XML / XPath ###

This release has migrated to Saxon as its default XSLT / XPath engine. Saxon is stricter than Xalan, so you may find that some of your transforms no longer work as expected; you can switch back to Xalan by downloading it, deleting `Saxon-HE.jar` and using `xalan.jar` along with `serializer.jar` from the Xalan download instead. If you are downloading your dependencies via [Apache Ivy] then your ivy file will something like :

```xml
<dependency org="xalan" name="xalan" rev="2.7.2" conf="runtime->default"/>
... // Other bits missed for brevity
<exclude org="net.sf.saxon" artifact="Saxon-HE"/>
<exclude org="net.sf.saxon" artifact="saxon"/>
```

All XPath resolution now has the ability to have a NamespaceContext associated with it; specifying a non-namespaced xpath on a document with namespaces in it will not work.

## User Interface ##

### Dashboard ###

The dashboard shows all the current adapters that the web application knows about. When you first start it up, it will just be the local adapter. It basically shows a high level view of the adapter, and statuses of various workflows/channels in the adapter. After a while messages will start failing (the supplied adapter has messages that fail randomly) to showcase some of the things that can be interacted with.
It is possible to add adapters to the dashboard; you need to know the JMXServiceURL for that adapter that you want to add, and also the adapter name. The JMXServiceURL for the running adapter can be found in bootstrap.properties.


### Monitoring ###

You can monitor different aspects of the adapter, and apply those screens in a grid-like fashion. Additional widgets are made available to you depending on the type of configuration that you have.


### Configuration ###

There is now support for configuring the running adapter. Configuration is supported in one of two fashions; either directly by choosing a new object to configure, or by selecting one from the _templates_ directory. The templates directory is configured in bootstrap.properties, and contains configuration that you have previously built and these templates can be inserted into the configuration canvas.


## New Components ##

### Shared Components ###

The most important item is the concept of shared components. This was primarily designed to allow you to share an expensive connection (e.g. JMS) across multiple channels and components. This is split into 2 parts; a new top-level element that sits below the adapter called shared-components and a shared-connection which is what you configure in order to reference those connections. What you need to do is
- Configure a new connection with a unique-id inside the shared-connection-list
- Use shared-connection where you would normally configure a connection and make sure the lookup-name refers to the unique-id configured in the first step.

Check the [Shared Components / JNDI Guide](adapter-jndi-guide.html) for more information.

### Remote control via JMS ###

If you check the `JMXServiceURL` property in bootstrap.properties you will see that it is the reference implementation jmxmp. It is now possible to switch the JMXServiceURL to be JMS based which will allow you to proxy all JMX requests over a JMS Queue or Topic. Currently the supported brokers are SonicMQ, ActiveMQ and any AMQP compliant broker (such as QPid). For example, if you have a standard SonicMQ installation and the DomainManager already running then by switching the JMXServiceURL in bootstrap.properties to be `service:jmx:sonicmq:///tcp://localhost:2506?type=Topic&destination=myTopic` then you will switch to using the topic myTopic on the domain manager as your JMX provider. The username and password are not provided here (they default to Administrator/Administrator for SonicMQ) but you can provide it as part of the JMXServiceURL or as environmental properties in bootstrap.properties.

Check the [JMS over JMX Guide](advanced-jmx-jms.html) for more information.

### XPath/XSLT ###

All XPath resolution now has the ability to have a NamespaceContext associated with it; specifying a non-namespaced xpath on a document with namespaces in it will not work due to saxon.
Additionally we support the Streaming Transformations for XML (STX) language as well as XSLT. In order to switch to using STX you will have to specify a new transformer element in your XmlTransformService. The default remains XSLT. You probably don't need to use STX, but it's going to be more efficient with large XML documents but it will mean re-writing all your transforms.


### SAP ###

There is now support for dynamic invocation of SAP RFC and BAPI modules. The structure of the XML message determines the module to call, and the appropriate import / export / table parameters are automatically derived from document. For more details you can check our [SAP BAPI/RFC integration guide](cookbook-sap-rfc.html#dynamic-rfc-invocation) for more details.

### Other ###

There are now a lot more optional components which interface with different systems. Check the directory structure in the optional directory for more information.

[JmsConnection]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/jms/JmsConnection.html
[Apache Ivy]: http://ivy.apache.org
