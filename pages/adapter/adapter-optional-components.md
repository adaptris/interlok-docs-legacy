---
title: Optional Components
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-optional-components.html
toc: false
summary: This describes all the optional components that are currently available.
---

As additional features are developed and released our public facing repository is updated; so you can always browse the [repository directly](https://development.adaptris.net/nexus/content/groups/public/com/adaptris/) to keep up to date.

## Component List ##

| GroupID | ArtifactID | Description | Versions
|----|----|----|----|
|com.adaptris | [adp-actional-interceptor][] | Instrumentation of the adapter with Actional Management Server; requires additional jars not automatically delivered ||
|com.adaptris | [adp-actional-stabiliser][] | Services that interact with the Actional Stabiliser Switch; requires additional jars not automatically delivered; requires [adp-licensing][] ||
|com.adaptris | [adp-amazon-sqs][] | Connect to Amazon SQS either using their JMS compatibility layer or directly| 3.0.3 to 3.2.1
|com.adaptris | [adp-amqp][] | Connect to a AMQP 0.9 / 1.0 provider ||
|com.adaptris | [adp-apache-http][] | HTTP Producer implementation using the Apache HTTP client as the transport | 3.0.5+
|com.adaptris | [adp-as2][] | Provides AS2 messaging support; requires [adp-licensing][] ||
|com.adaptris | [adp-cirrus-db-webapp][] | Provides access to the cirrus database for web applications ||
|com.adaptris | [adp-cirrus-db][] | Provides access to the cirrus database for adapter services ||
|com.adaptris | [adp-cirrus-services][] | Provides Cirrus routing services; requires [adp-licensing][] ||
|com.adaptris | [adp-core-apt][] | [Custom annotations](developer-annotations.html)||
|com.adaptris | [adp-core][] | The base Interlok framework ||
|com.adaptris | [adp-drools][] | Integration with JBoss Rules; | does not require [adp-licensing][] from 3.3.0
|com.adaptris | [adp-edi-legacy][] | Legacy v2.x style EDI Transforms; requires [adp-licensing][]||
|com.adaptris | [adp-edi-stream][] | Stream based EDI transformations; requires [adp-licensing][]||
|com.adaptris | [adp-ehcache][] | Integration with ehcache as a message store| does not require [adp-licensing][] since 3.3.0
|com.adaptris | [adp-failover][] | Running an adapter in failover mode; requires [adp-profiler][]||
|com.adaptris | [adp-fop][] | PDF Transformations|does not require [adp-licensing][] from 3.3.0
|com.adaptris | [adp-hornetq][] | Connect to HornetQ JMS (will become obsolete as HornetQ is merged into ActiveMQ) |
|com.adaptris | [adp-hpcc][] | Connect to [HPCC](http://www.hpccsystems.com)|3.3.0 - 3.6.0 only
|com.adaptris | [adp-interfax][] | Integration with the Java FAX API; requires [adp-licensing][]|
|com.adaptris | [adp-ironmq][] | Connect to IronMQ|does not require [adp-licensing][] from 3.3.0
|com.adaptris | [adp-jms-oracleaq][] | Connect to [Oracle via advanced queues](cookbook-oracleaq.html); requires additional jars not automatically delivered; ; requires [adp-licensing][]||
|com.adaptris | [adp-jms-sonicmq][] | Connect to SonicMQ JMS; ; requires [adp-licensing][]||
|com.adaptris | [adp-jmx-jms][] | Support for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) ||
|com.adaptris | [adp-json][] | Transform JSON data to and from XML ||
|com.adaptris | [adp-kafka][] | Connect to [Apache Kafka](http://kafka.apache.org/)|3.2.1+
|com.adaptris | [adp-licensing][] | Enforces a license on certain components ||
|com.adaptris | [adp-msmq][] | Connect to MSMQ via ActiveX; requires [adp-licensing][]||
|com.adaptris | [adp-msmq-javonet][] | Connect to MSMQ via .NET - Requires a license from [javonet](https://www.javonet.com); requires [adp-licensing][]|3.0.6+|
|com.adaptris | [adp-new-relic][] | Supports [New Relic Profiling](advanced-new-relic-profiling.html); requires [adp-profiler][] ||
|com.adaptris | [adp-oftp][] | Support for OFTP as a transport protocol; requires [adp-licensing][] ||
|com.adaptris | [adp-poi][] | Extract data from an Excel spreadsheet ||
|com.adaptris | [adp-profiler][] | Base package for supporting profiling (used by [adp-new-relic][] and [adp-stackify][]) ||
|com.adaptris | [adp-restful-services][] | [Exposing Workflows as a RESTful service](adapter-hosting-rest.html)|3.0.6+
|com.adaptris | [adp-reliable-messaging][] | Support for ordered and reliable messaging; requires [adp-licensing][] ||
|com.adaptris | [adp-salesforce][] | Integration with Salesforce; requires [adp-licensing][] ||
|com.adaptris | [adp-sap][] | Integration with SAP via [IDocs](cookbook-sap-idoc.html) or [RFC/BAPI](cookbook-sap-rfc.html); requires additional jars not automatically delivered; requires [adp-licensing][] ||
|com.adaptris | [adp-schema][] | RelaxNG [schema validation](advanced-configuration-pre-processors.html#schema-validation) for Interlok configuration files ||
|com.adaptris | [adp-simple-csv][] | Transform a CSV file to XML ||
|com.adaptris | [adp-solace][] | Integration with Solace Systems as a JMS provider; requires additional jars not automatically delivered; requires [adp-licensing][]||
|com.adaptris | [adp-sonicmf][] | Interlok runtime as [part of a Sonic Container](advanced-sonic-container.html) ||
|com.adaptris | [adp-stackify][] | Supports [Stackify Profiling](advanced-stackify-profiling.html); requires [adp-profiler][] ||
|com.adaptris | [adp-stubs][] | [Test Scaffolding](developer-services.html#writing-tests) for developers ||
|com.adaptris | [adp-swift][] | Transform to and from the Swift message format; requires [adp-licensing][] ||
|com.adaptris | [adp-swiftmq][] | Connect to a SwiftMQ instance or any AMQP1.0 broker; [requires SwiftMQ Client Download](http://swiftmq.com/downloads/index.html); requires [adp-licensing][]||
|com.adaptris | [adp-tibco][] | Connect to a Tibco instance; requires additional jars not automatically delivered; requires [adp-licensing][]||
|com.adaptris | [adp-triggered][] | Channels that can be started via an external trigger; requires [adp-licensing][] ||
|com.adaptris | [adp-varsub][] | [Variable substitution pre-processor](advanced-configuration-pre-processors.html#variable-substitution) ||
|com.adaptris | [adp-vcs-git][] | Interlok configuration [hosted in git](advanced-vcs-git.html) | 3.0.3+
|com.adaptris | [adp-vcs-subversion][] | Interlok configuration [hosted in subversion](advanced-vcs-svn.html) | 3.0.2+
|com.adaptris | [adp-webservice-cxf][] | Accessing [external webservices](adapter-executing-ws.html)| 3.2.1+
|com.adaptris | [adp-webservice-external][] | Accessing [external webservices](adapter-executing-ws.html); requires [adp-licensing][] ||
|com.adaptris | [adp-webservice-internal][] | [Exposing workflows as webservices](adapter-hosting-ws.html)| 3.0.0 - 3.0.5|
|com.adaptris | [adp-web-services][] | [Exposing workflows as webservices](adapter-hosting-ws.html); | 3.0.6
|com.adaptris | [adp-webspheremq][] | Connection to a [WebsphereMQ instance](cookbook-native-wmq.html); requires [adp-licensing][] ||
|com.adaptris | [adp-xinclude][] | [XInclude pre-processor](advanced-configuration-pre-processors.html#xinclude)||
|com.adaptris | [adp-xml-security][] | XML security (JSR 106); requires [adp-licensing][] ||
|com.adaptris | [interlok-activemq][] | Embedding ActiveMQ as a management component| 3.6.0+
|com.adaptris | [interlok-aws-common][] | Common components required for accessing AWS| 3.3.0+
|com.adaptris | [interlok-aws-sqs][] | Integration with Amazon SQS (requires [interlok-aws-common][]|3.3.0+
|com.adaptris | [interlok-aws-s3][] | Integration with Amazon S3 (requires [interlok-aws-common][] | 3.3.0+
|com.adaptris | [interlok-elastic-search][] | Integration with ElasticSearch (requires [adp-simple-csv][]) | 3.4.1+
|com.adaptris | [interlok-es5][] | Integration with ElasticSearch using v5 API (requires [adp-simple-csv][]) | 3.5.1+
|com.adaptris | [interlok-expressions][] | Perform inline mathematic expressions | 3.6.4+
|com.adaptris | [interlok-failover][] | Simplified failover not dependent on AOP profiling | 3.4.0+
|com.adaptris | [interlok-gcloud-pubsub][] | Connect to Google cloud pubsub|3.6.3+
|com.adaptris | [interlok-hpcc][] | Connect to [HPCC](http://www.hpccsystems.com)|3.6.1+ (now opensource/ licensed under ASLv2)
|com.adaptris | [interlok-jruby][] | Tighter coupling with [jruby](http://jruby.org) as an alternative to [ScriptingService][]/[EmbeddedScriptingService][]|3.6.3+ (opensource / licensed under ASLv2)
|com.adaptris | [interlok-legacyhttp][] | servicing HTTP requests without Jetty (Java 7 compatible)| 3.6.4+
|com.adaptris | [interlok-mqtt][] | Support for MQTT protocol | 3.5.1+
|com.adaptris | [interlok-shell][] | Commandline runtime UI based on [CRaSH](http://www.crashub.org) | 3.4.1+
|com.adaptris | [interlok-service-tester][] | Testing services as part of a CI pipeline | 3.5.0+
|com.adaptris | [interlok-vcs-command-line][] | Interlok configuration hosted in a configurable VCS | 3.5.1+
|com.adaptris | [interlok-vertx][] | [Clustered workflows and services](advanced-vertx.html); requires [adp-licensing][] | 3.5.0+
|com.adaptris | [interlok-xa][] | XA support within the Adapter; requires [adp-licensing][] | 3.4.0+

<br/>

## How to install ##

For optional components that come with the installer; all you need to do is to copy the contents of `optional/[required-component]` into `${adapter.home}/lib` and restart your adapter. This will automatically enable those components for runtime and use within the UI. There are some components that will require additional jars (e.g. [SAP][adp-sap], [WebsphereMQ][adp-webspheremq], [Tibco][adp-tibco], [Oracle][adp-jms-oracleaq]) which you will need to source from your installation / 3rd party provider.

{% include note.html content="Additional jars may need to be sourced from your target application / 3rd party provider." %}


## Manual install ##

For components that are not normally delivered with the installer; the recommended installation is via a [dependency management](advanced-ant-ivy-deploy.html) system. This will automagically download everything that is required for the optional component in question.

{% include note.html content="Additional jars may need to be sourced from your target application / 3rd party provider." %}

You should always match the version number with your primary Interlok installation version; so if you wanted [adp-simple-csv][] and your Interlok version is 3.0.2 then you would  configure your ivy dependency :

```xml
<dependency org="com.adaptris" name="adp-simple-csv" rev="3.0.2-RELEASE"/>
```

or add something to your POM file

```xml
<dependency>
	<groupId>com.adaptris</groupId>
	<artifactId>adp-simple-csv</artifactId>
	<version>3.0.2-RELEASE</version>
</dependency>
```

## Javadoc ##

Interlock comes automatically with some javadocs for its installed components. The javadocs file can be found into `${adapter.home}/docs/javadocs`.
You can access the javadocs by opening a browser at <http://localhost:8080/adapter-web-gui/javadocs>. **N.B** You will have to login into the Adapter UI to see the javadocs.

Optional components javadocs can be open in two ways:

- **The javadocs are within a folder:** Open your browser at <http://localhost:8080/adapter-web-gui/javadocs/optional/your-component/index.html> **e.g.** <http://localhost:8080/adapter-web-gui/javadocs/optional/xml-security/index.html>.
- **The javadocs are in a jar file:** Open your browser at <http://localhost:8080/adapter-web-gui/javadocs/your-component.jar/index.html> **e.g.** <http://localhost:8080/adapter-web-gui/javadocs/optional/adp-swiftmq-3.0.3-RELEASE-javadoc.jar/index.html>.

If you've added an optional components following the steps explained above you can copy the javadocs jar file into `${adapter.home}/docs/javadocs` to be able to access it via the browser. You will have to restart your adapter to be able to access the javadocs.


[adp-amazon-sqs]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-amazon-sqs/
[adp-amqp]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-amqp/
[adp-apache-http]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-apache-http/
[adp-as2]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-as2/
[adp-cirrus-db-webapp]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-cirrus-db-webapp/
[adp-cirrus-db]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-cirrus-db/
[adp-cirrus-services]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-cirrus-services/
[adp-core-apt]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-core-apt/
[adp-core]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-core/
[adp-drools]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-drools/
[adp-edi-legacy]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-edi-legacy/
[adp-edi-stream]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-edi-stream/
[adp-ehcache]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-ehcache/
[adp-fop]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-fop/
[adp-hornetq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-hornetq/
[adp-interfax]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-interfax/
[adp-ironmq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-ironmq/
[adp-jms-oracleaq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-jms-oracleaq/
[adp-jms-sonicmq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-jms-sonicmq/
[adp-jmx-jms]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-jmx-jms/
[adp-json]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-json/
[adp-msmq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-msmq/
[adp-new-relic]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-new-relic/
[adp-oftp]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-oftp/
[adp-poi]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-poi/
[adp-profiler]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-profiler/
[adp-reliable-messaging]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-reliable-messaging/
[adp-salesforce]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-salesforce/
[adp-sap]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-sap/
[adp-schema]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-schema/
[adp-simple-csv]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-simple-csv/
[adp-sonicmf]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-sonicmf/
[adp-stackify]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-stackify/
[adp-stubs]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-stubs/
[adp-swift]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-swift/
[adp-swiftmq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-swiftmq/
[adp-tibco]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-tibco/
[adp-triggered]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-triggered/
[adp-varsub]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-varsub/
[adp-vcs-subversion]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-vcs-subversion/
[adp-vcs-git]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-vcs-git/
[adp-webservice-cxf]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-webservice-cxf/
[adp-webservice-external]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-webservice-external/
[adp-webservice-internal]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-webservices-internal/
[adp-webspheremq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-webspheremq/
[adp-xinclude]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-xinclude/
[adp-xml-security]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-xml-security/
[adp-solace]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-solace/
[adp-actional-interceptor]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-actional-interceptor/
[adp-actional-stabiliser]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-actional-stabiliser/
[adp-msmq-javonet]:  https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-msmq-javonet/
[adp-web-services]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-web-services/
[adp-restful-services]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-restful-services/
[adp-kafka]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-kafka/
[adp-licensing]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-licensing/
[adp-failover]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-failover/
[interlok-aws-sqs]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-aws-sqs/
[interlok-aws-s3]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-aws-s3/
[interlok-aws-common]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-aws-common/
[adp-hpcc]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-hpcc/
[interlok-elastic-search]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-elastic-search/
[interlok-es5]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-es5/
[interlok-failover]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-failover/
[interlok-shell]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-shell/
[interlok-xa]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-xa/
[interlok-service-tester]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-service-tester/
[interlok-vertx]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-vertx/
[interlok-vcs-command-line]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-vcs-command-line/
[interlok-mqtt]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-mqtt/
[interlok-hpcc]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-hpcc/
[interlok-jruby]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-jruby/
[interlok-gcloud-pubsub]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-gcloud-pubsub/
[ScriptingService]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/ScriptingService.html
[EmbeddedScriptingService]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/EmbeddedScriptingService.html
[interlok-expressions]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-expressions/
[interlok-legacyhttp]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-legacyhttp/
[interlok-activemq]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-activemq/