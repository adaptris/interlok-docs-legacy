---
title: Email (POP3/IMAP/SMTP)
keywords: interlok
tags: [cookbook, messaging]
sidebar: home_sidebar
permalink: cookbook-email.html
summary: Interlok can both receive emails via POP3 and IMAP and send emails via SMTP as part of its standard feature set. This guide will show you how to use Interlok to interact with a mail server using these protocols.
---

On a high level:

- Receiving emails is done by using a message consumer that is configured for POP3 or IMAP.
- Sending emails is done by using a message producer that is configured for SMTP.

The worked examples used in this guide all refer to a locally running mail server that has been configured for this exercise. See the [instructions at the end](#setting-up-a-local-test-environment) for how you can set up your very own mail server with a corresponding configuration. To keep the examples simple, all workflows are a combination of a mail consumer with a [fs-producer] or of a [fs-consumer] with a mail producer. Throughout this guide you will find examples with snippets of adapter configuration, which are all taken from the whole configuration file [adapter.xml](./files/cookbook/email/adapter.xml).

# Consumers and producers

Neither of the mail consumers and producers need a connection definition in the channel, so a [null-connection] can be used. The mail server connection details are all configured in the consumer and producer.

Note that JavaMail session properties can be set in addition to the Interlok-specific features that this guide highlights. Please see the the official Java documentation for the [POP3][POP3 Javadocs], [IMAP][IMAP Javadocs] and [SMTP][SMTP Javadocs] session properties.

## Receiving emails

Interlok comes with two email consumers, both of which can connect via POP3 and IMAP:

 - [raw-mail-consumer], which processes emails raw as they are and therefore does not interpret attachments.
 - [default-mail-consumer], which can interpret emails with attachments.

Both consumers are configured with a number of properties, which are introduced in the following sub-sections, followed by some worked examples. The [default-mail-consumer] supports all of these properties, whereas the [raw-mail-consumer] only supports the subset that is not related to dealing with parts. The differences are mentioned where appropriate.

To start though, the following is an overview of some of the key differences. Each consumer outputs different internal Interlok messages depending on whether a multi-part email (i.e. an email with attachments) is being processed. For the [default-mail-consumer] the behaviour differs further depending on whether it has a [part-selector] set (see the [corresponding section](#part-selector-optional-only-default-mail-consumer) for details).

| **Mail consumer** | **Is [part-selector] set** | **Input: Email has multiple parts** | **Output: Message(s) output by consumer** |
| - | - | - | - |
| [raw-mail-consumer] | n/a | no | one (the whole email, being the body) |
| [raw-mail-consumer] | n/a | yes | one (the whole email, being the body and all attachments) |
| [default-mail-consumer] | no | no | one (the whole email, being the body) |
| [default-mail-consumer] | no | yes | multiple (one for body plus one per attachment) |
| [default-mail-consumer] | yes | no | none (since the [part-selector] is not able to select a part) |
| [default-mail-consumer] | yes | yes | one (containing the part the [part-selector] selected) |

Also see the documentation available for [mail-consumer-imp], from which both consumers inherit shared functionality.

Some general built-in behaviour worth noting:

- Interlok only ever consumes emails that are neither marked as read nor as deleted.
- Interlok marks each email consumed as read (however, oddly, with Sun's JavaMail implementation this only has an impact when using IMAP but not POP3).

The combination of the above means that when using IMAP with Sun's JavaMail implementation and even when not deleting consumed emails then Interlok will only consume new emails every time it queries the server. In turn, when using POP3 with Sun's JavaMail implementation this means that the only way to only consume new emails is to delete previously consumed ones. See the [mail receiver factory](#mail-receiver-factory-mandatory) property for using another implementation for POP3, as well as the [delete on receive](#delete-on-receive-optional) property.

### Configuration

#### Destination: protocols and filters

Note: For more information on how to configure the destination and filters please see [mail-consumer-imp], which includes how to put together the destination path, specifically the mailbox at the end of the URL.

The destination property is based on the generic [configured-consume-destination] and may look like this:

```xml
  <destination class="configured-consume-destination">
   <destination>pop3://username:password@server:110/INBOX</destination>
   <filter-expression>FROM=optionalFilter,SUBJECT=optionalFilter,RECIPIENT=optionalFilter</filter-expression>
  </destination>
  [...]
  <regular-expression-style>GLOB</regular-expression-style>
```

##### Protocols supported in the destination

Both consumers are able to receive from POP3, POP3S, IMAP and IMAPS simply by using the corresponding protocol in the destination, for example:

- `pop3://username:password@server:110/INBOX`
- `pop3s://myusername%40gmail.com:mypassword@pop.gmail.com:995/INBOX`
- `imap://myusername:mypassword@my.imap.server:143/INBOX`
- `imaps://myusername%40gmail.com:mypassword@imap.gmail.com:993/INBOX`

Note that user name and password can also be set via the dedicated corresponding properties `username` and `password` directly on the consumer, which will then allow having them encrypted in the XML.

##### Filters (optional)

It is also possible to define an optional filter expression, which is a comma-separated list in which filters for `FROM`, `SUBJECT` and `RECIPIENT` may be defined (in any order, the keys are case-insensitive).

```xml
<filter-expression>FROM=optionalFilter,SUBJECT=optionalFilter,RECIPIENT=optionalFilter</filter-expression>
```

The actual type of the expressions is defined by the `regular-expression-style` property of the consumer (i.e. not within the [configured-consume-destination], but on the same level as it). Values may be `GLOB` (default if omitted), `AWK` or `PERL5` .

```xml
  <regular-expression-style>GLOB</regular-expression-style>
```

#### Poller (mandatory)

The poller determines when Interlok will fetch new mails. Choose an implementation of [poller], for example a straightforward [fixed-interval-poller] or a more flexible [quartz-cron-poller].
The following examples are interchangeable and will trigger the consumer every 10 minutes:

```xml
  <poller class="fixed-interval-poller">
   <poll-interval>
    <unit>MINUTES</unit>
    <interval>10</interval>
   </poll-interval>
  </poller>
```

```xml
  <poller class="quartz-cron-poller">
   <cron-expression>00 */10 * * * ?</cron-expression>
  </poller>
```

#### Mail receiver factory (mandatory)

The mail consumer doesn't actually receive mails itself, but relies on a configurable mail receiver, which allows for more flexibility. This is done by configuring the consumer with a [mail-receiver-factory], which in turn will provide the consumer with a receiver.  There are various flavours of receiver factories, each corresponding to a specific type of receiver. Typically, [javamail-receiver-factory] will meet all needs, but [pop3-receiver-factory] and [pop3s-receiver-factory] are also available.

The sample below shows how to enable TLS for POP3 connections (see [POP3 Javadocs] for details on session properties).

```xml
  <mail-receiver-factory class="javamail-receiver-factory">
   <session-properties>
    <key-value-pair>
     <key>mail.pop3.starttls.enable</key>
     <value>true</value>
    </key-value-pair>
   </session-properties>
  </mail-receiver-factory>
```

#### Delete on receive (optional)

The consumer can be instructed to delete emails that it has received. This is done by setting the property `delete-on-receive` to `true` (by default this is `false`).

#### Part selector (optional, only [default-mail-consumer])

Whether a [part-selector] is set has a fundamental impact on how the [default-mail-consumer] processes emails, as is outlined in the [overview table](#receiving-emails) above.

However, in all cases where the consumer outputs a message it will have the following metadata set:

 - `emailmessageid` - message ID as determined by the underlying mail receiver impementation (if it doesn't provide an ID then this header will not be set)
 - `emailtotalattachments` - total number of attachments (only set if the email has any attachments)

##### Selector is not set

If the [part-selector] is _not_ set and the [default-mail-consumer] processes a:

- non-multi-part email (i.e. an email without attachments) then the consumer will output a single internal Interlok message containing the email's content (i.e. the body).
- multi-part email (i.e. an email with a body and at least one attachment) then the consumer will output several separate internal Interlok messages, one for the body and one per attachment. These internal messages will then subsequently all be processed individually as per the adapter config.

A message containing an attachment is base64-encoded and can be differentiated from a body message based on the following metadata which body messages do not have:

 - `emailattachmentfilename` - name of the attachment
 - `emailattachmentcontenttype` - content-type of the attachment

Additionally, an attachment message also contains the same metadata as the corresponding body message:

 - `emailmessageid` - can be used to correlate attachment messages with the body message
 - `emailtotalattachments`

##### Selector is set

If the [part-selector] is set and the [default-mail-consumer] processes a:

 - non-multi-part email then the consumer will not output any message, because no part is present that could be selected.
 - multi-part email then the consumer ignores all parts that the [part-selector] did _not_ select. In practice this can be used to only keep the body (the selected part) and ignore all attachments or for example to always select a specific attachment.

There are various selector implementations to choose from, e.g. [select-by-content-id], [select-by-header] or [select-by-position]. See the documentation and the example files that come with the Interlok installation for more details. One example would be to always select the first part (0-based index):

```xml
  <part-selector class="mime-select-by-position">
   <position>0</position>
  </part-selector>
```

#### Headers (optional, only [default-mail-consumer])

If the optional property `preserve-headers` is set to true on the [default-mail-consumer] then all the headers from the consumed email are preserved as metadata in the internal Interlok message. Each header can optionally be prefixed with the value specfied by the optional `header-prefix` property.

Example:

```xml
  <preserve-headers>true</preserve-headers>
  <header-prefix>MailHeader-</header-prefix>
```

### Examples

The examples shown here illustrate how the above configuration can be put together. They all:

 - connect to the POP3 server `mail.local` on port 110, configured as `pop3://mail.local:110/INBOX`,
 - receive mails for the user `pop3@mail.local`,
 - poll for mails every 30 seconds,
 - ignore all mails whose subject does not match the regular expression `^consume me.*$` (i.e. they all have to start with the text `consume me`),
 - ignore all mails that are marked as read or as deleted (this is Interlok's built-in behaviour),
 - do not delete consumed mails (which allows picking up the same emails every time the consumer connects),
 - produce a received email to the local file system, using the file name format `%2$tF-%2$tH%2$tM_%1$s`, which is the date and time followed by the message ID (e.g. `2016-02-17-1814_5c3f6c67-9b80-429c-9dee-f40df360664c`). These files are MIME-encoded text files, so they are a full representation of what the internal Interlok messages look like when output by a mail consumer and then further processed by services and producers. These files can give you an idea of what payload and metadata to expect in practice.

The following emails are used as sample inputs in all examples further below.

_Sample email with one part (i.e. no multi-part email, no attachments, the body is `I am the body of an email without attachments.`):_

```
From - Thu Feb 18 12:04:26 2016
X-Account-Key: account1
X-UIDL: 10
X-Mozilla-Status: 0001
X-Mozilla-Status2: 00000000
X-Mozilla-Keys:
Return-Path: pop3@mail.local
Received: from [127.0.0.1] (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Thu, 18 Feb 2016 12:03:46 +0000
To: pop3@mail.local
From: POP3 Test <pop3@mail.local>
Subject: consume me, no attachment
Message-ID: <56C5B322.7020501@mail.local>
Date: Thu, 18 Feb 2016 12:03:46 +0000
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.6.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

I am the body of an email without attachments.
```

_Sample email with three parts (i.e. multi-part email, two attachments which are text files called `one.txt` and `two.txt`, which respectively contain the text `I am text file number one.` and `I am text file number two.`, the body is `I am the body of an email with two attachments.`):_

```
From - Thu Feb 18 12:05:06 2016
X-Account-Key: account1
X-UIDL: 11
X-Mozilla-Status: 0001
X-Mozilla-Status2: 00000000
X-Mozilla-Keys:
Return-Path: pop3@mail.local
Received: from [127.0.0.1] (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Thu, 18 Feb 2016 12:05:03 +0000
To: pop3@mail.local
From: POP3 Test <pop3@mail.local>
Subject: consume me, two attachments
Message-ID: <56C5B36F.8080604@mail.local>
Date: Thu, 18 Feb 2016 12:05:03 +0000
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.6.0
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090203030401020902020306"

This is a multi-part message in MIME format.
--------------090203030401020902020306
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

I am the body of an email with two attachments.

--------------090203030401020902020306
Content-Type: text/plain; charset=UTF-8;
 name="one.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="one.txt"

SSBhbSB0ZXh0IGZpbGUgbnVtYmVyIG9uZS4=
--------------090203030401020902020306
Content-Type: text/plain; charset=UTF-8;
 name="two.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="two.txt"

SSBhbSB0ZXh0IGZpbGUgbnVtYmVyIHR3by4=
--------------090203030401020902020306--
```


#### Raw mails with [raw-mail-consumer]

This example produces a received email to a single MIME-encoded file, which contains a raw copy of the email, including any attachments if present.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="raw-mail-consumer">
	<unique-id>raw-mail-consumer</unique-id>
	<destination class="configured-consume-destination">
	  <destination>pop3://mail.local:110/INBOX</destination>
	  <filter-expression>SUBJECT=^consume me.*$</filter-expression>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>30</interval>
	  </poll-interval>
	</poller>
	<regular-expression-style>PERL5</regular-expression-style>
	<password>test</password>
	<username>pop3@mail.local</username>
	<mail-receiver-factory class="javamail-receiver-factory">
	  <session-properties/>
	</mail-receiver-factory>
  </consumer>
  <service-collection class="service-list">
	<unique-id>ServiceList-8225643</unique-id>
	<services/>
  </service-collection>
  <producer class="fs-producer">
	<encoder class="mime-encoder"/>
	<unique-id>fs-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-drop-raw</destination>
	</destination>
	<create-dirs>true</create-dirs>
	<fs-worker class="fs-nio-worker"/>
	<filename-creator class="formatted-filename-creator">
	  <filename-format>%2$tF-%2$tH%2$tM_%1$s</filename-format>
	</filename-creator>
  </producer>
  <unique-id>raw-mail-consumer-to-file</unique-id>
  [...]
</standard-workflow>
```

_The sample email with one part produces a file with the following content:_

```
Message-ID: 333d61fc-77fb-4d6a-8e95-ecfaf1967f8e
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_537_1387306349.1455797409714"
Content-Length: 986

------=_Part_537_1387306349.1455797409714
Content-Id: AdaptrisMessage/payload

Return-Path: pop3@mail.local
Received: from [127.0.0.1] (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Thu, 18 Feb 2016 12:03:46 +0000
To: pop3@mail.local
From: POP3 Test <pop3@mail.local>
Subject: consume me, no attachment
Message-ID: <56C5B322.7020501@mail.local>
Date: Thu, 18 Feb 2016 12:03:46 +0000
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.6.0
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

I am the body of an email without attachments.

------=_Part_537_1387306349.1455797409714
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 12:10:09 GMT 2016
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-raw
producedname=2016-02-18-1210_333d61fc-77fb-4d6a-8e95-ecfaf1967f8e
adpnextmlemarkersequence=1

------=_Part_537_1387306349.1455797409714--
```

_The sample email with three parts produces a single file with the following content:_

```
Message-ID: c964340f-2d73-4a1c-b61f-653e65327e9b
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_538_988519798.1455797409717"
Content-Length: 1658

------=_Part_538_988519798.1455797409717
Content-Id: AdaptrisMessage/payload

Return-Path: pop3@mail.local
Received: from [127.0.0.1] (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Thu, 18 Feb 2016 12:05:03 +0000
To: pop3@mail.local
From: POP3 Test <pop3@mail.local>
Subject: consume me, two attachments
Message-ID: <56C5B36F.8080604@mail.local>
Date: Thu, 18 Feb 2016 12:05:03 +0000
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64; rv:38.0) Gecko/20100101
 Thunderbird/38.6.0
MIME-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090203030401020902020306"

This is a multi-part message in MIME format.
--------------090203030401020902020306
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit

I am the body of an email with two attachments.

--------------090203030401020902020306
Content-Type: text/plain; charset=UTF-8;
 name="one.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="one.txt"

SSBhbSB0ZXh0IGZpbGUgbnVtYmVyIG9uZS4=
--------------090203030401020902020306
Content-Type: text/plain; charset=UTF-8;
 name="two.txt"
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
 filename="two.txt"

SSBhbSB0ZXh0IGZpbGUgbnVtYmVyIHR3by4=
--------------090203030401020902020306--

------=_Part_538_988519798.1455797409717
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 12:10:09 GMT 2016
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-raw
producedname=2016-02-18-1210_c964340f-2d73-4a1c-b61f-653e65327e9b
adpnextmlemarkersequence=1

------=_Part_538_988519798.1455797409717--
```

#### Interpreting parts with [default-mail-consumer]

The two sub-sections illustrate the behaviour of this consumer depending on whether a [part-selector] is set.

Notice how in all examples the original mail headers are preserved in the metadata and prefixed with `MailHeader-`.

#### Selector not set (allows handling attachments)

This example has no [part-selector] set, which means that the consumer will output one message for each part of an email.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="default-mail-consumer">
	<unique-id>default-mail-consumer-without-selector</unique-id>
	<destination class="configured-consume-destination">
	  <destination>pop3://mail.local:110/INBOX</destination>
	  <filter-expression>SUBJECT=^consume me.*$</filter-expression>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>30</interval>
	  </poll-interval>
	</poller>
	<regular-expression-style>PERL5</regular-expression-style>
	<password>test</password>
	<username>pop3@mail.local</username>
	<mail-receiver-factory class="javamail-receiver-factory">
	  <session-properties/>
	</mail-receiver-factory>
	<preserve-headers>true</preserve-headers>
	<header-prefix>MailHeader-</header-prefix>
  </consumer>
  <service-collection class="service-list">
	<unique-id>ServiceList-8225643</unique-id>
	<services/>
  </service-collection>
  <producer class="fs-producer">
	<encoder class="mime-encoder"/>
	<unique-id>fs-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-drop-default-without-selector</destination>
	</destination>
	<create-dirs>true</create-dirs>
	<fs-worker class="fs-nio-worker"/>
	<filename-creator class="formatted-filename-creator">
	  <filename-format>%2$tF-%2$tH%2$tM_%1$s</filename-format>
	</filename-creator>
  </producer>
  <unique-id>default-mail-consumer-without-selector-to-file</unique-id>
  [...]
</standard-workflow>
```

_The sample email with one part produces one file with the following content:_

```
Message-ID: 61b01ee0-0cc5-45df-86d7-17a8e8abce95
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2035_1752988844.1455836810480"
Content-Length: 1204

------=_Part_2035_1752988844.1455836810480
Content-Id: AdaptrisMessage/payload

I am the body of an email without attachments.



------=_Part_2035_1752988844.1455836810480
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 23:06:50 GMT 2016
MailHeader-Return-Path=imap@mail.local
MailHeader-MIME-Version=1.0
MailHeader-From=IMAP Test <imap@mail.local>
MailHeader-User-Agent=Mozilla/5.0 (Windows NT 6.1; WOW64; rv\:38.0) Gecko/20100101\r\n Thunderbird/38.6.0
MailHeader-Content-Type=text/plain; charset\=windows-1252; format\=flowed
emailmessageid=<56C64745.2090201@mail.local>
MailHeader-Subject=consume me, no attachment
producedname=2016-02-18-2306_61b01ee0-0cc5-45df-86d7-17a8e8abce95
MailHeader-To=pop3@mail.local
MailHeader-Received=from [127.0.0.1] (mail.local [127.0.0.1])\r\n\tby DOM-ADAPTRIS-PC with ESMTPA\r\n\t; Thu, 18 Feb 2016 22\:35\:49 +0000
MailHeader-Date=Thu, 18 Feb 2016 22\:35\:49 +0000
adpnextmlemarkersequence=1
MailHeader-Content-Transfer-Encoding=7bit
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-default-without-selector
MailHeader-Message-ID=<56C64745.2090201@mail.local>

------=_Part_2035_1752988844.1455836810480--
```

_The sample email with three parts produces three files with the following content (compare how `emailmessageid=<56C64734.2040500@mail.local>` is the same for all):_

_File 1 of 3, the body:_

```
Message-ID: ed06d3af-16ab-4302-90ef-0b1ad5aec807
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2031_67950131.1455836810461"
Content-Length: 1201

------=_Part_2031_67950131.1455836810461
Content-Id: AdaptrisMessage/payload

I am the body of an email with two attachments.


------=_Part_2031_67950131.1455836810461
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 23:06:50 GMT 2016
MailHeader-Return-Path=imap@mail.local
MailHeader-MIME-Version=1.0
MailHeader-From=IMAP Test <imap@mail.local>
MailHeader-User-Agent=Mozilla/5.0 (Windows NT 6.1; WOW64; rv\:38.0) Gecko/20100101\r\n Thunderbird/38.6.0
MailHeader-Content-Type=multipart/mixed;\r\n boundary\="------------050707030104020708030208"
emailmessageid=<56C64734.2040500@mail.local>
MailHeader-Subject=consume me, two attachments
producedname=2016-02-18-2306_1455836810460_ed06d3af-16ab-4302-90ef-0b1ad5aec807
MailHeader-To=pop3@mail.local
MailHeader-Received=from [127.0.0.1] (mail.local [127.0.0.1])\r\n\tby DOM-ADAPTRIS-PC with ESMTPA\r\n\t; Thu, 18 Feb 2016 22\:35\:32 +0000
emailtotalattachments=2
MailHeader-Date=Thu, 18 Feb 2016 22\:35\:32 +0000
adpnextmlemarkersequence=1
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-default-without-selector
MailHeader-Message-ID=<56C64734.2040500@mail.local>

------=_Part_2031_67950131.1455836810461--
```

_File 2 of 3, the first attachment named `one.txt`:_

```
Message-ID: eda7c369-fbe0-4cfd-a83f-5b109d617901
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2033_957460259.1455836810467"
Content-Length: 1290

------=_Part_2033_957460259.1455836810467
Content-Id: AdaptrisMessage/payload

I am text file number one.

------=_Part_2033_957460259.1455836810467
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 23:06:50 GMT 2016
MailHeader-Return-Path=imap@mail.local
MailHeader-MIME-Version=1.0
MailHeader-From=IMAP Test <imap@mail.local>
MailHeader-User-Agent=Mozilla/5.0 (Windows NT 6.1; WOW64; rv\:38.0) Gecko/20100101\r\n Thunderbird/38.6.0
MailHeader-Content-Type=multipart/mixed;\r\n boundary\="------------050707030104020708030208"
emailmessageid=<56C64734.2040500@mail.local>
MailHeader-Subject=consume me, two attachments
producedname=2016-02-18-2306_1455836810466_eda7c369-fbe0-4cfd-a83f-5b109d617901
MailHeader-To=pop3@mail.local
emailattachmentfilename=one.txt
MailHeader-Received=from [127.0.0.1] (mail.local [127.0.0.1])\r\n\tby DOM-ADAPTRIS-PC with ESMTPA\r\n\t; Thu, 18 Feb 2016 22\:35\:32 +0000
emailtotalattachments=2
MailHeader-Date=Thu, 18 Feb 2016 22\:35\:32 +0000
emailattachmentcontenttype=text/plain; charset\=UTF-8;\r\n name\="one.txt"
adpnextmlemarkersequence=1
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-default-without-selector
MailHeader-Message-ID=<56C64734.2040500@mail.local>

------=_Part_2033_957460259.1455836810467--
```

_File 3 of 3, the second attachment named `two.txt`:_

```
Message-ID: 1b7e0eae-f7d7-4644-9766-078f3b0d3c50
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_2034_2091164736.1455836810474"
Content-Length: 1293

------=_Part_2034_2091164736.1455836810474
Content-Id: AdaptrisMessage/payload

I am text file number two.

------=_Part_2034_2091164736.1455836810474
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 23:06:50 GMT 2016
MailHeader-Return-Path=imap@mail.local
MailHeader-MIME-Version=1.0
MailHeader-From=IMAP Test <imap@mail.local>
MailHeader-User-Agent=Mozilla/5.0 (Windows NT 6.1; WOW64; rv\:38.0) Gecko/20100101\r\n Thunderbird/38.6.0
MailHeader-Content-Type=multipart/mixed;\r\n boundary\="------------050707030104020708030208"
emailmessageid=<56C64734.2040500@mail.local>
MailHeader-Subject=consume me, two attachments
producedname=2016-02-18-2306_1455836810473_1b7e0eae-f7d7-4644-9766-078f3b0d3c50
MailHeader-To=pop3@mail.local
emailattachmentfilename=two.txt
MailHeader-Received=from [127.0.0.1] (mail.local [127.0.0.1])\r\n\tby DOM-ADAPTRIS-PC with ESMTPA\r\n\t; Thu, 18 Feb 2016 22\:35\:32 +0000
emailtotalattachments=2
MailHeader-Date=Thu, 18 Feb 2016 22\:35\:32 +0000
emailattachmentcontenttype=text/plain; charset\=UTF-8;\r\n name\="two.txt"
adpnextmlemarkersequence=1
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-default-without-selector
MailHeader-Message-ID=<56C64734.2040500@mail.local>

------=_Part_2034_2091164736.1455836810474--
```

#### Selector set (allows ignoring attachments)

This example uses [select-by-position] as the [part-selector] to select the first part of a multi-part email as the body part, which ignores all other message parts, assuming they are attachments.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="default-mail-consumer">
	<unique-id>default-mail-consumer-with-selector</unique-id>
	<destination class="configured-consume-destination">
	  <destination>pop3://mail.local:110/INBOX</destination>
	  <filter-expression>SUBJECT=^consume me.*$</filter-expression>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>30</interval>
	  </poll-interval>
	</poller>
	<regular-expression-style>PERL5</regular-expression-style>
	<password>test</password>
	<username>pop3@mail.local</username>
	<mail-receiver-factory class="javamail-receiver-factory">
	  <session-properties/>
	</mail-receiver-factory>
	<part-selector class="mime-select-by-position">
	  <position>0</position>
	</part-selector>
	<preserve-headers>true</preserve-headers>
	<header-prefix>MailHeader-</header-prefix>
  </consumer>
  <service-collection class="service-list">
	<unique-id>ServiceList-8225643</unique-id>
	<services/>
  </service-collection>
  <producer class="fs-producer">
	<encoder class="mime-encoder"/>
	<unique-id>fs-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-drop-default-with-selector</destination>
	</destination>
	<create-dirs>true</create-dirs>
	<fs-worker class="fs-nio-worker"/>
	<filename-creator class="formatted-filename-creator">
	  <filename-format>%2$tF-%2$tH%2$tM_%1$s</filename-format>
	</filename-creator>
  </producer>
  <unique-id>default-mail-consumer-with-selector-to-file</unique-id>
  [...]
</standard-workflow>
```

_The sample email with one part produces **no** file._

_The sample email with three parts produces one file with the following content (containing the selected part):_

```xml
Message-ID: 09b5c9c2-66c6-43cc-8d6a-2a51faf5cc13
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_1800_224457695.1455818574836"
Content-Length: 1160

------=_Part_1800_224457695.1455818574836
Content-Id: AdaptrisMessage/payload

I am the body of an email with two attachments.

------=_Part_1800_224457695.1455818574836
Content-Id: AdaptrisMessage/metadata

#
#Thu Feb 18 18:02:54 GMT 2016
MailHeader-Return-Path=pop3@mail.local
MailHeader-MIME-Version=1.0
MailHeader-From=POP3 Test <pop3@mail.local>
MailHeader-User-Agent=Mozilla/5.0 (Windows NT 6.1; WOW64; rv\:38.0) Gecko/20100101\r\n Thunderbird/38.6.0
MailHeader-Content-Type=multipart/mixed;\r\n boundary\="------------090203030401020902020306"
emailmessageid=<56C5B36F.8080604@mail.local>
MailHeader-Subject=consume me, two attachments
producedname=2016-02-18-1802_09b5c9c2-66c6-43cc-8d6a-2a51faf5cc13
MailHeader-To=pop3@mail.local
MailHeader-Received=from [127.0.0.1] (mail.local [127.0.0.1])\r\n\tby DOM-ADAPTRIS-PC with ESMTPA\r\n\t; Thu, 18 Feb 2016 12\:05\:03 +0000
MailHeader-Date=Thu, 18 Feb 2016 12\:05\:03 +0000
adpnextmlemarkersequence=1
fsProduceDir=C\:\\apps\\Adaptris\\Interlok\\test\\mail-drop-default-with-selector
MailHeader-Message-ID=<56C5B36F.8080604@mail.local>

------=_Part_1800_224457695.1455818574836--
```

## Sending emails

Interlok comes with two SMTP producers:

 - [default-smtp-producer], which can send emails with no or with a single attachment.
 - [multi-attachment-smtp-producer], which can send emails with multiple attachments.

Both producers are able to send via SMTP and SMTPS simply by using the corresponding protocol, for example `smtp://mail.local:25` or `smtps://mail.local:465`.

The following sections contain examples that illustrate how these producers are used. All these examples:

 - send to `imap@mail.local`,
 - send from `pop3@mail.local`,
 - send via the SMTP server `mail.local` on port 25, configured as `smtp://mail.local:25`,
 - use a plain text mail body,
 - delete the consumed file as soon as it's picked up.

### No or one attachment (using [default-smtp-producer])

This section contains examples using the [default-smtp-producer].

In all these examples the [add-metadata-service] is used to set a subject that differs from the default subject that is defined in the producer. Since the subject is a metadata item on the message, this simple configuration could be taken further by constructing the metadata value in a more complex way than just having it hard-coded in the workflow.

See the [documentation][default-smtp-producer] for further metadata items that the producer can interpret, such as setting a CC list.

#### No attachment

Below is an example which reads any given text file from a local directory and sends its content as the body of an email.

The result of this concrete example produces mails:

 - with the subject `This just in: Test email from Interlok!` set via metadata, rather than `Test email sent by Interlok`,
 - with a plain text body that is the content of the file that was picked up (note the content-encoding which is set to `quoted-printable`, for binary files you may for example choose `base64` instead),
 - without any attachments.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="fs-consumer">
	<unique-id>fs-consumer</unique-id>
	<destination class="configured-consume-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-pickup-default-no-attachment</destination>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>3</interval>
	  </poll-interval>
	</poller>
	<create-dirs>true</create-dirs>
	<file-sorter class="fs-sort-none"/>
	<wip-suffix>.wip</wip-suffix>
  </consumer>
  <service-collection class="service-list">
	<unique-id>service-list-8919318</unique-id>
	<services>
	  <add-metadata-service>
		<unique-id>Set email metadata</unique-id>
		<metadata-element>
		  <key>emailsubject</key>
		  <value>This just in: Test email from Interlok!</value>
		</metadata-element>
	  </add-metadata-service>
	</services>
  </service-collection>
  <producer class="default-smtp-producer">
	<unique-id>default-smtp-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>imap@mail.local</destination>
	</destination>
	<smtp-url>smtp://mail.local:25</smtp-url>
	<subject>Test email sent by Interlok</subject>
	<from>pop3@mail.local</from>
	<session-properties/>
	<metadata-filter class="remove-all-metadata-filter"/>
	<password>test</password>
	<username>pop3@mail.local</username>
	<is-attachment>false</is-attachment>
	<content-type>text/plain</content-type>
	<content-encoding>quoted-printable</content-encoding>
	<attachment-content-type>application/octet-stream</attachment-content-type>
  </producer>
  <unique-id>file-to-smtp-workflow-no-attachment</unique-id>
  [...]
</standard-workflow>
```

_Sample input text file (will become the body):_

```
I know kung fu.
```

_Sample email produced from the above:_

```
Return-Path: pop3@mail.local
Received: from Dom-Adaptris-PC (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Fri, 19 Feb 2016 22:08:42 +0000
Date: Fri, 19 Feb 2016 22:08:42 +0000 (GMT)
From: pop3@mail.local
To: imap@mail.local
Message-ID: <1840966489.5050.1455919722531.JavaMail.Dom@Dom-Adaptris-PC>
Subject: This just in: Test email from Interlok!
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5049_2068593190.1455919722453"

------=_Part_5049_2068593190.1455919722453
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

I know kung fu.
------=_Part_5049_2068593190.1455919722453--
```

#### One attached file

Below is an example which reads any given text file file from a local directory and sends it as an attachment of an email.

In contrast to the example without attachment, the body of the mail is now set using an additional metadata item. This is because the file is now an attachment and not used as the body.

By default, the name of the attachment is the message's unique ID, so not necessarily useful. The name can be set explicitly using the metadata key `emailattachmentfilename`. So this can be a hard-coded value, one that is constructed in a more complex way or simply the actual file name. The latter is done by using a [copy-metadata-service] to copy the original name from the metadata key `originalname`, which was set by the [fs-consumer] when it read the file. This is the approach taken in this example.

The result of this concrete example produces mails:

 - with the subject `This just in: Test email from Interlok with attachment!` set via metadata, rather than `Test email sent by Interlok`,
 - with a plain text body set via metadata,
 - with a single attached file that has the same name as the file that was picked up.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="fs-consumer">
	<unique-id>fs-consumer</unique-id>
	<destination class="configured-consume-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-pickup-default-with-attachment</destination>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>3</interval>
	  </poll-interval>
	</poller>
	<create-dirs>true</create-dirs>
	<file-sorter class="fs-sort-none"/>
	<wip-suffix>.wip</wip-suffix>
  </consumer>
  <service-collection class="service-list">
	<unique-id>service-list-8919318</unique-id>
	<services>
	  <add-metadata-service>
		<unique-id>Set body and subject</unique-id>
		<metadata-element>
		  <key>emailtemplatebody</key>
		  <value>Please have a look at the attached file.</value>
		</metadata-element>
		<metadata-element>
		  <key>emailsubject</key>
		  <value>This just in: Test email from Interlok with attachment!</value>
		</metadata-element>
	  </add-metadata-service>
	  <copy-metadata-service>
		<unique-id>set attachment file name</unique-id>
		<metadata-keys>
		  <key-value-pair>
			<key>originalname</key>
			<value>emailattachmentfilename</value>
		  </key-value-pair>
		</metadata-keys>
	  </copy-metadata-service>
	</services>
  </service-collection>
  <producer class="default-smtp-producer">
	<unique-id>default-smtp-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>imap@mail.local</destination>
	</destination>
	<smtp-url>smtp://mail.local:25</smtp-url>
	<subject>Test email with attachment sent by Interlok</subject>
	<from>pop3@mail.local</from>
	<session-properties/>
	<metadata-filter class="remove-all-metadata-filter"/>
	<password>test</password>
	<username>pop3@mail.local</username>
	<is-attachment>true</is-attachment>
	<content-type>text/plain</content-type>
	<content-encoding>quoted-printable</content-encoding>
	<attachment-content-type>application/octet-stream</attachment-content-type>
  </producer>
  <unique-id>file-to-smtp-workflow-one-attachment</unique-id>
  [...]
</standard-workflow>
```

_Sample input text file (will become an attachment):_

```
My hovercraft is full of eels.
```

_Sample email produced from the above:_

```
Return-Path: pop3@mail.local
Received: from Dom-Adaptris-PC (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Fri, 19 Feb 2016 22:12:08 +0000
Date: Fri, 19 Feb 2016 22:12:08 +0000 (GMT)
From: pop3@mail.local
To: imap@mail.local
Message-ID: <719851600.5095.1455919928202.JavaMail.Dom@Dom-Adaptris-PC>
Subject: This just in: Test email from Interlok with attachment!
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5094_1445748079.1455919928201"

------=_Part_5094_1445748079.1455919928201
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment;
	filename=mail-pickup-default-with-attachment.txt

TXkgaG92ZXJjcmFmdCBpcyBmdWxsIG9mIGVlbHMu

------=_Part_5094_1445748079.1455919928201
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Please have a look at the attached file.
------=_Part_5094_1445748079.1455919928201--
```

### Multiple attachments (using [multi-attachment-smtp-producer])

This section contains examples using the [multi-attachment-smtp-producer].

There are different ways this producer can be used depending on which implementation of [mail-content-creator] is used. Currently, there is one implementation to create mails with multiple attachments from a [MIME multi-part message][mime-mail-creator] and another implementation to do the same from a simple [message with XML content][xml-mail-creator]. The implementation to be used is set as the `mail-creator` property on the producer. The sub-sections below show how to use both of these creators.

Also see the documentation of [multi-attachment-smtp-producer] for general metadata items that the producer can interpret, such as setting a subject or a CC list.

#### From a MIME multi-part message

Below is an example which reads a MIME multi-part message from a file in a local directory. This is simply a text file that has a certain format, see below for a sample input file. However, this MIME multi-part message may also be created in other ways than using the [fs-consumer].

Using the [mime-mail-creator] allows using one part of the message as the body, while all other parts become attachments. There are various ways to select the body part. The [mime-mail-creator] has to be configured with the desired implementation of a [part-selector]. The example below uses [select-by-position], but it is for example also possible to use [select-by-content-id] or [select-by-header].

The result of this concrete example produces mails:

 - with the subject `Test email sent by Interlok with multiple attachments from MIME message`, as set in the producer,
 - with a plain text body that is taken from the second part (i.e. with index 1) of the multi-part message,
 - with two attachments, whose names are taken from the `Content-Type`/`Content-Disposition` headers of the respective parts.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="fs-consumer">
	<unique-id>fs-consumer</unique-id>
	<destination class="configured-consume-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-pickup-multi-attachment-mime</destination>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>3</interval>
	  </poll-interval>
	</poller>
	<create-dirs>true</create-dirs>
	<file-sorter class="fs-sort-none"/>
	<wip-suffix>.wip</wip-suffix>
  </consumer>
  <service-collection class="service-list">
	<unique-id>service-list-8919318</unique-id>
	<services/>
  </service-collection>
  <producer class="multi-attachment-smtp-producer">
	<unique-id>multi-attachment-smtp-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>imap@mail.local</destination>
	</destination>
	<smtp-url>smtp://mail.local:25</smtp-url>
	<subject>Test email sent by Interlok with multiple attachments from MIME message</subject>
	<from>pop3@mail.local</from>
	<session-properties/>
	<metadata-filter class="remove-all-metadata-filter"/>
	<password>test</password>
	<username>pop3@mail.local</username>
	<mail-creator class="mail-mime-content-creator">
	  <body-selector class="mime-select-by-position">
		<position>1</position>
	  </body-selector>
	</mail-creator>
	<content-encoding>quoted-printable</content-encoding>
  </producer>
  <unique-id>file-to-smtp-workflow-multiple-attachments-from-mime</unique-id>
  [...]
</standard-workflow>
```

_Sample input text file (in MIME multi-part format):_

```
Message-ID: 400941d0-d779-4be5-b8a8-bb83d50c1e0f
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_62_1160377335.1453980814248"
Content-Length: 746

------=_Part_62_1160377335.1453980814248
Content-Type: application/octet-stream;
Content-Disposition: attachment; filename="attachment1.txt"
Content-Id: 221641b1-1e73-4cb3-85a8-6ca25facdb01

The quick brown fox jumps over the lazy dog
------=_Part_62_1160377335.1453980814248
Content-Type: text/plain
Content-Disposition: attachment;
Content-Id: 80d41f75-55fb-4d95-8db8-9c2be283e8c4

Sixty zippers were quickly picked from the woven jute bag
------=_Part_62_1160377335.1453980814248
Content-Type: application/octet-stream;
Content-Disposition: attachment; filename="attachment2.txt"
Content-Id: 68bd34fe-d13c-4fa0-9a66-fd7cd605d96b

Quick zephyrs blow, vexing daft Jim
------=_Part_62_1160377335.1453980814248--
```

_Sample email produced from the above:_

```
Return-Path: pop3@mail.local
Received: from Dom-Adaptris-PC (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Fri, 19 Feb 2016 22:15:29 +0000
Date: Fri, 19 Feb 2016 22:15:28 +0000 (GMT)
From: pop3@mail.local
To: imap@mail.local
Message-ID: <2103046324.5139.1455920129154.JavaMail.Dom@Dom-Adaptris-PC>
Subject: Test email sent by Interlok with multiple attachments from MIME
 message
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5138_1687440924.1455920128962"

------=_Part_5138_1687440924.1455920128962
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=attachment1.txt

VGhlIHF1aWNrIGJyb3duIGZveCBqdW1wcyBvdmVyIHRoZSBsYXp5IGRvZw==

------=_Part_5138_1687440924.1455920128962
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=attachment2.txt

UXVpY2sgemVwaHlycyBibG93LCB2ZXhpbmcgZGFmdCBKaW0=

------=_Part_5138_1687440924.1455920128962
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

Sixty zippers were quickly picked from the woven jute bag
------=_Part_5138_1687440924.1455920128962--
```

#### Created from an XML message

Below is an example which reads a local XML file. The format of this file is flexible, it simply has to contain a node that contains the body and it can additionally contain several attachments in the same file in other nodes (each attachment needs to have the same format, but the format itself is not prescribed). See below for a sample input file.

Using the [xml-mail-creator] requires configuring a [body-handler] and an [attachment-handler]. The configuration of these handlers then describes how to extract the body and how to extract any attachments from the XML. For both handlers there is currently one implementation each, the aptly named [xml-body-handler] and [xml-attachment-handler].

Both handlers have a mandatory property called `xpath`, which contains the path to the node that contains the respective data. For the body, the result of this XPath should only be a single node containing the body text, whereas for attachments the result can be zero to many nodes. In both cases, this XPath is evaluted as an absolute path from the root of the document.

Both handlers also have the optional property `encoding-xpath`, which is typically more useful for attachments as they may likely be base64-encoded, rather than plain text. For the body, this XPath is evaluted from the root of the document, whereas for attachments it is evaluated from the path of the attachment node. This allows each attachment to be encoded differently.

Additionally, only the [xml-attachment-handler] has the optional property `filename-xpath`, which is evaluated from the path of the attachment node, just like `encoding-xpath`. This allows each attachment to be given a different file name.

The result of this concrete example produces mails:

 - with the subject `Test email sent by Interlok with multiple attachments from XML message`, as set in the producer,
 - with a body that is taken from the node `/document/content` of the XML message, encoded as `text/plain`,
 - with two attachments, both found as the nodes `/document/attachment`, their names taken from the respective relative XPath `@filename` and their encoding from `@encoding`.

_Adapter config:_

```xml
<standard-workflow>
  <consumer class="fs-consumer">
	<unique-id>fs-consumer</unique-id>
	<destination class="configured-consume-destination">
	  <destination>file:////C:/apps/Adaptris/Interlok/test/mail-pickup-multi-attachment-xml</destination>
	</destination>
	<poller class="fixed-interval-poller">
	  <poll-interval>
		<unit>SECONDS</unit>
		<interval>3</interval>
	  </poll-interval>
	</poller>
	<create-dirs>true</create-dirs>
	<file-sorter class="fs-sort-none"/>
	<wip-suffix>.wip</wip-suffix>
  </consumer>
  <service-collection class="service-list">
	<unique-id>service-list-8919318</unique-id>
	<services/>
  </service-collection>
  <producer class="multi-attachment-smtp-producer">
	<unique-id>multi-attachment-smtp-producer</unique-id>
	<destination class="configured-produce-destination">
	  <destination>imap@mail.local</destination>
	</destination>
	<smtp-url>smtp://mail.local:25</smtp-url>
	<subject>Test email sent by Interlok with multiple attachments from XML message</subject>
	<from>pop3@mail.local</from>
	<session-properties/>
	<metadata-filter class="remove-all-metadata-filter"/>
	<password>test</password>
	<username>pop3@mail.local</username>
	<mail-creator class="mail-xml-content-creator">
	  <attachment-handler class="mail-xml-attachment-handler">
		<xpath>/document/attachment</xpath>
		<filename-xpath>@filename</filename-xpath>
		<encoding-xpath>@encoding</encoding-xpath>
	  </attachment-handler>
	  <body-handler class="mail-xml-body-handler">
		<xpath>/document/content</xpath>
		<content-type>text/plain</content-type>
	  </body-handler>
	</mail-creator>
	<content-encoding>quoted-printable</content-encoding>
  </producer>
  <unique-id>file-to-smtp-workflow-multiple-attachments-from-xml</unique-id>
  [...]
</standard-workflow>
```

_Sample input text file (in XML format):_

```xml
<document>
 <content>The text body of the email</content>
 <attachment encoding="base64" filename="attachment1.txt">UXVpY2sgemVwaHlycyBibG93LCB2ZXhpbmcgZGFmdCBKaW0=</attachment>
 <attachment encoding="base64" filename="attachment2.txt">UGFjayBteSBib3ggd2l0aCBmaXZlIGRvemVuIGxpcXVvciBqdWdz</attachment>
</document>
```

_Sample email produced from the above:_

```
Return-Path: pop3@mail.local
Received: from Dom-Adaptris-PC (mail.local [127.0.0.1])
	by DOM-ADAPTRIS-PC with ESMTPA
	; Fri, 19 Feb 2016 22:15:35 +0000
Date: Fri, 19 Feb 2016 22:15:35 +0000 (GMT)
From: pop3@mail.local
To: imap@mail.local
Message-ID: <1773674884.5141.1455920135083.JavaMail.Dom@Dom-Adaptris-PC>
Subject: Test email sent by Interlok with multiple attachments from XML
 message
MIME-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_5140_229980997.1455920135079"

------=_Part_5140_229980997.1455920135079
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=attachment1.txt

UXVpY2sgemVwaHlycyBibG93LCB2ZXhpbmcgZGFmdCBKaW0=

------=_Part_5140_229980997.1455920135079
Content-Type: application/octet-stream
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=attachment2.txt

UGFjayBteSBib3ggd2l0aCBmaXZlIGRvemVuIGxpcXVvciBqdWdz

------=_Part_5140_229980997.1455920135079
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

The text body of the email
------=_Part_5140_229980997.1455920135079--
```

## Setting up a local test environment

This section contains instructions on how to set up a local email test server as well as an email test client in the same way that it was used to create the examples shown throughout this guide.

Note that the instructions are for Windows only.

### Email server

To set up an email server we will create both a unique host name that is only valid on the local machine as well as an actual email server that will be configured against that host name.

#### Set up a local host name

First, edit your `hosts` [file](https://en.wikipedia.org/wiki/Hosts_%28file%29) and add the line:

```
127.0.0.1	mail.local
```

This will give you a domain name that is only accessible on your local machine and that a locally installed mail server and clients can be set up against for testing.

#### Install and configure a mail server

For Windows download and install [hMailServer], which is a free POP3, IMAP and SMTP server that is straightforward to set up.

 1. Once installed, start the _hMailServer Administrator_ application and log into the administrator account that you created during installation.
 2. In the _Domains_ panel add a new domain called `mail.local` (must be the same domain name used in the `hosts` file).
 3. Open the new domain item and create two new accounts, one for testing POP3 and one for testing IMAP. Either may later be used to test SMTP. As addresses enter `pop3` and `imap` respectively, making sure to enter a password for both. For simplicity's sake use the password `test`. These two accounts will now be available as the email addresses `pop3@mail.local` and `imap@mail.local`. The full email address acts as the user name when configuring connections to the mail server.
 4. Nothing else needs to be configured now, the defaults are all good as they are. It is now possible to send mails using the host `mail.local` as a POP3, IMAP and SMTP server with the accounts `pop3@mail.local` and `imap@mail.local`.

### Configure a mail client

#### Thunderbird

[Thunderbird] is a free email client. It can struggle a little when displaying emails with attachments (some but not all attachments may be shown inline in the body instead of actual attachments), however viewing the raw email works perfectly (_View_ menu -- _Message Source_). Outlook is an alternative that hasn't exhibited this behaviour, so if it is available to you it may be a better choice.

Below are some screenshots that indicate how [Thunderbird] was configured.

POP3 account settings:

![pop3_account_settings.png](./images/cookbook/email/pop3_account_settings.png)

POP3 server settings (note that emails are left on the server, which is the default, but that they also won't be automatically deleted after some time):

![pop3_server_settings.png](./images/cookbook/email/pop3_server_settings.png)

IMAP account settings:

![imap_account_settings.png](./images/cookbook/email/imap_account_settings.png)

IMAP server settings:

![imap_server_settings.png](./images/cookbook/email/imap_server_settings.png)

Outgoing server settings:

![outgoing_server_settings.png](./images/cookbook/email/outgoing_server_settings.png)

SMTP server:

![smtp_server.png](./images/cookbook/email/smtp_server.png)

#### Java (only POP3/IMAP)

Below is a Java class that can be used to verify the contents of POP3 and IMAP accounts. This is useful if during testing you find that the messages that Interlok seems to see and consume differs from what you can see in your desktop email client. This is especially true for POP3 as deleting emails using a desktop client after having fetched them from the server may not be immediately reflected on the server, i.e. what you see in your local mail client may be different from what is actually on the server. This Java class however will always give you a fresh and raw view of the actual contents of any POP3 or IMAP folder. Plus, it won't fiddle with emails' flags such as marking them as seen; it is completely non-invasive.

To run it you will need to have [javax.mail.jar] on the classpath.

```java
package test.mail;

import java.io.IOException;
import java.util.Properties;

import javax.mail.Flags.Flag;
import javax.mail.Folder;
import javax.mail.Message;
import javax.mail.MessagingException;
import javax.mail.Session;
import javax.mail.Store;
import javax.mail.URLName;

public class ReadMail
{
	public static void main(String[] args) throws MessagingException, IOException
	{
		read("imap://imap%40mail.local:test@mail.local:143/INBOX");
		//read("pop3://pop3%40mail.local:test@mail.local:110/INBOX");
	}

	public static void read(String url) throws MessagingException, IOException
	{
		System.out.println("=====================================================================================");
		System.out.println("URL: " + url);

		Session session = Session.getInstance(new Properties(), null);

		URLName urlName = new URLName(url);

		Store store = session.getStore(urlName);
		store.connect();

		Folder folder = store.getFolder(urlName.getFile());
		folder.open(Folder.READ_ONLY);

		System.out.println("No of emails: " + folder.getMessageCount());
		System.out.println("No of unread emails: " + folder.getUnreadMessageCount());

		for (Message message : folder.getMessages())
		{
			System.out.println("-------------------------------------------------------------------------------------");
			System.out.println("Subject: " + message.getSubject());
			boolean seen = message.getFlags().contains(Flag.SEEN);
			boolean deleted = message.getFlags().contains(Flag.DELETED);
			System.out.println("Seen: " + seen);
			System.out.println("Deleted: " + deleted);
			System.out.println("Interlok will consume: " + !(seen || deleted));
			// System.out.println("From: " + Arrays.asList(message.getFrom()));
			// System.out.println("To: " + Arrays.asList(message.getAllRecipients()));
			// System.out.println("Date: " + message.getReceivedDate());
			// System.out.println("Size: " + message.getSize());
			// System.out.println("Flags: " + message.getFlags());
			System.out.println("Content-Type: " + message.getContentType());
			System.out.println("Body: \n" + message.getContent());
		}

		folder.close(true);
		store.close();
	}
}
```

Here is an example output:

```
=====================================================================================
URL: imap://imap%40mail.local:test@mail.local:143/INBOX
No of emails: 2
No of unread emails: 2
-------------------------------------------------------------------------------------
Subject: consume me, two attachments
Seen: false
Deleted: false
Interlok will consume: true
Content-Type: multipart/MIXED; boundary=------------050109000107030000000908
Body:
javax.mail.internet.MimeMultipart@621be5d1
-------------------------------------------------------------------------------------
Subject: consume me, no attachment
Seen: false
Deleted: false
Interlok will consume: true
Content-Type: TEXT/PLAIN; charset=windows-1252
Body:
I am the body of an email without attachments.
```







[add-metadata-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/services/metadata/AddMetadataService.html
[attachment-handler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/AttachmentHandler.html
[body-handler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/BodyHandler.html
[configured-consume-destination]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/ConfiguredConsumeDestination.html
[copy-metadata-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/services/metadata/CopyMetadataService.html
[default-mail-consumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/DefaultMailConsumer.html
[default-smtp-producer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/DefaultSmtpProducer.html
[fixed-interval-poller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/FixedIntervalPoller.html
[fs-consumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/fs/FsConsumer.html
[fs-producer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/fs/FsProducer.html
[hMailServer]: https://www.hmailserver.com
[IMAP Javadocs]: https://javamail.java.net/nonav/docs/api/com/sun/mail/imap/package-summary.html
[javamail-receiver-factory]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/mail/JavamailReceiverFactory.html
[javax.mail.jar]: https://java.net/projects/javamail/downloads
[mail-consumer-imp]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/MailConsumerImp.html
[mail-content-creator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/MailContentCreator.html
[mail-receiver-factory]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/mail/MailReceiverFactory.html
[mime-mail-creator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/MimeMailCreator.html
[multi-attachment-smtp-producer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/MultiAttachmentSmtpProducer.html
[null-connection]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/NullConnection.html
[part-selector]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/util/text/mime/PartSelector.html
[poller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/Poller.html
[POP3 Javadocs]: https://javamail.java.net/nonav/docs/api/com/sun/mail/pop3/package-summary.html
[pop3-receiver-factory]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/mail/Pop3ReceiverFactory.html
[pop3s-receiver-factory]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/mail/Pop3sReceiverFactory.html
[quartz-cron-poller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/QuartzCronPoller.html
[raw-mail-consumer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/RawMailConsumer.html
[select-by-content-id]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/util/text/mime/SelectByContentId.html
[select-by-header]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/util/text/mime/SelectByHeader.html
[select-by-position]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/util/text/mime/SelectByPosition.html
[SMTP Javadocs]: https://javamail.java.net/nonav/docs/api/com/sun/mail/smtp/package-summary.html
[Thunderbird]: https://www.mozilla.org/en-GB/thunderbird/
[xml-attachment-handler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/XmlAttachmentHandler.html
[xml-body-handler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/XmlBodyHandler.html
[xml-mail-creator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/mail/attachment/XmlMailCreator.html


{% include links.html %}