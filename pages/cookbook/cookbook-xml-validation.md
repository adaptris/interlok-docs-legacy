---
title: XML Validation
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-xml-validation.html
---

We can use [xml-validation-service] to validate a number of things about an XML document by using a list of [MessageValidator] implementations. Multiple validation steps can be done in a single [xml-validation-service] instance; so you could

- Check that a message matches a given schema
- Check that certain xpaths match given criteria that isn't defined in the schema.

The standard types of [MessageValidator][] are:

| Type | Description |
|----|----
|[xml-basic-validator][]| Validates that the input document is in fact XML |
|[xml-schema-validator][]| Validates that the input document is matches a given schema |
|[xml-rule-validator][]| Validates that the input document matches various criteria |


{% include important.html content="[xml-basic-validator][] tries to create a DOM object from the document. If you have a very large XML document, then this is going to impact performance." %}

## Validating against a schema ##

Validating an XML schema is quite simple; you just need to provide a `schema` location which could be on the local filesystem, hosted remotely and accessible via standard URL handling mechanisms (e.g. http). Optionally you can specify a `schema-metadata-key`; which if present in the message, overrides any configured schema that will be used to validate the message.

```xml
<xml-validation-service>
 <validators>
  <xml-schema-validator>
   <schema>http://myhost.com/schema.xsd</schema>
  </xml-schema-validator>
 </validators>
</xml-validation-service>
```


## XML Rule Validation ##

[xml-rule-validator][] allows us to validate arbitrary elements within the XML against some configured criteria. This is useful if there is a canonical data model, but we know that some parties cannot handle certain values in the XML. Each configured [xml-rule-validator][] is made up of a list of [ValidationStage] instances (which is responsible for iterating over the document) and a list of [ContentValidation] instances associated with each [ValidationStage].

Each [ValidationStage] contains a `iteration-xpath` and `element-xpath` which will be used to iterate over the XML document. For each `Node` returned by the `iteration-xpath`, we execute `element-xpath` on that node and apply all the configured [ContentValidation] instances to the text returned. If validation fails then an exception will be thrown and error handling is triggered.

The basic types of validator are [xml-content-not-null][], [xml-content-is-null][], [xml-content-in-list][], [xml-content-not-in-list][] and [xml-content-regexp][]:


| Rule Validator | Description |
|----|----|
| [xml-content-not-null][] | Asserts that the trimmed content value is not blank  |
| [xml-content-is-null][] | Asserts that the trimmed content value is blank  |
| [xml-content-in-list][] | Asserts that the content __is__ in the list of configured items |
| [xml-content-not-in-list][] | Asserts that the content __is not__ in the list of configured items |
| [xml-content-regexp][] | Asserts that the content matches the configured regular expression |

<br/>

### Example ###

Given the example made up document below; we want to apply the following validation rules:

1. Cronos and Rhea had children
    1. They all have names
    1. Their names must only have alphabetic characters in them.
    1. The names of Cronos and Rhea's children must be one of Zeus, Demeter, Hades, Hera
1. Zeus had quite a few children
    1. They all have names
    1. Zeus's children aren't called Helios, Selene or Eos
1. Poor old Hades didn't have any children.

```xml
<document>
 <parent id="Cronus">
  <child mother="Rhea"><name>Zeus</name></child>
  <child mother="Rhea"><name>Demeter</name></child>
  <child mother="Rhea"><name>Hades</name></child>
  <child mother="Rhea"><name>Hera</name></child>
 </parent>
 <parent id="Coeus">
  <child mother="Phoebe"><name>Asteria</name></child>
  <child mother="Phoebe"><name>Leto</name></child>
 </parent>
 <parent id="Hyperion">
  <child mother="Theia"><name>Helios</name></child>
  <child mother="Theia"><name>Selene</name></child>
  <child mother="Theia"><name>Eos</name></child>
 </parent>
 <parent id="Zeus">
  <child mother="Leto"><name>Apollo</name></child>
  <child mother="Leto"><name>Artemis</name></child>
  <child mother="Hera"><name>Hebe</name></child>
  <child mother="Hera"><name>Ares</name></child>
  <child mother="Hera"><name>Hephaestus</name></child>
  <child mother="Dione"><name>Aphrodite</name></child>
  <child mother="Demeter"><name>Persephone</name></child>
 </parent>
 <parent id="Hades">
 </parent>
</document>
```

Our configuration would be :

```xml
<xml-validation-service>
  <validators>
    <xml-rule-validator>
      <validation-stage>
        <iteration-xpath>/document/parent[@name='Cronos']</iteration-xpath>
        <element-xpath>child[@mother='Rhea']/name</element-xpath>
        <rules>
          <xml-content-not-null/>
          <xml-content-regexp>
            <pattern>[a-zA-Z]+</pattern>
          </xml-content-regex>
          <xml-content-in-list>
            <list-entry>Zeus</list-entry>
            <list-entry>Demeter</list-entry>
            <list-entry>Hades</list-entry>
            <list-entry>Hera</list-entry>
          </xml-content-in-list>
        </rules>
      </validation-stage>
      <validation-stage>
        <iteration-xpath>/document/parent[@id='Zeus']</iteration-xpath>
        <element-xpath>child/name</element-xpath>
        <rules>
          <xml-content-not-null/>
          <xml-content-not-in-list>
            <list-entry>Helios</list-entry>
            <list-entry>Selene</list-entry>
            <list-entry>Eos</list-entry>
          </xml-content-not-in-list>
        </rules>
      </validation-stage>
      <validation-stage>
        <iteration-xpath>/document/parent[@id='Hades']</iteration-xpath>
        <element-xpath>child/name</element-xpath>
        <fail-on-iterate-failure>true</fail-on-iterate-failure>
        <rules>
          <xml-content-is-null/>
        </rules>
      </validation-stage>
    </xml-rule-validator>
  </validators>
</xml-validation-service>
```

{% include note.html content="Iterating over a documentation where `iteration-xpath` returns no nodes will not cause a failure unless `fail-on-iterate-failure=true`." %}

If our document was modified to be

```xml
<document>
 <parent id="Poseidon">
 </parent>
</document>
```

Then validation would fail, but only because `/document/parent[@id='Hades']` does not exist in the document; the other [ValidationStages][ValidationStage] would still pass.


[xml-validation-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/transform/XmlValidationService.html
[xml-basic-validator]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/transform/XmlBasicValidator.html
[xml-schema-validator]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/transform/XmlSchemaValidator.html
[xml-rule-validator]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/transform/XmlRuleValidator.html
[MessageValidator]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/transform/MessageValidator.html
[xml-content-not-null]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/NotNullContentValidation.html
[xml-content-in-list]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/SimpleListContentValidation.html
[xml-content-not-in-list]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/NotInListContentValidation.html
[xml-content-is-null]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/IsNullContentValidation.html
[xml-content-regexp]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/RegexpContentValidation.html
[ContentValidation]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/ContentValidation.html
[ValidationStage]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/transform/validate/ValidationStage.html


