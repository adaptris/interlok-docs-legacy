---
title: Service Tester - Configuration
keywords: interlok
tags: [service-tester]
sidebar: home_sidebar
permalink: service-tester-configuration.html
---
## Configuration ##

Those familiar with Interlok config should have no problem traversing they're way through `service-test` configuration, as if it uses the same approach (and code) to go from configuration to execution.

There is hierarchy of configuration this is as follows:

 - A `service-test` contains a `test-client`.
 - A `service-test` contains a `test-list`.
 - A `test-list` contains multiple `test` entities.
 - A `test` contains a `service-to-test`.
 - A `service-to-test` contains a `source`
 - A `service-to-test` optionally contains `preprocessors`.
 - A `preprocessors` entity contains `preprocessor`.
 - A `test` contains multiple `test-case` entities.
 - A `test-case` optionally contains a `input-message-provider`
 - A `input-message-provider` contains a `payload-provider` and `metadata-provider`.
 - A `test-case` contains `assertions`.
 - A `assertions` entity contains `assertion` entities.

## Elements

The easiest way to check what configuration options are avaialble in using the [examples][].

| Element                                                                           | Description                                                                                   | Multiple | Optional |
|-----------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|----------|----------|
| `/service-test`                                                                   | Root element of service tester                                                                | false    | false    |
| `/service-test/test-client`                                                       | Client used to execute tests, can be: `embedded-jmx-test-client`, `external-jmx-test-client`  | false    | false    |
| `/service-test/test-list`                                                         | The container for `test` entities to allow separation                                         | true     | true     |
| `/service-test/test-list/test`                                                    | The container for `service-to-test` and `test-case` entities                                  | true     | true     |
| `/service-test/test-list/test/service-to-test/source`                             | The `source` for `service-to-test`, can be `file-source` or `inline-source`                   | false    | false    |
| `/service-test/test-list/test/service-to-test/preprocessors`                      | The container for `preprocessor` entities                                                     | false    | true     |
| `/service-test/test-list/test/service-to-test/preprocessors/preprocessor`         | The `preprocessor` configuration to execute against the `source`                              | true     | true     |
| `/service-test/test-list/test/test-case`                                          | The `test-case` to execute against the `service-to-test`                                      | true     | true     |
| `/service-test/test-list/test/test-case/input-message-provider`                   | The input message configuration built from `metadata-provider` and `payload-provider`         | false    | true     |
| `/service-test/test-list/test/test-case/input-message-provider/metadata-provider` | Provides metadata for input message, can be: `empty-...` or `inline-...`                      | false    | true     |
| `/service-test/test-list/test/test-case/input-message-provider/payload-provider`  | Provides payload for input message, can be: `empty-...`, `file-...` or `inline-...`           | false    | true     |
| `/service-test/test-list/test/test-case/assertions`                               | The container for `assertion` entities                                                        | false    | true     |
| `/service-test/test-list/test/test-case/assertions/assertion`                     | The `assertion` to run against outputted message, ex: `assert-metadata-contains`                | true     | true     |
| `/service-test/test-list/test/test-case/expected-exception`                       | Set the exception expected to be thrown.                                                     | false    | true     |

## Sample ##

### Inline Source

#### Test Configuration

```xml
<service-test>
  <unique-id>AdapterTest</unique-id>
  <test-client class="embedded-jmx-test-client" />
  <test-list>
    <unique-id>TestList</unique-id>
    <test>
      <unique-id>Test1</unique-id>
      <service-to-test>
        <source class="inline-source">
          <xml>
            <![CDATA[
              <add-metadata-service>
              <unique-id>Add1</unique-id>
              <metadata-element>
                <key>key1</key>
                <value>val1</value>
              </metadata-element>
              </add-metadata-service>
            ]]>
          </xml>
        </source>
      </service-to-test>
      <test-case>
        <unique-id>TestCase1</unique-id>
        <input-message-provider class="test-message-provider">
          <payload-provider class="inline-payload-provider">
            <payload><![CDATA[<xml/>]]></payload>
          </payload-provider>
        </input-message-provider>
        <assertions>
          <assert-payload-contains>
            <payload>xml</payload>
          </assert-payload-contains>
          <assert-metadata-contains>
            <metadata>
              <key-value-pair>
                <key>key1</key>
                <value>val1</value>
              </key-value-pair>
            </metadata>
          </assert-metadata-contains>
        </assertions>
      </test-case>
    </test>
  </test-list>
</service-test>
```

### File Source

#### Test Configuration

```xml
<service-test>
  <unique-id>interlok-hello-world</unique-id>
  <test-client class="embedded-jmx-test-client" />
  <test-list>
    <unique-id>service-tests</unique-id>
    <test>
      <unique-id>payload-from-metadata-service</unique-id>
      <service-to-test>
        <source class="file-source">
          <file>config/adapter.xml</file>
        </source>
        <preprocessors>
          <preprocessor class="xpath-preprocessor">
            <xpath>//payload-from-metadata-service</xpath>
          </preprocessor>
        </preprocessors>
      </service-to-test>
      <test-case>
        <unique-id>TestCase1</unique-id>
        <assertions>
          <assert-payload-equals>
            <payload>Hello World!</payload>
          </assert-payload-equals>
        </assertions>
      </test-case>
    </test>
  </test-list>
</service-test>
```

#### Interlok Configuration

```xml
<adapter>
  <unique-id>hello-world</unique-id>
  <channel-list>
    <channel>
      <unique-id>channel</unique-id>
      <consume-connection class="jetty-embedded-connection">
        <unique-id>jetty-embedded-connection</unique-id>
      </consume-connection>
      <produce-connection class="null-connection" />
      <workflow-list>
        <standard-workflow>
          <unique-id>workflow</unique-id>
          <consumer class="jetty-message-consumer">
            <destination class="configured-consume-destination">
              <configured-thread-name>hello-world</configured-thread-name>
              <destination>/*</destination>
            </destination>
            <parameter-handler class="jetty-http-ignore-parameters"/>
            <header-handler class="jetty-http-headers-as-metadata"/>
          </consumer>
          <service-collection class="service-list">
            <services>
              <payload-from-metadata-service>
                <template><![CDATA[Hello World!]]></template>
              </payload-from-metadata-service>
            </services>
          </service-collection>
          <producer class="jetty-standard-response-producer">
            <unique-id>Send HTTP Response</unique-id>
            <status-provider class="http-metadata-status">
              <code-key>adphttpresponse</code-key>
              <default-status>OK_200</default-status>
            </status-provider>
            <response-header-provider class="jetty-metadata-response-headers">
              <filter class="remove-all-metadata-filter"/>
            </response-header-provider>
            <content-type-provider class="http-configured-content-type-provider">
              <mime-type>text/plain</mime-type>
            </content-type-provider>
            <send-payload>true</send-payload>
          </producer>
        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>
```

[examples]: https://nexus.adaptris.net/nexus/service/local/artifact/maven/redirect?r=releases&g=com.adaptris&a=interlok-service-tester&v=LATEST&c=examples