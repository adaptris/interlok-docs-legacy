---
title: EDI Data transformations
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-edi-transform.html
summary: Using the edistream package to transform edi messages to xml and back
---


The [interlok-edistream][] optional package allows you to handle the processing of EDI messages. EDI is a compact and cryptic message format that has been around for many years, long before xml.

The following is a sample edi message:

> UNB+UNOA:2+8713235028078:14:Gallagher UK L+5013546157584:14:Mole Valley Fa+130517:0811+ROZ01883954109'UNH+1+INVOIC:D:96A:UN:EAN008'BGM+380456789A1321312730192372193732432048234732504234+20466276+9'UNS+1'MOA+77:921.92'UNT+4+17'UNZ+17+ROZ01883954109'
>

## Overview ##

There are a number of EDI standards and each defines its own messages ie messages have a name, version and their own structure / schema.  
In order to use edi with interlok you will need the following:  

* A basic level interlok licence to use the optional Edi component called: interlok-edistream. 
* A grammar file that describes the edi message that you intend to use – this is like a schema file defined in xml and often with the extension: .gxml.

EDI messages are not easy to work with so it’s typically best to convert them to a more pliable format such XML.


## EDI to XML ##

### Typical configuration ###

The following config snippet shows a typical service setup to parse an INVOIC:D96A Edifact message which is defined in the local adapter resources folder:

~~~ xml
<edi-xml-stream-service>
	<unique-id>edi-to-xml-service</unique-id>
	<edi-separator-set class="edi-edifact-separators"/>
	<xml-tagnames class="edi-legacy-xml-tag-names"/>
	<output-charset>UTF-8</output-charset>
	<input-charset>US-ASCII</input-charset>
	<xml-definition-url>file://localhost/./resources/edi96a_invoicegxml_ffxml.xml</xml-definition-url>
	<auto-detect-msg-details>true</auto-detect-msg-details>
	<trim-white-space-from-data>false</trim-white-space-from-data>
</edi-xml-stream-service>
~~~

### Options Explained ###

|Option|Description|Default|
|-|-|-|
|message-name|name of the edi message we are expecting eg INVOIC||
|message-version|version of the edi message eg D96A||
|message-organisation|the EDIFACT governing body eg X12 or EDIFACT||
|input-charset|Sets the encoding of the input edi document, this can be picked up from the incoming adapter message, or you can override it with this setting|UTF-8|
|output-charset|Sets the encoding of the generated XMl document|UTF-8|
|edi-separator-set|Specifies the separator to use to parse the incoming Edi document. If the autoDetectMsgDetails is set, then these can be picked up from the edi document. Note for X12 it is best to rely on the autodetect settings.<br/>The following classes are available:<br/>* edi-edifact-separators<br/>* edi-x12-separators<br/>* edi-tradacoms-separators<br/>* edi-custom-separators|edi-edifact-separators|
|xml-tagnames|Specifies the XML tagname set to use for the generated XML document. It allows you to customise only the tagnames used in the document rather than the structure.<br/>The following are available:<br/>* edi-default-xml-tag-names<br/>* edi-basic-xml-tag-names<br/>* edi-legacy-xml-tag-names |edi-default-xml-tag-names|
|xml-definition-url|This is a list element and you can provide multiple grammar files to be loaded on startup. Files can be local, remote, or even on the classpath, here are some examples:<br/>* http://example.com/message-grammar.xml<br/>* file://localhost/./resources/edi96a_invoicegxml_ffxml.xml<br/>* /opt/adapter/resources/edi96a_invoicegxml_ffxml.xml<br/>* file:///C:/projects/interlok-edistream/src/test/resources/edi96a_invoicegxml_ffxml.xml<br/>* ./resources/message-grammar.xml<br/>* classpath:message-grammar.xml||

### Advanced Options ###

|Option|Description|Default|
|-|-|-|
|trim-white-space-from-data|This settings strips whitespace from the actual data that is conveyed in the edi document eg REF+ myname', there is a leading space to the text myname that you may wish removed. This option calls java.lang.String.trim() underneath and so leading and trailing spaces are removed|false|
|output-empty-fields|This setting causes the output of all fields defined in the gXml in the output xml document. By default only values that are present in the edi document are output. With this option enabled all fields will be output.|false|
|enable-validation|This setting enables validation of the edi document. Enabled, it will perform additional checks of the edi document against the rules in the gXml. All errors are built up and the output xml document continues to be generated. Once the edi document is processed, should there be any validation errors then a service exception is thrown. The validation errors can be found in the log file.|false|
|auto-detect-msg-details|With this setting there is no need to configure the msg details in the adapter config(messageName, messageVersion, messageOrganisation). Instead these are picked up from the input document.<br/>The following settings are picked up:<br/>* message-name - name of the edi message eg INVOIC<br/>* message-version - version of the message eg D96A<br/>* message-organisation - the EDIFACT governing body eg X12 or EDIFACT<br/>* edi-separator-set - Picks up the UNA segment from an EDIFACT msg, or configures the separators for X12<br/>* input-charset - for EDIFACT UNB segments - based on the syntax specifier ie UNOA/UNOB the system sets the associated inputCharset<br/>|false|
|---
|enable-grammar-file-caching|This avoids unnecessary processing of grammar files by ensuring that they are only read once. Since grammar files don't change once defined so no need to re-read them during processing.|true|
|grammar-cache-limit|This sets the maximum number of grammars that can be loaded in memory at any one given time. The default value should be fine for most instances and defaults to: ParserRulesRegistry.DEFAULT_MAX_RULES_CACHE_SIZE.|10|

### Metadata Config ###


In some Interlok setups you may need to deal with a number of different EDI messages and and therefore wish to dynamically configure the message to be parsed. The service supports metadata configuration for a few key items to enable this. The following config items can be passed through metadata and these would override any hard coded values from the config file, but not the auto-detected values.

|Config Item|Metadata Key|Description|
|-|-|-|
|message name|message_name||
|message version|message_version||
|message organisation|message_organisation||
|message grammar|message_gxml|the message will be parsed against this file unless the other metadata items are specified<br/>Simply put: you can pass the grammar file (url) in the metadata along with the message and the message will be processed against it. If you do specify other metadata elements, then although the grammar will be loaded, the message will be parsed against the grammar indicated by these values rather than the supplied grammar|

## XML to EDI ##

You may wish to also generate EDI messages, in which case you should be aware of the fact that only XML documents that adhere to the message grammar structure can be converted to EDI.

### Typical configuration ###

The following config snippet shows a typical service setup to format an INVOIC:D96A Edifact message which is defined in the local adapter resources folder:

~~~ xml
<xml-edi-stream-service>
	<unique-id>xml-to-edi-service</unique-id>
	<edi-separator-set class="edi-edifact-separators"/>
	<xml-tagnames class="edi-legacy-xml-tag-names"/>
	<output-charset>UTF-8</output-charset>
	<input-charset>UTF-8</input-charset>
	<xml-definition-url>file://localhost/./resources/edi96a_invoicegxml_ffxml.xml</xml-definition-url>
	<message-name>INVOIC</message-name>
	<message-version>D96A</message-version>
	<message-organisation>EDIFACT</message-organisation>
</xml-edi-stream-service>
~~~

### Options Explained ###

|Option|Description|Default|
|-|-|-|
|message-name|name of the edi message we wish to format eg INVOIC||
|message-version|version of the edi message eg D96A||
|message-organisation|the EDIFACT governing body eg X12 or EDIFACT||
|input-charset|Sets the encoding of the input document, this can be picked up from the incoming adapter message, or you can override it with this setting|UTF-8|
|output-charset|Sets the encoding of the generated XML document|UTF-8|
|edi-separator-set|Specifies the separator to use to parse the incoming Edi document. If the autoDetectMsgDetails is set, then these can be picked up from the edi document. Note for X12 it is best to rely on the autodetect settings.<br/>The following classes are available:<br/>* edi-edifact-separators<br/>* edi-x12-separators<br/>* edi-tradacoms-separators<br/>* edi-custom-separators|edi-edifact-separators|
|xml-tagnames|Specifies the XML tagname set to use for parsing the XML document.<br/>The following are available:<br/>* edi-default-xml-tag-names<br/>* edi-basic-xml-tag-names<br/>* edi-legacy-xml-tag-names |edi-default-xml-tag-names|
|xml-definition-url|This is a list element and you can provide multiple grammar files to be loaded on startup. File can be local or remote ie provide URLs||


### Advanced Options ###

Note there is no auto detection of message details or a validation option when generating to XML.

|Option|Description|Default|
|-|-|-|
|new-line-per-record|pretty printing for EDI documents|false|
|enable-grammar-file-caching|This avoids unnecessary processing of grammar files by ensuring that they are only read once. Since grammar files don't change once defined so no need to re-read them during processing.|true|
|grammar-cache-limit|This sets the maximum number of grammars that can be loaded in memory at any one given time. The default value should be fine for most instances and defaults to: ParserRulesRegistry.DEFAULT_MAX_RULES_CACHE_SIZE.|10|

Metadata configuration options are the same as for the previous service.

## Additional ##

There is also an [interlok-edi-legacy][] package which is the older edi package. The new stream package was designed to offer higher performance and more efficiency over the previous one especially when dealing with large files. The old package works perfectly well for most common scenarios though.

[interlok-edistream]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-edi-stream/
[interlok-edi-legacy]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-edi-legacy/