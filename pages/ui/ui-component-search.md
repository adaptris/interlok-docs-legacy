---
title: Interlok Component Search
keywords: interlok
tags: [components, ui]
sidebar: home_sidebar
permalink: ui-interlok-component-search.html
summary: The Interlok Component Search page allows you to search an interlok component database. (Since 3.8.2)
---

## Getting Started ##

To access the Interlok Component Search page, you use the component search button on the header navigation bar, which is located in the Config sub-menu.

The header navigation bar:

 ![Navigation bar with search shown](./images/ui-user-guide/component-search-nav.png)

## Component Search Page ##

The component search page allows you to search an Elasticsearch index containing data concerned with all (most) our Interlok components for a given version. At this time (3.8.2), not every Interlok component has been indexed, but most are and the indexing process will be improved over time.

Upon opening the component search page, you are presented with a search input that you can type your search criteria into. 

The search page upon opening:

 ![Component Search Page](./images/ui-user-guide/component-search-blank.png)

Having typed search criteria and pressed enter or clicked search you will be shown the search results:

 ![Component Search Page](./images/ui-user-guide/component-search.png)
 
Each result will contain the following information:

![Component Search Page](./images/ui-user-guide/component-search-anotated.png)
 

## Search Criteria ##

The search criteria can contain Elasticsearch filters, such as
'fullClassName:com.adaptris.core.services.metadata.AddMetadataService' or 'alias:add-metadata-service'

Other useful fields to filter include:
* fullClassName:com.adaptris.core.services.metadata.AddMetadataService
* className:AddMetadataService
* packageName:com.adaptris.core.services.metadata
* componentType:service
* alias:add-metadata-service
* jarFileName:interlok-core.jar

