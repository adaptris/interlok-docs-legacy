---
title: Switch Database Provider
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-switch-db.html
toc: false
summary: Since 3.6.3 the gui can be used with MySQL.
---

## MySQL Configuration ##

By default the Interlok web application uses an Embedded database called Derby. However since version 3.6.2 the web application can be configured to use MySQL (from v5.6).

In order to use MySQL you will need to follow these steps:

 - Add the java MySQL connector jar to the adapter/lib directory. You can find the connector on [MySQL website](https://dev.mysql.com/downloads/connector/j/).
 - Create a database for the interlok web application (e.g. `interlokuidb`) and a user with access to it (e.g. user: `interlokuidb`, password: `interlokuidb`)

```sql
CREATE DATABASE interlokuidb;
CREATE USER 'adaptergui'@'localhost' IDENTIFIED BY 'adaptergui';
GRANT ALL PRIVILEGES ON adaptergui.* TO 'interlokuidb'@'localhost';
```
 - Add a properties file named `interlokuidb.properties` in the `adapter/ui-resources` or in the `adapter/lib` directory with the following properties:

```properties
dataSource.provider=mysql
dataSource.driverClass=com.mysql.jdbc.Driver
dataSource.jdbcURL=jdbc:mysql://localhost:3306/interlokuidb?autoReconnect=true
dataSource.user=interlokuidb
dataSource.password=interlokuidb
```
 - Start the adapter

{% include note.html content="The given sql queries are just example an may need to be adjusted to your needs." %}

## PostgreSQL Configuration ##

Since version 3.6.3 the web application can be configured to use PostgreSQL (from v9.6).

In order to use PostgreSQL you will need to follow these steps:

 - Add the java PostgreSQL connector jar to the adapter/lib directory. You can find the connector on [PostgreSQL website](https://jdbc.postgresql.org/download.html).
 - Create a database for the interlok web application (e.g. `interlokuidb`) and a user with access to it (e.g. user: `interlokuidb`, password: `interlokuidb`)

```sql
CREATE DATABASE interlokuidb;
CREATE USER adaptergui WITH PASSWORD 'adaptergui';
GRANT ALL PRIVILEGES ON DATABASE interlokuidb TO adaptergui
```
 - Add a properties file named `interlokuidb.properties` in the `adapter/ui-resources` or in the `adapter/lib` directory with the following properties:
 
```properties
dataSource.provider=postgresql
dataSource.driverClass=org.postgresql.Driver
dataSource.jdbcURL=jdbc:postgresql://localhost:32770/interlokuidb?autoReconnect=true
dataSource.user=interlokuidb
dataSource.password=interlokuidb
```
 - Start the adapter

{% include note.html content="The given sql queries are just example an may need to be adjusted to your needs." %}