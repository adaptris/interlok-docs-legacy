---
title: Integrating with OracleAQ
keywords: interlok oracle OracleAQ
tags: [cookbook, messaging]
sidebar: home_sidebar
permalink: cookbook-oracleaq.html
summary: This document summarises configurations for consuming and producing JMS messages using OracleAQ.
---

{% include important.html content="in 3.8.0; adp-jms-oraclemq was renamed to interlok-jms-oracleaq" %}


This document summarises configurations for consuming and producing JMS messages using OracleAQ.  It is assumed that you have a passing knowledge of Interlok and its configuration. No Oracle knowledge is assumed, though you should have some passing familiarity with SQL. You will be expected to be able to manipulate and compile java classes exported from Oracle. This guide has been built with Oracle 10g in mind.  However if you happen to be using later Oracle versions, the only changes should be to the java archive files you will need to copy from your Oracle installation to your Interlok installation, mentioned later in this guide

If you are an Oracle expert and everything is already setup, you can probably ignore almost all of the Oracle specific configuration instructions and do your own thing. If you aren't an Oracle expert and are setting up an Oracle instance from scratch, then you need to pay careful attention to the Oracle specific configuration instructions.

----

## Getting Started ##

### Interlok Pre-requisites ###

Before you can start Interlok that is able to consume or produce from or to OracleAQ, you must first install the Interlok OracleAQ optional component into your Interlok installation. All available Interlok sub components are shipped with the standard Interlok installation.  Simply navigate to the _optional_ directory at the root of your Interlok installation and from there the `oracle` subdirectory.   Copy the java archive file named `interlok-jms-oracleaq.jar` to your _lib_ directory in the root of your Interlok installation.  Finally you will also need to copy any required java archives for client access into the _lib_ directory of your Interlok installation directory. Generally speaking this will be all `jdbc14.jar` and `aqapi.jar`, however additional jars may be required depending on the connection method. All configuration examples for can be found in the _docs/optional/example-xml_ directory as normal.

----

## Oracle Configuration ##

The required oracle configuration covers a number of steps:

1. Create the tablespace to be used
1. Creating the required roles and privileges
1. Create the users
1. Create the AQ Queue

Using your preferred SQL Client, login to oracle as a DBA user and create a new tablespace.

```sql
create tablespace aq
  logging
  datafile 'C:\ORACLE\PRODUCT\10.2.0\ORADATA\ORCL\AQ'
  size 32m
  autoextend on
  next 32m maxsize 2048m
  extent management local;
```

Next, create the AQ Administrator and AQ User roles.

```sql
-- AQ administrator
DROP ROLE my_aq_adm_role;
CREATE ROLE my_aq_adm_role;
--

GRANT CONNECT, RESOURCE, aq_administrator_role TO my_aq_adm_role;

-- AQ users
DROP ROLE my_aq_user_role;
CREATE ROLE my_aq_user_role;
--

GRANT CREATE SESSION, aq_user_role TO my_aq_user_role;
--

EXEC DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE(PRIVILEGE=>'ENQUEUE_ANY',GRANTEE=>'my_aq_user_role', ADMIN_OPTION=>FALSE);
EXEC DBMS_AQADM.GRANT_SYSTEM_PRIVILEGE(PRIVILEGE=>'DEQUEUE_ANY',GRANTEE=>'my_aq_user_role', ADMIN_OPTION=>FALSE);
```

Create users matching the roles that you have just created.

```sql
-- Create the AQADM user.
DROP USER aqadm CASCADE;
CREATE USER aqadm IDENTIFIED BY aqadm
    DEFAULT TABLESPACE aq
    TEMPORARY TABLESPACE temp
    QUOTA 0 ON system
    QUOTA UNLIMITED ON aq
    PROFILE default;
GRANT my_aq_adm_role TO aqadm;
-- Create the AQUSER
DROP USER aquser CASCADE;
CREATE USER aquser IDENTIFIED BY aquser
    DEFAULT TABLESPACE aq
    TEMPORARY TABLESPACE temp
    QUOTA 0 ON system
    QUOTA UNLIMITED ON aq
    PROFILE default;
GRANT my_aq_user_role TO aquser;
```

Finally, create the AQ Queue. This step must be done as the AQ Administrator user, so reconnect using the AQ Administrator credentials (if you used the example above, that will be aqadm/aqadm):

```sql
EXEC DBMS_AQADM.STOP_QUEUE (queue_name => 'message_queue');
EXEC DBMS_AQADM.DROP_QUEUE (queue_name => 'message_queue');
EXEC DBMS_AQADM.DROP_QUEUE_TABLE (queue_table => 'queue_message_table');

EXEC DBMS_AQADM.CREATE_QUEUE_TABLE (queue_table => 'queue_message_table', queue_payload_type => 'SYS.AQ$_JMS_TEXT_MESSAGE');
EXEC DBMS_AQADM.CREATE_QUEUE (queue_name => 'message_queue', queue_table => 'queue_message_table');
EXEC DBMS_AQADM.START_QUEUE (queue_name => 'message_queue');
```

### Summary ###

What you have done is create a queue that accepts and delivers standard JMS Text messages. You will now be able to send and receive messages using a [oracleaq-implementation][] as the specific VendorImplementation paying attention to the broker-url that will be used to connect to the Oracle instance.

----

## Interlok Configuration ##

The associated vendor implementation class that should be used is [oracleaq-implementation][]. Ensure that the broker URL is the full JDBC connection string and that the user associated with the connection has the correct access rights. If you configure an Adapter which 2 channels, one filesystem to Oracle and the other Oracle to filesystem, then you should be able to perform a simple loopback test using Oracle AQ using the queue `message_queue`.

### Destinations ###

The produce and consume destinations should always resolve to the AQ Queue that you wish to send and receive from. If you have created the Oracle AQ Queue using one user and intend on connecting using a different user; provided you have sufficient rights as the second user, you can simply specify the owner of the queue using dot notation (e.g. for the above example it would be aqadm.message_queue if you were connecting as `aquser`).


### Recipient Lists ###

A feature of using Topics is that you can restrict the delivery of the message to a subset of listeners on the topic. This is achieved within Oracle AQ though the use of recipient lists. As this feature deviates from the standard JMS API; you have to use a different producer - [oracle-topic-producer][] which understands the concept of `AQjmsAgent`. The provided implementation allows you to specify a [ReceipientList][]  implementation which then provides the AQjmsAgent[] instance which can be used in AQjmsTopicPublisher#publish().

The default implementation, [oracleaq-simple-recipient-list][], allows you to configure multiple nested [oracleaq-configured-recipient][] and [oracleaq-metadata-recipient][] instances. If this type of behaviour is not suitable for your purposes, then you will need to build a custom class that implements the RecipientList interface. However, in most cases, provided you can extract the required information as metadata, the standard implementation should be sufficient.

----

## Additional Message Types ##

Standard message types are supported by the usual `MessageTypeTranslator` implemenstations such as [text-message-translator][], provided you have setup the AQ Queue with the appropriate `queue_payload_type`. Oracle AQ JMS also supports an additional message type that represents internal Oracle objects called `AdtMessage`. This is a message whose body contains an Oracle object type, and as such isn't handled by the standard JMS message types. Using this type of message involves a few more steps before you can start Interlok.

- Create the object type
- Create the queue to use the object type
- Export the object as a java class
- Configure Interlok to map between AdaptrisMessage and the object

This walkthrough will create a simple Oracle object type and configure an appropriate MessageTypeTranslator that is capable of handling the object.  Connect to the database as the AQ Administrator (aqadm/aqadm) user to perform the SQL commands.

### Oracle Configuration ###

First of all, create the object type. Here we create an object called `queue_message_type_clob` that contains 3 fields; for the purposes of our example, we'll use 3 different types of field just to demonstrate the mapping capabilities.

```sql
CREATE TYPE queue_message_type_clob AS OBJECT (
  no NUMBER,
  title VARCHAR2(30),
  text CLOB
);
/
GRANT EXECUTE ON queue_message_type_clob TO my_aq_user_role;

```

Next we need to replace the existing queue definition with a new one using `queue_message_type_clob`:

```sql

EXEC DBMS_AQADM.STOP_QUEUE (queue_name => 'message_queue');
EXEC DBMS_AQADM.DROP_QUEUE (queue_name => 'message_queue');
EXEC DBMS_AQADM.DROP_QUEUE_TABLE (queue_table => 'queue_message_table');

EXEC DBMS_AQADM.CREATE_QUEUE_TABLE (queue_table => 'queue_message_table', queue_payload_type => 'aqadm.queue_message_type_clob');
EXEC DBMS_AQADM.CREATE_QUEUE (queue_name => 'message_queue', queue_table => 'queue_message_table');
EXEC DBMS_AQADM.START_QUEUE (queue_name => 'message_queue');

```

To make sure that we have done everything correctly, then we can use [SQLDeveloper][] to manually test that the queue was created successfully using the newly created object. You should connect as the AQ user and run the following commands.

```sql
--
-- Enqueue message
DECLARE
  queue_options 		DBMS_AQ.ENQUEUE_OPTIONS_T;
  message_properties	DBMS_AQ.MESSAGE_PROPERTIES_T;
  message_id		RAW(16);
  my_message 		aqadm.queue_message_type_clob;
BEGIN
  my_message := aqadm.queue_message_type_clob(
			1,
			'This is a sample message',
			'This message has been posted on ' || TO_CHAR(SYSDATE, 'DD.MM.YYYY HH24:MI:SS'));
  DBMS_AQ.ENQUEUE(
    queue_name => 'aqadm.message_queue',
    enqueue_options => queue_options,
    message_properties => message_properties,
    payload => my_message,
    msgid => message_id);
  COMMIT;
END;
/

--
-- Dequeue message
SET SERVEROUTPUT ON;
DECLARE
  queue_options 		DBMS_AQ.DEQUEUE_OPTIONS_T;
  message_properties	DBMS_AQ.MESSAGE_PROPERTIES_T;
  message_id		RAW(2000);
  my_message 		aqadm.queue_message_type_clob;
BEGIN
  DBMS_AQ.DEQUEUE(
    queue_name =>'aqadm.message_queue',
    dequeue_options => queue_options,
    message_properties => message_properties,
    payload => my_message,
    msgid => message_id
  );
  COMMIT;
  DBMS_OUTPUT.PUT_LINE('Dequeued no:    ' || my_message.no);
  DBMS_OUTPUT.PUT_LINE('Dequeued title: ' || my_message.title);
  DBMS_OUTPUT.PUT_LINE('Dequeued text:  ' || my_message.text);
END;

```

The `enqueue` SQL command is an easy way of injecting messages onto the queue (and thus into Interlok) for testing.

Now that the object has been created within Oracle, we need to export so that it is available as a java object. The Oracle installation should provide a tool called JPublisher that allows you to export oracle objects as java source files. The tool is available in the \oc4j\bin directory. With some versions of Oracle, the script may be missing for the Windows platform, but will be available for the UNIX platform. It should be relatively simple to modify the UNIX script to be suitable for Windows. Having created the script (as appropriate) you can run something similar to the following sequence of commands.

```nohighlight
echo "SQL QUEUE_MESSAGE_TYPE_CLOB GENERATE QueueMessageTypeClob" >input.txt
jpub -user=aqadm/aqdm -input=input.txt
```

This will create a number of files in the current work directory. The most important is `QueueMessageTypeClob.java` which should be modified to include a package directive, compiled to a .class file, placed in a jar, and made available in the Interlok lib directory.

### Interlok Configuration ###

[dynamic-adt-message-translator][] is provided as a generic message translator that uses reflection to parse the generated wrapper object and map fields directly into the AdaptrisMessage. This should be suitable for most situations, depending on the type of field that is present in the Oracle object type, if not; the other option is to provide your own implementation of [AdtMessageTranslator][] which allows you to control directly how the object will be mapped to and from AdaptrisMessage. Based on the example Oracle object type, we would use a [dynamic-adt-message-translator][] instance with three [FieldMapper][] instances that handle the mapping for `No`, `Text` and `Title`. We will map the `Text` field into the payload and all the other fields into metadata.

In addition to standard fields inherited from the parent `MessageTypeTranslator`; [dynamic-adt-message-translator][] exposes some additional fields which are detailed below.

| Field | Description|
|----|----|
|adt-classname|The classname of the object previously exported using JPublisher|
|move-jms-headers|Whether to move JMS Headers into the object. The default is false as using an AdtMessage may not allow you to specify JMS Headers.|
|move-metadata|Whether to move AdaptrisMessage metadata as JMS Properties on the message. The default is false as required metadata must be explicitly mapped into the AdtMessage.|
|field-mapper|A List of explicitly configured elements that control how the AdaptrisMessage is mapped into the AdtMessage and vice-versa|

<br/>

### Mapping Fields ###

There are a number of ways you can map specific AdtMessage fields into AdaptrisMessage and vice versa. All field mapper instances contain some common configuration elements:

| Field | Description|
|----|----|
|field-name|This refers to the specific field within the AdtMessage that you wish to map. From the example, valid values could be `No,`Text`, or `Title`. The field name here should match the getter and setter method in the published source file without the get/set prefix
|field-type|This refers to the type of the field|


The supported types of [FieldMapper][] implemenstations are currently [oracleaq-metadata-mapper][], [oracleaq-payload-mapper][], [oracleaq-message-id-mapper][], [oracleaq-configured-field][] and [oracleaq-xpath-field][].

| Field Mapper| Description |
|----|----|
|[oracleaq-metadata-mapper][]|This maps an item of AdaptrisMessage metadata to a specific AdtMessage field (and vice versa). The metadata-key element determines the metadata key that will be used to derive the content of the mapping.|
|[oracleaq-payload-mapper][]|This maps the AdaptrisMessage payload into a specific AdtMessage (and vice versa)|
|[oracleaq-message-id-mapper][]|This maps the AdaptrisMessage unique id into a specific AdtMessage field (and vice versa).|
|[oracleaq-configured-field][]|This simply sets a specific AdtMessage field to the configured value. AdtMessage fields may not be mapped into AdaptrisMessage using this FieldMapper instance.|
|[oracleaq-xpath-field][]|This resolves an XPath against the AdaptrisMessage payload and sets a specific AdtMessage field based on this value. AdtMessage fields may not be mapped into AdaptrisMessage instances using this FieldMapper instance.|

<br/>

### Handling Different Types ###

The [TypeWrapper][] interface allows you to handle different types of data within the abstract data type. A number of implementations are provided for you; these match the basic JDBC data types.

| Type Wrapper| Description |
|----|----|
|[oracleaq-simple-type][]|This handles the basic primitive types within java; these are configured using the type field. The following types are supported: `BIGDECIMAL`, `BOOLEAN`, `DOUBLE`, `FLOAT`, `INTEGER`, and `STRING`.|
|[oracleaq-blob-type][]|This type handles a blob field. As the TypeWrapper interface only supports Strings, various ByteFlavours are supported in order to convert the binary object into a string. The supported byte flavours are `BASE64`, `PLATFORM`, `UTF-8`.|
|[oracleaq-clob-type][]|This handles a CLOB field. You can set a [ClobType.Handler][] which is either ASCII or CHARACTER, this in turn delegates to either Clob#getAsciiStream() or Clob#getCharacterStream(). If none is specified, ASCII is assumed.|
|[oracleaq-date-type][]|This handles a `java.sql.Date` field. By setting the format string, you can control how the object is converted to and from a String. The conversion will be done using `SimpleDateFormat` and the specified format string.|
|[oracleaq-time-type][]|This type handles a `java.sql.Time` field. By setting the format string, you can control how the object is converted to and from a String. The conversion will be done using `SimpleDateFormat` and the specified format string|
|[oracleaq-timestamp-type][]|This type handles a `java.sql.Timestamp` field. By setting the format string, you can control how the object is converted to and from a String. The conversion will be done using `SimpleDateFormat` and the specified format string|

<br/>

[oracleaq-implementation]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/OracleAqImplementation.html
[oracle-topic-producer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/OracleAqPasProducer.html
[ReceipientList]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/RecipientList.html
[oracleaq-configured-recipient]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/ConfiguredRecipient.html
[oracleaq-metadata-recipient]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/MetadataRecipient.html
[text-message-translator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.11-SNAPSHOT/com/adaptris/core/jms/TextMessageTranslator.html
[SQLDeveloper]: http://www.oracle.com/technetwork/developer-tools/sql-developer/downloads/index.html
[dynamic-adt-message-translator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/DynamicAdtMessageTranslator.html
[FieldMapper]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/FieldMapper.html
[oracleaq-metadata-mapper]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/MetadataMapper.html
[oracleaq-payload-mapper]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/PayloadMapper.html
[oracleaq-message-id-mapper]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/MessageIdMapper.html
[oracleaq-configured-field]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/ConfiguredField.html
[oracleaq-xpath-field]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/XpathField.html
[TypeWrapper]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/TypeWrapper.html
[AdtMessageTranslator]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/AdtMessageTranslator.html
[oracleaq-simple-type]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/SimpleType.html
[oracleaq-blob-type]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/BlobType.html
[oracleaq-clob-type]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/ClobType.html
[oracleaq-date-type]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/DateType.html
[oracleaq-time-type]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/TimeType.html
[oracleaq-timestamp-type]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/TimestampType.html
[ClobType.Handler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-jms-oracleaq/3.11-SNAPSHOT/com/adaptris/core/jms/oracle/ClobType.Handler.html
