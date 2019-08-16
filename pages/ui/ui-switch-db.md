---
title: Switch Database Provider
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-switch-db.html
toc: false
summary: Since 3.6.3 the gui can be used with other database providers.
---

## MySQL Configuration ##

By default the Interlok web application uses an Embedded database called Derby. However since version 3.6.2 the web application can be configured to use MySQL (from v5.6).

In order to use MySQL you will need to follow these steps:

 - Add the java MySQL connector jar to the adapter/lib directory. You can find the connector on [MySQL website](https://dev.mysql.com/downloads/connector/j/).
 - Create a database for the interlok web application (e.g. `interlokuidb`) and a user with access to it (e.g. user: `interlokuidb`, password: `int3rL0cku1DB`)

```sql
CREATE DATABASE interlokuidb;
CREATE USER 'interlokuidb'@'localhost' IDENTIFIED BY 'int3rL0cku1DB';
GRANT ALL PRIVILEGES ON interlokuidb.* TO 'interlokuidb'@'localhost';
```

or

```sql
CREATE DATABASE interlokuidb;
GRANT ALL ON interlokuidb.* TO 'interlokuidb'@'localhost' IDENTIFIED BY 'int3rL0cku1DB';
```

 - Add a properties file named `interlokuidb.properties` in the `adapter/ui-resources` or in the `adapter/lib` directory with the following properties:

```properties
dataSource.provider=mysql
dataSource.driverClass=com.mysql.jdbc.Driver
dataSource.jdbcURL=jdbc:mysql://localhost:3306/interlokuidb?autoReconnect=true
dataSource.user=interlokuidb
dataSource.password=int3rL0cku1DB
```
 - Start the adapter

{% include note.html content="The given sql queries are just example an may need to be adjusted to your needs." %}

## PostgreSQL Configuration ##

Since version 3.6.3 the web application can be configured to use PostgreSQL (from v9.6).

In order to use PostgreSQL you will need to follow these steps:

 - Add the java PostgreSQL connector jar to the adapter/lib directory. You can find the connector on [PostgreSQL website](https://jdbc.postgresql.org/download.html).
 - Create a database for the interlok web application (e.g. `interlokuidb`) and a user with access to it (e.g. user: `interlokuidb`, password: `int3rL0cku1DB`)

```sql
CREATE DATABASE interlokuidb;
CREATE USER interlokuidb WITH PASSWORD 'int3rL0cku1DB';
GRANT ALL PRIVILEGES ON DATABASE interlokuidb TO interlokuidb
```
 - Add a properties file named `interlokuidb.properties` in the `adapter/ui-resources` or in the `adapter/lib` directory with the following properties:

```properties
dataSource.provider=postgresql
dataSource.driverClass=org.postgresql.Driver
dataSource.jdbcURL=jdbc:postgresql://localhost:5432/interlokuidb?autoReconnect=true
dataSource.user=interlokuidb
dataSource.password=int3rL0cku1DB
```
 - Start the adapter

{% include note.html content="The given sql queries are just example an may need to be adjusted to your needs." %}

## MS SQLServer Configuration ##

Since version 3.9.0 the web application can be configured to use
Microsoft's SQLServer.

In order to use SQLServer you will need to follow these steps:

 - Add the Java SQLServer connector jar to the adapter/lib directory. You can find the connector on the Microsoft [SQLServer website](https://docs.microsoft.com/en-us/sql/connect/jdbc/download-microsoft-jdbc-driver-for-sql-server).
 - Create a database for the interlok web application (e.g. `interlokuidb`) and a user with access to it (e.g. user: `interlokuidb`, password: `int3rL0cku1DB`)

```sql
CREATE DATABASE interlokuidb;
CREATE LOGIN interlokuidb WITH PASSWORD = 'int3rL0cku1DB';
USE interlokuidb
CREATE USER interlokuidb FOR LOGIN interlokuidb;
GRANT CONTROL ON database::interlokuidb TO interlokuidb;
```

__Or__ use the Microsoft SQL Server Management Studio to create the user
and grant all permissions, *and* change the connection settings to allow
SQL Server authentication in addition to Windows Authentication.

 - Add a properties file named `interlokuidb.properties` in the `adapter/ui-resources` or in the `adapter/lib` directory with the following properties:

```properties
dataSource.provider=sqlserver
dataSource.driverClass=com.microsoft.sqlserver.jdbc.SQLServerDriver
dataSource.jdbcURL=jdbc:sqlserver://localhost:1433;databaseName=interlokuidb
dataSource.user=interlokuidb
dataSource.password=int3rL0cku1DB
```

## System Properties ##

Since version 3.6.5 the database settings can be configured with command line system properties.
When used they will override any properties set in properties files.

```
-DdataSource.provider=mysql -DdataSource.driverClass=com.mysql.jdbc.Driver -DdataSource.jdbcURL="jdbc:mysql://localhost:3306/interlokuidb?&autoReconnect=true" -DdataSource.user=interlokuidb -DdataSource.password=int3rL0cku1DB
```

If the user and password are provided in the jdbc url they will override any other set user and password.

```
-DdataSource.provider=mysql -DdataSource.driverClass=com.mysql.jdbc.Driver -DdataSource.jdbcURL="jdbc:mysql://localhost:3306/interlokuidb?user=interlokuidb&password=int3rL0cku1DB&autoReconnect=true"
```
