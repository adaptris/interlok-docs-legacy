---
title: Integrating with MSMQ
keywords: interlok msmq
tags: [cookbook, messaging]
sidebar: home_sidebar
permalink: cookbook-msmq.html
summary: This document summarises configurations for consuming and producing messages using MSMQ. We will also describe some best practices related to the MSMQ infrastructure. It assumed that you have a passing knowledge of Interlok and its configuration with a basic understanding of MSMQ.
---

## Getting Started ##

### Interlok Pre-requisites ###

Before you can start Interlok that is able to consume or produce from or to MSMQ, you must first install the Interlok MSMQ sub component into your Interlok installation. All available Interlok sub components are shipped with the standard Interlok installation.  Simply navigate to the _optional_ directory at the root of your Interlok installation.  Copy the java archive files named `adp-msmq.jar` and `izmcomjni.jar` from the sub component directory to your _lib_ directory in the root of your Interlok installation.  Finally you will also need to copy the `izmcomjni.dll` into the lib directory. All configuration examples for can be found in the _docs/optional/example-xml_ directory.

The JRE needs to be the 32bit version of the JRE, as the native bridge between Java/ActiveX is currently not 64bit compatible. If you have installed using the bundled JRE, then this will be the 64bit version, so you need to install and supply your own JRE.


### MSMQ ###

MSMQ is part of the standard Microsoft Windows software stack. It is not, however, installed by default; so this feature needs to be turned on if it is available on your specific version of Windows. You can do this through the windows control panel;
- Control Panel -> Programs and Features -> Turn Windows features on or off

![msmq-windows-features.png](./images/msmq/msmq-windows-features.png)


{% include note.html content="Interlok must be installed on a Windows XP (or higher) platform." %}

Interlok must be installed on a Windows XP (or higher) platform as it makes use of the underlying ActiveX controls that are available once MSMQ is enabled. There are no other requirements, provided MSMQ has been enabled prior to your Interlok installation. Note that versions of MSMQ prior to 3.0 are not supported. This means that platforms prior to Windows XP Professional and Windows 2003 Server are not suitable for running this type of Interlok instance. You should still be able to send and receive messages from platforms using MSMQ 1.0 and MSMQ 2.0; however, the platform that Interlok runs on must be capable of MSMQ 3.0.

----

## MSMQ Configuration ##

Initially, there is little or no configuration required for MSMQ other than to start the service (if not already automatically started), and to create a queue. You will need to be a domain administrator if you wish to create public queues that are published in Active Directory. For a simple loopback test on the local machine, a private queue is sufficient.

![msmq-queue-manager.png](./images/msmq/msmq-queue-manager.png)

In order to enable security in transit between queue managers, all queues have to be published in Active Directory. This can cause issues where there are issues with active directory as the domain controller needs to be queried each time. To enable message encryption on a queue, it should be created with a privacy level of either optional or body. If created with a privacy level of body, then messages that are not encrypted will be discarded.

When receiving messages from COM components, the sending application does not always indicate the type of information (string, array of bytes, numeric types, currency, date, or COM object) that is stored in the message body. Interlok will always try and treat the incoming message as Text (for our purposes, Text equates to the Microsoft Variant type of *VT_BSTR*) when receiving a message from MSMQ. In the event that you do not have direct control over the back-end application; it is possible for the back-end application to deliver messages to Interlok that are not considered Text. You may choose to use the built in best-guess conversion routines to attempt to convert the message payload into a String (the attempt-silent-conversion-to-string field); you should set this to true if the .NET back-end component uses a _redundant_ UTF-8 BOM. Please be aware that this conversion is not always accurate, and you may not get the data that you expect; if not explicitly specified in the message-factory, then the platform default character encoding is used as the base character set for the converted String (on Windows platforms this is cp1252)

You can control the underlying variant that the message body is comprised of by specifying a [MsmqMessageFormat][] implementation in the producer. Currently two types are supported:

|Type|Description|
|----|-----------|
|[msmq-string-message-format][]|This is the default, and generates an MSMQ message body that has a variant type of VT_BSTR. Depending on the version of Windows/architecture, the default encoding for a VT_BSTR may not be UTF-8; it might be UTF-16 which gives you double-byte encoding. This can present problems for legacy applications which cannot handle UTF-16|
|[msmq-byte-array-message-format][]|This generates an MSMQ message body that has a variant type of VT_UI1 | VT_ARRAY which allows internal MSMQ auto conversion to enable interoperability with legacy .NET applications.|

----

## Interlok Configuration ##

Configure Interlok with 2 channels, one connecting the file-system to [standard-msmq-producer][], and the other using [msmq-polling-consumer] and writing to the file system. Both components should have an msmq-connection configured; there is example configuration for each component in the examples directory; however using the defaults, and having a minimal configuration will be fine for the scope of a loopback test.

The produce and consume destinations should always resolve to the MSMQ Queue that you wish to send and receive from. The queue itself can be addressed in a number of ways according to the syntax:

- PUBLIC=QueueGUID
- DIRECT=Protocol:ComputerAddress\QueueName
- DIRECT=OS:ComputerName\private$\QueueName
- PRIVATE=ComputerGUID\QueueNumber
- ComputerName\\QueueName

From the example above you could either use DIRECT=OS:.\private$\zzlc or .\PRIVATE$\zzlc.

### Producers & Consumers ###

Along with some simple string based fields that control the transaction and share mode; both producers and consumers contain a list of [PropertyMapper][] objects which will be responsible for mapping various parts of AdaptrisMessage into corresponding internal MSMQ Message fields.

|Field|Description|
|----|-----------|
|transaction-mode|The transaction mode to be used when sending or receiving messages. By default it is MQ_NO_TRANSACTION, but can be set to MQ_MTS_TRANSACTION, MQ_XA_TRANSACTION or MQ_SINGLE_MESSAGE : [MSDN Transaction Mode Reference][]|
|share-mode|The share mode to be used when opening the queue for reading or writing. By default it is MQ_DENY_NONE, but may be set to MQ_DENY_RECEIVE_SHARE : [MSDN Share Mode Reference][]|

There are four different available [PropertyMapper][] implementations: [msmq-configured-property][], [msmq-message-id-mapper][], [msmq-metadata-mapper][] and [msmq-xpath-property][]; each of these implementations handles a different aspect of mapping to and from MSMQ Message properties. They all share some common configuration inherited from [PropertyMapper][]

|Field|Description|
|----|-----------|
|property-name|The MSMQ property that should be mapped - [MSDN Property Reference][]|
|convert-null|If set to true, then an attempt will be made to convert null fields into something meaningful for the type|
|byte-translator|This is the byte translator implementation that should be used when the corresponding MSMQ message property equates to byte[]|

Each of the [PropertyMapper][] implementations have the following specific behaviour :

|Property Mapper Name|Description|
|----|-----------|
|[msmq-configured-property][]|This simply maps the configured value to the corresponding MSMQ message property. It cannot be used as part of an [msmq-polling-consumer][]|
|[msmq-message-id-mapper][]|This maps the AdaptrisMessage unique id to and from the corresponding MSMQ message property.|
|[msmq-metadata-mapper][]|This maps an item of AdaptrisMessage metadata to a specific MSMQ message property (and vice versa). The metadata-key element determines the metadata key that will be used to derive the content of the mapping.|
|[msmq-xpath-property][]|This resolves an XPath against the AdaptrisMessage payload and sets a specific MSMQ message property based on this value. It cannot be used as part of an [msmq-polling-consumer][].

----

## MSMQ Best Practices ##

There is a Microsoft MSMQ best practice document which is available for download: [http://download.microsoft.com/download/F/C/9/FC9989A2-DA75-4D96-B654-4BD29CF6AEE1/MSMQBestPractice.doc](http://download.microsoft.com/download/F/C/9/FC9989A2-DA75-4D96-B654-4BD29CF6AEE1/MSMQBestPractice.doc). The following are the best practices that we have found to increase overall performance and reliability of MSMQ.

### Use Private Queues ###

The accepted best practice for overall performance is to not use public MSMQ queues; private queues are preferred. A public queue is published in Active Directory (only a domain admin can create them), and the domain controller is queried when the queue needs to be found (e.g. when opening the queue). Private queues are not published in Active Directory. A drawback of only using private queues is that the MSMQ Message encryption during transit between queue managers is not supported. If security during transit is of high importance, then you should use public queues. To enable message encryption on a queue, it should be created with a privacy level of either optional or body. If created with a privacy level of body, then messages that are not encrypted will be discarded.


### Use Direct Addressing ####

By using the DIRECT form of addressing you bypass any interrogation of the domain controller:

- computer\queue : public queue (interrogates AD to find the queue)
- computer\private$\queue : private queue (interrogates AD to find the computer)
= DIRECT=OS:computer\private$\queue :  private queue (do not use AD, use the operating system to find computer and connect directly to access the queue.

A drawback of only using directly addressed queues is that the MSMQ Message encryption during transit between queue managers is not supported.

### Remote Writes; Local Reads ###

MSMQ is designed optimally for sending remotely and receiving locally. Remote queue reads (receives) have several disadvantages:
- Remote reads are not supported in transactions.
- Remote reading may not respond due to network failures
- When you do a remote read, the message body will pass between the reader and the remote computer, even if not required.


### Don't use Journaling ###

Journaling can use up disk space quickly. If you must use journaling, to increase messaging performance, purge messages in all journal queues and dead-letter queues often.


### Use Windows Security Sparingly ###

MSMQ uses the standard Windows security model; you can configure queues to permit only senders and receivers with appropriate security privileges. Using Windows security in messaging means it takes about significantly longer to send the same messages. Configure MSMQ not to send the security descriptors associated with the sending application by setting the message property AttachSenderID to False (the default is True)

[MsmqMessageFormat]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/MsmqMessageFormat.html
[msmq-string-message-format]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/StringMessageFormat.html
[msmq-byte-array-message-format]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/ByteArrayMessageFormat.html
[standard-msmq-producer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/StandardMsmqProducer.html
[msmq-polling-consumer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/MsmqPollingConsumer.html
[PropertyMapper]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/PropertyMapper.html
[MSDN Transaction Mode Reference]: http://msdn.microsoft.com/en-us/library/ms703934(VS.85).aspx
[MSDN Share Mode Reference]: http://msdn.microsoft.com/en-us/library/ms706937(VS.85).aspx
[MSDN Property Reference]: http://msdn.microsoft.com/en-us/library/ms705286(VS.85).aspx
[msmq-configured-property]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/ConfiguredProperty.html
[msmq-message-id-mapper]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/MessageIdMapper.html
[msmq-metadata-mapper]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/MetadataMapper.html
[msmq-xpath-property]: https://development.adaptris.net/javadocs/v3-snapshot/optional/msmq/com/adaptris/core/msmq/XpathProperty.html
