---
title: Data Query using JDBC
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-jdbc-data-query.html
---

[jdbc-data-query-service][] is often used to extract data from a database to enrich the message. Here we will work through a few examples using the different translators and statements parameters.


## Sample Data ##

Our sample database contains a single table with two rows.

```nohighlight
mysql> select * from testtable\G
*************************** 1. row ***************************
     id: 1
   name: Mitch Chung
payload: <details>
  <firstname>Mitch</firstname>
  <surname>Chung</surname>
</details>
   date: 2011-11-03 09:21:48
*************************** 2. row ***************************
     id: 2
   name: Keis Agrebi
payload: <details>
  <firstname>Keis</firstname>
  <surname>Agrebi</surname>
</details>
   date: 2011-11-03 09:22:05
2 rows in set (0.00 sec)
```

Our source input document is simply:

```xml
<root>
  <id>1</id>
</root>
```


# Handling the ResultSet #

There are two main ways to handle the results of your query. Either by using an [XML ResultSetTranslator][] or a [Metadata ResultSetTranslator][]; we have found that these translator types will cover the majority of use cases. Each of the translator types defines common behaviour shared between the concrete sub classes. Naturally, if your use case isn't covered then you can write your own implementation of [ResultSetTranslator][].

{% include tip.html content="If converting to XML, then you should consider setting `strip-illegal-xml-chars=true`; illegal characters are not a problem when writing XML; it will be a problem when you read it in (later on when you need to use XSLT)." %}

## XmlPayloadTranslator ##

[jdbc-xml-payload-translator][] replaces the existing payload with the contents of the `ResultSet`. The top-level element is called `Results` and can optionally preserve the original message in an `OriginalMessage` element. Each row in the result set becomes a repeating element named `Row`; and each column of the result set forms a child XML element; the name of each element is dependent on the _column-name-style_ chosen.


```xml
<jdbc-data-query-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <statement>SELECT id,name from testtable</statement>
 <result-set-translator class="jdbc-xml-payload-translator">
  <column-name-style>NoStyle</column-name-style>
  <preserve-original-message>true</preserve-original-message>
 </result-set-translator>
</jdbc-data-query-service>
```

Will give us a new payload of:

```xml
<Results>
  <OriginalMessage>
    <root>
      <id>1</id>
    </root>
  </OriginalMessage>
  <Row>
    <id>1</id>
    <name>Mitch Chung</name>
  </Row>
  <Row>
    <id>2</id>
    <name>Keis Agrebi</name>
  </Row>
</Results>

```

- The original message is preserved under the element `OriginalMessage`.
    - If the message was not XML then this would still be the case.
- [NoStyle][] was the _column-name-style_ specified, so the XML element name for each column is database dependent.

## MergeResultSetIntoXmlPayload ##

[jdbc-merge-into-xml-payload][] takes the result set and merges it into the existing XML payload using the specified [DocumentMerge][] implementation. There are 3 standard [DocumentMerge][] implementations available: [xml-insert-node][], [xml-replace-node][], [xml-replace-original][]. Their names describe their behaviour quite succintly.

The result set is turned into an XML document with the a top level element called `Results`; each row in the result set becomes a repeating element named `Row`; and each column of the result set forms a child XML element; the name of the element is dependent on the _column-name-style_ chosen. The resulting document is _merged_ into the existing document.


```xml
<jdbc-data-query-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <statement>SELECT id,name from testtable</statement>
 <result-set-translator class="jdbc-merge-into-xml-payload">
  <column-name-style>UpperCase</column-name-style>
  <merge-implementation class="xml-insert-node">
   <xpath-to-parent-node>/root</xpath-to-parent-node>
  </merge-implementation>
 </result-set-translator>
</jdbc-data-query-service>
```

Would give us:

```xml
<root>
  <id>1</id>
  <RESULTS>
    <ROW>
      <ID>1</ID>
      <NAME>Mitch Chung</NAME>
    </ROW>
    <ROW>
      <ID>2</ID>
      <NAME>Keis Agrebi</NAME>
    </ROW>
  </RESULTS>
</root>
```

- The results have been merged into the existing message; there is no `OriginalMessage` element, and the top level element remains unchanged.
- We have specified [UpperCase][] as the style; so all elements from the query are upper case.

## FirstRowMetadataTranslator

[jdbc-first-row-metadata-translator][] takes the first row of the result set and stores each column as a separate metadata key. There is an optional `metadata-prefix` and `separator` that can be specified; these will be prefixed to the column to form a new metadata key. The use of metadata-prefix is encouraged as

- Any existing metadata will be overwritten (so unfortunate table names may override critical metadata).
- You can subsequently remove the metadata easily using [metadata-filter-service][]

```xml
<jdbc-data-query-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <result-set-translator class="jdbc-first-row-metadata-translator">
  <column-name-style>NoStyle</column-name-style>
  <metadata-key-prefix>testtable</metadata-key-prefix>
  <separator>+</separator>
 </result-set-translator>
</jdbc-data-query-service>
```

- The original message is unchanged.
- The message now has additional metadata `testtable+id=1` and `testtable+name=Mitch Chung`.


## AllRowsMetadataTranslator ##

[jdbc-all-rows-metadata-translator][] performs as you might expect; it iterates over all the rows of the result set, taking each column and storing that as a separate metadata key. A count is appended to the key, to make it unique.

```xml
<jdbc-data-query-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <statement>SELECT name from testtable</statement>
 <result-set-translator class="jdbc-all-rows-metadata-translator">
  <column-name-style>NoStyle</column-name-style>
  <metadata-key-prefix>testtable</metadata-key-prefix>
  <separator>+</separator>
 </result-set-translator>
</jdbc-data-query-service>
```

- The original message is unchanged.
- The message now has additional metadata `testtable+name+1=Mitch Chung` and `testtable+name+2=Keis Agrebi`.


## Column Translation ##

### Column Names into XML ###

The name of each column (if using an [XML ResultSetTranslator][]) will be checked for validity as an XML element name. Invalid characters will be removed and replaced with a `_`. If there will be an invalid character as the first character (e.g. a number); then a `_` is used as the first character.

{% include tip.html content="A blank column name (yes it could happen) will result in an element named `column-N`, where N is the column index starting from 1." %}

### Column Style ###

There are 4 supported styles for column names: [Capitalize][], [UpperCase][], [LowerCase][], [NoStyle][]. The style specified will affect both XML element names and also metadata keys. For metadata keys, the prefix is not affected by the style specified.

### Column Translators ###

For the standard JDBC datatypes, you can specify a [list of ColumnTranslator][] instances that will be used and applied to the column in the result set.

- If this list is not empty then each translator in the list will be used to translate the corresponding column in the result set.
- If the list is empty then each column in the result set will be treated as either a `byte[]` or `String` column which may lead to undefined behaviour in the event of columns being CLOB / NCLOB / BLOB types.
- If the size of the list is less than the number of columns then each element of the list will be used to translate the corresponding columns; remaining columns will be treated either as `byte[]` or `String`

{% include tip.html content="You might want to use a [ColumnTranslator][] to apply formatting to `java.sql.Timestamp` or numeric data columns." %}

If your select statement was

```sql
select string_data1, boolean_data, inserted_on, updated_on from data
```

then your [jdbc-xml-payload-translator][] configuration might be (_inserted_on_, and _updated_on_ assumed to be `java.sql.Timestamp` columns):

```xml
<result-set-translator class="jdbc-xml-payload-translator">
 <column-name-style>NoStyle</column-name-style>
 <preserve-original-message>true</preserve-original-message>
 <jdbc-type-string-column-translator>
   <format>My Data: '%1$s'</format>
 </jdbc-type-string-column-translator>
 <jdbc-type-boolean-column-translator/>
 <jdbc-type-timestamp-column-translator>
  <date-format>yyyy-MM-dd</date-format>
 </jdbc-type-timestamp-column-translator>
</result-set-translator>
```

- We have applied additional formatting on the `string_data1` column (see [String.format][]).
- We have applied additional formatting on the `inserted_on` column (see [SimpleDateFormat][]).
- No formatting is applied on the `updated_on` column; the output will be Locale/precision dependent.
- We have to add a `jdbc-type-boolean-column-translator` because we want to apply formatting on `inserted_on`.


### Special Columns ###

As you can see from the sample data above; the `payload` column contains data that would be considered XML. In these examples we have not been selecting that column, however, if you were to select the column then on an [XML ResultSetTranslator][] implementation you can specify a `xml-column-regexp` which will cause the translator to do additional processing of that column to render the contents of that column into XML. Columns that should be rendered within a CDATA tag can similarly be specified using a `cdata-column-regexp`


# Statement Parameters #

Up until now we have not passed any parameters into our select statements; [jdbc-statement-parameter][] allows us to do this. If our statements are changed to `select name from testtable where id=?` then we need to pass in a single parameter to the select statement. This parameter can be be derived from the payload via an XPath, from metadata, the message id, a constant, or the entire payload itself.

The generalised configuration for a statement parameter is as follows

```xml
<jdbc-statement-parameter>
  <query-string>Changes meaning depending on query-type</query-string>
  <query-class>Generally java.lang.String, could be any fully qualified class name</query-class>
  <query-type>The Query Type</query-type>
</jdbc-statement-parameter>
```

<br/>

| Query-Type | Query-String | Behaviour |
|----|----|----
| metadata| a metadata key | Get the metadata value associated with `query-string` |
| xpath | an XPath | Resolve the xpath associated with `query-string` and return the value|
| constant | a constant| Return the `query-string` as is |
| payload | n/a | Return the entire payload as is |
| id | n/a | Return the message unique id |

<br/>

## Named vs Sequential Parameters ##

The standard behaviour when configuring your parameters is to make sure they're configured in the correct order.

Take the following select statement;

```
SELECT * FROM mytable WHERE field1=? AND field2=? AND field3=? AND field4=? AND field5=?
```

We have a select statement that requires 5 parameters, these parameters now need to be configured in the correct order;

```xml
<jdbc-statement-parameter>
  <query-string>...</query-string>
  <query-class>...</query-class>
  <query-type>...</query-type>
</jdbc-statement-parameter>
<jdbc-statement-parameter>
  <query-string>...</query-string>
  <query-class>...</query-class>
  <query-type>...</query-type>
</jdbc-statement-parameter>
<jdbc-statement-parameter>
  <query-string>...</query-string>
  <query-class>...</query-class>
  <query-type>...</query-type>
</jdbc-statement-parameter>
...
```

Above is just 3 of those parameters.  As you can imagine when you have more complex queries with many more parameters the configuration can become difficult to maintain.

To somewhat ease the burden we can reference parameters by name.  To activate this feature you simply need to configure a "named-parameter-applicator";

```xml
<jdbc-data-query-service>
	<parameter-applicator class="named-parameter-applicator"/>
```

This allows us to change this services configuration in two ways.  First we can modify our select statement;

```sql
SELECT * FROM mytable WHERE field1=#param1 AND field2=#param2 AND field3=#param3 AND field4=#param4 AND field5=#param5
```

Rather than each value in our "where" clause as a simple "?", we specify a name.  Each of these names will match a statement-parameter, who's configuration changes slightly to include this name ```<name>param1</name>```;

```xml
<jdbc-statement-parameter>
  <name>param1<name/>
  <query-string>...</query-string>
  <query-class>...</query-class>
  <query-type>...</query-type>
</jdbc-statement-parameter>
...
```

With the following configuration changes you do not need to make sure all parameters are configured in the correct order.

### Further named parameter configuration ###

As you may have noticed in example select statement above, named parameters are referenced with a "#" symbol.  This parameter prefix can be configured for a different value, for example "@";

```xml
<parameter-applicator class="named-parameter-applicator">
  <parameter-name-prefix>@</parameter-name-prefix>
</parameter-applicator>
```

Finally, the internals of the named-parameter-applicator will search the SQL statement for named parameter references using a regular expression.  The default regular expression is this; ```"#\w*"```

This regular expression will search for all words (equivalent to "[a-zA-Z_0-9]") starting with a "#".

Should you modify the prefix or wish to use a different regular expression you can modify it like this;

```xml
<parameter-applicator class="named-parameter-applicator">
  <parameter-name-prefix>@</parameter-name-prefix>
  <parameter-name-regex>@\w*</parameter-name-regex>
</parameter-applicator>
```

## Different types of Parameter ##

There are sub-classes of [jdbc-statement-parameter][] that override the `convertToQueryClass` method. The standard ones will transform a String into the standard JDBC datatypes like Boolean, Double, Float, Integer, Long, Short, Date etc. Classes that are database implementation specific (for instance, there might be a LONGITUDE type in your database); then provided the class has a `String` constructor, then you can specify the classname as the `query-class` parameter and keep using [jdbc-statement-parameter].

```xml
<jdbc-statement-parameter>
  <query-string>8.779897727500000</query-string>
  <query-class>com.mydatabase.types.Longitude</query-class>
  <query-type>constant</query-type>
</jdbc-statement-parameter>
```

Which will effectively call `new com.mydatabase.types.Longitude("8.779897727500000")` via reflection. No validation of the value passed into the constructor is done, it simply assumes that there is a constructor that takes a `String` parameter.

## Example ##

Given the example document above, we can use an XPath statement parameter to extract the ID that is required to select data.

```xml
<jdbc-data-query-service>
 <connection class="jdbc-connection">
  <driver-imp>com.mysql.jdbc.Driver</driver-imp>
  <connect-url>jdbc:mysql://localhost:3306/mydatabase</connect-url>
 </connection>
 <statement>SELECT id,name from testtable where id=?</statement>
 <jdbc-statement-parameter>
  <query-string>/root/id</query-string>
  <query-class>java.lang.String</query-class>
  <query-type>xpath</query-type>
 </jdbc-statement-parameter>
 <result-set-translator class="jdbc-merge-into-xml-payload">
  <column-name-style>LowerCase</column-name-style>
  <merge-implementation class="xml-insert-node">
   <xpath-to-parent-node>/root</xpath-to-parent-node>
  </merge-implementation>
 </result-set-translator>
</jdbc-data-query-service>
```

which results in

```xml
<root>
  <id>1</id>
  <results>
    <row>
      <id>1</id>
      <name>Mitch Chung</name>
    </row>
  </results>
</root>
```

- Only 1 row is selected in the result set.
- We have specified lowercase as the style; so elements from the query are lowercase.



[jdbc-data-query-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/JdbcDataQueryService.html
[jdbc-xml-payload-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/XmlPayloadTranslator.html
[jdbc-merge-into-xml-payload]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/MergeResultSetIntoXmlPayload.html
[DocumentMerge]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/DocumentMerge.html
[xml-insert-node]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/InsertNode.html
[xml-replace-node]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/ReplaceNode.html
[xml-replace-original]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/util/text/xml/ReplaceOriginal.html
[jdbc-first-row-metadata-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/FirstRowMetadataTranslator.html
[jdbc-all-rows-metadata-translator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/AllRowsMetadataTranslator.html
[metadata-filter-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/metadata/MetadataFilterService.html
[XML ResultSetTranslator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/XmlPayloadTranslatorImpl.html
[jdbc-statement-parameter]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/StatementParameter.html
[Capitalize]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/ResultSetTranslatorImp.ColumnStyle.html#Capitalize
[UpperCase]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/ResultSetTranslatorImp.ColumnStyle.html#UpperCase
[LowerCase]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/ResultSetTranslatorImp.ColumnStyle.html#LowerCase
[NoStyle]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/ResultSetTranslatorImp.ColumnStyle.html#NoStyle
[list of ColumnTranslator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/ResultSetTranslatorImp.html#setColumnTranslators-java.util.List-
[ColumnTranslator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/types/ColumnTranslator.html
[String.format]: http://docs.oracle.com/javase/7/docs/api/java/util/Formatter.html
[SimpleDateFormat]: http://docs.oracle.com/javase/7/docs/api/java/text/SimpleDateFormat.html
[Metadata ResultSetTranslator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/MetadataResultSetTranslatorImpl.html
[ResultSetTranslator]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/ResultSetTranslator.html


{% include links.html %}