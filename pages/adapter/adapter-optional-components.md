---
title: Optional Components
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-optional-components.html
toc: false
summary: This describes all the optional components that are currently available.
---

As additional features are developed and released our public facing repository is updated; so you can always browse the [repository directly](https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/) to keep up to date.

## Component List ##

| GroupID | ArtifactID | Description | Versions | Notes
|----|----|----|----|----|
|com.adaptris | [interlok-actional-interceptor][] | Instrumentation of the adapter with Actional Management Server; requires additional jars not automatically delivered | 3.8.0+
|com.adaptris | [interlok-actional-stabiliser][] | Services that interact with the Actional Stabiliser Switch; requires additional jars not automatically delivered; requires [interlok-licensing][] - This is compiled against Actional 8.2 and may not work with the latest versions of actional if running outside of a Sonic container (the jars are no longer available)| 3.8.0+ |
|com.adaptris | [interlok-activemq][] | Embedding ActiveMQ as a management component| 3.6.0+ | available on [github](https://github.com/adaptris/interlok-activemq)
|com.adaptris | [interlok-amqp][] | Connect to a AMQP 0.9 / 1.0 provider | 3.8.0 |available on [github](https://github.com/adaptris/interlok-amqp)
|com.adaptris | [interlok-apache-http][] | HTTP Producer implementation using the Apache HTTP client as the transport | 3.8.0+|available on [github](https://github.com/adaptris/interlok-apache-http)
|com.adaptris | [interlok-artemis][] | Embedding ArtemisMQ as a management component| 3.9.0+ | available on [github](https://github.com/adaptris/interlok-artemis)
|com.adaptris | [interlok-as2][] | Provides AS2 messaging support; requires [interlok-licensing][] | 3.8.0+
|com.adaptris | [interlok-aws-common][] | Common components required for accessing AWS| 3.3.0+ | available on [github](https://github.com/adaptris/interlok-aws)
|com.adaptris | [interlok-aws-kinesis][] | Publish to AWS kinesis (requires [interlok-aws-common][]) | 3.9.1+ | available on [github](https://github.com/adaptris/interlok-aws)
|com.adaptris | [interlok-aws-sqs][] | Integration with Amazon SQS (requires [interlok-aws-common][])|3.3.0+ | available on [github](https://github.com/adaptris/interlok-aws)
|com.adaptris | [interlok-aws-s3][] | Integration with Amazon S3 (requires [interlok-aws-common][]) | 3.3.0+ | available on [github](https://github.com/adaptris/interlok-aws)
|com.adaptris | [interlok-aws-sns][] | Publish to an SNS topic (requires [interlok-aws-common][]) | 3.7.2+ | available on [github](https://github.com/adaptris/interlok-aws)
|com.adaptris | [interlok-azure-cosmosdb][] | Interacting with Azure CosmosDB | 3.9.2+ | available on [github](https://github.com/adaptris/interlok-azure)
|com.adaptris | [interlok-cassandra][] | Interacting with Cassandra datastores | 3.8.0+ | available on [github](https://github.com/adaptris/interlok-cassandra)
|com.adaptris | ~~[interlok-cirrus-db-webapp][]~~ | ~~Provides access to the cirrus database for web applications~~ | 3.8.0+ | Now retired; you should have no need for this.
|com.adaptris | ~~[interlok-cirrus-db][]~~ | ~~Provides access to the cirrus database for adapter services~~ | 3.8.0+ | Now retired; you should have no need for this
|com.adaptris | ~~[interlok-cirrus-services][]~~ | ~~Provides Cirrus routing services; requires [interlok-licensing][]~~ | 3.8.0+ | Now retired; you should have no need for this
|com.adaptris | [interlok-client][] | Additional workflow support| 3.8.0+ | available on [github](https://github.com/adaptris/interlok)
|com.adaptris | [interlok-client-jmx][] | interact with workflows via JMX | 3.8.0+
|com.adaptris | ~~[interlok-config-conditional][]~~ | ~~Conditional branching and looping~~ | 3.7.3 - 3.8.4 only; merged into [interlok-core][] from 3.9.0 onwards | available on [github](https://github.com/adaptris/interlok-config-conditional)
|com.adaptris | [interlok-core-apt][] | [Custom annotations](developer-annotations.html)| 3.8.0+| available on [github](https://github.com/adaptris/interlok)
|com.adaptris | [interlok-core][] | The base Interlok framework | 3.8.0+ |available on [github](https://github.com/adaptris/interlok)
|com.adaptris | [interlok-csv][] | CSV operations, transforms etc. | 3.8.0+|available on [github](https://github.com/adaptris/interlok-csv)
|com.adaptris | [interlok-csv-json][] | Convert between CSV and JSON (requires both [interlok-json][] and [interlok-csv][]) | 3.6.6+|available on [github](https://github.com/adaptris/interlok-csv-json)
|com.adaptris | ~~[interlok-drools][]~~ | ~~Integration with JBoss Rules;~~ | 3.8.0+; deprecated in favour of [interlok-kie][]| available on [github](https://github.com/adaptris/interlok-drools)
|com.adaptris | [interlok-edi-legacy][] | Legacy support for EDI to XML transforms; requires [interlok-licensing][]| 3.8.0+
|com.adaptris | [interlok-edi-stream][] | Support for EDI to XML transforms; requires [interlok-licensing][]| 3.8.0+
|com.adaptris | [interlok-ehcache][] | Integration with ehcache as a cache provider | 3.8.0+ |  available on [github](https://github.com/adaptris/interlok-cache)
|com.adaptris | [interlok-elastic-common][] | Transport agnostic support for [interlok-elastic-rest][] - requires [interlok-csv][] | 3.9.1+ | available on [github](https://github.com/adaptris/interlok-elastic)
|com.adaptris | [interlok-elastic-rest][] | Integration with ElasticSearch via their high level REST client (requires [interlok-elastic-common][]) | 3.9.1+ | available on [github](https://github.com/adaptris/interlok-elastic)
|com.adaptris | ~~[interlok-elastic-search][]~~ | ~~Integration with ElasticSearch via the v2 API (requires [interlok-csv][])~~ | 3.4.1+; deprecated in favour of [interlok-elastic-rest][] | available on [github](https://github.com/adaptris/interlok-elasticsearch)
|com.adaptris | ~~[interlok-es5][]~~ | ~~Integration with ElasticSearch using v5 API (requires [interlok-csv][])~~ | 3.5.1+; deprecated in favour of [interlok-elastic-rest][] | available on [github](https://github.com/adaptris/interlok-es5)
|com.adaptris | ~~[interlok-es-rest][]~~ | ~~Integration with ElasticSearch via their high level REST client (requires [interlok-csv][])~~ | 3.8.0+; deprecated in favour of [interlok-elastic-rest][] | available on [github](https://github.com/adaptris/interlok-es-rest)
|com.adaptris | [interlok-expressions][] | Perform inline mathematic expressions | 3.6.4+ | available on [github](https://github.com/adaptris/interlok-expressions)
|com.adaptris | [interlok-excel][] | Extract data from an Excel spreadsheet | 3.8.0+
|com.adaptris | [interlok-exec][] | Management component executes arbitrary programs | 3.8.2+ | available on [github](https://github.com/adaptris/interlok-exec)
|com.adaptris | [interlok-filesystem][] | Services for interacting with the filesystem | 3.6.6+ | available on [github](https://github.com/adaptris/interlok-filesystem)
|com.adaptris | [interlok-failover][] | Simplified failover not dependent on AOP profiling | 3.4.0+
|com.adaptris | [interlok-flatfile][] | Flat file transformations; migrated from [interlok-core][] into its own optional component |3.9.0+ | available on [github](https://github.com/adaptris/interlok-flatfile)
|com.adaptris | [interlok-flyway][] | JdbcPooledConnection wrapper that includes flyway support |3.9.0+ | available on [github](https://github.com/adaptris/interlok-flyway)
|com.adaptris | [interlok-gcloud-pubsub][] | Connect to Google cloud pubsub (requires [interlok-oauth-gcloud][])|3.6.3+ | available on [github](https://github.com/adaptris/interlok-gcloud-pubsub)
|com.adaptris | ~~[interlok-hornetq][]~~ | ~~Connect to HornetQ JMS (will become obsolete as HornetQ is merged into ActiveMQ)~~ | 3.8.0+
|com.adaptris | [interlok-hpcc][] | Connect to [HPCC](http://www.hpccsystems.com)|3.6.1+ | available on [github](https://github.com/adaptris/interlok-hpcc)
|com.adaptris | [interlok-interfax][] | Integration with the Java FAX API; requires [interlok-licensing][]| 3.8.0+
|com.adaptris | [interlok-ironmq][] | Connect to IronMQ| 3.8.0+| you could use [interlok-aws-sqs][] in JMS mode.
|com.adaptris | [interlok-jclouds-blobstore][] | Use [Apache jclouds](https://jcloud.apache.org) to access your cloud storage |3.7.3+ | available on [github](https://github.com/adaptris/interlok-jclouds)
|com.adaptris | [interlok-jms-oracleaq][] | Connect to [Oracle via advanced queues](cookbook-oracleaq.html); requires additional jars not automatically delivered; requires [interlok-licensing][]| 3.8.0+
|com.adaptris | [interlok-jms-sonicmq][] | Connect to SonicMQ JMS; requires additional jars not automatically delivered; requires [interlok-licensing][]| 3.8.0+|
|com.adaptris | ~~[interlok-jmx-jms][]~~| Support for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | 3.8.0+; removed in 3.10.0|
|com.adaptris | [interlok-jmx-activemq][]| ActiveMQ Provider for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | 3.10+ | available on [github](https://github.com/adaptris/interlok-jmx-jms)
|com.adaptris | [interlok-jmx-amqp][]| AMQP Provider for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | 3.10+ | available on [github](https://github.com/adaptris/interlok-jmx-jms)
|com.adaptris | [interlok-jmx-jms-common][]| Provider neutral runtime support for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | 3.10+ | available on [github](https://github.com/adaptris/interlok-jmx-jms)
|com.adaptris | [interlok-jmx-solace][]| Solace Provider for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | 3.10+ | available on [github](https://github.com/adaptris/interlok-jmx-jms)
|com.adaptris | [interlok-jmx-sonicmq][]| SonicMQ Provider for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | 3.10+ |
|com.adaptris | [interlok-jruby][] | Tighter coupling with [jruby](http://jruby.org) as an alternative to [ScriptingService][]/[EmbeddedScriptingService][]|3.6.3+ | available on [github](https://github.com/adaptris/interlok-jruby)
|com.adaptris | [interlok-jsr107-cache][] | Cache implementation that wraps JSR107 cache implementations |3.8.0+ | available on [github](https://github.com/adaptris/interlok-cache)
|com.adaptris | [interlok-jq][] | JSON transformations using JQ-like syntax |3.7.0+ | available on [github](https://github.com/adaptris/interlok-jq)
|com.adaptris | [interlok-json][] | Transform JSON data to and from XML | 3.8.0+ |available on [github](https://github.com/adaptris/interlok-json)
|com.adaptris | [interlok-json-streaming][] | Transform JSON via a STaX like interface | 3.8.2+ |available on [github](https://github.com/adaptris/interlok-json-streaming)
|com.adaptris | [interlok-kafka][] | Connect to [Apache Kafka](http://kafka.apache.org/)| 3.8.0+|available on [github](https://github.com/adaptris/interlok-kafka)
|com.adaptris | [interlok-kie][] | Integration with the drools business rule management system from KIE group | 3.8.2+|available on [github](https://github.com/adaptris/interlok-kie)
|com.adaptris | [interlok-kubernetes-metrics][] | [Reporting metrics to kubernetes](advanced-interlok-scaling.html)| 3.9.1+|available on [github](https://github.com/adaptris/interlok-kubernetes)
|com.adaptris | [interlok-kubernetes-prometheus][] | [Reporting metrics to kubernetes](advanced-interlok-scaling.html)| 3.9.1+|available on [github](https://github.com/adaptris/interlok-kubernetes)
|com.adaptris | ~~[interlok-legacyhttp][]~~ | ~~servicing HTTP requests without Jetty (Java 7 Compatibile where base Interlok Version is)~~ | 3.6.4+; upgrade to Java 8 already! | available on [github](https://github.com/adaptris/interlok-legacyhttp)
|com.adaptris | [interlok-licensing][] | Enforces a license on certain components | 3.8.0+
|com.adaptris | [interlok-logging][] | Custom JMX Appender for [Log4j2](https://logging.apache.org/log4j) | | available on [github](https://github.com/adaptris/interlok)
|com.adaptris | [interlok-mail][] | Support for Email servers; migrated from [interlok-core][] into its own optional component | 3.9.0+ | available on [github](https://github.com/adaptris/interlok-mail)
|com.adaptris | [interlok-mongodb][] | Support for MongoDB | 3.7.2+ | available on [github](https://github.com/adaptris/interlok-mongodb)
|com.adaptris | [interlok-mqtt][] | Support for MQTT protocol | 3.5.1+ | available on [github](https://github.com/adaptris/interlok-mqtt)
|com.adaptris | [interlok-msmq][] | Connect to MSMQ via ActiveX; requires [interlok-licensing][]| 3.8.0+| Requires a 32bit JVM due to JNI.
|com.adaptris | [interlok-msmq-javonet][] | Connect to MSMQ via .NET - Requires a license from [javonet](https://www.javonet.com); requires [interlok-licensing][]|3.8.0+
|com.adaptris | [interlok-nats][] | Support for NATS.io | 3.9.3+ | available on [github](https://github.com/adaptris/interlok-nats)
|com.adaptris | [interlok-new-relic][] | Supports [New Relic Profiling](advanced-new-relic-profiling.html); requires [interlok-profiler][] | 3.8.0+
|com.adaptris | [interlok-oauth-azure][] | Retrieve OAUTH access tokens from MS Azure | 3.6.5+ | available on [github](https://github.com/adaptris/interlok-oauth)
|com.adaptris | [interlok-oauth-gcloud][] | Retrieve OAUTH access tokens from Google Cloud | 3.6.5+ | available on [github](https://github.com/adaptris/interlok-oauth); package move from [interlok-gcloud-pubsub][]
|com.adaptris | [interlok-oauth-salesforce][] | Retrieve OAUTH access tokens from Salesforce | 3.6.5+ | available on [github](https://github.com/adaptris/interlok-oauth)
|com.adaptris | [interlok-oftp][] | Support for OFTP as a transport protocol; requires [interlok-licensing][] | 3.8.0+|
|com.adaptris | [interlok-okhttp][] | HTTP Producer implementation using the OKHTTP client as the transport | 3.8.2+|available on [github](https://github.com/adaptris/interlok-okhttp)
|com.adaptris | [interlok-pdf][] | PDF Transformations| 3.8.0+
|com.adaptris | [interlok-pgp][] | Encrypt/Decrypt/Sign/Verify using PGP | 3.9.2+|available on [github](https://github.com/adaptris/interlok-pgp)
|com.adaptris | [interlok-profiler][] | Base package for supporting profiling (used by [interlok-new-relic][] and [interlok-profiler-prometheus][]) | 3.8.0+ | available on [github](https://github.com/adaptris/interlok-profiler)
|com.adaptris | [interlok-profiler-prometheus][] | [Interlok Prometheus profiling](advanced-profiler-prometheus.html) | 3.10.0+ | available on [github](https://github.com/adaptris/interlok-profiler-prometheus)
|com.adaptris | ~~[interlok-profiler-failover][]~~ | ~~Running an adapter in failover mode; requires [interlok-profiler][]~~| 3.8.0 only; removed in 3.8.1
|com.adaptris | ~~[interlok-restful-services][]~~ | ~~[Exposing Workflows as a RESTful service](adapter-hosting-rest.html)~~|3.8.0 to 3.8.2 only; removed in 3.8.3
|com.adaptris | [interlok-reliable-messaging][] | Support for ordered and reliable messaging; requires [interlok-licensing][] | 3.8.0+
|com.adaptris | [interlok-salesforce][] | Integration with Salesforce via WebServices (generally use their REST interface via HTTP/HTTPS instead); requires [interlok-licensing][] | 3.8.0+
|com.adaptris | [interlok-sap][] | Integration with SAP via [IDocs](cookbook-sap-idoc.html) or [RFC/BAPI](cookbook-sap-rfc.html); requires additional jars not automatically delivered; requires [interlok-licensing][] | 3.8.0+
|com.adaptris | ~~[interlok-schema][]~~ | ~~RelaxNG [schema validation](advanced-configuration-pre-processors.html#schema-validation) for Interlok configuration files~~ | 3.8.0+, deprecated since 3.9.0
|com.adaptris | [interlok-service-tester][] | Testing services as part of a CI pipeline | 3.5.0+ | available on [github](https://github.com/adaptris/interlok-service-tester)
|com.adaptris | [interlok-shell][] | Commandline runtime UI based on [CRaSH](http://www.crashub.org) | 3.4.1+|available on [github](https://github.com/adaptris/interlok-shell)
|com.adaptris | [interlok-socket][] | Vanilla Socket support; migrated from [interlok-core][] into its own component  | 3.7.0+ | available on [github](https://github.com/adaptris/interlok-socket)
|com.adaptris | [interlok-solace][] | Integration with Solace Systems as a JMS provider; requires additional jars not automatically delivered; requires [interlok-licensing][]| 3.8.0+
|com.adaptris | [interlok-sonicmf][] | Interlok runtime as [part of a Sonic Container](advanced-sonic-container.html) | 3.8.0+
|com.adaptris | [interlok-sshtunnel][] | Management component that opens one or more SSH tunnels | 3.7.1+ | available on [github](https://github.com/adaptris/interlok-sshtunnel)
|com.adaptris | ~~[interlok-stackify][]~~ | ~~Supports [Stackify Profiling](advanced-stackify-profiling.html); requires [interlok-profiler][]~~ |3.8.0 only, removed in 3.8.1|available on [github](https://github.com/adaptris/interlok-stackify)
|com.adaptris | [interlok-stax][] | Using the STaX API to read/write XML | 3.6.6+ | available on [github](https://github.com/adaptris/interlok-stax)
|com.adaptris | [interlok-stubs][] | [Test Scaffolding](developer-services.html#writing-tests) for developers |3.8.0+
|com.adaptris | [interlok-swift][] | Transform to and from the Swift message format; | 3.8.0+| available on [github](https://github.com/adaptris/interlok-swift). Does not require [interlok-licensing][] from 3.9.2+
|com.adaptris | [interlok-swiftmq][] | Connect to a SwiftMQ instance or any AMQP1.0 broker; [requires SwiftMQ Client Download](http://swiftmq.com/downloads/index.html); requires [interlok-licensing][]| 3.8.0+
|com.adaptris | [interlok-tibco][] | Connect to a Tibco instance; requires additional jars not automatically delivered; requires [interlok-licensing][]| 3.8.0+|
|com.adaptris | [interlok-triggered][] | Channels that can be started via an external trigger; requires [interlok-licensing][] | 3.8.0+
|com.adaptris | [interlok-varsub][] | [Variable substitution pre-processor](advanced-configuration-pre-processors.html#variable-substitution) | 3.8.0+|available on [github](https://github.com/adaptris/interlok-varsub)
|com.adaptris | [interlok-vcs-command-line][] | Interlok configuration hosted in a configurable VCS | 3.5.1+
|com.adaptris | [interlok-vcs-git][] | Interlok configuration [hosted in git](advanced-vcs-git.html) | 3.8.0+ | available on [github](https://github.com/adaptris/interlok-vcs-git)
|com.adaptris | [interlok-vcs-subversion][] | Interlok configuration [hosted in subversion](advanced-vcs-svn.html) | 3.8.0+
|com.adaptris | [interlok-vertx][] | [Clustered workflows and services](advanced-vertx.html) | 3.5.0+| No longer licensed since _3.8.0_; available on [github](https://github.com/adaptris/interlok-vertx)
|com.adaptris | [interlok-webservice-cxf][] | Accessing [external webservices](adapter-executing-ws.html)| 3.8.0+
|com.adaptris | [interlok-webservice-external][] | Accessing [external webservices](adapter-executing-ws.html); requires [interlok-licensing][] | 3.8.0+
|com.adaptris | [interlok-web-services][] | [Exposing workflows as webservices](adapter-hosting-ws.html); | 3.8.0+
|com.adaptris | [interlok-webspheremq][] | Connection to a [WebsphereMQ instance](cookbook-native-wmq.html); requires [interlok-licensing][] | 3.8.0+
|com.adaptris | [interlok-workflow-rest-services][] | [Exposing Workflows as a RESTful service](adapter-hosting-rest.html) | 3.8.3+|available on [github](https://github.com/adaptris/interlok-workflow-rest-services)
|com.adaptris | [interlok-xinclude][] | [XInclude pre-processor](advanced-configuration-pre-processors.html#xinclude)| 3.8.0+|available on [github](https://github.com/adaptris/interlok-xinclude)
|com.adaptris | ~~[interlok-xa][]~~ | ~~XA support within the Adapter; requires [interlok-licensing][]~~ | 3.4.0 - 3.8.4; removed in 3.9.0 | XA support was split into various sub modules; see below
|com.adaptris | [interlok-xa-activemq][] | ActiveMQ XA JMS Vendor implementaiton; requires [interlok-licensing][] | 3.9.0+
|com.adaptris | [interlok-xa-atomikos][] | XA support using Atomikos as the transaction manage; requires [interlok-licensing][] | 3.9.0+ | Use this artefact in conjunction one of the other supported providers
|com.adaptris | [interlok-xa-jms][] | XA/JMS support within the Adapter; requires [interlok-licensing][] | 3.9.0+
|com.adaptris | [interlok-xa-solace][] | Solace XA JMS Vendor implementaiton; requires [interlok-licensing][] | 3.9.0+
|com.adaptris | [interlok-xa-tibco][] | Tibco XA JMS Vendor implementaiton; requires [interlok-licensing][] | 3.9.0+
|com.adaptris | [interlok-xa-wmq][] | WebsphereMQ XA JMS Vendor implementaiton; requires [interlok-licensing][] | 3.9.0+
|com.adaptris | [interlok-xml-security][] | XML security (JSR 106); requires [interlok-licensing][] | 3.8.0+


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

Interlok comes automatically with some javadocs for its installed components. The javadocs file can be found into `${adapter.home}/docs/javadocs`.
You can access the javadocs by opening a browser at <http://localhost:8080/interlok/javadocs> if the adapter is started.

{% include note.html content="You will have to login into the Adapter UI to see the javadocs." %}

You can also see the javadocs for a specific component when using the settings modal in the UI config page by hovering the (i) icon near the setting name.

If the tooltip has `Help not found` it's most likely that the setting does not have any javadoc or the javadocs jar has not been added to `${adapter.home}/docs/javadocs`.

Optional components javadocs can be opened in two ways:

- **The javadocs are within a folder:** Open your browser at <http://localhost:8080/interlok/javadocs/optional/your-component/index.html> **e.g.** <http://localhost:8080/interlok/javadocs/optional/xml-security/index.html>.
- **The javadocs are in a jar file:** Open your browser at <http://localhost:8080/interlok/javadocs/your-component.jar/index.html> **e.g.** <http://localhost:8080/interlok/javadocs/optional/adp-swiftmq-3.0.3-RELEASE-javadoc.jar/index.html>.

If you've added an optional components following the steps explained above you can copy the javadocs jar file into `${adapter.home}/docs/javadocs` to be able to access it via the browser. You will have to restart your adapter to be able to access the javadocs.

## Optional Components prior to 3.7.3 ##

In release 3.8.0; we renamed all the artefacts so that they consistently started with `interlok-`; the list of associated artefacts that were renamed is listed below.

| GroupID | ArtifactID | Description | Versions | Notes
|----|----|----|----|----|
|com.adaptris | [adp-actional-interceptor][] | Instrumentation of the adapter with Actional Management Server; requires additional jars not automatically delivered | until 3.7.3|  _since 3.8.0_ use [interlok-actional-interceptor][] instead.
|com.adaptris | [adp-actional-stabiliser][] | Services that interact with the Actional Stabiliser Switch; requires additional jars not automatically delivered; requires [adp-licensing][] - This is compiled against Actional 8.2 and may not work with the latest versions of actional if running outside of a Sonic container (the jars are no longer available)| until 3.7.3 | _since 3.8.0_ use [interlok-actional-stabiliser][] instead|
|com.adaptris | [adp-amazon-sqs][] | Connect to Amazon SQS either using their JMS compatibility layer or directly| 3.0.3 to 3.2.1
|com.adaptris | [adp-amqp][] | Connect to a AMQP 0.9 / 1.0 provider | until 3.7.3 | _since 3.8.0_ use [interlok-amqp][] instead.|
|com.adaptris | [adp-apache-http][] | HTTP Producer implementation using the Apache HTTP client as the transport | 3.0.5 - 3.7.3 | _since 3.8.0_ use [interlok-apache-http][] instead
|com.adaptris | [adp-as2][] | Provides AS2 messaging support; requires [adp-licensing][] | until 3.7.3|  _since 3.8.0_ use [interlok-as2][] instead |
|com.adaptris | [adp-cirrus-db-webapp][] | Provides access to the cirrus database for web applications | until 3.7.3|   _since 3.8.0_ use [interlok-cirrus-db-webapp][] instead|
|com.adaptris | [adp-cirrus-db][] | Provides access to the cirrus database for adapter services | until 3.7.3|_since 3.8.0_ use [interlok-cirrus-db][] instead|
|com.adaptris | [adp-cirrus-services][] | Provides Cirrus routing services; requires [adp-licensing][] |  until 3.7.3 |_since 3.8.0_ use [interlok-cirrus-services][] instead|
|com.adaptris | [adp-core-apt][] | [Custom annotations](developer-annotations.html)| until 3.7.3| available on [github](https://github.com/adaptris/interlok);  _since 3.8.0_ use [interlok-core-apt][] instead
|com.adaptris | [adp-core][] | The base Interlok framework | until 3.7.3 | available on [github](https://github.com/adaptris/interlok);  _since 3.8.0_ use [interlok-core][] instead.
|com.adaptris | [adp-drools][] | Integration with JBoss Rules; | until 3.7.3 | does not require [adp-licensing][] from 3.3.0;  _since 3.8.0_ use [interlok-drools][] instead.
|com.adaptris | [adp-edi-legacy][] | Legacy v2.x style EDI Transforms; requires [adp-licensing][]| until 3.7.3 |  _since 3.8.0_ use [interlok-edi-legacy][] instead.
|com.adaptris | [adp-edi-stream][] | Stream based EDI transformations; requires [adp-licensing][]| until 3.7.3|  _since 3.8.0_ use [interlok-edi-stream][] instead
|com.adaptris | [adp-ehcache][] | Integration with ehcache as a message store| until 3.7.3 | does not require [adp-licensing][] since 3.3.0;  _since 3.8.0_ use [interlok-ehcache][] instead.
|com.adaptris | [adp-failover][] | Running an adapter in failover mode; requires [adp-profiler][]| until 3.7.3 |  _since 3.8.0_ use [interlok-profiler-failover][] instead.
|com.adaptris | [adp-fop][] | PDF Transformations| until 3.7.3 | does not require [adp-licensing][] from 3.3.0;  _since 3.8.0_ use [interlok-pdf][] instead.
|com.adaptris | [adp-hornetq][] | Connect to HornetQ JMS (will become obsolete as HornetQ is merged into ActiveMQ) | until 3.7.3 |  _since 3.8.0_ use [interlok-hornetq][] instead.
|com.adaptris | [adp-hpcc][] | Connect to [HPCC](http://www.hpccsystems.com)|3.3.0 - 3.6.0 only
|com.adaptris | [adp-interfax][] | Integration with the Java FAX API; requires [adp-licensing][]| until 3.7.3 |  _since 3.8.0_ use [interlok-interfax][] instead.
|com.adaptris | [adp-ironmq][] | Connect to IronMQ| until 3.7.3 |does not require [adp-licensing][] from 3.3.0;  _since 3.8.0_ use [interlok-ironmq][] instead or [interlok-aws-sqs][] in JMS mode.
|com.adaptris | [adp-jms-oracleaq][] | Connect to [Oracle via advanced queues](cookbook-oracleaq.html); requires additional jars not automatically delivered; ; requires [adp-licensing][]| until 3.7.3|  _since 3.8.0_ use [interlok-jms-oracleaq][] instead.
|com.adaptris | [adp-jms-sonicmq][] | Connect to SonicMQ JMS; ; requires [adp-licensing][]| until 3.7.3 |  _since 3.8.0_ use [interlok-jms-sonicmq][] instead.
|com.adaptris | [adp-jmx-jms][] | Support for [JMX via JMS or AMQP 1.0](advanced-jmx-jms.html) | until 3.7.3 |  _since 3.8.0_ use [interlok-jmx-jms][] instead.
|com.adaptris | [adp-json][] | Transform JSON data to and from XML | until 3.7.3 |  _since 3.8.0_ use [interlok-json][] instead.
|com.adaptris | [adp-kafka][] | Connect to [Apache Kafka](http://kafka.apache.org/)|3.2.1-3.7.3|  _since 3.8.0_ use [interlok-kafka][] instead.
|com.adaptris | [adp-licensing][] | Enforces a license on certain components | until 3.7.3|  _since 3.8.0_ use [interlok-licensing][] instead.
|com.adaptris | [adp-msmq][] | Connect to MSMQ via ActiveX; requires [adp-licensing][]| until 3.7.3 |  _since 3.8.0_ use [interlok-msmq][] instead. Requires a 32bit JVM due to JNI.
|com.adaptris | [adp-msmq-javonet][] | Connect to MSMQ via .NET - Requires a license from [javonet](https://www.javonet.com); requires [adp-licensing][]|3.0.6-3.7.3|  _since 3.8.0_ use [interlok-msmq-javonet][]
|com.adaptris | [adp-new-relic][] | Supports [New Relic Profiling](advanced-new-relic-profiling.html); requires [adp-profiler][] | until 3.7.3 |  _since 3.8.0_ use [interlok-new-relic][]
|com.adaptris | [adp-oftp][] | Support for OFTP as a transport protocol; requires [adp-licensing][] | until 3.7.3 |  _since 3.8.0_ use [interlok-oftp][] instead.
|com.adaptris | [adp-poi][] | Extract data from an Excel spreadsheet | until 3.7.3|  _since 3.8.0_ use [interlok-excel][] instead.
|com.adaptris | [adp-profiler][] | Base package for supporting profiling (used by [adp-new-relic][] and [adp-stackify][]) | until 3.7.3 |  _since 3.8.0_ use [interlok-profiler][] instead.
|com.adaptris | [adp-restful-services][] | [Exposing Workflows as a RESTful service](adapter-hosting-rest.html)|3.0.6 - 3.7.3 |  _since 3.8.0_ use [interlok-restful-services][] instead
|com.adaptris | [adp-reliable-messaging][] | Support for ordered and reliable messaging; requires [adp-licensing][] | until 3.7.3 |  _since 3.8.0_ use [interlok-reliable-messaging][] instead
|com.adaptris | [adp-salesforce][] | Integration with Salesforce via WebServices (generally use their REST interface via HTTP/HTTPS instead); requires [adp-licensing][] | until 3.7.3 |  _since 3.8.0_ use [interlok-salesforce][] instead
|com.adaptris | [adp-sap][] | Integration with SAP via [IDocs](cookbook-sap-idoc.html) or [RFC/BAPI](cookbook-sap-rfc.html); requires additional jars not automatically delivered; requires [adp-licensing][] | until 3.7.3 |  _since 3.8.0_ use [interlok-sap][] instead.
|com.adaptris | [adp-schema][] | RelaxNG [schema validation](advanced-configuration-pre-processors.html#schema-validation) for Interlok configuration files | until 3.7.3 |  _since 3.8.0_ use [interlok-schema][] instead.
|com.adaptris | [adp-simple-csv][] | Transform a CSV file to XML | until 3.7.3 |  _since 3.8.0_ use [interlok-csv][] instead.
|com.adaptris | [adp-solace][] | Integration with Solace Systems as a JMS provider; requires additional jars not automatically delivered; requires [adp-licensing][]| until 3.7.3 |  _since 3.8.0_ use [interlok-solace][] instead.
|com.adaptris | [adp-sonicmf][] | Interlok runtime as [part of a Sonic Container](advanced-sonic-container.html) | until 3.7.3 |  _since 3.8.0_ use [interlok-sonicmf][] instead.
|com.adaptris | [adp-stackify][] | Supports [Stackify Profiling](advanced-stackify-profiling.html); requires [adp-profiler][] | until 3.7.3 |  _since 3.8.0_ use [interlok-stackify][] instead.
|com.adaptris | [adp-stubs][] | [Test Scaffolding](developer-services.html#writing-tests) for developers | until 3.7.3|  _since 3.8.0_ use [interlok-stubs][] instead.
|com.adaptris | [adp-swift][] | Transform to and from the Swift message format; requires [adp-licensing][] | until 3.7.3|  _since 3.8.0_ use [interlok-swift][] instead.
|com.adaptris | [adp-swiftmq][] | Connect to a SwiftMQ instance or any AMQP1.0 broker; [requires SwiftMQ Client Download](http://swiftmq.com/downloads/index.html); requires [adp-licensing][]| until 3.7.3 |  _since 3.8.0_ use [interlok-swiftmq][] instead.
|com.adaptris | [adp-tibco][] | Connect to a Tibco instance; requires additional jars not automatically delivered; requires [adp-licensing][]| until 3.7.3|  _since 3.8.0_ use use [interlok-tibco][] instead.
|com.adaptris | [adp-triggered][] | Channels that can be started via an external trigger; requires [adp-licensing][] | until 3.7.3 |  _since 3.8.0_ use [interlok-triggered][] instead
|com.adaptris | [adp-varsub][] | [Variable substitution pre-processor](advanced-configuration-pre-processors.html#variable-substitution) | until 3.7.3|  _since 3.8.0_ use [interlok-varsub][] instead.
|com.adaptris | [adp-vcs-git][] | Interlok configuration [hosted in git](advanced-vcs-git.html) | 3.0.3 - 3.7.3 |  _since 3.8.0_ use [interlok-vcs-git][] instead.
|com.adaptris | [adp-vcs-subversion][] | Interlok configuration [hosted in subversion](advanced-vcs-svn.html) | 3.0.2 - 3.7.3 |  _since 3.8.0_ use [interlok-vcs-subversion][] instead.
|com.adaptris | [adp-webservice-cxf][] | Accessing [external webservices](adapter-executing-ws.html)| 3.2.1-3.7.3 |  _since 3.8.0_ use [interlok-webservice][] instead.
|com.adaptris | [adp-webservice-external][] | Accessing [external webservices](adapter-executing-ws.html); requires [adp-licensing][] | until 3.7.3|  _since 3.8.0_ use [interlok-webservice-external][] instead.
|com.adaptris | [adp-webservice-internal][] | [Exposing workflows as webservices](adapter-hosting-ws.html)| 3.0.0 - 3.0.5|
|com.adaptris | [adp-web-services][] | [Exposing workflows as webservices](adapter-hosting-ws.html); | 3.0.6 - 3.7.3 |  _since 3.8.0_ use [interlok-web-services][] instead.
|com.adaptris | [adp-webspheremq][] | Connection to a [WebsphereMQ instance](cookbook-native-wmq.html); requires [adp-licensing][] | until 3.7.3|  _since 3.8.0_ use interlok-webspheremq instead
|com.adaptris | [adp-xinclude][] | [XInclude pre-processor](advanced-configuration-pre-processors.html#xinclude)| until 3.7.3 |  _since 3.8.0_ use [interlok-xinclude][] instead
|com.adaptris | [adp-xml-security][] | XML security (JSR 106); requires [adp-licensing][] | until 3.7.3 |  _since 3.8.0_ use [interlok-xml-security][] instead.


[adp-amazon-sqs]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-amazon-sqs/
[adp-amqp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-amqp/
[interlok-amqp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-amqp/
[adp-apache-http]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-apache-http/
[interlok-apache-http]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-apache-http/
[adp-as2]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-as2/
[interlok-as2]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-as2/
[adp-cirrus-db-webapp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-cirrus-db-webapp/
[interlok-cirrus-db-webapp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-cirrus-db-webapp/
[adp-cirrus-db]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-cirrus-db/
[interlok-cirrus-db]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-cirrus-db/
[adp-cirrus-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-cirrus-services/
[interlok-cirrus-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-cirrus-services/
[adp-core-apt]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-core-apt/
[interlok-core-apt]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-core-apt/
[adp-core]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-core/
[interlok-core]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-core/
[adp-drools]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-drools/
[interlok-drools]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-drools/
[adp-edi-legacy]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-edi-legacy/
[interlok-edi-legacy]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-edi-legacy/
[adp-edi-stream]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-edi-stream/
[interlok-edi-stream]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-edi-stream/
[adp-ehcache]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-ehcache/
[interlok-ehcache]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-ehcache/
[adp-fop]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-fop/
[interlok-pdf]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-pdf/
[adp-hornetq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-hornetq/
[interlok-hornetq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-hornetq/
[adp-interfax]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-interfax/
[interlok-interfax]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-interfax/
[adp-ironmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-ironmq/
[interlok-ironmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-ironmq/
[adp-jms-oracleaq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-jms-oracleaq/
[interlok-jms-oracleaq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jms-oracleaq/
[adp-jms-sonicmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-jms-sonicmq/
[interlok-jms-sonicmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jms-sonicmq/
[adp-jmx-jms]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-jmx-jms/
[interlok-jmx-jms]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jmx-jms/
[adp-json]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-json/
[interlok-json]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-json/
[adp-msmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-msmq/
[interlok-msmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-msmq/
[adp-new-relic]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-new-relic/
[interlok-new-relic]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-new-relic/
[adp-oftp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-oftp/
[interlok-oftp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-oftp/
[adp-poi]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-poi/
[interlok-excel]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-excel/
[adp-profiler]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-profiler/
[interlok-profiler]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-profiler/
[interlok-profiler-prometheus]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-profiler-prometheus/
[adp-reliable-messaging]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-reliable-messaging/
[interlok-reliable-messaging]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-reliable-messaging/
[adp-salesforce]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-salesforce/
[interlok-salesforce]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-salesforce/
[adp-sap]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-sap/
[interlok-sap]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-sap/
[adp-schema]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-schema/
[interlok-schema]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-schema/
[adp-simple-csv]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-simple-csv/
[interlok-csv]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-csv/
[adp-sonicmf]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-sonicmf/
[interlok-sonicmf]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-sonicmf/
[adp-stackify]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-stackify/
[interlok-stackify]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-stackify/
[adp-stubs]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-stubs/
[interlok-stubs]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-stubs/
[adp-swift]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-swift/
[interlok-swift]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-swift/
[adp-swiftmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-swiftmq/
[interlok-swiftmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-swiftmq/
[adp-tibco]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-tibco/
[interlok-tibco]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-tibco/
[adp-triggered]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-triggered/
[interlok-triggered]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-triggered/
[adp-varsub]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-varsub/
[interlok-varsub]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-varsub/
[adp-vcs-subversion]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-vcs-subversion/
[interlok-vcs-subversion]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-vcs-subversion/
[adp-vcs-git]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-vcs-git/
[interlok-vcs-git]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-vcs-git/
[adp-webservice-cxf]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-webservice-cxf/
[interlok-webservice-cxf]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-webservice-cxf/
[adp-webservice-external]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-webservice-external/
[interlok-webservice-external]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-webservice-external/
[adp-webservice-internal]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-webservices-internal/
[interlok-webservice-internal]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-webservices-internal/
[adp-webspheremq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-webspheremq/
[interlok-webspheremq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-webspheremq/
[adp-xinclude]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-xinclude/
[interlok-xinclude]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xinclude/
[adp-xml-security]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-xml-security/
[interlok-xml-security]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xml-security/
[adp-solace]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-solace/
[interlok-solace]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-solace/
[adp-actional-interceptor]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-actional-interceptor/
[interlok-actional-interceptor]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-actional-interceptor/
[adp-actional-stabiliser]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-actional-stabiliser/
[interlok-actional-stabiliser]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-actional-stabiliser/
[adp-msmq-javonet]:  https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-msmq-javonet/
[interlok-msmq-javonet]:  https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-msmq-javonet/
[adp-web-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-web-services/
[interlok-web-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-web-services/
[adp-restful-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-restful-services/
[interlok-restful-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-restful-services/
[adp-kafka]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-kafka/
[interlok-kafka]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-kafka/
[adp-licensing]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-licensing/
[interlok-licensing]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-licensing/
[adp-failover]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-failover/
[interlok-profiler-failover]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-profiler-failover/
[interlok-aws-sqs]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-aws-sqs/
[interlok-aws-s3]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-aws-s3/
[interlok-aws-common]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-aws-common/
[adp-hpcc]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/adp-hpcc/
[interlok-elastic-search]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-elastic-search/
[interlok-es5]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-es5/
[interlok-failover]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-failover/
[interlok-shell]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-shell/
[interlok-xa]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa/
[interlok-service-tester]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-service-tester/
[interlok-vertx]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-vertx/
[interlok-vcs-command-line]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-vcs-command-line/
[interlok-mqtt]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-mqtt/
[interlok-hpcc]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-hpcc/
[interlok-jruby]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jruby/
[interlok-gcloud-pubsub]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-gcloud-pubsub/
[ScriptingService]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/services/ScriptingService.html
[EmbeddedScriptingService]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.10-SNAPSHOT/com/adaptris/core/services/EmbeddedScriptingService.html
[interlok-expressions]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-expressions/
[interlok-legacyhttp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-legacyhttp/
[interlok-activemq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-activemq/
[interlok-oauth-salesforce]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-oauth-salesforce/
[interlok-oauth-azure]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-oauth-azure/
[interlok-oauth-gcloud]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-oauth-gcloud/
[interlok-csv-json]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-csv-json/
[interlok-jq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jq/
[interlok-sshtunnel]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-sshtunnel/
[interlok-filesystem]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-filesystem/
[interlok-aws-sns]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-aws-sns/
[interlok-aws-kinesis]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-aws-kinesis/
[interlok-stax]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-stax/
[interlok-jclouds-blobstore]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jclouds-blobstore/
[interlok-config-conditional]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-config-conditional
[interlok-mongodb]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-mongodb
[interlok-socket]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-socket
[interlok-logging]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-logging
[interlok-es-rest]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-es-rest
[interlok-jsr107-cache]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jsr107-cache
[interlok-kie]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-kie
[interlok-okhttp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-okhttp
[interlok-workflow-rest-services]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-workflow-rest-services
[interlok-flatfile]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-flatfile
[interlok-mail]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-mail
[interlok-exec]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-exec
[interlok-json-streaming]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-json-streaming
[interlok-flyway]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-flyway
[interlok-artemis]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-artemis
[interlok-xa-activemq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa-activemq
[interlok-xa-atomikos]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa-atomikos
[interlok-xa-jms]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa-jms
[interlok-xa-solace]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa-solace
[interlok-xa-tibco]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa-tibco
[interlok-xa-wmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-xa-wmq
[interlok-elastic-rest]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-elastic-rest
[interlok-elastic-common]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-elastic-common
[interlok-kubernetes-metrics]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-kubernetes-metrics
[interlok-kubernetes-prometheus]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-kubernetes-prometheus
[interlok-pgp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-pgp
[interlok-azure-cosmosdb]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-azure-cosmosdb
[interlok-client-jmx]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-client-jmx
[interlok-client]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-client
[interlok-cassandra]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-cassandra
[interlok-edi-legacy]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-edi-legacy
[interlok-edi-stream]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-edi-stream
[interlok-nats]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-nats
[interlok-jmx-activemq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jmx-activemq
[interlok-jmx-amqp]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jmx-amqp
[interlok-jmx-jms-common]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jmx-jms-common
[interlok-jmx-solace]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jmx-solace
[interlok-jmx-sonicmq]: https://nexus.adaptris.net/nexus/content/groups/interlok/com/adaptris/interlok-jmx-sonicmq
