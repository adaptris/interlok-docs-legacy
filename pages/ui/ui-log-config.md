---
title: Log Config
keywords: interlok
tags: [getting_started, ui]
sidebar: home_sidebar
permalink: ui-log-config.html
summary: The Log Config page allows you to modify an adapter log configuration. (Since 3.6.0)
---

## Getting Started ##

To access the Log Config page, you use the log config button on the header navigation bar. The page is only accessible by admin users.

The header navigation bar:
 ![Navigation bar with log config selected](./images/ui-user-guide/log-config-header-navigation.png)

## Log Config ##

### Select a Log Config ###

![Log config page](./images/ui-user-guide/log-config-page.png)

Select an Adapter via the dropdown and the log config will be displayed in the editor if available.

The Save button will be enabled if the log configuration is editable (e.g. a log4j2.xml file exist in the /interlok/config folder).
When saving a modified configuration it will take few seconds for the adapter to pick up the changes. 

You can find more help on how to configure [Log4j](https://logging.apache.org/log4j/2.x/manual/configuration.html#XML).

