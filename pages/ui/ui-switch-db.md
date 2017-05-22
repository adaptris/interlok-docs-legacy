---
title: Switch Database Provider
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-switch-db.html
toc: false
summary: Since 3.6.3 the gui can be used with MySQL.
---

## Configuration ##

By default the Interlok web application uses an Embedded database called Derby. However since version 3.6.2 the web application can be configured to use MySQL (from v5.6).

In order to use MySQL you will need to follow these steps:

 - Add the java MySQL connector jar to the adapter/lib ddirectory. You can find the connector on [MySQL website](https://dev.mysql.com/downloads/connector/j/).
 - Create a database for the interlok web application (e.g. `interlokuidb`) and a user with access to it (e.g. user: `interlokuidb`, password: `interlokuidb`)
 - Add a properties file named `interlokuidb.properties` in the `adapter/ui-resources` or in the `adapter/lib` directory with the following properties:
 
```properties
dataSource.provider=mysql
dataSource.driverClass=com.mysql.jdbc.Driver
dataSource.jdbcURL=jdbc:mysql://localhost:3306/interlokuidb?autoReconnect=true
dataSource.user=interlokuidb
dataSource.password=interlokuidb
```
 - Start the adapter
