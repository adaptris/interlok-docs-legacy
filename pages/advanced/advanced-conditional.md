---
title: Interlok configuration with logic blocks
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-conditional.html
summary: This page describes how to configure logic blocks inside your Interlok configuration (since 3.9.0)
---

# Adding logic to your configuration

As of Interlok __3.9.0__ you can insert logic statements into your configuration.  Logic statements and blocks allow you to repeat services until a condition is met or execute services if certain conditions are met.
The following guide will walk you through the available logic statements and show you how use them in configuration.


## Logic statements/blocks

We will move onto conditions later in this document, but first we will list the available logic statements and blocks.

### If / Then / Otherwise

Adding this logic block will allow you to test __if__ a condition(s) is met.   __If__ it is met __Then__ run a service or service-list, __Otherwise__ run a separate service or service-list.

An example;

This example checks if your messages metadata named "myKey" has a value of "1".  If it does then the "my-service" is executed, if not then "my-other-service" is executed.

```xml
  <if-then-otherwise>
   <condition class="expression">
     <algorithm>%message{myKey} == 1</algorithm>
    </condition>
   <then>
    <service class="my-service">
    </service>
   </then>
   <otherwise>
    <service class="my-other-service">
    </service>
   </otherwise>
  </if-then-otherwise>
```

### While

__While__ will test your configured conditions and if they are met will run your service or service-list.  __While__ your conditions are still met your services will be repeatedly executed.

An example;

In this example we will check if your messages metadata item named "myKey" has a value equal to "1".  __While__ this is true we will repeatedly run the service "my-service".  We also have a max-loops check which will only allow a maximum repeated execution of your services.

```xml
  <while>
   <condition class="expression">
     <algorithm>%message{myKey} == 1</algorithm>
    </condition>
   <then>
    <service class="my-service">
    </service>
   </then>
   <max-loops>10</max-loops>
  </while>
```

### DoWhile

__DoWhile__ will run your configured service or service-list through once, then will continue to run your service or service-list if your configured conditions are met.
Notice this is different from the above __While__ service, in that __DoWhile__ willl always run your service or service-list at least once.

An example;

In this example your services will be guaranteed to run once, but will then be repeatedly run (up to a maximum number of 10 times) while the messages metadata item named "myKey" has a value equal to "1".

```xml
  <do-while>
   <condition class="expression">
     <algorithm>%message{myKey} == 1</algorithm>
    </condition>
   <then>
    <service class="my-service">
    </service>
   </then>
   <max-loops>10</max-loops>
  </do-while>
```

### Switch

__Switch__ acts a bit like __If / Then / Otherwise__, but allows you to specify a any number of conditions; each one if met will execute your configured service or service-list.  A bit difference here with __Switch__ from __If / Then / Otherwise__ is that multiple conditions could be met, therefore multiple services may be executed.

An Example;

In this example we will check the values of the messages metadata named "myKey1", "myKey2" and "myKey3" are equal to the values "1", "2" and "3", respectively.  In this instance some, all or none of those conditions may be met.  

```xml
  <switch>
   <case>
    <condition class="expression">
     <algorithm>%message{myKey1} == 1</algorithm>
    </condition>
    <service class="service-list">
     <services>
      <my-service-1 />
     </services>
    </service>
   </case>
   <case>
    <condition class="expression">
     <algorithm>%message{myKey2} == 2</algorithm>
    </condition>
    <service class="service-list">
     <services>
      <my-service-2 />
     </services>
    </service>
   </case>
   <case>
    <condition class="expression">
     <algorithm>%message{myKey3} == 3</algorithm>
    </condition>
    <service class="service-list">
     <services>
      <my-service-3 />
     </services>
    </service>
   </case>
  </switch>
```

### ForEach
__Since Interlok 3.9.3__
__ForEach__ is for use only with Multi Payloads.  And this logic block will simply run your service or service-list __ForEach__ of your payloads.

An example;

In this example the "log-message-service" is executed __ForEach__ payload in a multi payload message.  Additionally, we may specify the thread-count.  If the thread-count is higher than 1, say 2 and you have more than 1 payload, say 2, then we will run the log-message-service for both payloads in parallel.

## Conditions

As shown above __Conditions__ allow us to set a test, the result of which will determine if a service or service-list is executed.

### ConditionExpression

__ConditionExpression__ allows us to write simple testing equations.

In this example we take the value of the metadata item "myKey", then add 10 to it before finally checking if the result is equal to 20.

```xml
   <if-then-otherwise>
    <condition class="expression">
     <algorithm>(%message{myKey} + 10) == 20</algorithm>
    </condition>
   ...
```

### ConditionFunction

__ConditionFunction__ allows us to write inline scripts (those compatible with the JVM) to evaluate an condition.

In this example we test if the metadata item "myKey" has a value of "myValue".

```xml
   <if-then-otherwise>
    <function>
     <definition><![CDATA[function evaluateScript(message) { return message.getMetadataValue('mykey').equals('myvalue');}]]></definition>
    </function>
   ...
```

### ConditionAnd

__ConditionAnd__ allows us to check two separate conditions and if both are met, then the main condition is met.

In this example we check that both the metadata key "key1" is not-null __AND__ metadata key "key2" is null.

```xml
  <if-then-otherwise>
   <condition class="and">
    <metadata>
     <operator class="not-null"/>
     <metadata-key>key1</metadata-key>
    </metadata>
    <metadata>
     <operator class="is-null"/>
     <metadata-key>key2</metadata-key>
    </metadata>
   </condition>
  ...
```

### ConditionOr

__ConditionOr__ allows us to check if a condition is true __OR__ if another condition is true.  In this case if either condition is true, then the main condition is met.

In this example we check if the metadata item "key1" is not-null __OR__ if the metadata item "key2" is null.

```xml
  <if-then-otherwise>
   <condition class="or">
    <metadata>
     <operator class="not-null"/>
     <metadata-key>key1</metadata-key>
    </metadata>
    <metadata>
     <operator class="is-null"/>
     <metadata-key>key2</metadata-key>
    </metadata>
   </condition>
  ...
```

### ConditionNot

__ConditionNot__ lets us reverse a condition.  Normally, your conditions must evaluate to true to be met, with __not__ however we test that the condition has __not__ been met.

In this example we reverse the check on whether the metadata item "key1" is null, therefore if the value is not null, the condition will be met.

```xml
  <if-then-otherwise>
   <condition class="not">
    <metadata>
     <operator class="is-null"/>
     <metadata-key>key1</metadata-key>
    </metadata>
   </condition>
  ...
```

### ConditionMetadata

__ConditionMetadata__ is used to specifically test a metadata item together with an __Operator__.

In this example we test that the metadata item "key1" is null.

```xml
   <if-then-otherwise>
    <metadata>
     <operator class="not-null"/>
     <metadata-key>key1</metadata-key>
    </metadata>
   ...
```

### ConditionPayload

__ConditionPayload__ is used to test a single payload with an __Operator__.

In this example we test to see if the value of the payload is "MyPayload".

```xml
   <if-then-otherwise>
    <payload>
     <operator class="equals">
      <value>MyPayload</value>
     </operator>
    </payload>
   ...
```

## Operators

Some of the above conditions will require an additional __Operator__ so that evaluation of the condition can be tested.  Here are the available __Operators__.

### IsNull

This __Operator__ is simply used to check if the condition (payload or metadata item) is null.

### IsEmpty

__IsEmpty__ will test the condition is either null or has no content (empty string).

### NotNull

__NotNull__ will simply test that a value even if it is empty does exist.

### Equals

Tests the equality of two items.

### NotEquals

Tests the inequality of two items.

### Matches

__Matches__ is similar to __Equals__ however you may use a regular expression rather than a static string.