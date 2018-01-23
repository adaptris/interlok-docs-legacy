---
title: Generate Config from Swagger YAML
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-swagger.html
toc: false
summary: Since 3.5.0 the gui config page allows you to open a simple Swagger configuration file (yaml or json). It will be converted to an Adapter xml configuration files supporting the defined http rest services.
---

<iframe width="560" height="315" src="https://www.youtube.com/embed/xeZVjyjmVto" frameborder="0" allowfullscreen></iframe>

## Adapter Swagger Example ##

Since 3.7.0 the generated xml configuration will depends on how your swagger configuration is designed:

- If the swagger config uses different paths, like `/path/to/weather/service/` and `/path/to/converter/service` for instance, a [Pooling Workflow](#using-pooling-workflow) will be used.
- If the swagger config uses the same path with different HTTP methods or some URL params, like `/contacts` and `/contacts/{contactId}` with post, put and delete HTTP method for instance, a [Jetty Routing Service](#using-jetty-routing-service) will be used.

Both can be used at the same time and in that case the XML configuration will have a mix of Pooling Workflows and Jetty Routing Service.

## Using Pooling Workflow ##

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
                <producer class="jetty-standard-response-producer">
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
                <producer class="jetty-standard-response-producer">
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

## Using Jetty Routing Service ##

Below is an example of a Swagger configuration that can be converted to an adapter Configuration (the JSON equivalent works the same way).

```yaml
swagger: "2.0"
info:
  title: Simple Contact Manager
  description: This is a simple little contact manager database.
  version: "1.0.0"
host: test.host.com:8080
# array of all schemes that your API supports
schemes:
  - http
# will be prefixed to all paths
basePath: /
produces:
  - application/json
paths:
  /contacts:
    post:
      summary: "Add a new contact"
      consumes:
      - "application/json"
      produces:
      - "application/json"
      parameters:
      - in: "body"
        name: "body"
        description: "Contact that needs to be added."
        required: true
        schema:
          $ref: "#/definitions/Contact"
      responses:
        400:
          description: "Couldn't handle it"
        500:
          description: "Error during processing"
        200:
          description: "successful operation"
          schema:
            $ref: "#/definitions/ContactId"
    get:
      summary: "Get All the contacts"
      produces:
      - "application/json"
      responses:
        400:
          description: "Couldn't handle it"
        500:
          description: "Error during processing"
        200:
          description: "successful operation"
          schema:
              $ref: "#/definitions/DatabaseResult"
  /contacts/{contactId}:
    get:
      summary: "Get a contact by contactId"
      description: ""
      produces:
      - "application/json"
      parameters:
      - name: "contactId"
        in: "path"
        description: "The ID that needs to be fetched."
        required: true
        type: "string"
      responses:
        400:
          description: "Couldn't handle it"
        500:
          description: "Error during processing"
        200:
          description: "successful operation"
          schema:
            $ref: "#/definitions/DatabaseResult"
    delete:
      summary: "Delete a contact by contactId"
      description: ""
      produces:
      - "application/json"
      parameters:
      - name: "contactId"
        in: "path"
        description: "The ID that needs to be deleted."
        required: true
        type: "string"
      responses:
        400:
          description: "Couldn't handle it"
        500:
          description: "Error during processing"
        200:
          description: "successful operation"
          schema:
            $ref: "#/definitions/ContactDeleted"
    patch:
      summary: "Update an existing contact"
      consumes:
      - "application/json"
      produces:
      - "application/json"
      parameters:
      - name: "contactId"
        in: "path"
        description: "The ID that needs to be patched."
        required: true
        type: "string"
      - in: "body"
        name: "body"
        description: "Contact that should be modified"
        required: true
        schema:
          $ref: "#/definitions/Contact"
      responses:
        400:
          description: "Couldn't handle it"
        500:
          description: "Error during processing"
        200:
          description: "successful operation"
          schema:
            $ref: "#/definitions/DatabaseResult"
definitions:
  ContactId:
    type: "object"
    properties:
      id:
        type: "string"
        example: "ee57e611-1498-4652-a37c-12d55e686ca5"
  ContactDeleted:
    type: "object"
    properties:
      id:
        type: "string"
        example: "ee57e611-1498-4652-a37c-12d55e686ca5"
      status:
        type: "string"
        enum:
        - "deleted"
  DatabaseContact:
    type: "object"
    properties:
      id:
        type: "string"
        example: "ee57e611-1498-4652-a37c-12d55e686ca5"
      FirstName:
        type: "string"
        example: "John"
      LastName:
        type: "string"
        example: "Smith"
      Email:
        type: "string"
        example: "john.smith@abclabs.com"
      Phone:
        type: "string"
        example: "+44 1234 56789"
      LastUpdated:
        type: "string"
        example: "2017-05-07 15:13:38.0"
      Created:
        type: "string"
        example: "2017-05-07 15:13:38.0"
  Contact:
    type: "object"
    required:
    - "FirstName"
    - "LastName"
    - "Email"
    - "Phone"
    properties:
      FirstName:
        type: "string"
        example: "John"
      LastName:
        type: "string"
        example: "Smith"
      Email:
        type: "string"
        example: "john.smith@abclabs.com"
      Phone:
        type: "string"
        example: "+44 1234 56789"
  DatabaseResult:
    type: "object"
    properties:
      result:
        type: "array"
        items:
          $ref: "#/definitions/DatabaseContact"

```

This will give an Adapter configuration xml like:

```xml
<adapter>
  <unique-id>Simple Contact Manager</unique-id>
  <start-up-event-imp>com.adaptris.core.event.StandardAdapterStartUpEvent</start-up-event-imp>
  <heartbeat-event-imp>com.adaptris.core.HeartbeatEvent</heartbeat-event-imp>
  <shared-components>
    <connections/>
    <services/>
  </shared-components>
  <event-handler class="default-event-handler">
    <unique-id>DefaultEventHandler</unique-id>
    <connection class="null-connection">
      <unique-id>grave-bhaskara</unique-id>
    </connection>
    <producer class="null-message-producer">
      <unique-id>sad-perlman</unique-id>
    </producer>
  </event-handler>
  <message-error-handler class="null-processing-exception-handler">
    <unique-id>pensive-rosalind</unique-id>
  </message-error-handler>
  <failed-message-retrier class="no-retries">
    <unique-id>sick-noyce</unique-id>
  </failed-message-retrier>
  <channel-list>
    <channel>
      <consume-connection class="jetty-embedded-connection">
        <unique-id>Embedded Jetty Connection</unique-id>
      </consume-connection>
      <produce-connection class="null-connection">
        <unique-id>small-ride</unique-id>
      </produce-connection>
      <workflow-list>
        <standard-workflow>
          <consumer class="jetty-message-consumer">
            <unique-id>/contacts/*</unique-id>
            <destination class="configured-consume-destination">
              <destination>/contacts/*</destination>
            </destination>
            <parameter-handler class="jetty-http-parameters-as-metadata"/>
            <header-handler class="jetty-http-ignore-headers"/>
          </consumer>
          <service-collection class="service-list">
            <unique-id>eager-borg</unique-id>
            <services>
              <branching-service-collection>
                <unique-id>HTTP Router</unique-id>
                <services>
                  <jetty-routing-service>
                    <unique-id>Route</unique-id>
                    <route>
                      <url-pattern>^/contacts/(.*)$</url-pattern>
                      <method>DELETE</method>
                      <metadata-key>contactId</metadata-key>
                      <service-id>Delete a contact by contactId</service-id>
                    </route>
                    <route>
                      <url-pattern>^/contacts/(.*)$</url-pattern>
                      <method>GET</method>
                      <metadata-key>contactId</metadata-key>
                      <service-id>Get a contact by contactId</service-id>
                    </route>
                    <route>
                      <url-pattern>^/contacts/(.*)$</url-pattern>
                      <method>PATCH</method>
                      <metadata-key>contactId</metadata-key>
                      <service-id>Update an existing contact</service-id>
                    </route>
                    <route>
                      <url-pattern>^/contacts$</url-pattern>
                      <method>GET</method>
                      <service-id>Get All the contacts</service-id>
                    </route>
                    <route>
                      <url-pattern>^/contacts$</url-pattern>
                      <method>POST</method>
                      <service-id>Add a new contact</service-id>
                    </route>
                    <default-service-id>NotHandled</default-service-id>
                  </jetty-routing-service>
                  <service-list>
                    <unique-id>Delete a contact by contactId</unique-id>
                    <services/>
                  </service-list>
                  <service-list>
                    <unique-id>Get a contact by contactId</unique-id>
                    <services/>
                  </service-list>
                  <service-list>
                    <unique-id>Update an existing contact</unique-id>
                    <services/>
                  </service-list>
                  <service-list>
                    <unique-id>Get All the contacts</unique-id>
                    <services/>
                  </service-list>
                  <service-list>
                    <unique-id>Add a new contact</unique-id>
                    <services/>
                  </service-list>
                  <service-list>
                    <unique-id>NotHandled</unique-id>
                    <services>
                      <add-metadata-service>
                        <unique-id>Add 400 Response Code</unique-id>
                        <metadata-element>
                          <key>ResponseCode</key>
                          <value>400</value>
                        </metadata-element>
                      </add-metadata-service>
                      <payload-from-metadata-service>
                        <unique-id>Add Not Handled Status Message</unique-id>
                        <metadata-tokens/>
                        <template><![CDATA[{"Status" : "Not Handled; please check"}]]></template>
                      </payload-from-metadata-service>
                    </services>
                  </service-list>
                </services>
                <first-service-id>Route</first-service-id>
              </branching-service-collection>
              <standalone-producer>
                <unique-id>SendResponse</unique-id>
                <connection class="null-connection">
                  <unique-id>pensive-blackwell</unique-id>
                </connection>
                <producer class="jetty-standard-response-producer">
                  <unique-id>ResponseProducer</unique-id>
                  <status-provider class="http-metadata-status">
                    <code-key>ResponseCode</code-key>
                    <default-status>OK_200</default-status>
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
            <unique-id>sad-brattain</unique-id>
          </producer>
          <produce-exception-handler class="null-produce-exception-handler"/>
          <unique-id>contacts API</unique-id>
        </standard-workflow>
      </workflow-list>
      <unique-id>Simple Contact Manager</unique-id>
      <auto-start>false</auto-start>
    </channel>
  </channel-list>
  <message-error-digester class="standard-message-error-digester">
    <unique-id>ErrorDigest</unique-id>
    <digest-max-size>100</digest-max-size>
  </message-error-digester>
</adapter>
```

## Channel Swagger Example ##

Since 3.6.3 the gui config page allows you to create a channel using a simple Swagger configuration file (yaml or json).
It will be converted to an Channel xml configuration files supporting the defined http rest services.

To create a channel using a Swagger config you simply need to click on the *Add Channel* button and once the modal is opened select *Swagger Snippet*.
You can then copy a Swagger config or just drag and drop a _swagger.yaml_ or _swagger.json_ file into the text area.

