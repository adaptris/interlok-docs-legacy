---
title: Interlok RESTful Services
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-hosting-rest.html
---

{% include note.html content="This is only useful if you want to inject messages into an arbitrary workflow. Use a normal jetty based workflow if that is the intended endpoint" %}

Generally, if you are using Interlok as an HTTP endpoint, then you would just use one of the standard HTTP consumers as part of a normal workflow ([Servicing HTTP requests](cookbook-http-server.html)); however, in certain situations it can be useful to expose an arbitrary workflow (e.g. a JMS bridge) so that you can inject messages into the workflow without doing additional configuration. This requires that you enable the built-in jetty instance, and to use a custom web application.

## Enabling the built-in Webserver ##

With a factory installation of Interlok, the embedded web server should already be enabled by default.  This can be checked in the bootstrap.properties for the "managementComponents" property.

All enabled management components are listed, separated by colon's as the value to the "managementComponents" property;

```
managementComponents=jetty:jmx
```

As shown above "jetty", the embedded web server is enabled.

# Installing the Restful Services Component #

Get the restful services application (_adp-restful-services.war_), from either then [snapshot repository](https://development.adaptris.net/nexus/content/groups/adaptris-snapshots/com/adaptris/adp-restful-services/) or the [release repository](https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-restful-services/).

Drop _adp-restful-services.war_ and drop it into the interlok web-app directory.  The default location for the web-app directory will be a directory named `webapps` in the root of your Interlok installation.  This folder should already exist, if not, create it.

You can check/change the location of the jetty web-app directory within the jetty.xml file.  A property named;

```xml
<Set name="monitoredDirName"><Property name="jetty.home" default="." />/webapps</Set>
```

# Standard Interlok Restful Services #

There are two sets of restful services that allow you to inject messages into your Interlok workflows;

- Services that will wait for the message to be processed by the workflow and then return the resulting message (synchronous).
- Services that simply return a "true" value after successfully injecting a message (asynchronous).

All clients wishing to use the restful services will use the HTTP method of POST and will target the following URL;
`http://<host>:<port>/adp-restful-services/rest/service/...` followed by the required method and parameters as detailed by each services below.

Additionally you must set the `Content-Type` HTTP header to the value `text/plain`.

## Synchronous Services ##

**Warning:  All synchronous services require Java 1.8+ only; since 3.0.6**

### submitMessage ###

This service allows you to inject a message directly into a workflow, bypassing the message consumer. As long as each workflow and channel in your Interlok configuration has a unique-id, you can target any workflow to process your message.

Once the message has completed its processing in the targeted workflow, the resulting message is returned back to the calling process.

#### Parameters ####

There are 5 parameters and the POST data payload required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| channelId | This is the unique ID of the targeted channel.|
| workflowId | This is the unique ID of the targeted workflow.|
| inputFormat | Specifies the format of the supplied message; currently supported formats are JSON and XML|
| outputFormat | Specifies the required format of the returned message; currently supported formats are JSON and XML|
| POST data | The message is the XStream marshalled instance of the following class [SerializableMessage][]. For more information on the SerializableAdaptrisMessage, please see the java-doc for this class. |

#### Example ####

This example will use a very basic Interlok configuration and will assume the incoming format of the message is XML and the returned message is JSON formatted.

The basic Interlok configuration;

```xml
<adapter>
  <unique-id>FS-FS-Adapter</unique-id>
  <channel-list>
    <channel>
      <unique-id>Channel1</unique-id>
      <workflow-list>
        <standard-workflow>
          <unique-id>Workflow1</unique-id>
          <consumer class="fs-consumer">
            <unique-id>FS-Consumer</unique-id>
            <destination class="configured-consume-destination">
              <destination>messages_in</destination>
            </destination>
            <poller class="fixed-interval-poller">
              <poll-interval>
                <unit>SECONDS</unit>
                <interval>10</interval>
              </poll-interval>
            </poller>
            <create-dirs>true</create-dirs>
          </consumer>
          <producer class="fs-producer">
            <unique-id>FS-Producer</unique-id>
            <filename-creator class="formatted-filename-creator">
              <filename-format>%2$tQ.xml</filename-format>
            </filename-creator>
            <destination class="configured-produce-destination">
              <destination>messages_out</destination>
            </destination>
            <create-dirs>true</create-dirs>
          </producer>
        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>
```

Assuming that you have configured Interlok as above and it is up and running with the restful-services component, you can use your favourite client tool to fire a HTTP request at our restful-services server.

Your raw HTTP request will look something like this;

```
POST http://<host>:<port>/adp-restful-services/rest/service/submitmessage?adapterId=FS-FS-Adapter&channelId=Channel1&workflowId=Workflow1&inputFormat=XML&outputFormat=JSON

POST data:
<serializable-adaptris-message>
  <unique-id>MyMessageID</unique-id>
  <payload>My message payload</payload>
  <metadata>
    <metadata-element>
      <key>myMetadataKey1</key>
      <value>myMetadataValue1</value>
    </metadata-element>
    <metadata-element>
      <key>myMetadata2</key>
      <value>myMetadataValue2</value>
    </metadata-element>
  </metadata>
</serializable-adaptris-message>

[no cookies]

Request Headers:
Connection: keep-alive
Content-Type: text/plain
Content-Length: 512
Host: localhost:8080
User-Agent: Apache-HttpClient/4.2.6 (java 1.5)
```

Notice the entire XML marshalled message is the entire POST data.  The example above uses a very simple message, the payload equalling `My message payload` and a message id of `MyMessageID`. This also supplies some metadata for completeness.  It should be noted that you are not required to provide a unique-id, one will be generated for you if you choose not to supply one.

If the restful-service should fail, you will receive an error in the body of the result.  If the restful service call should succeed, in this case you will find the supplied message produced to your local file system and you will receive a JSON marshalled message in the response body;

```xml
{"serializable-adaptris-message":{"unique-id":"MyMessageID","payload":"My message payload","metadata":[{"key-value-pair":[{"key":"fsProduceDir","value":"C:\\Adaptris\\Interlok3.0.6\\messages_out"},{"key":"myMetadataKey1","value":"myMetadataValue1"},{"key":"producedname","value":"1442405528738.xml"},{"key":"myMetadata2","value":"myMetadataValue2"},{"key":"adpnextmlemarkersequence","value":2}]}]}}
```


### submitPayload ###

This service allows you to inject a text payload directly into a workflow, bypassing the message consumer. As long as each workflow and channel in your Interlok configuration has a unique-id, you can target any workflow to process your message.

You do not need to marshall the supplied payload to either XML or JSON, but you can specify the format of the returned message.

#### Parameters ####

There are 4 parameters and the POST data payload required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| channelId | This is the unique ID of the targeted channel.|
| workflowId | This is the unique ID of the targeted workflow.|
| outputFormat | Specifies the required format of the returned message; currently supported formats are JSON and XML|
| POST data | Your text payload that you wish to inject into a workflow. |

#### Example ####

Using the same Interlok configuration above, our raw HTTP POST, assuming you wish to have an XML formatted message returned would be;

```
POST http://<host>:<port>/adp-restful-services/rest/service/submitpayload?adapterId=FS-FS-Adapter&channelId=Channel1&workflowId=Workflow1&outputFormat=XML

POST data:
My text payload back to XML

[no cookies]

Request Headers:
Connection: keep-alive
Content-Type: text/plain
Content-Length: 27
Host: localhost:8080
User-Agent: Apache-HttpClient/4.2.6 (java 1.5)
```

If the web-service should fail, you will receive an exception in the returned response body.  If the web service call should succeed, you will get a similar response as the following;

```xml
<serializable-adaptris-message>
  <unique-id>a5a4c20e-57ff-4904-86cb-254d40e4053c</unique-id>
  <payload>My text payload back to XML</payload>
  <metadata>
    <key-value-pair>
      <key>fsProduceDir</key>
      <value>C:\Adaptris\Interlok3.0.6\messages_out</value>
    </key-value-pair>
    <key-value-pair>
      <key>producedname</key>
      <value>1442405528819.xml</value>
    </key-value-pair>
    <key-value-pair>
      <key>adpnextmlemarkersequence</key>
      <value>2</value>
    </key-value-pair>
  </metadata>
</serializable-adaptris-message>
```

Should you have specified JSON as the returned message type, then your raw POST request will look like this;

```
POST http://<host>:<port>/adp-restful-services/rest/service/submitpayload?adapterId=FS-FS-Adapter&channelId=Channel1&workflowId=Workflow1&outputFormat=JSON

POST data:
My text payload back to JSON

[no cookies]

Request Headers:
Connection: keep-alive
Content-Type: text/plain
Content-Length: 27
Host: localhost:8080
User-Agent: Apache-HttpClient/4.2.6 (java 1.5)
```

And the successful response body will look similar to this;

```json
{
    "serializable-adaptris-message": {
        "unique-id": "f55a8313-3074-428a-b7e8-6454cbb5433f",
        "payload": "My text payload back to JSON",
        "metadata": [{
            "key-value-pair": [{
                "key": "fsProduceDir",
                "value": "C:\\Adaptris\\Interlok3.0.6\\messages_out"
            }, {
                "key": "producedname",
                "value": "1442405528853.xml"
            }, {
                "key": "adpnextmlemarkersequence",
                "value": 2
            }]
        }]
    }
}
```

## Asynchronous Services ##

**since 3.0.6**

### executeMessage ###

This service is a variation of `submitMessage` but does not require Java 1.8; and will only return true (or false) depending on whether the message was successfully injected into the workflow. As long as the workflow and channel in your Interlok configuration has a unique-id, you can target any workflow to process your message.

#### Parameters ####

There are 4 parameters and the POST data required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| channelId | This is the unique ID of the targeted channel.|
| workflowId | This is the unique ID of the targeted workflow.|
| inputFormat | Specifies the format of the supplied message; currently supported formats are JSON and XML|
| POST data | The message is the XStream marshalled instance of the following class [SerializableMessage][]. For more information on the SerializableAdaptrisMessage, please see the java-doc for this class. |


#### Example ####

Using the same adapter configuration above, assuming our supplied message is XStream marshalled into XML, our raw HTTP POST request would be;

```
POST http://<host>:<port>/adp-restful-services/rest/service/executemessage?adapterId=FS-FS-Adapter&channelId=Channel1&workflowId=Workflow1&inputFormat=XML

POST data:
<serializable-adaptris-message>
  <unique-id>MyMessageID</unique-id>
  <payload>My awesome XML payload no return</payload>
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

[no cookies]

Request Headers:
Connection: keep-alive
Content-Type: text/plain
Content-Length: 522
Host: localhost:8080
User-Agent: Apache-HttpClient/4.2.6 (java 1.5)
```

If your message was successfully submitted to the workflow then you will get a simple true/false response returned.

### executePayload ###

This service is very similar to the execute method above, but simpoly allows you to provide a raw payload in the requests POST body.

### Parameters ###

There are 3 parameters and the POST data required for this service.

| Parameter | Description |
|----|----|
| adapterId| This is the unique-id of the running Interlok adapter instance.|
| channelId | This is the unique ID of the targeted channel.|
| workflowId | This is the unique ID of the targeted workflow.|
| POST data | Your text payload that you wish to inject into a workflow. |


### Example ###

Using the same adapter configuration above, our raw HTTP POST request, using some random XML as the payload, could be;

```
POST http://<host>:<port>/adp-restful-services/rest/service/executepayload?adapterId=FS-FS-Adapter&channelId=Channel1&workflowId=Workflow1

POST data:
<resources>
  <resource>
    <directory>myDirectory</directory>
    <filtering>true</filtering>
    <random>
      <exclude>context.file</exclude>
    </random>
  </resource>
</resources>

[no cookies]

Request Headers:
Connection: keep-alive
Content-Type: text/plain
Content-Length: 213
Host: localhost:8080
User-Agent: Apache-HttpClient/4.2.6 (java 1.5)
```

If your message was successfully submitted to the workflow then you will get a simple true/false response returned.


[SerializableMessage]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/SerializableAdaptrisMessage.html