---
title: Shared Components / JNDI
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-jndi-guide.html
summary: This document will describe how Interlok utilizes the Java Naming and Directory Interface so that workflows may reference pre-configured connection objects rather than having to duplicate connection configuration in each workflow that requires that connection.
---

## Shared Components ##

Interlok shared components are the corner stone of JNDI object configuration.  All objects you wish to expose via the JNDI API must be configured in the Interlok shared-component-list. Please note that currently only objects of that are concrete implementations of [AdaptrisConnection][], such as [JmsConnection][] or [JdbcConnection][] are supported as shared components and therefore exposed via JNDI.

### Configuration ###

The root configuration element, `<adapter>` can now be optionally configured with a direct child element named `<shared-components>`.  For future proofing with the potential for other types of objects to be configured as `shared`, we have the configuration element `<connections>` as a child element of `<shared-components>`. Here you can configure as many connections as you wish to be made available via JNDI, or to simply be sharable. An example, demonstrating a simple [JdbcConnection][] :

```xml
<adapter>
  <!-- Shared Components -->
  <shared-components>
    <connections>
      <connection class="jdbc-connection">
        <unique-id>myDatasource</unique-id>
        <lookup-name>adapter:comp/env/myDatasource</lookup-name>
        <test-statement>SELECT DATABASE(), VERSION(), NOW(), USER();</test-statement>
        <driver-imp>com.mysql.jdbc.Driver</driver-imp>
        <username>myUser</username>
        <password>myUserPassword</password>
        <connect-url>jdbc:mysql://localhost:3306/myDatabase</connect-url>
      </connection>
    </connections>
  </shared-components>
...
```

### Enabling Debugging ###

If you enable debug in the shared component configuration:

```xml
<shared-components>
  <debug>true</debug>
    <connections>
...

```

Then during initialization of the shared-components you will see further debug logging informing you of each JNDI name that has been bound. Enabling log4j trace level logging will log every request to lookup an object.

{% include image.html file="jndi/jndi-logging-1.png" alt="jndi-logging-1" %}

{% include image.html file="jndi/jndi-logging-2.png" alt="jndi-logging-2" %}


## JNDI Naming ##

For each connection object we configure in the shared-components we need to bind those objects to a name.  It is through this configured name that we can recall these objects for later use. Notice in the above example configuration, the lookup-name specifies a JNDI scheme, prepending the fully qualified binding name (`adapter:/...`).  We will go into more detail on the binding names in the very next sections, but note that any specified schemes will be stripped and ignored before being bound. We have purposefully specified the `adapter:` scheme in the above example just to demonstrate this point.  You do not need to specify the JNDI scheme; and can specify the binding name of your shared component in one of two ways:

- unique-id
- lookup-name

### unique-id ###

As shown in the example above, we have specified a value of `myDatasource` as the unique-id.  Internally, we will bind your connection object to the following fully qualified JNDI name; _comp/env/myDatasource_. If you are only planning on using the shared-components within configuration, i.e. you are not planning on accessing these objects from custom web applications, you will not be concerned about the fully qualified name. If you specify a unique id which includes sub-contexts (e.g. _comp/env/_ or a custom variety) these will be stripped from the actual name used to bind your object. As a rule, if the shared components are only referenced in the adapter, then the unique-id is all that is required; specifying the lookup name can sometimes lead to unexpected behaviour within the UI.

{% include note.html content="As a rule, if the shared components are only referenced inside Interlok configuration, then the unique-id is all that is required; specifying the lookup name can sometimes lead to unexpected behaviour within the UI." %}

### lookup-name ###

The lookup-name is optional, but if specified takes precedence over the unique-id. The main difference between using the lookup-name and the unique-id, is that the value you specify in the lookup-name will be used _as-is_ to bind your object.  In other words we will not prepend the sub-contexts _comp/env/_ to your name, which also means you can, should you wish, specify your own custom sub-contexts (for example _my/sub/contexts/..._). You do not need to worry about sub-contexts already existing in the JNDI store.  When we bind a name to an object we will automatically create any sub-contexts you have specified in the binding name for you. You should only specify the lookup name if you have non-Interlok components hosted inside the Interlok JVM accessing the component.

{% include tip.html content="You should only specify the lookup name if you have non-Interlok components hosted inside the Interlok JVM accessing the component." %}

### JDBC Objects, a special case ###

Should any of your shared-components be a DatabaseConnection, we will as detailed above bind that DatabaseConnection to the configured name, but an additional step is also taken; We will also bind the associated DataSource object of your DatabaseConnection to the following fully qualified name: `comp/env/jdbc/<configured name>`. This allows you to specify a database connection as a shared-component which can then later be recalled from a custom web application in the more universal form of a DataSource object.  See the examples later in this document for more information. Specifying a `unique-id` of `mydatasource` will expose both the DatabaseConnection under the name `mydatasource` and the underlying DataSource under `comp/env/jdbc/mydatasource`.

{% include note.html content="Specifying a `unique-id` of `mydatasource` will expose both the DatabaseConnection under the name `mydatasource` and the underlying DataSource under `comp/env/jdbc/mydatasource`." %}


## Referencing Shared Components ##

Once you have configured any connections as shared-components, you can recall these objects for use in either Interlok configuration or from your own custom web-applications.

### Within configuration ###

To recall an AdaptrisConnection object to be used, for example, in a service, rather than configuring the connection manually, you will use a shared-connection. SharedConnections are special connection objects that know they must _lookup_ the connection object to use. Taking the example Jdbc shared connection earlier in this document, we can use that connection for a [JdbcDataQueryService][], the lookup-name must match either the _unique-id_, or, if configured, the _lookup-name_ of the shared component. for example, by using the shared-connection configuration

```xml
<jdbc-data-capture-service>
  <connection class="shared-connection">
    <lookup-name>myDatasource</lookup-name>
  </connection>
...
</jdbc-data-capture-service>
```

### From an intra JVM hosted application ###

You also have the ability to access shared-components outside of Interlok configuration. As long as your process/application is running _in-process_ (i.e. inside the same JVM) as Interlok, you can use Interloks JNDI context to request these pre-configured connection objects. A typical process or application might be a custom Interlok management process or even a web application served by Interloks embedded web server. The following sections will demonstrate two typical use cases where a developer can access the shared-components through their application code or use JPA/Hibernate configuration.

{% include important.html content="You must set `enableLocalJndiServer=true` in your _bootstrap.properties_ before this becomes available." %}

### Application code ###

Should application developers wish to access shared-components configured in Interlok configuration, they simply need to apply the following 2 steps;

1. Set the `java.naming.factory.initial` to com.adaptris.core.JndiContextFactory
1. Perform a context lookup with the fully qualified object name.

```java
private AdaptrisConnection interlokLookup() throws NamingException {
    AdaptrisConnection lookedUpConnection = null;

    Properties env = new Properties();
    env.put(Context.INITIAL_CONTEXT_FACTORY, com.adaptris.core.JndiContextFactory.class.getName());

    InitialContext ctx = new InitialContext(env);
    lookedUpConnection = (AdaptrisConnectionImp) ctx.lookup("comp/env/myConnection");

    return lookedUpConnection;
}
```

If you do not set the `java.naming.factory.initial` property (or cannot), then you need to specify the JNDI scheme with your lookup name (i.e. `adapter:comp/env/myConnection`).


### JPA / Hibernate ###

Should you need a DataSource to be used via JPA or Hibernate you can request a pre-configured JDBC shared-component.  If you configure a [DatabaseConnection][] in the shared-components, you can request that connection via the `comp/env/jdbc/` sub-contexts. Following is a JPA persistence.xml file that uses JNDI to fetch the DataSource:

```xml
<persistence xmlns="http://java.sun.com/xml/ns/persistence"
  		xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
  		xsi:schemaLocation="http://java.sun.com/xml/ns/persistence
    		http://java.sun.com/xml/ns/persistence/persistence_1_0.xsd"
  		version="1.0">
  <persistence-unit name="jndi-datasource" transaction-type="RESOURCE_LOCAL">
    <provider>org.hibernate.ejb.HibernatePersistence</provider>
    <non-jta-data-source>adapter:comp/env/jdbc/myDatasource</non-jta-data-source>
    <exclude-unlisted-classes>true</exclude-unlisted-classes>

    <properties>
       <property name="hibernate.archive.autodetection" value="class"/>
       <property name="hibernate.dialect" value="org.hibernate.dialect.MySQL5InnoDBDialect"/>
       <property name="hibernate.ejb.naming_strategy" value="org.hibernate.cfg.ImprovedNamingStrategy"/>
       <property name="hibernate.hbm2ddl.auto" value="update"/>
    </properties>
  </persistence-unit>
</persistence>
```

The important part is the non-jta-data-source value, which includes the fully qualified (with _adapter:_ scheme) JNDI name. The _adapter_ scheme will point any JNDI client to Interloks context, which contains the list of configured shared-components.  And unless you have access to the java.naming.factory.initial environment property, you should always specify the _adapter_ scheme.

[AdaptrisConnection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisConnection.html
[JmsConnection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsConnection.html
[DatabaseConnection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jdbc/DatabaseConnection.html
[JdbcConnection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jdbc/JdbcConnection.html
[JdbcDataQueryService]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/jdbc/JdbcDataQueryService.html