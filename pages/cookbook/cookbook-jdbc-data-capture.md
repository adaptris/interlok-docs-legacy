---
title: Data Capture using JDBC
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-jdbc-data-capture.html
---

Sometimes; you'll want to capture data from an in-flight [message][AdaptrisMessage] and write it out to a JDBC compliant database. There are 3 standard ways you can do this : [jdbc-data-capture-service][], [jdbc-raw-data-capture-service][] and [jdbc-stored-procedure-producer][]. The first 2 are [Service][] implementations which can write to any database table; the last is only used when executing a stored procedure.

## JDBC Data Capture Service ##

[jdbc-data-capture-service][] assumes that the payload of the [message][AdaptrisMessage] is text based (often XML). Data can be extracted from the message and stored in a database. There is the ability to optionally [iterate over an XPath][] insert multiple rows into the database as part of the same service. The configuration for this service closely mirrors that of [jdbc-data-query-service][] in that it will have a number of [jdbc-statement-parameter][] parameters configured and an SQL Statement.

If we consider the following example document:

```xml
<document>
  <subject>Pangrams</subject>
  <sample>
    <data>The quick brown fox jumps over the lazy dog.</data>
  </sample>
  <sample>
    <data>Pack my box with a dozen liqour jugs.</data>
  </sample>
  <sample>
    <data>Quick zephyrs blow, vexing daft Jim.</data>
  </sample>
  <sample>
    <data>How quickly daft jumping zebras vex.</data>
  </sample>
</document>
```

Then our [jdbc-data-capture-service][] to insert all the sample pangrams into a database table called `PANGRAMS` might be:

```xml
<jdbc-data-capture-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <statement>INSERT INTO PANGRAMS (pangram) values (?);</statement>
 <parameter-applicator class="sequential-parameter-applicator"/>
 <iteration-xpath>/document/sample</iteration-xpath>
 <iterates>true</iterates>
 <jdbc-statement-parameter>
  <query-string>./data</query-string>
  <query-class>java.lang.String</query-class>
  <query-type>xpath</query-type>
 </jdbc-statement-parameter>
</jdbc-data-capture-service>
```

- This results in 4 new rows in the database table `PANGRAMS`
- We get the nodelist returned by `/document/sample` and for each node in the list we resolve the the xpath `./data` to find the parameter to pass into the insert statement.
   - This results in 4 INSERT statements being executed.

{% include tip.html content="There is a variant of this service called [jdbc-batching-data-capture-service][] which allows you to set a batch window for performance purposes; a [jdbc-data-capture-service][] is simply a [jdbc-batching-data-capture-service][] with a batch window set to 1." %}

## JDBC Raw Data Capture Service ##

[jdbc-raw-data-capture-service][] makes no assumptions about the payload itself; if you configure a [jdbc-statement-parameter][] that is xpath based and the document is not XML; then results are undefined. It is designed for the use-cases where the [message][AdaptrisMessage] contains binary data, and you need to store the entire payload into a database table; optionally capturing some non-payload information as well. Again it will have a number of [jdbc-statement-parameter][] parameters configured and an SQL Statement.

Taking the example document above, we want to insert the entire document as a new row in the database table `PANGRAMS` capturing the message-id as well.

```xml
<jdbc-raw-data-capture-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <statement>INSERT INTO PANGRAMS (uniqueId, pangram) values (?, ?);</statement>
 <parameter-applicator class="sequential-parameter-applicator"/>
 <jdbc-statement-parameter>
  <query-class>java.lang.String</query-class>
  <query-type>id</query-type>
 </jdbc-statement-parameter>
 <jdbc-character-stream-statement-parameter/>
</jdbc-raw-data-capture-service>
```

- This results in a single new row in the database table `PANGRAMS` containing the message id and the entire document as two columns.

{% include note.html content="For a full discussion about [jdbc-statement-parameters][jdbc-statement-parameter] then you can look at the [Statement Parameters section of Data Extract using JDBC](cookbook-jdbc-data-query.html#statement-parameters)" %}

[jdbc-data-capture-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/JdbcDataCaptureService.html
[jdbc-raw-data-capture-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/raw/JdbcRawDataCaptureService.html
[jdbc-stored-procedure-producer]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jdbc/JdbcStoredProcedureProducer.html
[Service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html
[AdaptrisMessage]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessage.html
[iterate over an XPath]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/JdbcDataCaptureService.html#setIterates-java.lang.Boolean-
[jdbc-data-query-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/JdbcDataQueryService.html
[jdbc-statement-parameter]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/StatementParameter.html
[jdbc-batching-data-capture-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/JdbcBatchingDataCaptureService.html

{% include links.html %}