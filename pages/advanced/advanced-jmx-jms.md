---
title: JMX over JMS
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-jmx-jms.html
---

In a factory fresh installation of Interlok; the _JMXServiceURL_ property in _bootstrap.properties_ is set to be the reference implementation `jmxmp`. This implementation is fine if the adapter is running in the local network and there are no issues with making connections to the Interlok instance from your browser. However, depending on how the adapter will be deployed, it may be that it will be behind a firewall, and will only allow limited connections; and certainly not unencrypted socket connections. In these types of deployment scenarios; where you may have to traverse firewalls to get to the adapter; it may be useful to proxy all JMX requests over a JMS Queue or Topic. This is where the _optional/jmx-jms_ component comes into action; you will need to copy all the jars in that directory into the main adapter _lib_ directory.

Although core functionality has been implemented to handle remote JMX over JMS, there are some contracts which are not fulfilled. The most important one is the behaviour of `JMXConnectorServer.getConnectionIds()` and `JMXConnector.getConnectionId()`. The JMS provider provide connectivity so clients aren't directly connected to our [JmsJmxConnectorServer][] implementation, requests just appear on a given Destination and we service them. As a result, you will find that the `JMXConnectorServer.getConnectionIds()` will return an empty string, and although `JMXConnector.getConnectionId()` will return a conventional connection ID, it is only consistent for the lifetime of the underlying JMS connection and cannot be cross-referenced with anything.

Communication via both Queue and Topic are supported, each request will create a temporary destination matching the target destination type for responses. Notifications are received and handled via a separate temporary destination.

----

## SonicMQ ##

To switch to using SonicMQ as the JMX transport mechanism we simply start using `sonicmq` instead of `jmxmp` as the protocol part of the _JMXServiceURL_ along with a URL that specifies the connection to the SonicMQ broker instance along with some specific environment properties which should be self explanatory. `jmxservice.env.` is the prefix that indicates that this property should be passed through to the initial environment when invoking `JMXConnectorFactory.newJMXConnector()`. This prefix is stripped off before the property is added to the initial environment.

```
adapterConfigUrl=file://localhost/./config/adapter.xml
managementComponents=jmx:jetty
jmxserviceurl=service:jmx:sonicmq:///tcp://localhost:2506
jmxserviceurl.env.jmx.brokerUser=Administrator
jmxserviceurl.env.jmx.brokerPassword=Administrator
jmxserviceurl.env.jmx.type=Topic
jmxserviceurl.env.jmx.destination=SampleQ4
```

The various environment properties may also be specified as part of the _JMXServiceURL_, so you could specify `service:jmx:sonicmq:///tcp://localhost:2506?jmx.type=Topic&jmx.destination=SampleQ4` which achieves the same thing. For SonicMQ the default username and password defaults to _Administrator/Administrator_; so we have missed it out from the URL for clarity. The full list of supported properties are

| Name | Description |
|----|----|
|jmx.type|The destination type (i.e. _Topic_ or _Queue_; case-sensitive); defaults to Topic. |
|jmx.destination|The name of a Topic or Queue; if not assigned, then a unique one will be created to avoid exceptions; this is, though, pointless from a usability perspective |
|jmx.brokerUser|The username to connect to the broker (if required); defaults to 'Administrator'.|
|jmx.brokerPassword|The password to connect to the broker (if required); defaults to 'Administrator'.|
|jmx.timeout|The timeout in milliseconds for a client to wait for a reply after sending a request; defaults to 60000.|
|jmx.clientid|The client ID to be associated with the underlying `progress.message.jclient.ConnectionFactory` if desired; defaults to null.|
|jmx.backupBrokers|A comma separated list of additional brokers that should serve as a list of backup brokers. Note that doing this as part of the URL will make it hard to read, so that should be discouraged from maintainability point of view, it will be best to add the backup brokers as part of the initial environment|

All properties are case sensitive; you can mix and match the environment with the URL, the URL will take precedence, apart from in the case where `JMXConnector.CREDENTIALS` exists in the initial set of attributes, that will always replace the brokerUser and brokerPassword.

----

## ActiveMQ ##

To switch to using ActiveMQ as the JMX transport mechanism we simply start using `activemq` instead of `jmxmp` as the protocol part of the _JMXServiceURL_ along with a URL that specifies the connection information for the ActiveMQ broker. Configuration for ActiveMQ tends to specified completely via the URL, so anything that would be valid as part of an ActiveMQ URL tends to be valid as part of the _JMXServiceURL_. So our bootstrap.properties might end up looking like this:


```
adapterConfigUrl=file://localhost/./config/adapter.xml
managementComponents=jmx:jetty
jmxserviceurl=service:jmx:activemq:///tcp://localhost:61616?jmx.type=Topic&jmx.destination=jmxTopic
# Not required because everything is in the url.
# jmxserviceurl.env.jmx.type=Topic
# jmxserviceurl.env.jmx.destination=jmxTopic
```

The full list of supported properties that control JMX behaviour are as follows :

| Name | Description |
|----|----|
|jmx.type|The destination type (i.e. _Topic_ or _Queue_; case-sensitive); defaults to Topic. |
|jmx.destination|The name of a Topic or Queue; if not assigned, then a unique one will be created to avoid exceptions; this is, though, pointless from a usability perspective |
|jmx.brokerUser| 	The username to connect to the broker (if required); defaults to null. This may be a redundant; as you can often configure the username directly on the URL|
|jmx.brokerPassword|The password to connect to the broker (if required); defaults to null. This is likely to be redundant; as you can often configure the password directly on the URL.|
|jmx.timeout|The timeout in milliseconds for a client to wait for a reply after sending a request; defaults to 60000.|
|jmx.clientid|The client ID to be associated with the underlying `ActiveMQConnectionFactory` if desired; defaults to null.|


All keys are case sensitive, and if specified in the URL will be stripped before being passed to `ActiveMQConnectionFactory` so, for `service:jmx:activemq:///tcp://localhost:61616?jmx.type=Topic&jmx.destination=jmxTopic`; both _jmx.type_ and _jmx.destination_ will be stripped from the URL (leaving `tcp://localhost:61616`) before being passed to `ActiveMQConnectionFactory`. Each of the properties may also be specified in the initial environment as per the SonicMQ example, the URL will take precedence, apart from in the case where `JMXConnector.CREDENTIALS` exists in the initial set of attributes, that will always replace the brokerUser and brokerPassword.

----

## Solace ##

_Since 3.6.4_, you can switch to using Solace as the JMX transport mechanism using `solace` instead of `jmxmp` as the protocol part of the _JMXServiceURL_ along with a URL that specifies the connection to the Solace broker instance along with some specific environment properties which should be self explanatory. `jmxservice.env.` is the prefix that indicates that this property should be passed through to the initial environment when invoking `JMXConnectorFactory.newJMXConnector()`. This prefix is stripped off before the property is added to the initial environment.

```
adapterConfigUrl=file://localhost/./config/adapter.xml
managementComponents=jmx:jetty
jmxserviceurl=service:jmx:solace:///smf://localhost:55555
jmxserviceurl.env.jmx.brokerUser=default
jmxserviceurl.env.jmx.type=Topic
jmxserviceurl.env.jmx.destination=jmxTopic
jmxserviceurl.env.jmx.messageVPN=default
```

The various environment properties may also be specified as part of the _JMXServiceURL_, so you could specify `service:jmx:solace:///smf://localhost:55555?jmx.type=Topic&jmx.destination=jmxTopic` which achieves the same thing. For Solace the default username and password defaults to _default_ along with an empty password. The full list of supported properties are

| Name | Description |
|----|----|
|jmx.type|The destination type (i.e. _Topic_ or _Queue_; case-sensitive); defaults to Topic. |
|jmx.destination|The name of a Topic or Queue; if not assigned, then a unique one will be created to avoid exceptions; this is, though, pointless from a usability perspective |
|jmx.brokerUser|The username to connect to the broker (if required); defaults to 'default'.|
|jmx.brokerPassword|The password to connect to the broker (if required); defaults to ''.|
|jmx.timeout|The timeout in milliseconds for a client to wait for a reply after sending a request; defaults to 60000.|
|jmx.clientid|The client ID to be associated with the underlying `SolConnectionFactory` if desired; defaults to null.|
|jmx.messageVPN| The message VPN to use with the underlying `SolConnectionFactory`; defaults to 'default'|
|jmx.backupBrokers|A comma separated list of additional brokers that should serve as a list of backup brokers. Note that doing this as part of the URL will make it hard to read, so that should be discouraged from maintainability point of view, it will be best to add the backup brokers as part of the initial environment|

All properties are case sensitive; you can mix and match the environment with the URL, the URL will take precedence, apart from in the case where `JMXConnector.CREDENTIALS` exists in the initial set of attributes, that will always replace the brokerUser and brokerPassword.

----

## AMQP 1.0 ##

AMQP 1.0 support is provided by the [Apache Qpid][] library. To switch to using AMQP as the JMX transport mechanism we simply start using `amqp` instead of `jmxmp` as the protocol part of the _JMXServiceURL_ along with a URL that specifies the connection information for the AMQP 1.0 broker. Configuration for Qpid tends to specified completely via the URL, so anything that would be valid as part of an URL will be valid as part of the _JMXServiceURL_. So our bootstrap.properties might end up looking like this:

```
adapterConfigUrl=file://localhost/./config/adapter.xml
managementComponents=jmx:jetty
jmxserviceurl=service:jmx:amqp:///amqp://guest:guest@localhost:5672?clientid=test-client&jmx.type=Topic&jmx.destination=jmxTopic
# Not required because everything is in the url.
# jmxserviceurl.env.jmx.type=Topic
# jmxserviceurl.env.jmx.destination=jmxTopic
```

The full list of supported properties that control JMX behaviour are as follows :

| Name | Description |
|----|----|
|jmx.type|The destination type (i.e. _Topic_ or _Queue_; case-sensitive); defaults to Topic. |
|jmx.destination|The name of a Topic or Queue; if not assigned, then a unique one will be created to avoid exceptions; this is, though, pointless from a usability perspective |
|jmx.brokerUser| 	The username to connect to the broker (if required); defaults to null. This may be a redundant; as you can often configure the username directly on the URL|
|jmx.brokerPassword|The password to connect to the broker (if required); defaults to null. This is likely to be redundant; as you can often configure the password directly on the URL.|

All keys are case sensitive, and if specified in the URL will be stripped before being passed to the Qpid ConnectionFactory so, for `service:jmx:amqp:///amqp://guest:guest@localhost:5672?clientid=test-client&jmx.destination=jmxTopic`; then _jmx.destination_ will be stripped from the URL leaving `amqp://guest:guest@localhost:5672?clientid=test-client`. Each of the properties may also be specified in the initial environment as per the SonicMQ example, the URL will take precedence, apart from in the case where `JMXConnector.CREDENTIALS` exists in the initial set of attributes, which will always replace the brokerUser and brokerPassword.


[Apache Qpid]: https://qpid.apache.org/
[JmsJmxConnectorServer]: https://development.adaptris.net/javadocs/v3-snapshot/optional/jmx-jms/com/adaptris/jmx/remote/jms/JmsJmxConnectorServer.html
[ActiveMQ]: http://activemq.apache.org/

