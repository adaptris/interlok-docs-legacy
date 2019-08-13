---
title: Split and Aggregate
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-split-join.html
summary: Many messages passing through Interlok will consist of multiple elements. Often you will get a batch of messages (popular if you're a heavy EDI user); but each message needs to be handled individually. However your use-case means that you still need to aggregate the results of the processing in some fashion.
---

[split-join-service][] is similar to the [advanced-message-splitter-service][] in that you specify an arbitrary set of services to apply to each split message; however, rather than processing them sequentially, the split messages are processed concurrently, and then the results of the processing captured and merged using your specified [MessageAggregator][] implementation.

## Splitter Implementations ##

The standard implementations of [MessageSplitter][] are the same as described in the [Splitting Messages](cookbook-splitting-messages.html#splitter-implementations) document.

## Aggregator implementations ##

The standard implementations of [MessageAggregator][] are the same as described in the [Aggregating Messages](cookbook-aggregating-messages.html#aggregator-implementations) document.


## Example ##

We have an example document, that needs to be split on a XPath _/envelope/input/document_; a transform needs to be executed on each document created; and the results captured back into the original document as an `output` element.

```xml
<envelope>
  <input>
    <document>
      <data>The quick brown fox jumps over the lazy dog.</data>
    </document>
    <document>
      <data>Quick zephyrs blow, vexing daft Jim.</data>
    </document>
    <document>
      <data>Pack my box with a dozen liqour jugs.</data>
    </document>
    <document>
      <data>How quickly daft jumping zebras vex.</data>
    </document>
  </input>
</envelope>
```

Our example configuration would be

```xml
<split-join-service>
 <service class="service-list">
  <services>
    <xml-transform-service>
     <url>http://www.example.com/my/transform.xsl</url>
     <xml-transformer-factory class="xslt-transformer-factory"/>
    </xml-transform-service>
  </services>
 </service>
 <splitter class="xpath-message-splitter">
  <xpath>/envelope/input/document</xpath>
  <encoding>UTF-8</encoding>
 </splitter>
 <aggregator class="xml-document-aggregator">
  <merge-implementation class="xml-insert-node">
   <xpath-to-parent-node>/envelope/output</xpath-to-parent-node>
  </merge-implementation>
 </aggregator>
</split-join-service>
```

And the output (the transform just swaps the `data` element to be `verified`)

```xml
<envelope>
  <input>
    <document>
      <data>The quick brown fox jumps over the lazy dog.</data>
    </document>
    <document>
      <data>Quick zephyrs blow, vexing daft Jim.</data>
    </document>
    <document>
      <data>Pack my box with a dozen liqour jugs.</data>
    </document>
    <document>
      <data>How quickly daft jumping zebras vex.</data>
    </document>
  </input>
  <output>
    <document>
      <verified>The quick brown fox jumps over the lazy dog.</verified>
    </document>
    <document>
      <verified>Quick zephyrs blow, vexing daft Jim.</verified>
    </document>
    <document>
      <verified>Pack my box with a dozen liqour jugs.</verified>
    </document>
    <document>
      <verified>How quickly daft jumping zebras vex.</verified>
    </document>
  </output>
</envelope>
```

## Filtering messages ##

As of Interlok v3.9.1B the aggregator classes feature a filter that allows you to select which messages qualify to be merged. This is especially useful when processing a list of records as it effectively implements the filter pipeline integration pattern.

The filter functionality makes use of the recently added Condition and Operator classes.

The following config snippet configures the json array aggregator to only merge those messages that have a metadata element that is equal to "false":

```xml
<aggregator class="json-array-aggregator">
	<filter-condition class="metadata">
		<operator class="equals">
			<value>false</value>
		</operator>
		<metadata-key>IsDeleted</metadata-key>
	</filter-condition>
</aggregator>
```

Conditionals can be grouped together such as the following which states that only those messages that are not empty and who have a deleted metadata item equal to "false" should merged:

```xml
<aggregator class="json-array-aggregator">
	<filter-condition class="and">
		<not>
			<condition class="payload">
				<operator class="is-empty"/>
			</condition>
		</not>
		<metadata>
			<operator class="equals">
				<value>False</value>
			</operator>
			<metadata-key>deleted</metadata-key>
		</metadata>
	</filter-condition>
</aggregator>
```

[advanced-message-splitter-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/AdvancedMessageSplitterService.html
[service-list]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/ServiceList.html
[MessageSplitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/MessageSplitter.html
[AdaptrisMessage]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisMessage.html
[Service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/Service.html
[MessageAggregator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/MessageAggregator.html
[AggregatingConsumeService]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/AggregatingConsumeService.html
[mime-aggregator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/MimeAggregator.html
[ignore-original-mime-aggregator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/IgnoreOriginalMimeAggregator.html
[replace-with-first-message-aggregator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/ReplaceWithFirstMessage.html
[xml-document-aggregator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/XmlDocumentAggregator.html
[ignore-original-xml-document-aggregator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/aggregator/IgnoreOriginalXmlDocumentAggregator.html
[split-join-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/SplitJoinService.html