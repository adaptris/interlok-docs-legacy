---
title: JSON Data transformations
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-json-transform.html
summary: Using the JSON packge to perform JSON/XML and JSON to JSON transformations
---

{% include important.html content="in 3.8.0; adp-json and adp-simple-csv were renamed to interlok-json and interlok-csv respectively" %}

The [interlok-json][] optional package handles JSON documents within the framework. It supports the majority of operations that are available for XML within the base packages. It is included as an optional package because it introduces a significant number of additional dependencies.  The key features are described here; some JSON specific implementations are also available to support other services such as [jdbc-json-first-resultset-output][] for [jdbc-data-query-service][]; [routing-json-path-syntax-identifier][] for [syntax-routing-service][]; [json-array-splitter][], [json-path-splitter][] as a [MessageSplitter][] implementation.

## JSON Path ##

Similar to XPath, there is a defacto standard for extracting data from a JSON document. We use [JsonPath][] as our implementation; their documentation on [github][JsonPath] is replicated in the javadocs for [json-path-service][] as a handy reminder, however you should always treat the original [JsonPath][] documentation as the canonical source.

For a given document shown below

```json
{
  "rectangle" : {
    "length" : 5,
    "breadth" : 5
  }
}
```

We can extract the rectangle's length and breadth into metadata by using the following service definition :

```xml
<json-path-service>
  <source class="string-payload-data-input-parameter"/>
  <json-path-execution>
    <source class="constant-data-input-parameter">
      <value>$.rectangle.length</value>
    </source>
    <target class="metadata-data-output-parameter">
      <metadata-key>length</metadata-key>
    </target>
  </json-path-execution>
  <json-path-execution>
    <source class="constant-data-input-parameter">
      <value>$.rectangle.breadth</value>
    </source>
    <target class="metadata-data-output-parameter">
      <metadata-key>breadth</metadata-key>
    </target>
  </json-path-execution>
</json-path-service>
```

Since __3.6.4__ you have the option of extract all top level fields as metadata directly using [json-to-metadata][] (nested objects are effectively converted into strings) as a convenience service if you need all the data from a simple JSON document exposed as metadata.

## Native JSON transformations ##

You can use [JOLT][] to perform direct JSON to JSON mappings. This is useful if you need to structurally change the JSON document (removing elements, changing objects into arrays) but it does not have any of the advanced features that are available in XSLT; if you do need those, [consider converting to XML](#json-to-xml), using [standard xslt](cookbook-xml-transform.html), and then rendering back to JSON again.

Again, the documentation from the [JOLT github][JOLT] page is replicated as part of the javadocs for [json-transform-service][], but you should always consider the [JOLT github][JOLT] documentation as the canonical source. The only addition that we have added is support for arbitrary metadata to be inserted into the transform directive as constant values. So, for instance if you had a standard _swagger.json_ document generated from swagger.yml (you can use [yaml-to-json][] to do this), and you wanted to change the `host` field to be something that was defined in metadata then you could use the following mapping specification (where `adapter.api.hostname` is the metadata key you want to use.)

```json
[{
    "operation": "remove",
    "spec": {
        "host": ""
    }
}, {
    "operation": "shift",
    "spec": {
        "*": "&",
        "#${adapter.api.hostname}": "host"
    }
}]
```

Giving a resulting configuration of

```xml
<json-transform-service>
  <mapping-spec class="file-data-input-parameter">
    <destination class="configured-destination">
      <destination>file:///path/to/my/mapping.json</destination>
    </destination>
  </mapping-spec>
  <metadata-filter class="regex-metadata-filter"/>
</json-transform-service>
```

### Custom transform operations ###

We also provide [com.adaptris.core.transform.json.jolt.EmptyStringToNull][] and [com.adaptris.core.transform.json.jolt.NullToEmptyString][] as possible operations to convert all null/empty string instances into something else, so `{"empty": null}` would be transformed to `{"empty":""}` by `com.adaptris.core.transform.json.jolt.EmptyStringToNull`.

## JSON to XML ##

You can convert to and from XML via [json-xml-transform-service][] by specifying the direction and driver; there are a number of available drivers, and they are discussed more fully here. It's fully expected that when rendering XML as JSON you will need to execute a transform to get the document into the right format for the driver implementation chosen.

{% include note.html content="Choosing a JSON->XML driver implementation may impact downstream stylesheets as the output can be different." %}


### Driver implementations ###

|Implementation| Description|
|----|----
|[simple-transformation-driver][]| The simplest driver that uses [json.org][] as the implementation. It adds a root element `json` or `json-array` depending on the JSON received, each fieldname in the JSON document creates a new XML element. This is the preferred implementation if you are using relatively simple JSON documents and you know that the fieldnames aren't invalid XML element names; if fieldnames contain invalid XML characters, then output will still be generated, but subsequent XML parsing steps will fail.|
|[default-transformation-driver][]| The default driver based on [json-lib][]. It allows you to provide type hints for conversion purposes, and supports both json objects and arrays converted to and from XML; XML that should be rendered as a json array with a single element is possible; this would not be the case with [simple-transformation-driver][]. It will also attempt to make XML names _safe_ according to the XML specification; if fieldnames contain invalid XML characters, then the XML output will not accurately reflect the JSON field.|
|[json-array-transformation-driver][]| Same behaviour as [default-transformation-driver][] but only allows json arrays|
|[json-object-transformation-driver][]| Same behaviour as [default-transformation-driver][] but only allows json objects|
|[json-safe-transformation-driver][]| _Since 3.6.4_ Same behaviour as [default-transformation-driver][] but strips any formatting prior to rendering XML as JSON as [default-transformation-driver][] can be sensitive to whitespace. Since you are very likely to be executing a stylesheet to get your data into the right format anyway, you should use `<xsl:strip-space elements="*" />` appropriately in your stylesheet.|

{% include tip.html content="The general rule of thumb is if the JSON in question is simple, then use [simple-transformation-driver][], otherwise use a variation of [default-transformation-driver][] as appropriate." %}

## JSON to CSV ##

Since 3.6.6 you can convert to and from CSV via the [interlok-csv-json][] optional package. This adds new services that allow you to easily convert JSON to CSV and vice versa. It has a dependency on both [interlok-csv][] and [interlok-json][].

## JSON Schema ##

You can use [json-schema-service] to validate that a document conforms to a specific schema. You can also define specific behaviour if schema validation fails (the default is to throw an exception detailing all the schema violations).

If we revisit the JSON document from [JSON Path](#json-path) then we could define our schema thus:

```json
{
    "type" : "object",
    "properties" : {
        "rectangle" : {"$ref" : "#/definitions/Rectangle" }
    },
    "definitions" : {
        "size" : {
            "type" : "number",
            "minimum" : 0
        },
        "Rectangle" : {
            "type" : "object",
            "properties" : {
                "length" : {"$ref" : "#/definitions/size"},
                "breadth" : {"$ref" : "#/definitions/size"}
            }
        }
    }
}
```
along with configuration, which will throw an exception for error handling if the document does not conform to the schema.

```xml
<json-schema-service>
  <schema-url class="file-data-input-parameter">
    <destination class="configured-destination">
       <destination>file:///./config/schema.rectangle.json</destination>
    </destination>
  </schema-url>
</json-schema-service>
```



[interlok-json]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-json/
[jdbc-json-first-resultset-output]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/json/jdbc/JdbcJsonOutput.html
[jdbc-data-query-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/jdbc/JdbcDataQueryService.html
[routing-json-path-syntax-identifier]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/services/routing/json/JsonPathSyntaxIdentifier.html
[syntax-routing-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/routing/SyntaxRoutingService.html
[JOLT]: https://github.com/bazaarvoice/jolt
[JsonPath]: https://github.com/jayway/JsonPath
[json-path-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/services/path/json/JsonPathService.html
[json-array-splitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/services/splitter/json/JsonArraySplitter.html
[MessageSplitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/splitter/MessageSplitter.html
[json-to-metadata]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/json/JsonToMetadata.html
[json-transform-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/JsonTransformService.html
[json-xml-transform-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/JsonXmlTransformService.html
[json.org]: http://www.json.org/java/index.html
[simple-transformation-driver]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/SimpleJsonTransformationDriver.html
[default-transformation-driver]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/DefaultJsonTransformationDriver.html
[json-lib]: http://json-lib.sourceforge.net/
[json-array-transformation-driver]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/JsonArrayTransformationDriver.html
[json-object-transformation-driver]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/JsonObjectTransformationDriver.html
[json-safe-transformation-driver]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/SafeJsonTransformationDriver.html
[yaml-to-json]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/YamlToJsonService.html
[json-schema-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/json/schema/JsonSchemaService.html
[com.adaptris.core.transform.json.jolt.EmptyStringToNull]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/jolt/EmptyStringToNull.html
[com.adaptris.core.transform.json.jolt.NullToEmptyString]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/transform/json/jolt/NullToEmptyString.html
[json-path-splitter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-json/3.8-SNAPSHOT/com/adaptris/core/services/splitter/json/JsonPathSplitter.html
[interlok-csv-json]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-csv-json/
[interlok-csv]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-csv/
