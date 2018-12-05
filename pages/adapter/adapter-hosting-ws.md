---
title: Interlok as a Webservices Host
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-hosting-ws.html
---

{% include note.html content="This is only useful if you want to inject messages into an arbitrary workflow. Use a normal jetty based workflow if that is the intended endpoint" %}

{% include important.html content="since 3.8.0; adp-web-services has been renamed to interlok-web-services" %}

Generally, if you are using Interlok as an HTTP endpoint, then you would just use one of the standard HTTP consumers as part of a normal workflow ([Servicing HTTP requests](cookbook-http-server.html)); however, in certain situations it can be useful to expose an arbitrary workflow (e.g. a JMS bridge) so that you can inject messages into the workflow without doing additional configuration. This requires that you enable the built-in jetty instance, and to use a custom web application.

## Enabling the built-in Webserver ##

With a factory installation of Interlok, the embedded web server should already be enabled by default.  This can be checked in the bootstrap.properties for the "managementComponents" property.

All enabled management components are listed, separated by colon's as the value to the "managementComponents" property;

```
managementComponents=jetty:jmx
```
As shown above "jetty", the embedded web server is enabled.

# Installing the Web Services Component #

Get the webservice application (_interlok-web-services.war_), from either then [snapshot repository](https://nexus.adaptris.net/nexus/content/groups/adaptris-snapshots/com/adaptris/interlok-web-services/) or the [release repository](https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-web-services/). For versions 3.0.5 and earlier, the artefact was called adp-webservices-internal and can be found under that name.

Rename the file to be _interlok-web-services.war_ and drop it into the interlok web-app directory.  The default location for the web-app directory will be a directory named `webapps` in the root of your Interlok installation.  This folder should already exist, if not, create it.

You can check/change the location of the jetty web-app directory within the jetty.xml file.  A property named;

```xml
<Set name="monitoredDirName"><Property name="jetty.home" default="." />/webapps</Set>
```
You can check everything is correct, by starting Interlok and navigating to the following url (assuming, Interlok is running locally): `http://localhost:8080/interlok-web-services/workflow-services?wsdl`

# Standard Interlok Web Services #

## submitMessage ##

**Warning:  Java 1.8+ only; since 3.0.4**

This service allows you to inject a message directly into a workflow, bypassing the message consumer. As long as each workflow and channel in your Interlok configuration has a unique-id, you can target any workflow to process your message.

### Parameters ###

There are 3 parameters required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| workflowId | Interlok publishes JMX entry points, one of which allows you to get a list of workflows that are currently in the "running" state.  This parameter requires the string value of the ID of a running workflow. The format of the ID, is the workflow's unique id + "@" + the parent channel's unique id. For example : `myWorkflowID@myChannelID`|
| message | The message is the XStream marshalled instance of the following class [SerializableMessage][]. For more information on the SerializableAdaptrisMessage, please see the java-doc for this class. You must also remember to encode the marshalled result, as shown in the practical example below.|


### Example ###

```xml
<adapter>
  <unique-id>Inject-Test-Adapter</unique-id>

  <channel-list>
    <channel>
      <unique-id>Channel1</unique-id>
      <workflow-list>
        <pooling-workflow>
          <unique-id>Workflow1</unique-id>
          <consumer class="null-message-consumer"/>

          <service-collection class="service-list">
            <services>
              <add-metadata-service>
                <unique-id>AddMetaService</unique-id>
                <metadata-element>
                  <key>AddedKey1</key>
                  <value>AddedValue1</value>
                </metadata-element>
                <metadata-element>
                  <key>AddedKey2</key>
                  <value>AddedValue2</value>
                </metadata-element>
              </add-metadata-service>

              <base64-encode-service>
                <unique-id>Base64EncodeService</unique-id>
              </base64-encode-service>

              <base64-decode-service>
                <unique-id>Base64DecodeService</unique-id>
              </base64-decode-service>
            </services>
          </service-collection>

          <producer class="null-message-producer"/>
        </pooling-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>
```

Assuming that you have configured Interlok as above and it is up and running with the web-services component, you can use your favourite SOAP client tool to fire a SOAP request at our web-service server (we'll use SOAP UI).

Your SOAP request will look something like this;

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:submitMessage>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
         <message><![CDATA[<?xml version="1.0"?>
        <serializable-adaptris-message>
          <unique-id>MyMessageID</unique-id>
          <payload>My awesome payload</payload>
          <metadata>
            <key-value-pair>
              <key>myMetadataKey1</key>
              <value>myMetadataValue1</value>
            </key-value-pair>
            <key-value-pair>
              <key>myMetadata2</key>
              <value>myMetadataValue2</value>
            </key-value-pair>
          </metadata>
        </serializable-adaptris-message>
]]></message>
      </war:submitMessage>
   </soapenv:Body>
</soapenv:Envelope>
```

Notice the message element contains the XStream marshalled SerializableAdaptrisMessage wrapped as a CDATA element. The example above uses a very simple message, the payload equalling `My awesome payload` and a message id of `MyMessageID`. This also supplies some metadata for completeness.  It should be noted that you are not required to provide a unique-id, one will be generated for you if you choose not to supply one.

If the web-service should fail, you will receive a SOAP fault response with the exception detail as the body.  If the web service call should succeed, you will get the following response;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:submitMessageResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return><![CDATA[<serializable-adaptris-message>
  <unique-id>MyMessageID</unique-id>
  <payload>My awesome payload</payload>
  <metadata>
    <key-value-pair class="metadata-element">
      <key>AddedKey2</key>
      <value>AddedValue2</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>AddedKey1</key>
      <value>AddedValue1</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>myMetadataKey1</key>
      <value>myMetadataValue1</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>myMetadata2</key>
      <value>myMetadataValue2</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>adpnextmlemarkersequence</key>
      <value>5</value>
    </key-value-pair>
  </metadata>
</serializable-adaptris-message>]]></return>
      </ns2:submitMessageResponse>
   </S:Body>
</S:Envelope>
```

## submitFormattedMessage ##

**Warning:  Java 1.8+ only; since 3.0.6**

This service is almost identical to the submitMessage method above with two additional options.  This version allows you to specify the format of the incoming and returned message.  Currently there are 2 supported formats; XML and JSON.

### Parameters ###

There are 5 parameters required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| workflowId | Interlok publishes JMX entry points, one of which allows you to get a list of workflows that are currently in the "running" state.  This parameter requires the string value of the ID of a running workflow. The format of the ID, is the workflow's unique id + "@" + the parent channel's unique id. For example : `myWorkflowID@myChannelID`|
| inputFormat| Either XML or JSON.|
| outputFormat| Either XML or JSON.|
| message | The message is the XStream XML/JSON marshalled instance of the following class [SerializableMessage][]. For more information on the SerializableAdaptrisMessage, please see the java-doc for this class. You must also remember to encode the marshalled result, as shown in the practical examples below.|


### Example ###

Using the same injectTestAdapter as the submitMessage above and assuming that you have configured Interlok as above and it is up and running with the web-services component, you can use your favourite SOAP client tool to fire a SOAP request at our web-service server (we'll use SOAP UI).

Your XML SOAP request will look something like this;

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:submitMessage>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
     <inputFormat>XML</inputFormat>
     <outputFormat>XML</outputFormat>
         <message><![CDATA[<?xml version="1.0"?>
        <serializable-adaptris-message>
          <unique-id>MyMessageID</unique-id>
          <payload>My awesome payload</payload>
          <metadata>
            <key-value-pair>
              <key>myMetadataKey1</key>
              <value>myMetadataValue1</value>
            </key-value-pair>
            <key-value-pair>
              <key>myMetadata2</key>
              <value>myMetadataValue2</value>
            </key-value-pair>
          </metadata>
        </serializable-adaptris-message>
]]></message>
      </war:submitMessage>
   </soapenv:Body>
</soapenv:Envelope>
```

Should you wish to inject a JSON formatted message, your request will look like this;

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:submitMessage>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
     <inputFormat>JSON</inputFormat>
     <outputFormat>JSON</outputFormat>
         <message>{"serializable-adaptris-message":{"unique-id":"MyMessageID","payload":"My awesome json payload","metadata":[{"key-value-pair":[{"key":"fsProduceDir","value":"C:\\Adaptris\\Interlok3.0.3RC1\\messages_out"},{"key":"myMetadataKey1","value":"myMetadataValue1"},{"key":"producedname","value":"1441622806841.xml"},{"key":"myMetadata2","value":"myMetadataValue2"},{"key":"adpnextmlemarkersequence","value":2}]}]}}</message>
      </war:submitMessage>
   </soapenv:Body>
</soapenv:Envelope>
```

Notice the message element contains the XStream marshalled SerializableAdaptrisMessage wrapped as a CDATA element. The example above uses a very simple message, the payload equalling `My awesome payload` and a message id of `MyMessageID`. This also supplies some metadata for completeness.  It should be noted that you are not required to provide a unique-id, one will be generated for you if you choose not to supply one.

If the web-service should fail, you will receive a SOAP fault response with the exception detail as the body.  If the web service call should succeed and you have specified XML as the output format, you will get the following response;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:submitMessageResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return><![CDATA[<serializable-adaptris-message>
  <unique-id>MyMessageID</unique-id>
  <payload>My awesome payload</payload>
  <metadata>
    <key-value-pair class="metadata-element">
      <key>AddedKey2</key>
      <value>AddedValue2</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>AddedKey1</key>
      <value>AddedValue1</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>myMetadataKey1</key>
      <value>myMetadataValue1</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>myMetadata2</key>
      <value>myMetadataValue2</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>adpnextmlemarkersequence</key>
      <value>5</value>
    </key-value-pair>
  </metadata>
</serializable-adaptris-message>]]></return>
      </ns2:submitMessageResponse>
   </S:Body>
</S:Envelope>
```

Or if you have specified JSON as the output format, then your response will look something like this;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:submitFormattedMessageResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return>{"serializable-adaptris-message":{"unique-id":"MyMessageID","payload":"My awesome json payload","metadata":[{"key-value-pair":[{"key":"fsProduceDir","value":"C:\\Adaptris\\Interlok3.0.3RC1\\messages_out"},{"key":"myMetadataKey1","value":"myMetadataValue1"},{"key":"producedname","value":"1441631436913.xml"},{"key":"myMetadata2","value":"myMetadataValue2"},{"key":"adpnextmlemarkersequence","value":5}]}]}}</return>
      </ns2:submitFormattedMessageResponse>
   </S:Body>
</S:Envelope>
```

## submitPayload ##

**Warning:  Java 1.8+ only; since 3.0.4 **

This service is a variation of `submitMessage` which assumes that you have no requirement to specify the message unique id or any metadata. It similarly allows you to inject a message directly into a workflow, bypassing the message consumer. As long as the workflow and channel in your Interlok configuration has a unique-id, you can target any workflow to process your message.

### Parameters ###

There are 3 parameters required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| workflowId | Interlok publishes JMX entry points, one of which allows you to get a list of workflows that are currently in the "running" state.  This parameter requires the string value of the ID of a running workflow. The format of the ID, is the workflow's unique id + "@" + the parent channel's unique id. For example : `myWorkflowID@myChannelID`|
| payload | The payload of the message|


### Example ###

Using the same adapter configuration above, our SOAP UI document would be

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:submitPayload>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
         <payload>My wicked payload</payload>
      </war:submitPayload>
   </soapenv:Body>
</soapenv:Envelope>
```

If the web-service should fail, you will receive a SOAP fault response with the exception detail as the body.  If the web service call should succeed, you will get the following response;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:submitPayloadResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return><![CDATA[<serializable-adaptris-message>
  <unique-id>54d966e3-e05c-46e4-9e3c-583f87bc88d9</unique-id>
  <payload>My wicked payload</payload>
  <metadata>
    <key-value-pair class="metadata-element">
      <key>AddedKey2</key>
      <value>AddedValue2</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>AddedKey1</key>
      <value>AddedValue1</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>adpnextmlemarkersequence</key>
      <value>5</value>
    </key-value-pair>
  </metadata>
</serializable-adaptris-message>]]></return>
      </ns2:submitPayloadResponse>
   </S:Body>
</S:Envelope>
```

## submitFormattedPayload ##

**Warning:  Java 1.8+ only; since 3.0.6**

This service is very similar to the submitPayload service above, but allows you to specify the returned message format.
Two formats are currently supported; XML and JSON.
If you specify XML as the output format, the behaviour of this service will be identical to submitPayload.

### Parameters ###

There are 4 parameters required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| workflowId | Interlok publishes JMX entry points, one of which allows you to get a list of workflows that are currently in the "running" state.  This parameter requires the string value of the ID of a running workflow. The format of the ID, is the workflow's unique id + "@" + the parent channel's unique id. For example : `myWorkflowID@myChannelID`|
| outputFormat| Either XML or JSON.|
| payload | The payload of the message|


### Example ###

Using the same adapter configuration above, our SOAP request assuming an XML response would be :

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:submitPayload>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
     <outputFormat>XML</outputFormat>
         <payload>My wicked payload</payload>
      </war:submitPayload>
   </soapenv:Body>
</soapenv:Envelope>
```

Or for a JSON response, would be;

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:submitPayload>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
     <outputFormat>JSON</outputFormat>
         <payload>My wicked payload</payload>
      </war:submitPayload>
   </soapenv:Body>
</soapenv:Envelope>
```

If the web-service should fail, you will receive a SOAP fault response with the exception detail as the body.  If the web service call should succeed for an XML response, you will get the following returned from the web service;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:submitPayloadResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return><![CDATA[<serializable-adaptris-message>
  <unique-id>54d966e3-e05c-46e4-9e3c-583f87bc88d9</unique-id>
  <payload>My wicked payload</payload>
  <metadata>
    <key-value-pair class="metadata-element">
      <key>AddedKey2</key>
      <value>AddedValue2</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>AddedKey1</key>
      <value>AddedValue1</value>
    </key-value-pair>
    <key-value-pair class="metadata-element">
      <key>adpnextmlemarkersequence</key>
      <value>5</value>
    </key-value-pair>
  </metadata>
</serializable-adaptris-message>]]></return>
      </ns2:submitPayloadResponse>
   </S:Body>
</S:Envelope>
```

Or for a JSON response;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:submitFormattedPayloadResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return>{"serializable-adaptris-message":{"unique-id":"32786298-d2f5-4a72-9bce-f140ea133fbe","payload":"My Wicked Payload","metadata":[{"key-value-pair":[{"key":"fsProduceDir","value":"C:\\Adaptris\\Interlok3.0.3RC1\\messages_out"},{"key":"producedname","value":"1441633752283.xml"},{"key":"adpnextmlemarkersequence","value":2}]}]}}</return>
      </ns2:submitFormattedPayloadResponse>
   </S:Body>
</S:Envelope>
```


## execute ##

This service is a variation of `submitMessage` but does not require Java 1.8; and will only return true (or false) depending on whether the message was successfully injected into the workflow. As long as the workflow and channel in your Interlok configuration has a unique-id, you can target any workflow to process your message.

### Parameters ###

There are 3 parameters required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| workflowId | Interlok publishes JMX entry points, one of which allows you to get a list of workflows that are currently in the "running" state.  This parameter requires the string value of the ID of a running workflow. The format of the ID, is the workflow's unique id + "@" + the parent channel's unique id. For example : `myWorkflowID@myChannelID`|
| message | The message is the XStream marshalled instance of the following class [SerializableMessage][]. For more information on the SerializableAdaptrisMessage, please see the java-doc for this class. You must also remember to encode the marshalled result, as shown in the practical example below.|


### Example ###

Using the same adapter configuration above, our SOAP UI document would be

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:execute>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
         <message><![CDATA[<?xml version="1.0"?>
        <serializable-adaptris-message>
          <unique-id>MyMessageID</unique-id>
          <payload>My awesome payload</payload>
        </serializable-adaptris-message>
]]></message>
      </war:execute>
   </soapenv:Body>
</soapenv:Envelope>
```

If message was successfully submitted to the workflow then you will get a simple true/false response back

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:executeResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return>true</return>
      </ns2:executeResponse>
   </S:Body>
</S:Envelope>
```

## executeFormatted ##

** Since 3.0.6**
This service is very similar to the execute method above, but allows you to specify the format of the incoming message.  The two formats currently supported are XML and JSON.

### Parameters ###

There are 4 parameters required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| workflowId | Interlok publishes JMX entry points, one of which allows you to get a list of workflows that are currently in the "running" state.  This parameter requires the string value of the ID of a running workflow. The format of the ID, is the workflow's unique id + "@" + the parent channel's unique id. For example : `myWorkflowID@myChannelID`|
| inputFormat| Either XML or JSON.|
| message | The message is the XStream XML/JSON marshalled instance of the following class [SerializableMessage][]. For more information on the SerializableAdaptrisMessage, please see the java-doc for this class. You must also remember to encode the marshalled result, as shown in the practical example below.|


### Example ###

Using the same adapter configuration above, our SOAP request with an XML formatted message would be

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:execute>
         <adapterId>Inject-Test-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
         <inputFormat>XML</inputFormat>
     <message><![CDATA[<?xml version="1.0"?>
        <serializable-adaptris-message>
          <unique-id>MyMessageID</unique-id>
          <payload>My awesome payload</payload>
        </serializable-adaptris-message>
]]></message>
      </war:execute>
   </soapenv:Body>
</soapenv:Envelope>
```

And with a JSON formatted message would be

```xml
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:war="http://war.ws.adaptris.com/">
   <soapenv:Header/>
   <soapenv:Body>
      <war:executeFormatted>
         <adapterId>FS-FS-Adapter</adapterId>
         <workflowId>Workflow1@Channel1</workflowId>
         <inputFormat>JSON</inputFormat>
         <message>{"serializable-adaptris-message":{"unique-id":"MyMessageID","payload":"My awesome json payload"}</message>
      </war:executeFormatted>
   </soapenv:Body>
</soapenv:Envelope>
```

If message was successfully submitted to the workflow then you will get a simple true/false response returned;

```xml
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
   <S:Body>
      <ns2:executeResponse xmlns:ns2="http://war.ws.adaptris.com/" xmlns:ns3="http://core.adaptris.com/">
         <return>true</return>
      </ns2:executeResponse>
   </S:Body>
</S:Envelope>
```


[SerializableMessage]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/SerializableAdaptrisMessage.html