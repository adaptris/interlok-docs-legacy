---
title: SAP BAPI/RFC Integration
keywords: interlok sap
tags: [cookbook,]
sidebar: home_sidebar
permalink: cookbook-sap-rfc.html
summary: This is a brief checklist and documentation of how Interlok can interact with SAP using RFC and BAPI calls. You will be already familiar with Interlok and its underlying concepts. No SAP knowledge is assumed. Interlok uses SAP JCo Standalone in order to achieve the desired integration (3.x).
---

## Software Pre-requisites ##

Interlok does not ship with the specific jars required to connect to SAP via ALE. You will have to download these directly from SAP. They are free to download provided you have a login to their support center. You will need the following software packages for your platform:

- SAP Java Connector (we build against 3.0.12) : `sapjco3-linuxintel-3.0.12.tgz`
- SAP Java IDoc Class Library (we build against 3.0P11) : `sapjidoc30P_11-10009485.zip`

Follow the instructions for installing the packages for the platform in question, but in brief, make sure that all the jar files are in the ${adapter}/lib directory, and the native libraries are available to the JVM

- Windows : Make sure that the directory containing any DLLs from SAP Java Connector is on the PATH (or put them all into \windows\system32 perhaps).
- Linux : Make sure that the environment variable LD_LIBRARY_PATH also contains the directory where any shared objects from the SAP Java Connector download can be found.

----

## Connections ##

The connection instance that you need is a [sapjco3-configured-rfc-connection][] or [sapjco3-dynamic-rfc-connection][]. The former allows you to configure a static [destination-provider-info][] which defines the connection, and can be used as a produce connection as part of a channel. [sapjco3-dynamic-rfc-connection][] instead derives the appropriate [destination-provider-info][] from metadata in the message, which makes it suitable for use as part of a [standalone-producer][] or [sapjco3-rfc-service-list][] but unsuitable for use as part of a channel.

{% include note.html content="The metadata keys used by [sapjco3-dynamic-rfc-connection][] to generate the connection info are not validated, and passed as-is to the underlying JCO layer." %}

```xml
 <connection class="sapjco3-configured-rfc-connection">
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
 </connection>
```

## Basic Invocation ##

There are two standard implementations of [AdaptrisMessageProducer][] : [sapjco3-rfc-producer][] and [sapjco3-bapi-producer][]. The key difference between the 2 producers is that [sapjco3-bapi-producer][] allows the configuration of a [BapiReturnParser][] which deals with the `RETURN` parameter present in all BAPIs. The [ProduceDestination][] for each producer should be the RFC or BAPI that is going to be invoked. As from an underlying technology point of view both BAPI and RFC function calls are the same, we tend to refer to them interchangably, using RFC in most instances.

### Parameters ###

Each producer defines a list of [ImportParameter][] instances and [ExportParameter][] instances, this is obviously less than the 4 types of parameter within a SAP function, `IMPORT`, `EXPORT`, `CHANGING` and `TABLE`; so both types of parameter will try to find the appropriate parameter within each of the given SAP types.
[ImportParameter][] maps onto the `IMPORT`, `TABLE` and `CHANGING` parameters within the RFC definition. [ExportParameter][] maps onto the `EXPORT`, `TABLE` and `CHANGING` parameter. These parameters define how the producer interacts with the message being handled, either writing new information into the message, or extracting information for passing to SAP.

| Type | Description|
|----|----|
|[sapjco3-constant-parameter][]| This [ImportParameter][] implementation maps a statically configured field as the specified parameter name to the RFC. |
|[sapjco3-string-metadata][]|This implements both [ImportParameter][] and [ExportParameter][] and maps an item of AdaptrisMessage metadata to a specific RFC parameter (and vice versa). The metadata-key element determines the metadata key that will be used to store the content of the mapping.|
|[sapjco3-string-payload][]|This implements both [ImportParameter][] and [ExportParameter][] and maps the AdaptrisMessage payload to and from a specific RFC Parameter
|[sapjco3-string-to-xml-payload][]|This [ExportParameter][] implementation takes an export field and depending on the XML handling strategy configured; inserts a new node ([xml-insert-node][]), replaces an existing node ([xml-replace-node][]), or replaces the entire document ([xml-replace-original][]).|
|[sapjco3-structure-to-xml-metadata][]|This [ExportParameter][] implementation maps a specific RFC structure parameter to the specified metadata key. The metadata-key element determines the metadata key that will be used to store the content of the mapping.|
|[sapjco3-structure-to-xml-payload][]|This [ExportParameter][] implementation takes an export structure parameter and depending on the XML handling strategy configured; inserts a new node ([xml-insert-node][]), replaces an existing node ([xml-replace-node][]), or replaces the entire document ([xml-replace-original][]).|
|[sapjco3-table-to-xml-metadata][]|This [ExportParameter][] implementation maps a specific RFC table parameter to the specified metadata key. The metadata-key element determines the metadata key that will be used to store the content of the mapping.|
|[sapjco3-table-to-xml-payload][]|This ExportParameter implementation takes a RFC table parameter and depending on the XML handling strategy configured; inserts a new node ([xml-insert-node][]), replaces an existing node ([xml-replace-node][]), or replaces the entire document ([xml-replace-original][]).|
|[sapjco3-xpath-to-structure][]|This [ImportParameter][] implementation evaluates the configured XPath expression and uses the evaluated node as the basis of an RFC structure. It is assumed that each element of the node is a field within the structure; the element name being the name of the field, and the associated element value the actual field value.|
|[sapjco3-xpath-to-table][]|This [ImportParameter][] implementation evaluates the configured XPath expression and uses the evaluated nodelist as the basis of an RFC table. Each entry in the nodelist adds a new table entry. It is assumed that each child node is a field within the table; the element name being the name of the field, and the associated element value the actual field value.|
|[sapjco3-xpath-string][]|This ImportParameter implementation evaluates the configured XPath expression and uses that value as an import parameter. It may not be used as an export parameter.|

{% include note.html content="In order to create parameters that are tables/structures, there must be metadata available in the SAP system describing the table/structure. This is queried to build up the internal object." %}


### Parsing the RETURN parameter ###

The [BapiReturnParser][] interface, which is the additional configuration for [sapjco3-bapi-producer][] allows you to specify behaviour when handling the standard `RETURN` parameter which should be present in all BAPIs. The following standard implementations are provided, in all cases an empty TYPE is transformed into `S` indicating success.

| Parser Type | Description |
|----|----|
|[sapjco3-bapireturn-fail-on-error][]|This throws an Exception when the RETURN Type field returns either `E` or `A`, indicating Error and Abort respectively.|
|[sapjco3-bapireturn-add-all-to-metadata][]|This adds all the values available in the RETURN parameter as metadata using the configured prefix. In the event of multiple RETURN parameters being present (such as if the RETURN type is actually a table parameter), then each metadata key generated will have an indicator as to which RETURN parameter it originated from (starts from 0).|
|[sapjco3-bapireturn-add-basic-metadata][]|This simply checks for the Type and Message fields in the RETURN parameter, and adds them as the specific metadata key.|
|[sapjco3-bapireturn-add-failure-metadata][]|Sets the configured metadata-key to be true if the RETURN Type field returns either `E` or `A`. This is useful if you wish to use a branching service later on in the chain.|
|[sapjco3-bapireturn-add-first-to-metadata][]|This is a variation on [sapjco3-bapireturn-add-all-to-metadata][] and simply uses the first available RETURN parameter rather than all of them. The configuration is the same as for [sapjco3-bapireturn-add-all-to-metadata][].|

<br/>

### Example config ###

Let's say we wanted to call the BAPI `BAPI_FLIGHT_GETLIST` specifying the airline, the country of departure within a given date range. To showcase all the parameters, let's also say that our input document is:

```xml
<BAPI_FLIGHT_GETLIST>
 <IMPORT_PARAMETERS>
   <AIRLINE>LH</AIRLINE>
   <DESTINATION_FROM>
    <AIRPORTID></AIRPORTID>
    <CITY></CITY>
    <COUNTR>DE</COUNTR>
    <COUNTR_ISO></COUNTR_ISO>
   </DESTINATION_FROM>
 </IMPORT_PARAMETERS>
 <TABLES>
  <DATE_RANGE>
   <item>
    <SIGN>I</SIGN>
    <OPTION>GE</OPTION>
    <LOW>20100101</LOW>
    <HIGH></HIGH>
   </item>
  </DATE_RANGE>
  <DATE_RANGE>
   <item>
    <SIGN>E</SIGN>
    <OPTION>LT</OPTION>
    <LOW>20100401</LOW>
    <HIGH></HIGH>
   </item>
  </DATE_RANGE>
 </TABLES>
</BAPI_FLIGHT_GETLIST>
```

Then our configuration could be something like :


```xml
 <producer class="sapjco3-bapi-producer">
  <destination class="configured-produce-destination">
   <destination>BAPI_FLIGHT_GETLIST</destination>
  </destination>
  <import-parameters>
   <sapjco3-xpath-string>
    <parameter-name>AIRLINE</parameter-name>
    <null-converter class="null-to-empty-string-converter"/>
    <xpath>/BAPI_FLIGHT_GETLIST/IMPORT_PARAMETERS/AIRLINE</xpath>
   </sapjco3-xpath-string>
   <sapjco3-xpath-to-structure>
    <parameter-name>DESTINATION_FROM</parameter-name>
    <null-converter class="nulls-not-supported-converter"/>
    <xpath>/BAPI_FLIGHT_GETLIST/IMPORT_PARAMETERS/DESTINATION_FROM</xpath>
   </sapjco3-xpath-to-structure>
   <sapjco3-xpath-to-table>
    <parameter-name>DATE_RANGE</parameter-name>
    <null-converter class="nulls-not-supported-converter"/>
    <xpath>/BAPI_FLIGHT_GETLIST/TABLES/DATE_RANGE/item</xpath>
   </sapjco3-xpath-to-table>
  </import-parameters>
  <export-parameters>
   <sapjco3-table-to-xml-payload>
    <parameter-name>FLIGHT_LIST</parameter-name>
    <null-converter class="nulls-not-supported-converter"/>
    <xml-handler class="xml-insert-node">
     <xpath-to-parent-node>/BAPI_FLIGHT_GETLIST/TABLES</xpath-to-parent-node>
    </xml-handler>
    <xml-encoding>UTF-8</xml-encoding>
   </sapjco3-table-to-xml-payload>
   <sapjco3-table-to-xml-payload>
    <parameter-name>DATE_RANGE</parameter-name>
    <null-converter class="nulls-not-supported-converter"/>
    <xml-handler class="xml-replace-node">
     <xpath-to-node>/BAPI_FLIGHT_GETLIST/DATE_RANGE</xpath-to-node>
    </xml-handler>
    <xml-encoding>UTF-8</xml-encoding>
   </sapjco3-table-to-xml-payload>
  </export-parameters>
  <return-parser class="sapjco3-bapireturn-fail-on-error"/>
 </producer>
```

This will execute the BAPI, and also write all the flights that match the query into `/BAPI_FLIGHT_GETLIST/TABLES`; giving you an XML document that you can manipulate later on in the workflow.

## Dynamic invocation ##

[sapjco3-dynamic-bapi-producer][] and [sapjco3-dynamic-rfc-producer][] work in much the same way as [sapjco3-bapi-producer][] and [sapjco3-rfc-producer][]. The difference here is that you do not need to specify [ImportParameter][] or [ExportParameter][] instances. Everything is derived from the input XML document (this does mean that the [ProduceDestination][] is ignored for these types of producer). You should first use [sapjco3-bapi-xml-generator][] or [sapjco3-rfc-xml-generator][] as part of a standard service chain to generate the idealised XML format that describes the RFC call in question. This is generally a one-time exercise, but they are delivered as services so that you can use that as part of any standard workflow. You can then predictably map to this format, and get information out in this format. Other than that, [sapjco3-dynamic-bapi-producer][] can still be configured with a [BapiReturnParser][] so that you can control the behaviour when a error is encounted.


## Stateful Execution Chain ##

In some cases it is often a requirement to invoke a sequence of BAPI’s or RFC’s in order; using the same connection configuration. In this case there is an additional service [sapjco3-rfc-service-list][] which can be configured with either a [sapjco3-configured-rfc-connection][] or [sapjco3-dynamic-rfc-connection][] which all nested producers will have access to (so nested producers do not need to have an explicit connection defined). In addition, there are two services [sapjco3-start-session-service][] and [sapjco3-end-session-service][] which will force the underlying JCo libraries to use the same connection for all invocations to the same JCo destination for any services sandwiched between them.

```xml
  <sapjco3-rfc-service-list>
   <services>
    <sapjco3-start-session-service/>
    <standalone-producer>
     <producer class="sapjco3-rfc-producer">
      <destination class="configured-produce-destination">
       <destination>Z_INCREMENT_COUNTER</destination>
      </destination>
     </producer>
    </standalone-producer>
    <standalone-producer>
     <producer class="sapjco3-rfc-producer">
      <destination class="configured-produce-destination">
       <destination>Z_INCREMENT_COUNTER</destination>
      </destination>
     </producer>
    </standalone-producer>
    <standalone-requestor>
     <producer class="sapjco3-rfc-producer">
      <destination class="configured-produce-destination">
       <destination>Z_GET_COUNTER</destination>
      </destination>
      <export-parameters>
       <sapjco3-string-metadata>
        <parameter-name>GET_VALUE</parameter-name>
        <null-converter class="null-to-empty-string-converter"/>
        <metadata-key>IncrementedValue</metadata-key>
       </sapjco3-string-metadata>
      </export-parameters>
     </producer>
    </standalone-requestor>
    <sapjco3-end-session-service/>
   </services>
   <rfc-connection class="sapjco3-dynamic-rfc-connection"/>
  </sapjco3-rfc-service-list>
```


[sapjco3-configured-rfc-connection]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/ConfiguredRfcConnection.html
[sapjco3-dynamic-rfc-connection]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/dynamic/DynamicRfcConnection.html
[destination-provider-info]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/JcoConnection.html#setDestinationProviderInfo-com.adaptris.core.sap.jco3.ProviderInfo-
[sapjco3-rfc-service-list]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/services/RfcServiceList.html
[standalone-producer]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/StandaloneProducer.html
[sapjco3-bapi-producer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/BapiProducer.html
[sapjco3-rfc-producer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/RfcProducer.html
[ProduceDestination]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ProduceDestination.html
[BapiReturnParser]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/BapiReturnParser.html
[ImportParameter]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/ImportParameter.html
[ExportParameter]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/ExportParameter.html
[sapjco3-string-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/StringMetadata.html
[sapjco3-string-payload]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/StringPayload.html
[sapjco3-string-to-xml-payload]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/StringToXmlPayload.html
[xml-insert-node]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/InsertNode.html
[xml-replace-node]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/ReplaceNode.html
[xml-replace-original]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/ReplaceOriginal.html
[sapjco3-structure-to-xml-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/StructureToXmlMetadata.html
[sapjco3-structure-to-xml-payload]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/StructureToXmlPayload.html
[sapjco3-table-to-xml-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/TableToXmlMetadata.html
[sapjco3-table-to-xml-payload]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/TableToXmlPayload.html
[sapjco3-xpath-to-structure]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/XpathToStructure.html
[sapjco3-xpath-to-table]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/XpathToTable.html
[sapjco3-xpath-string]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/XpathString.html
[sapjco3-bapireturn-fail-on-error]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/FailOnError.html
[sapjco3-bapireturn-add-all-to-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/AddAllToMetadata.html
[sapjco3-bapireturn-add-basic-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/AddBasicMetadata.html
[sapjco3-bapireturn-add-failure-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/AddFailureMetadata.html
[sapjco3-bapireturn-add-first-to-metadata]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/bapi/AddFirstReturnToMetadata.html
[sapjco3-dynamic-bapi-producer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/dynamic/DynamicBapiProducer.html
[sapjco3-rfc-xml-generator]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/dynamic/RfcXmlGenerator.html
[sapjco3-bapi-xml-generator]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/dynamic/BapiXmlGenerator.html
[sapjco3-dynamic-rfc-producer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/dynamic/DynamicRfcProducer.html
[sapjco3-end-session-service]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/services/StatefulSessionEnd.html
[sapjco3-start-session-service]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/services/StatefulSessionStart.html
[AdaptrisMessageProducer]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageProducer.html
[sapjco3-constant-parameter]: https://development.adaptris.net/javadocs/v3-snapshot/optional/sap/com/adaptris/core/sap/jco3/rfc/params/ConstantParameter.html
