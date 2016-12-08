---
title: Startup in Detail
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-bootstrap.html
---
When Interlok is started without any commandline parameters, it expects to find a file `bootstrap.properties` on the classpath (generally in the _config_ directory). If a file is specified on the commandline then this is expected to be a file present on the classpath or a fully qualified filename. This properties file contains the initial behaviour of Interlok and has a number of settings that can be modified to suit your environment. The keys themselves tend to be treated in a case insenstive fashion (not always guaranteed) so you should try and be consistent in your naming.

The list of keys and a brief description of each key is described below :

| Name/prefix | Description |
|----|----|
| licenseUrl| _Removed since 3.1.0_ The URL containing the license key for your adapter. At installation time, licenceUrl defaults to license.properties which is populated with your license key information. There is generally no reason to change this value. In some deployment scenarios licenceUrl may be a remote HTTP URL|
| adapterConfigUrl | This is an primary means of locating adapter runtime configuration; use any supported URL scheme, specify a `file:///` scheme for a local file|
| managementComponents | a list of `:` separated management components that will be started.
| configManager | Defaults to [XStreamConfigManager][]; you should never have to change this|
| marshallerOutputType | The default output type for the marshaller; this defaults to XML and you should never have to modify this|
| beautifyXStreamOutput | Defaults to false, and if true, means that an attempt is made to remove all `class=` attributes, and to only use the raw alias as the element name. this means that where the same interface is used (e.g. for `produce-connection` + `consume-connection`, order becomes important.|
| httpEnableProxyAuth | Defaults to false, and if true, means that a custom [Authenticator][] is inserted to authenticate against any HTTP Proxy servers|
| useJavaLangManagementFactory | Defaults to true, and you should never have to change this |
| preProcessors | A `:` separated list of [pre-processors][advanced-configuration-pre-processors] that need to be applied before configuration is unmarshalled |
| enableLocalJndiServer| defaults to false, and should be set to true, if you intend on having [shared components][adapter-jndi-guide] accessible via the `adapter:` scheme|
| sysprop. | Properties prefixed by this key will be converted into system properties at startup (minus the `sysprop.`) |
| adapterTemplatesUrl | __Deprecated__ : Configure this directly in the UI; A file URL for a directory that contains all the templates that will be searched by the UI; defaults to `file://localhost/./ui-resources/config-templates`|
| adapterScmUrl | __Deprecated__ : Configure this directly in the UI; a file URL that for a directory where the UI will backup any configuration that is saved/applied; defaults to `file://localhost/./ui-resources/config-store`|
| log4j12Url | __Deprecated__ : use loggingUrl instead |
| loggingConfigUrl | since 3.1.0 - If specified then then an attempt is made to configure the logging (log4j1.2 or log4j2) subsystem with the referenced URL; if this is not configured then logging initialisation uses the standard defaults for log4j. |
| startAdapterQuietly | Defaults to true, and if false, then if an adapter fails to start, then the entire JVM will be terminated. |

<br/>

Some of the keys deserve a bit more detail, so lets talk about them now.

## Config Synchronisation ##

The `adapterConfigUrl` key is also used a prefix for any number of keys which will enable two additional features.

- Multiple sources for the adapter runtime config.
- Synchronisation of the secondary sources with the primary source.

If many keys are prefixed by `adapterConfigUrl`, then the following rules will apply:

- The keys will be sorted using their natural order (alphabetically) prior to use.
- The first entry in the sorted list is considered the primary for synchronisation purposes; the others are considered secondary URLs.
- Only local file system URLs (file:///) will be considered candidates for secondary synchronisation.

Which means that you can configure something like :

```
adapterConfigUrl=http://localhost/adapter.xml
adapterConfigUrl.1=http://localhost/adapter2.xml
adapterConfigUrl.2=file:///./config/adapter3.xml
```

`http://localhost/adapter.xml` is considered the primary source for the adapter runtime object. If that is not available then `http://localhost/adapter2.xml` is used. If the primary source is available, then it will be synchronised to `file:///./config/adapter3.xml` only. Synchronisation occurs after the Adapter is un-marshalled; but before any initialisation of components occurs. The entire adapter is marshalled again to the secondary source(s) which means that it is always written out as a monolithic XML document.

## Management Components ##

Management components are Interlok components exist outside of the normal adapter lifecycle. Typical examples of this are the JMX component and the embedded Jetty component which hosts the UI. The `:` separated list here can be either a short name (e.g. `jetty`) or a fully qualified classname of something that implements [ManagementComponent][]

### JMX Component ###

If the JMX management component is specified via `managementComponents=jmx` then additional keys in bootstrap.properties determine the behaviour of the component.

| Name/prefix | Description |
|----|----|
|jmxserviceurl|The URL that will be passed into `JMXConnectorServerFactory#newJMXConnectorServer()`|
|jmxserviceurl.objectname| The ObjectName to be associated with the `JMXConnectorServer` when registering it as an MBean, defaults to `Adaptris:type=JmxConnectorServer`|
|jmxserviceurl.env.| Each property that matches this prefix is passed through to the JMXConnectorServer as part of its environment (minus the prefix); if the JMXConnectorServer required specific configuration, this is where you would do it. e.g. `jmxserviceurl.env.myEnvironment=ABCDE` would cause an environment containing `myEnvironment=ABCDE` to be passed into `JMXConnectorServerFactory#newJMXConnectorServer()`. The environment will be the equivalent of `Map<String, String>()`.

<br/>

So, if we wanted to enable JMX over JMS using SonicMQ then we could have :

```
managementComponents=jmx
jmxserviceurl=service:jmx:sonicmq:///tcp://localhost:2506
jmxserviceurl.env.jmx.brokerUser=Administrator
jmxserviceurl.env.jmx.brokerPassword=Administrator
jmxserviceurl.env.jmx.type=Topic
jmxserviceurl.env.jmx.destination=SampleQ4
```

### Jetty Component ###

If jetty is enabled via `managementComponents=jetty` then an additional key is required : `webServerConfigUrl`. This should contain the fully qualified filename for a jetty configuration file. As the UI requires the jetty component and communicates with Adapters using JMX, then if you intend on using the UI you should always have `managementComponents=jmx:jetty`.

```
managementComponents=jetty:jmx
webServerConfigUrl=./config/jetty.xml
```

## System Properties ##

Properties prefixed by `sysprop.` (note the `.`) will be converted into system properties at boot time (minus the prefix). For instance specifying `sysprop.myEnvironment=ABCDE` will be equivalent to using `-DmyEnvironment=ABCDE` on the command-line. These will overwrite any system properties that you may have already specified on the command-line. Use one method or the other, don’t mix the two.

Sensitive system property values may be stored encoded in the file; they will be decoded at boot time and the decoded value used for System.setProperty(). Of course, this means these values still plain text within the JVM, but are encoded for the purposes of storage on the file system in configuration/startup scripts. The syntax for an encoded property is to use {password} at the start of the property value; for instance: `sysprop.myEncodedString={password}PW:AA...N` (skipped some actual characters) is functionally equivalent to specifying –DmyEncodedString=admin on the command-line. These sensitive values will have been encrypted using the [password handling mechanism][advanced-password-handling].

If you were using JRuby, and you wanted to ensure that variable scope was threadsafe; and you needed to specify a javax.net.ssl keystore and password; the keystore password is of course sensitive so you have encrypted it.

```
sysprop.org.jruby.embed.localcontext.scope=threadsafe
# Not all the text shown here for brevity.
sysprop.javax.net.ssl.keyStorePassword={password}PW:AA...N
sysprop.javax.net.ssl.keyStore=/path/to/my/keystore
```

## Pre Processors ##

Pre-Processors are components that allow you to inject some additional processing of Interlok configuration files before attempting to unmarshal them. It is discussed in more detail in the [pre-processors][advanced-configuration-pre-processors] document.

{% include links.html %}

[XStreamConfigManager]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/management/config/XStreamConfigManager.html
[ManagementComponent]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/management/ManagementComponent.html
[Authenticator]: http://docs.oracle.com/javase/7/docs/api/java/net/Authenticator.html