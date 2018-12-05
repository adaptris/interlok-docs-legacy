---
title: Splitting Messages
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-splitting-messages.html
summary: Many messages passing through Interlok will consist of multiple elements. Often you will get a batch of messages (popular if you're a heavy EDI user); but each message needs to be handled individually.
---

Many messages passing through Interlok will consist of multiple elements. Often you will get a batch of messages (popular if you're a heavy EDI user); but each message needs to be handled individually. This is where the [basic-message-splitter-service] and [advanced-message-splitter-service][] are useful.

The key difference [basic-message-splitter-service][] and  [advanced-message-splitter-service][] is that [advanced-message-splitter-service][] allows you to apply an arbitrary set of services to each split message; whereas [basic-message-splitter-service][] does not. This means that [advanced-message-splitter-service][] is able to handle split messages inline; [basic-message-splitter-service][] forces you to use an external messaging system like JMS to handle inter-workflow communications.


## Basic Message Splitting ##

```xml
<basic-message-splitter-service>
  <connection class="jms-connection">
 ... Configuration skipped
  </connection>
  <producer class="jms-topic-producer">
    <destination class="configured-produce-destination">
      <destination>split.message</destination>
    </destination>
  </producer>
  <splitter class="line-count-splitter">
    <split-on-line>10</split-on-line>
  </splitter>
</basic-message-splitter-service>
```

- Uses a [line-count-splitter][] to create a new message every 10 lines.
- Each split message is published to the JMS topic `split.message`

{% include tip.html content="You could have another Interlok workflow listening on `split.message` to handle the integration required for each split message." %}

## Advanced Message Splitting ##

Rather than containing a producer and connection combination, the [advanced-message-splitter-service][] wraps a [Service][] to define the functionality required for each split message. Again, we are using standard components to compose the behaviour that is required.

To replicate the same behaviour as [basic-message-splitter-service][] using [advanced-message-splitter-service][] then we could have something like this:

```xml
<advanced-message-splitter-service>
 <splitter class="line-count-splitter">
  <split-on-line>10</split-on-line>
 </splitter>
 <service class="service-list">
  <services>
   <standalone-producer>
    <connection class="jms-connection">
   ... Configuration skipped
    </connection>
    <producer class="jms-topic-producer">
      <destination class="configured-produce-destination">
        <destination>split.message</destination>
      </destination>
    </producer>
   </standalone-producer>
  </services>
 </service>
</advanced-message-splitter-service>
```

- Uses a [line-count-splitter][] to create a new message every 10 lines.
- Each split message is published to the JMS topic `split.message`

{% include tip.html content="Because the nested `service` is a [service-list][] we can insert additional behaviour into the service list before publishing the message on `split.message`." %}


## Splitter Implementations ##

The standard implementations of [MessageSplitter][] are:

|Splitter Type| Description|
|----|----
|[line-count-splitter](#line-count-splitter)|Creates a new message every `n` lines (configurable). This splitter is capable of handling arbitrarily large messages.|
|[xpath-message-splitter](#xpath-message-splitter)| Split a message by resolving an XPath which returns a repeating subset of the document.|
|[xpath-document-copier](#xpath-document-copier)| Creates multiple copies of a message based on an XPath. The XPath evaluation should return an integer which dictates how many messages are created.
|[split-by-metadata](#split-by-metadata)|Creates multiple copies of the message based on the number of items in a configurable metadata key.|
|[mime-part-splitter](#mime-part-splitter)|Splits a message containing multiple MIME parts into their constituent parts.|
|[simple-regexp-message-splitter](#regexp-message-splitter)| Splits a message based on a regular expression match. It can optionally group records based on some common element.|


## Splitter Examples ##

It's probably best to describe behaviour using an example. You'll be able figure out the best splitter for your use-case; in the following sections the _payload_ is shown first (where applicable) then an XML configuration snippet and finally the resulting behaviour.

### Line count splitter ###

```
First,Second,Team
A1,A2,Team1
B1,B2,Team1
C1,C2,Team1
D1,D2,Team2
E1,E2,Team3
F1,F2,Team3
```

```xml
<splitter class="line-count-splitter">
  <split-on-line>1</split-on-line>
  <keep-header-lines>1</keep-header-lines>
</splitter>
```

- [line-count-splitter][] creates 6 messages.
    - Each message will have `First,Second,Team` as the first line.

### XPath Message Splitter ###

```
<envelope>
  <document>one</document>
  <document>two</document>
  <document>three</document>
</envelope>
```

```xml
<splitter class="xpath-message-splitter">
 <xpath>/envelope/document</xpath>
 <encoding>UTF-8</encoding>
</splitter>
```

- [xpath-message-splitter][] creates 3 messages, each only containing a `<document>` element.

### Xpath Document Copier ###


```
<envelope>
  <document>one</document>
  <document>two</document>
  <document>three</document>
</envelope>"
```

```xml
<splitter class="xpath-document-copier">
  <xpath>count(/envelope/document)</xpath>
</splitter>
```

- [xpath-document-copier][] creates 3 copies of the original document.


### Split By Metadata ###

The [message][AdaptrisMessage] contains the following metadata:

```
recipients=Alice,Bob,Carol
```

```xml
<splitter class="split-by-metadata">
 <separator>,</separator>
 <metadata-key>recipients</metadata-key>
 <split-metadata-key>recipient</split-metadata-key>
</splitter>
```

- [split-by-metadata][] creates 3 new messages, each of which will contain a `recipient` metadata key.
    - The first will contain `recipient=Alice`; the second `recipient=Bob`, and the last `recipient=Carol`

### Mime Part Splitter ###

```
Content-Type: multipart/related;
  boundary="_005_AA217B98DF7BEB479FEA1BAF75D31ADBA57C11mtanobodycom_";
  type="multipart/alternative"
MIME-Version: 1.0

--_005_AA217B98DF7BEB479FEA1BAF75D31ADBA57C11mtanobodycom_
Content-Type: text/plain; charset="us-ascii"

The quick brown fox jumps over the lazy dog.

--_005_AA217B98DF7BEB479FEA1BAF75D31ADBA57C11mtanobodycom_
Content-Type: text/plain; charset="us-ascii"

Pack my box with a dozen liquor jugs.

--_005_AA217B98DF7BEB479FEA1BAF75D31ADBA57C11mtanobodycom_
Content-Type: text/plain; charset="us-ascii"

Quick zephyrs blow, vexing daft Jim.

--_005_AA217B98DF7BEB479FEA1BAF75D31ADBA57C11mtanobodycom_
Content-Type: text/plain; charset="us-ascii"

How quickly daft jumping zebras vex.

--_005_AA217B98DF7BEB479FEA1BAF75D31ADBA57C11mtanobodycom_--
```

```xml
<splitter class="mime-part-splitter"/>
```
- [mime-part-splitter][] creates 4 split messages.

### Regexp Message Splitter ###

This type of splitter can be as complicated or as simple as your regular expression skills; for our purposes let's say that the document is:

```
A1,A2,Group1
B1,B2,Group1
C1,C2,Group1
D1,D2,Group2
E1,E2,Group3
F1,F2,Group3
```

Our configuration is:

```xml
<splitter class="simple-regexp-message-splitter">
 <split-pattern>&#x0A;</split-pattern>
 <compare-to-previous-match>true</compare-to-previous-match>
 <ignore-first-sub-message>true</ignore-first-sub-message>
 <match-pattern>^[^,]+,[^,]+,([^,]+)</match-pattern>
</splitter>
```
- [simple-regexp-message-splitter][] creates 3 messages, grouped by the 3rd field of the CSV message `GroupX`.


{% include tip.html content="If you wanted to split on each line, then you could remove everything other than `split-pattern`." %}

[basic-message-splitter-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/BasicMessageSplitterService.html
[advanced-message-splitter-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/AdvancedMessageSplitterService.html
[line-count-splitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/LineCountSplitter.html
[service-list]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/ServiceList.html
[MessageSplitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/MessageSplitter.html
[mime-part-splitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/MimePartSplitter.html
[split-by-metadata]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/SplitByMetadata.html
[simple-regexp-message-splitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/SimpleRegexpMessageSplitter.html
[xpath-document-copier]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/XpathDocumentCopier.html
[xpath-message-splitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/XpathMessageSplitter.html
[AdaptrisMessage]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisMessage.html
[Service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/Service.html
