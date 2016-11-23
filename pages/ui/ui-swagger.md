---
title: Generate Config from Swagger YAML
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-swagger.html
toc: false
summary: Since 3.5.0 the gui config page allows you to open a simple Swagger configuration file (yaml or json). It will be converted to an Adapter xml configuration files supporting the defined http rest services.
---

## Swagger Example ##

Below is an example of a Swagger configuration that can be converted to an adapter Configuration (the JSON equivalent works the same way).

```yaml
swagger: '2.0'
info:
  title: Rest API
  description: My Example Rest API
  version: "1.0.0"
# the domain of the service
host: your.domain.com:80
# array of all schemes that your API supports
schemes:
  - http
# will be prefixed to all paths
basePath: /
produces:
  - application/json
paths:
  /path/to/weather/service/:
    get:
      summary: My Weather Service
      description: |
       Get daily weather data based on a latitude, longitude and date.
      parameters:
        - name: lat
          in: query
          description: Latitude component of location, e.g. 51.501364
          required: true
          type: number
          format: double
        - name: lon
          in: query
          description: Longitude component of location, e.g. -0.14189
          required: true
          type: number
          format: double
        - name: date
          in: query
          required: true
          type: string
          format: dateTime
          description: The date in yyyy-MM-dd'T'HH:mm:ssX e.g. 2016-01-01T12:00:00Z
      tags:
        - weather
      responses:
        200:
          description: The Weather
        400:
          description: Problem with Parameters
        500:
          description: Unexpected error
  /path/to/converter/service:
    get:
      summary: Convert currency
      description: Convert teh given currency to a different currency
      parameters:
        - name: amount
          in: query
          description: Amount to convert
          required: true
          type: number
          format: double
        - name: from
          in: query
          description: Currency to convert from
          required: true
          type: number
          format: string
        - name: to
          in: query
          description: Currency to convert to
          required: true
          type: number
          format: string
      tags:
        - currency
      responses:
        200:
          description: The New Amount
        400:
          description: Problem with Parameters
        500:
          description: Unexpected error
```

This will give an Adapter configuration xml like:

```xml
<adapter>
  <unique-id>Rest API</unique-id>
  <start-up-event-imp>com.adaptris.core.event.StandardAdapterStartUpEvent</start-up-event-imp>
  <heartbeat-event-imp>com.adaptris.core.HeartbeatEvent</heartbeat-event-imp>
  <log-handler class="null-log-handler"/>
  <shared-components/>
  <event-handler class="default-event-handler">
    <unique-id>DefaultEventHandler</unique-id>
    <connection class="null-connection">
      <unique-id>NullConnection-2052748</unique-id>
    </connection>
    <producer class="null-message-producer">
      <unique-id>NullMessageProducer-7760592</unique-id>
    </producer>
  </event-handler>
  <message-error-handler class="null-processing-exception-handler">
    <unique-id>NullProcessingExceptionHandler-2611066</unique-id>
  </message-error-handler>
  <failed-message-retrier class="no-retries"/>
  <channel-list>
    <channel>
      <consume-connection class="jetty-embedded-connection">
        <unique-id>Embedded Jetty Connection</unique-id>
        <host>your.domain.com:80</host>
      </consume-connection>
      <produce-connection class="null-connection">
        <unique-id>NullConnection-1665559</unique-id>
      </produce-connection>
      <workflow-list>
        <pooling-workflow>
          <consumer class="jetty-message-consumer">
            <unique-id>/path/to/converter/service</unique-id>
            <destination class="configured-consume-destination">
              <configured-thread-name>Convert currency</configured-thread-name>
              <destination>/path/to/converter/service</destination>
              <filter-expression>GET</filter-expression>
            </destination>
            <warn-after-message-hang-millis>20000</warn-after-message-hang-millis>
            <parameter-handler class="jetty-http-parameters-as-metadata"/>
            <header-handler class="jetty-http-ignore-headers"/>
          </consumer>
          <service-collection class="service-list">
            <unique-id>ServiceList-2371968</unique-id>
            <services>
              <standalone-producer>
                <unique-id>SendResponse</unique-id>
                <connection class="null-connection">
                  <unique-id>NullConnection-4170774</unique-id>
                </connection>
                <producer class="jetty-standard-reponse-producer">
                  <unique-id>ResponseProducer</unique-id>
                  <status-provider class="http-configured-status">
                    <status>OK_200</status>
                    <text>The New Amount</text>
                  </status-provider>
                  <response-header-provider class="jetty-no-response-headers"/>
                  <content-type-provider class="http-configured-content-type-provider">
                    <mime-type>application/json</mime-type>
                  </content-type-provider>
                  <send-payload>true</send-payload>
                </producer>
              </standalone-producer>
            </services>
          </service-collection>
          <producer class="null-message-producer">
            <unique-id>NullMessageProducer-8532789</unique-id>
          </producer>
          <send-events>false</send-events>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>Convert currency</unique-id>
        </pooling-workflow>
        <pooling-workflow>
          <consumer class="jetty-message-consumer">
            <unique-id>/path/to/weather/service/</unique-id>
            <destination class="configured-consume-destination">
              <configured-thread-name>My Weather Service</configured-thread-name>
              <destination>/path/to/weather/service/</destination>
              <filter-expression>GET</filter-expression>
            </destination>
            <warn-after-message-hang-millis>20000</warn-after-message-hang-millis>
            <parameter-handler class="jetty-http-parameters-as-metadata"/>
            <header-handler class="jetty-http-ignore-headers"/>
          </consumer>
          <service-collection class="service-list">
            <unique-id>ServiceList-3617011</unique-id>
            <services>
              <standalone-producer>
                <unique-id>SendResponse</unique-id>
                <connection class="null-connection">
                  <unique-id>NullConnection-4097164</unique-id>
                </connection>
                <producer class="jetty-standard-reponse-producer">
                  <unique-id>ResponseProducer</unique-id>
                  <status-provider class="http-configured-status">
                    <status>OK_200</status>
                    <text>The Weather</text>
                  </status-provider>
                  <response-header-provider class="jetty-no-response-headers"/>
                  <content-type-provider class="http-configured-content-type-provider">
                    <mime-type>application/json</mime-type>
                  </content-type-provider>
                  <send-payload>true</send-payload>
                </producer>
              </standalone-producer>
            </services>
          </service-collection>
          <producer class="null-message-producer">
            <unique-id>NullMessageProducer-8858341</unique-id>
          </producer>
          <send-events>false</send-events>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>My Weather Service</unique-id>
        </pooling-workflow>
      </workflow-list>
      <unique-id>Rest API</unique-id>
      <auto-start>false</auto-start>
    </channel>
  </channel-list>
  <message-error-digester class="standard-message-error-digester">
    <digest-max-size>100</digest-max-size>
    <unique-id>ErrorDigest</unique-id>
  </message-error-digester>
</adapter>
```
