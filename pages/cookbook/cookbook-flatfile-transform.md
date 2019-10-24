---
title: Flat file Transformations
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-flatfile-transform.html
summary: Use flat-file-transform-service to transform flat documents into XML.
---

We can use [flat-file-transform-service] to transform a flat file into a simplified XML structure so we can use standard XSLT to transform the data further. The [flat-file-transform-service] relies on a definition file that describes the file. It uses this file to parse and then render the contents as XML. If required, you can specify the definition file using a metadata key rather than statically within the interlok configuration file.

The way in which it works is most easily demonstrated with an example.

## Example ##

If we take the following input file that contains a header, any number of detail records and a trailer records. In this instance there are no separators; and each record is expected to be 64 characters terminated by a newline.

```
HDRSRC20110601THE TITLE OF DOCSrcDescDestinationDesc  1234567890
DETField   1.01Field  1.02Field     1.0320110630Field   1.04400821
DETField   2.01Field  2.02Field     2.0320110730Field   2.04400821
DETField   3.01Field  3.02Field     3.0320110830Field   3.04400821
TRL00000005
```

Our corresponding definition XML would look like

```xml
<root>
<segment name="Document">
  <segment name="Header">
  <record length="0" separator="\n" rec_id="HDR" rec_id_start="1" rec_id_len="3" field_sep="" repetitions="0">
    <field name = "RecordType" length = "3" separator = ""/>
    <field name = "SourceCode" length = "3" separator = ""/>
    <field name = "RunDate" length = "8" separator = ""/>
    <field name = "Title" length = "16" separator = ""/>
    <field name = "SourceDescription" length = "7" separator = ""/>
    <field name = "DestDescription" length = "17" separator = ""/>
    <field name = "Filler" length = "10" separator = ""/>
  </record>
  </segment>
  <segment name="Details">
    <record length="0" separator="\n" rec_id="DET" rec_id_start="1" rec_id_len="3" field_sep="" repetitions="0">
      <field name = "RecordType" length = "3" separator = ""/>
      <field name = "FieldOne" length = "12" separator = ""/>
      <field name = "FieldTwo" length = "11" separator = ""/>
      <field name = "FieldThree" length = "14" separator = ""/>
      <field name = "CompletionDate" length = "8" separator = ""/>
      <field name = "FieldFour" length = "12" separator = ""/>
      <field name = "Filler" length = "6" separator = ""/>
    </record>
  </segment>
  <segment name="Trailer">
    <record length="0" separator="\n" rec_id="TRL" rec_id_start="1" rec_id_len="3" field_sep="" repetitions="0">
      <field name = "RecordType" length = "3" separator = ""/>
      <field name = "Total" length = "8" separator = ""/>
      <field name = "Filler" length = "53" separator = ""/>
    </record>
  </segment>
</segment>
</root>
```

which would produce the output :

```xml
<?xml version="1.0" encoding="UTF-8" ?>
<root>
  <segment_Document>
    <segment_Header>
      <record_HDR>
        <RecordType>HDR</RecordType>
        <SourceCode>SRC</SourceCode>
        <RunDate>20110601</RunDate>
        <Title>THE TITLE OF DOC</Title>
        <SourceDescription>SrcDesc</SourceDescription>
        <DestDescription>DestinationDesc</DestDescription>
        <Filler>1234567890</Filler>
      </record_HDR>
    </segment_Header>
    <segment_Details>
      <record_DET>
        <RecordType>DET</RecordType>
        <FieldOne>Field   1.01</FieldOne>
        <FieldTwo>Field  1.02</FieldTwo>
        <FieldThree>Field     1.03</FieldThree>
        <CompletionDate>20110630</CompletionDate>
        <FieldFour>Field   1.04</FieldFour>
        <Filler>400821</Filler>
      </record_DET>
      <record_DET>
        <RecordType>DET</RecordType>
        <FieldOne>Field   2.01</FieldOne>
        <FieldTwo>Field  2.02</FieldTwo>
        <FieldThree>Field     2.03</FieldThree>
        <CompletionDate>20110730</CompletionDate>
        <FieldFour>Field   2.04</FieldFour>
        <Filler>400821</Filler>
      </record_DET>
      <record_DET>
        <RecordType>DET</RecordType>
        <FieldOne>Field   3.01</FieldOne>
        <FieldTwo>Field  3.02</FieldTwo>
        <FieldThree>Field     3.03</FieldThree>
        <CompletionDate>20110830</CompletionDate>
        <FieldFour>Field   3.04</FieldFour>
        <Filler>400821</Filler>
      </record_DET>
    </segment_Details>
    <segment_Trailer>
      <record_TRL>
        <RecordType>TRL</RecordType>
        <Total>00000005</Total>
        <Filler></Filler>
      </record_TRL>
    </segment_Trailer>
  </segment_Document>
</root>
```



[flat-file-transform-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/transform/FfTransformService.html

