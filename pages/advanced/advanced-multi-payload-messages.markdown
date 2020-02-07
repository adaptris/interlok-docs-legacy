---
title:     "Multi-Payload Messages"
keywords:  "interlok, multi-payload, messages"
tags:      [advanced]
sidebar:   home_sidebar
permalink: advanced-multi-payload-messages.html
summary:   This page describes how to use the Multi-Payload Adaptris Message
---

## New Message Type and Factory

### Multi-Payload Adaptris Message

The Multi-Payload Adaptris Message is a new message type that supports
having multiple payloads in a single message. Each payload can be
accessed by its user-defined ID.

### Multi-Payload Message Factory

The Multi-Payload Message Factory is the standard way to create a new
multi-payload capable message. It can be used instead of the default
message factory, with the option of setting the default payload ID.

```xml
   <message-factory class="multi-payload-message-factory">
       <default-char-encoding>UTF-8</default-char-encoding>
       <default-payload-id>payload-1</default-payload-id>
   </message-factory>
```

## New Services

### Add Payload

The Add Payload Service allows for a new payload to be added to an
existing multi-payload message. The service allows for the new payload
to originate from any Data Input Parameter String.

```xml
    <add-payload-service>
        <unique-id>add-payload-unique-id</unique-id>
        <new-payload-id>payload-2</new-payload-id>
        <new-payload class="file-data-input-parameter">
            <destination class="configured-destination">
                <destination><!-- path to file to include as new payload --></destination>
            </destination>
        </new-payload>
    </add-payload-service>
```

### Switch Payload

The Switch Payload Service allows for the current working payload to be
changed. This is particularly useful if the next service in the workflow
only supports standard messages and the current payload isn't the
desired one.

```xml
    <switch-payload-service>
        <unique-id>switch-payload-unique-id</unique-id>
        <new-payload-id>payload-1</new-payload-id>
    </switch-payload-service>
```

### MIME Encoder

The Multi-Payload Message MIME encoder allows for a multi-payload
message to be both exported and imported, similarly to the existing MIME
encoder/decoder (payload/metadata/etc). Where it differs is its ability
to handle each payload as a separate MIME part. It expects the target
for export and the source for import to be IO streams.

```xml
    <encoder class="com.adaptris.core.MultiPayloadMessageMimeEncoder">
        <metadata-encoding>base64</metadata-encoding>
        <payload-encoding>base64</payload-encoding>
        <retain-unique-id>true</retain-unique-id>
    </encoder>
```

### Message Splitting & Joining

The Multi-Payload Message Splitter allows for a multi-payload message to
be split with each of its payloads becoming a new (standard) message.
This message splitter can be used wherever a message splitter is valid
but does expect the original message to have multiple payloads. This
will copy all metadata keys and values, therefore each split message
will have identical metadata to the original.

The Multi-Payload Message Aggregator allows for a collection of messages
to be merged into a single multi-payload message. The original message
MUST be able to support multiple payloads. Metadata from the collections
of messages is not combined so as not to accidentally overwrite values
with identical keys.

Both of these need further work to properly respect the copy/combine
metadata configuration options that are present in their respective
parent classes.

```xml
    <split-join-service>
        <unique-id>split-join-id</unique-id>
        <service class="shared-service">
            <lookup-name>for-each-service-list-id</lookup-name>
            <unique-id>for-each-service-list-id</unique-id>
        </service>
        <splitter class="multi-payload-splitter"/>
        <aggregator class="multi-payload-aggregator">
            <replace-original-message>false</replace-original-message>
        </aggregator>
    </split-join-service>
```


### For Each

A for-each implementation that iterates over the payloads in a
multi-payload message. For each payload it then executes the given
service (list). By default this process is single threaded but a thread
pool can be used to parallelize the loop.

```xml
    <for-each-payload>
        <unique-id>for-each-id</unique-id>
        <then>
            <service class="shared-service">
                <lookup-name>for-each-service-list-id</lookup-name>
                <unique-id>for-each-service-list-id</unique-id>
            </service>
        </then>
        <thread-count>1</thread-count>
    </for-each-payload>
```

## Data Parameters

### Input

There are three data input parameters that are multi-payload aware, and
as such they require a payload ID from where to get the data. Depending
on the expected data type in the payload, it can be treated as a string,
a byte[] or an input stream.

* Multi-payload string input
* Multi-payload byte[] input
* Multi-payload stream input

### Output

There are also three corresponding data output parameters that will
write data to a new or existing payload.

* Multi-payload string output
* Multi-payload byte[] output
* Multi-payload stream output

### Usage Example XML

As an example of where these may be useful, see the example XML
configuration below for the PGP Encrypt service (which is not
multi-payload aware), but is able to reference three payload. Two for
input: they public key and the plain text to encrypt; and one for
streaming the encrypted cipher text out to a newly created payload.

```xml
    <pgp-encrypt>
        <unique-id>trusting-bohr</unique-id>
        <public-key class="multi-payload-string-input-parameter">
            <payload-id>publickey</payload-id>
        </public-key>
        <clear-text class="multi-payload-byte-array-input-parameter">
            <payload-id>plaintext</payload-id>
        </clear-text>
        <cipher-text class="multi-payload-stream-output-parameter">
            <content-encoding>UTF-8</content-encoding>
            <payload-id>ciphertext</payload-id>
        </cipher-text>
        <armor-encoding>true</armor-encoding>
        <integrity-check>true</integrity-check>
    </pgp-encrypt>
```
