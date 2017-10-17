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
CREATE USER 'interlokuidb'@'localhost' IDENTIFIED BY 'interlokuidb';
GRANT ALL PRIVILEGES ON interlokuidb.* TO 'interlokuidb'@'localhost';
```

or 

```sql
CREATE DATABASE interlokuidb;
GRANT ALL ON interlokuidb.* TO 'interlokuidb'@'localhost' IDENTIFIED BY 'interlokuidb';
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
CREATE USER interlokuidb WITH PASSWORD 'interlokuidb';
GRANT ALL PRIVILEGES ON DATABASE interlokuidb TO interlokuidb
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

## System Properties ##

Since version 3.6.5 the database settings can be configured with command line system properties.
When used they will override any properties set in properties files.

```
-DdataSource.provider=mysql -DdataSource.driverClass=com.mysql.jdbc.Driver -DdataSource.jdbcURL="jdbc:mysql://localhost:3306/interlokuidb?&autoReconnect=true" -DdataSource.user=interlokuidb -DdataSource.password=interlokuidb
```

If the user and password are provided in the jdbc url they will override any other set user and password.

```
-DdataSource.provider=mysql -DdataSource.driverClass=com.mysql.jdbc.Driver -DdataSource.jdbcURL="jdbc:mysql://localhost:3306/interlokuidb?user=interlokuidb&password=interlokuidb&autoReconnect=true"
```
