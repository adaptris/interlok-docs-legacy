---
title: XML Transformations
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-xml-transform.html
summary: Use xml-transform-service to transform XML documents
---

We can use [xml-transform-service] to execute a XSLT in order to transform XML documents from one format to another. XSLT needs no further introduction.

Without any additional configuration Interlok will use the default Saxon transformation engine to handle transforms; however this is configurable within the transform-service itself by selecting the appropriate transformer factory. You can also pass in metadata (String/Object/) into your XSLT via use of the [xml-transform-pararmeter]. A common use case for this is to extract information via [xpath-metadata-service] or [xpath-object-metadata-service] and to then use those values within your XSLT.

Through use of [xpath-object-metadata-service] you can extract a node from the current document, store it in object metadata, replace the entire document was something else (perhaps from a HTTP request) and then subsequently insert the node back into the data at a later point within the same workflow. This is useful if your service chain is complex and the required information can't be easily stored as strings.

## XML Transformer implementations ##

|Transformer Implementation| Description|
|----|----
|[stx-transformer-factory][]| Use Joost as a transform factory for _Streaming Transformations for XML_ support [via net.sf.joost:joost:0.9.1](http://joost.sourceforge.net/)|
|[xslt-transformer-factory][]| Standard XSLT transform; You can specify the transformer factory implementation is you want to switch to Xalan or another factory. |



[xml-transform-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/transform/XmlTransformService.html
[xml-transform-pararmeter]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/transform/XmlTransformParameter.html
[xpath-metadata-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/services/metadata/XpathMetadataService.html
[xpath-object-metadata-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/services/metadata/XpathObjectMetadataService.html
[xslt-transformer-factory]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/util/text/xml/XsltTransformerFactory.html
[stx-transformer-factory]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/util/text/xml/StxTransformerFactory.html
