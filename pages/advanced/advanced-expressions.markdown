---
title:     "Resolvable Expressions"
keywords:  "interlok, expressions, messages, metadata"
tags:      [advanced]
sidebar:   home_sidebar
permalink: advanced-expressions.html
summary:   This page describes how to use the expressions available for metadata lookup
---

The expression resolver allows for metadata values, as well as a limited
amount of other message information to be inserted into configuration
to create dynamic values. The screenshot below shows a simple example
where a new payload will be added (to a multi-payload message), where
the new payload ID will be the metadata value associated with
metadata-key.

![Expression Resolver Example](./images/expression-resolver.png)

## Standard Messages

The standard Adaptris Message type has four different expressions for
looking up data.

### Message Unique ID

This will resolve the current message unique ID.

    %message{​%uniqueId}

### Message Payload Size

This will resolve the current payload size, in bytes.

    %message{​%size}

### Message Payload

This will resolve the current payload in its entirety.

    %message{​%payload}

### Metadata Keys

If the expression within `%message` does not start with `%` then it is
treated as a metadata key, and will resolve the associated value. For
instance, if you have a metadata key/value pair `day=Monday` then
`%message{day}` would resolve to `Monday`.

    %message{…}

## Multi-Payload Messages

The following expressions is for referencing any given payload within a
multi-payload message. This can be particularly useful if you want to
keep a history of payload changes; a before and after each service type
of thing.

    %payload{id:…}

## External Resolvers

### Environment

This resolves values based on the associated environment variable. For
example `%env{HOSTNAME}` will return the value of the environment
variable `HOSTNAME`. If the variable not defined then the
variable will be returned as is.

    %env{…}

### System Properties

This resolver will resolve values based on the associated system
property; for example `%sysprop{my.sysprop}` will return the value of
the system property `my.sysprop`. If the property is not defined then
the property name will be returned as is.

    %sysprop{…}

### XPath

The XPath resolver allows for part of an XML payload to be extracted
using an XPath expression.

    %payload{xpath:…}

#### Example

##### XML Payload

```xml
<?xml version="1.0" encoding="utf-8"?>
<Wikimedia>
  <projects>
      <project name="Wikipedia" launch="2001-01-05">
        <editions>
        <edition language="English">en.wikipedia.org</edition>
        <edition language="German">de.wikipedia.org</edition>
        <edition language="French">fr.wikipedia.org</edition>
        <edition language="Polish">pl.wikipedia.org</edition>
        <edition language="Spanish">es.wikipedia.org</edition>
      </editions>
    </project>
    <project name="Wiktionary" launch="2002-12-12">
      <editions>
        <edition language="English">en.wiktionary.org</edition>
        <edition language="French">fr.wiktionary.org</edition>
        <edition language="Vietnamese">vi.wiktionary.org</edition>
        <edition language="Turkish">tr.wiktionary.org</edition>
        <edition language="Spanish">es.wiktionary.org</edition>
      </editions>
    </project>
  </projects>
</Wikimedia>
```

##### Expression

    %payload{xpath:/Wikimedia/projects/project/@name}

##### Resolved Value

    Wikipedia,Wiktionary

### JSON

There is a JSONPath resolver within the `interlok-json` package, which
allows JSON data to be extracted from a message payload.

    %payload{jsonpath:…}

#### Example

##### JSON Payload

```json
{
  "store":
  {
    "book":
    [
      {
        "category": "reference",
        "author": "Nigel Rees",
        "title": "Sayings of the Century",
        "price": 8.95
      },
      {
        "category": "fiction",
        "author": "Evelyn Waugh",
        "title": "Sword of Honour",
        "price": 12.99
      },
      {
        "category": "fiction",
        "author": "Herman Melville",
        "title": "Moby Dick",
        "isbn": "0-553-21311-3",
        "price": 8.99
      },
      {
        "category": "fiction",
        "author": "J. R. R. Tolkien",
        "title": "The Lord of the Rings",
        "isbn": "0-395-19395-8",
        "price": 22.99
      }
    ],
    "bicycle":
    {
      "color": "red",
      "price": 19.95
    }
  },
  "expensive": 10
}
```

##### Expression

    %payload{jsonpath:$.store.book[*].author}

##### Resolved Value

```json
    [ "Nigel Rees", "Evelyn Waugh", "Herman Melville", "J. R. R. Tolkien" ]
```
