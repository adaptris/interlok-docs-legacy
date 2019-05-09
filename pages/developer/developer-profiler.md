---
title: Interlok Performance profiling
keywords: interlok
tags: [developer]
sidebar: home_sidebar
permalink: developer-profiler.html
---

This page explains how to setup Interlok to collect runtime performance based metrics, how to process them and where to store them for later analysis.

## Overview ##
* The profiler is attached to the java process via the jvm startup process via command line args and optional jars.

* The profiler will emit a UDP event for each message processed that gives the processing time and msg count for each of the executed services.

* The profiler relies on each component in your config having a unique name. Duplicate names will clearly give inaccurate results

## Setting up ##
The following steps are required to configure your Interlok instance to generate profiler statistics.

1.  Add in the following additional jars into the interlok lib folder:
    * from the interlok-profiler project add in the generated jar artifact along with its runtime dependencies
      * aspectjrt 1.9.2
      * aspectjweaver 1.9.2
      * aspectjtools 1.9.2

    * from the interlok-monitor-agent add in the generated jar artifact along with the following runtime dependencies
      * org.apache.commons:commons-collections4 4.2
      * com.google.code.gson:gson 1.4
    * from the interlok-profiler-metric-services add in the generated jar artifact along with the following runtime dependencies
      * groovy-all 2.4.5


2.  Add in the following config file into the Interlok config directory
    * create a file called interlok-profiler.properties with the following settings:

      > com.adaptris.profiler.plugin.factory=com.adaptris.monitor.agent.InterlokMonitorPluginFactory
      > com.adaptris.monitor.agent.EventPropagator=MULTICAST
	  {: title="Configuration File"}

3.  Update Interlok to have a startup command like the following:

    > java -Dorg.aspectj.weaver.loadtime.configuration=META-INF/profiler-aop.xml -javaagent:%ADAPTRIS_HOME%\lib\aspectjweaver.jar –jar interlok-boot.jar
	{: title="Startup options"}

## Associated projects ##
* [Interlok profiler](https://github.com/adaptris/interlok-profiler), this is the main interlok profiler project that uses AOP to capture the performance statistics of the running adapter.

* [Interlok monitor agent](https://bitbucket.org/adaptris/interlok-monitor-agent), this project allows the profile emitted events to be captured and transformed into a suitable form.

* [Interlok profiler metric services](https://github.com/adaptris/interlok-profiler-metric-services), is a collection of services that allow the transformation of the raw metrics message to other formats.

## Sample Capture Interlok Configs ##

### Writing the metrics to Elasticsearch ###

Elastic search is a great tool for data collection and analysis and the following Adapter Channel demonstrates how the metrics can be captured and exported into Elasticsearch via its REST interface

```xml
<channel>
	<unique-id>performance-metrics-channel</unique-id>
	<consume-connection class="com.adaptris.monitor.agent.UDPConnection">
		<unique-id>udp-connection</unique-id>
		<port>5577</port>
		<group>224.0.0.4</group>
	</consume-connection>

	<produce-connection class="null-connection"/>

	<workflow-list>
		<standard-workflow>
			<unique-id>main-metric-workflow</unique-id>

			<consumer class="com.adaptris.monitor.agent.UDPProfilerConsumer">
				<unique-id>udp-profile-consumer</unique-id>
				<poller class="com.adaptris.monitor.agent.UDPPoller">
				</poller>
			</consumer>

			<service-collection class="service-list">
				<unique-id>main-metric-service-list</unique-id>
				<services>
					<log-message-service>
						<unique-id>log-initial-performance-request-log</unique-id>
						<log-level>INFO</log-level>
						<include-payload>true</include-payload>
					</log-message-service>

					<service class="com.adaptris.json2csv.MetricsToElasticsearchBulkService">
						<unique-id>metrics-json-to-csv-service</unique-id>
						<index-name>profilermetrics</index-name>
						<type-name>default</type-name>
						<channel-include-patterns>
							<string>firco-filter-clink-request-processing-channel</string>
						</channel-include-patterns>
						<channel-exclude-patterns>
							<string>performance-metrics-channel</string>
						</channel-exclude-patterns>
					</service>
					
					<log-message-service>
						<unique-id>log-converted-performance-log</unique-id>
						<log-level>INFO</log-level>
						<include-payload>true</include-payload>
					</log-message-service>
					
					<apache-http-request-service>
						<unique-id>HttpRequestService-2836156</unique-id>
						<url>http://localhost:9200/_bulk</url>
						<content-type>application/json</content-type>
						<method>POST</method>
						<response-header-handler class="apache-http-discard-response-headers"/>
						<request-header-provider class="apache-http-no-request-headers"/>
						<authenticator class="http-no-authentication"/>
					</apache-http-request-service>

					<log-message-service>
						<unique-id>final-metrics-log-service</unique-id>
						<log-level>INFO</log-level>
					</log-message-service>
				</services>
			</service-collection>
			
			<producer class="null-message-producer"/>

			<produce-exception-handler class="null-produce-exception-handler"/>

			<message-metrics-interceptor>
				<unique-id>CommitResponseTest-MessageMetrics</unique-id>
				<timeslice-duration>
					<unit>MINUTES</unit>
					<interval>5</interval>
				</timeslice-duration>
				<timeslice-history-count>12</timeslice-history-count>
			</message-metrics-interceptor>
		</standard-workflow>
	</workflow-list>
	<auto-start>true</auto-start>
</channel>
```

### Writing the metrics to a csv file ###

Writing the metrics to a csv file which can later be imported into another tool offers a flexible solution. The file can be imported into Excel and various charts can also be generated.

```xml
<channel>
	<unique-id>performance-metrics-channel</unique-id>
	<consume-connection class="com.adaptris.monitor.agent.UDPConnection">
		<unique-id>udp-connection</unique-id>
		<port>5577</port>
		<group>224.0.0.4</group>
	</consume-connection>


	<produce-connection class="null-connection"/>

	<workflow-list>
		<standard-workflow>
			<unique-id>main-metric-workflow</unique-id>

			<consumer class="com.adaptris.monitor.agent.UDPProfilerConsumer">
				<unique-id>udp-profile-consumer</unique-id>
				<poller class="com.adaptris.monitor.agent.UDPPoller">
				</poller>
			</consumer>

			<service-collection class="service-list">
				<unique-id>main-metric-service-list</unique-id>
				<services>

					<log-message-service>
						<unique-id>log-initial-performance-request-log</unique-id>
						<log-level>INFO</log-level>
						<include-payload>true</include-payload>
					</log-message-service>

					<service class="com.adaptris.json2csv.MetricsToCSVService">
						<unique-id>metrics-json-to-csv-service</unique-id>
						<channel-include-patterns>
							<string>firco-filter-clink-request-processing-channel</string>
						</channel-include-patterns>
						<channel-exclude-patterns>
							<string>performance-metrics-channel</string>
						</channel-exclude-patterns>
					</service>

					<log-message-service>
						<unique-id>final-metrics-log-service</unique-id>
						<log-level>INFO</log-level>
					</log-message-service>
				</services>
			</service-collection>
			
			<producer class="fs-producer">
				<destination class="configured-produce-destination">
					<destination>output</destination>
				</destination>
				<create-dirs>true</create-dirs>
				<fs-worker class="fs-append-file"/>
				<filename-creator class="formatted-filename-creator">
					<filename-format>performance-metrics.csv</filename-format>
				</filename-creator>
			</producer>

			<produce-exception-handler class="null-produce-exception-handler"/>

			<message-metrics-interceptor>
				<unique-id>CommitResponseTest-MessageMetrics</unique-id>
				<timeslice-duration>
					<unit>MINUTES</unit>
					<interval>5</interval>
				</timeslice-duration>
				<timeslice-history-count>12</timeslice-history-count>
			</message-metrics-interceptor>
		</standard-workflow>
	</workflow-list>
	<auto-start>true</auto-start>
</channel>
```

## Transforming the JSON ##

Sometimes you may wish to manipulate the JSON message according to your requirements. One of the custom metrics services flattens out the hierarchical structure so that each record contains the full hierarchical names.

```xml
<channel>
	<unique-id>performance-metrics-channel</unique-id>
	<consume-connection class="com.adaptris.monitor.agent.UDPConnection">
		<unique-id>udp-connection</unique-id>
		<port>5577</port>
		<group>224.0.0.4</group>
	</consume-connection>


	<produce-connection class="null-connection"/>

	<workflow-list>
		<standard-workflow>
			<unique-id>main-metric-workflow</unique-id>

			<consumer class="com.adaptris.monitor.agent.UDPProfilerConsumer">
				<unique-id>udp-profile-consumer</unique-id>
				<poller class="com.adaptris.monitor.agent.UDPPoller">
				</poller>
			</consumer>

			<service-collection class="service-list">
				<unique-id>main-metric-service-list</unique-id>
				<services>

					<log-message-service>
						<unique-id>log-initial-performance-request-log</unique-id>
						<log-level>INFO</log-level>
						<include-payload>true</include-payload>
					</log-message-service>

					<service class="com.adaptris.json2csv.MetricsToFlatJsonService">
						<unique-id>metrics-json-to-csv-service</unique-id>
						<index-name>profilermetrics</index-name>
						<type-name>default</type-name>
						<channel-include-patterns>
							<string>firco-filter-clink-request-processing-channel</string>
						</channel-include-patterns>

						<channel-exclude-patterns>
							<string>performance-metrics-channel</string>
						</channel-exclude-patterns>
					</service>

					<!-- add json transformations here -->
					
					<log-message-service>
						<unique-id>final-metrics-log-service</unique-id>
						<log-level>INFO</log-level>
					</log-message-service>
				</services>
			</service-collection>
			
			<producer class="null-message-producer"/>
			
			<produce-exception-handler class="null-produce-exception-handler"/>

			<message-metrics-interceptor>
				<unique-id>CommitResponseTest-MessageMetrics</unique-id>
				<timeslice-duration>
					<unit>MINUTES</unit>
					<interval>5</interval>
				</timeslice-duration>
				<timeslice-history-count>12</timeslice-history-count>
			</message-metrics-interceptor>
		</standard-workflow>
	</workflow-list>
	<auto-start>true</auto-start>
</channel>
```

