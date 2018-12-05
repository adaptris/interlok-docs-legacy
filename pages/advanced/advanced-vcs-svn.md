---
title: Version Control with Subversion
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-vcs-svn.html
summary: Configure Interlok to automatically check out config from SVN when starting.
---

{% include note.html content="This depends on the artifact com.adaptris:interlok-vcs-subversion. In 3.8.0; adp-vcs-subversion was renamed to interlok-vcs-subversion" %}


## Installation ##

JavaHL is an (native, using JNI and javah) implementation of a high level Java API for Subversion and provides a minimal-but-complete set of APIs which expose the core Subversion C API to Java. JavaHL can be considered part of Subversion, so its version needs to match that of the Subversion you have installed. We have defaulted to Subclipse 1.8.x which is based on the Subversion 1.7.x client features and working copy format; iff your working copy format is Subversion 1.8 or later then you can download [a later version of subclipse](http://subclipse.tigris.org/servlets/ProjectDocumentList?folderID=2240) directly and use those jar files instead (we have tested subclipse version 1.8.22 and 1.10.9 against the Subversion instance provided by [assembla.com](https://www.assembla.com/home) and [github](https://github.com)

As a result of the native libraries you will require additional DLL/shared objects; this page is basically a short overview of what you need to do and should be fine for standard subversion installations (HTTP / filesystem) on popular systems. Check [http://subclipse.tigris.org/wiki/JavaHL](http://subclipse.tigris.org/wiki/JavaHL) for more in-depth details on how to install JavaHL.

After installing all the shared objects; you will also need to drop the rest of the jar files into the `lib` directory and then you're ready to configure Interlok to checkout configuration from Subversion via bootstrap.properties.

### Windows ###

#### Automatic ####

Since 3.0.3, on Windows, Interlok will attempt to find the jar containing `libsvnjavahl-1.dll`; extract the contents of that jar; and then load the native libraries contained in the jar (the DLL files are extracted into _./.adp-vcs-subversion_). A choice will be made based on the architecture of the underlying JVM; if `os.arch=x86` and `sun.arch.data.model=32` then _javahl-win32.jar_ is selected; otherwise _javahl-win64.jar_ is selected (if neither is available, we just try and find it on the classpath). Existing files **will not be overwritten** during the extract phase. This means that the manual steps detailed below are un-necessary if attempting to quick-start an instance with SVN. Using the automatic feature on your production instances is discouraged, it is generally better to manually specify the `java.library.path` explicitly; disable it with `-Dadp.vcs.svn.disable.autoload=true` on the commandline.

#### Manual ####

- Extract either the `javahl-win64` or `javahl-win32` jar files (the choice depends on whether you are using 32bit or 64bit java; rather than your OS version), and place all the DLL files into a single directory (`C:/Adaptris/Interlok/svn-dll`)
- Pass in an additional system property `-Djava.library.path=C:/Adaptris/Interlok/svn-dll` when starting Interlok.
    - Alternatively put all the DLL files on the path.

{% include tip.html content="Using the automatic feature on your production instances is discouraged, it is generally better to manually specify the `java.library.path` explicitly; disable it with `-Dadp.vcs.svn.disable.autoload=true` on the commandline." %}

```bash
java -Djava.library.path=.\svn-dll -jar lib\adp-core.jar
```

### Linux ###

- Get the subversion-javahl distribution from your preferred repository.
    - Ubuntu : `sudo apt-get install libsvn-java`
    - RHEL: `sudo yum install subversion-javahl`
        - RHEL6 ships with subversion 1.6; so you may need to enable the rpmforge-extras repository to install the 1.7 version of subversion-javahl.
- Configure LD_LIBRARY_PATH or add a -Djava.library.path= system property to the startup script.
    - RHEL: `sudo yum install --enablerepo rpmforge-extras subversion-javahl` put everything into the right place, and no changes for required to LD_LIBRARY_PATH.


## Configuration ##

### Basic Configuration ###

All configuration for version control will live in bootstrap.properties.  The following basic properties must be set (if not set, then no VCS operations are done):

| Property | Description |
|----|----|
| vcs.workingcopy.url | This is the URL to the local directory where all files will be checked out to. |
| vcs.remote.repo.url | This is the URL to your remote Subversion checkout |

<br/>

All files from the remote location will be checked out to your local directory location. Standard subversion URL and protocol formats are supported such as `file://`, `http://`, `https://`, `svn://`. Other protocols are also supported; but may require additional jars such as `trilead-ssh2` for SSH access.


### Authentication ###

Additional bootstrap properties will control the various authentication schemes available to subversion.

| Property | Description |
|----|----|
| vcs.username | Your Subversion username |
| vcs.password | Your subversion usernames password.  May be [treated as a password](advanced-password-handling.html) |
| vcs.ssh.tunnel.port | The port for which the SSH tunnel will use |
| vcs.ssh.keyfile.url | The URL to your local keyfile |
| vcs.ssh.passphrase | Your passphrase for your local keyfile. May be [treated as a password](advanced-password-handling.html)  |
| vcs.ssl.certificate.url | The URL to your certificate file (if using SSL based certificate authentication) |
| vcs.ssl.password | Your password matched with your certificate file. May be [treated as a password](advanced-password-handling.html)  |



### Optional ###

| Property | Description |
|----|----|
| vcs.implementation | since 3.5.1 Which VCS implementation to load |
| vcs.revision | The revision to checkout; by default this will be the latest revision for the remote URL, and will be logged. |
| vcs.always.reset | Whether or not to always discard any uncommitted changes when updating; defaults to false |
| log4j12Url | __Deprecated__: use loggingConfigUrl instead.|
| loggingConfigUrl | since 3.1.0 If specified then then an attempt is made to re-configure the logging (log4j1.2 or log4j2) subsystem with the referenced URL. This is done after any checkout/update is performed.|
| vcs.auth | The authentication method to use, either "SSH" or "UsernamePassword", defaults to the later. |

<br/>

## Example ##

If we take an example bootstrap.properties. Note that this project does exist on github.com, and is public (so the bootstrap.properties should be usable as-is).

```properties
managementComponents=jetty:jmx

# The adapter configuration file is VCS managed; so we refer to the local working copy.
adapterConfigUrl=file://localhost/./config/interlok-config-example/adapter.xml

# Our Log4j is VCS managed; so we can refer to the local working copy.
loggingConfigUrl=file://localhost/./config/interlok-config-example/log4j2.xml

# Again, the jetty.xml is checked in, so let's refer to the local working copy.
webServerConfigUrl=./config/interlok-config-example/jetty.xml

# This controls how we connect to SVN.
vcs.implementation=Subversion
vcs.workingcopy.url=file://localhost/./config/interlok-config-example
vcs.remote.repo.url=https://github.com/adaptris/interlok-config-example/trunk
# Enabled for public access we don't need username/passsword.
# vcs.username=my-user-name
# vcs.password={password}PW:My-encoded-password
jmxserviceurl=service:jmx:jmxmp://localhost:5555

# Threadsafe jruby
sysprop.org.jruby.embed.localcontext.scope=threadsafe
# Force jboss to use slf4j
sysprop.org.jboss.logging.provider=slf4j
```

Which should give you logging similar to :

```
Bootstrap of Interlok 3.1-SNAPSHOT(2015-11-19) complete
TRACE [main] [BootstrapProperties] Properties resource is [bootstrap.properties]
TRACE [main] [PropertyResolver] Parsing PropertyResolver URL [jar:file:/C:/Users/lchan/work/runtime/v3-nightly/lib/adp-core.jar!/META-INF/com/adaptris/core/management/properties/resolver]
TRACE [main] [PropertyResolver] Registered Decoders : {password=com.adaptris.core.management.properties.PasswordDecoder}
TRACE [main] [BootstrapProperties] Adding org.jboss.logging.provider=slf4j to system properties
TRACE [main] [BootstrapProperties] Adding org.jruby.embed.localcontext.scope=threadsafe to system properties
INFO  [main] [RuntimeVersionControlLoader] Found version control system for [Subversion]
INFO  [main] [SubversionVCS] Subversion: Checking local repository; [.\config\interlok-config-example]
TRACE [main] [SubversionVCS] Found SVN Java HL library: C:\Users\lchan\work\runtime\v3-nightly\lib\org.tigris.subversion.clientadapter.javahl-win64.jar
TRACE [main] [SubversionVCS] Extracting [C:\Users\lchan\work\runtime\v3-nightly\lib\org.tigris.subversion.clientadapter.javahl-win64.jar] to [C:\Users\lchan\work\runtime\v3-nightly\.adp-vcs-subversion]
TRACE [main] [ClientAdapterFactory] Subversion Client Type is javahl
INFO  [main] [SubversionVCS] Subversion: Updated configuration to revision: 20
TRACE [main] [BootstrapProperties] Attempting Logging reconfiguration using file://localhost/./config/interlok-config-example/log4j2.xml
WARN  [main] [ResponseProducer.<init>()] [ResponseProducer] is deprecated, use [com.adaptris.core.http.jetty.StandardResponseProducer] instead
WARN  [main] [JdkHttpProducer.<init>()] [JdkHttpProducer] is deprecated, use [com.adaptris.core.http.client.net.StandardHttpProducer] instead
TRACE [main] [WorkflowManager.configureMessageCounter()] Message count interceptor added for [com.adaptris:type=Workflow,adapter=MyInterlokInstance,channel=WebServer,id=HandleProductCodeLookup], tracks metrics for ~1hr
TRACE [main] [WorkflowManager.configureMessageCounter()] Message count interceptor added for [com.adaptris:type=Workflow,adapter=MyInterlokInstance,channel=WebServer,id=HandleProductMovement], tracks metrics for ~1hr
TRACE [main] [WorkflowManager.configureMessageCounter()] Message count interceptor added for [com.adaptris:type=Workflow,adapter=MyInterlokInstance,channel=WebServer,id=HandleProductRecall], tracks metrics for ~1hr
TRACE [main] [WorkflowManager.configureMessageCounter()] Message count interceptor added for [com.adaptris:type=Workflow,adapter=MyInterlokInstance,channel=WebServer,id=DefaultURL], tracks metrics for ~1hr
TRACE [main] [WorkflowManager.configureMessageCounter()] Message count interceptor added for [com.adaptris:type=Workflow,adapter=MyInterlokInstance,channel=WebClient,id=ProductLookup], tracks metrics for ~1hr
TRACE [main] [RuntimeInfoComponentFactory.create()] No RuntimeInfoComponent for class com.adaptris.core.NoRetries
TRACE [main] [RuntimeInfoComponentFactory.create()] No RuntimeInfoComponent for class com.adaptris.core.NullProcessingExceptionHandler
TRACE [main] [RuntimeInfoComponentFactory.create()] No RuntimeInfoComponent for class com.adaptris.core.NullLogHandler
INFO  [main] [UnifiedBootstrap.createAdapter()] Adapter created
TRACE [main] [JettyServerComponent.connectToUrl()] Connecting to ./config/interlok-config-example/jetty.xml
TRACE [main] [JettyServerComponent.createServer()] Create Server from XML
TRACE [main] [JmxRemoteComponent.register()] MBean [com.adaptris:type=JmxConnectorServer] registered
TRACE [StandardBootstrap] [JettyServerComponent.start()] JettyServerComponent Started
WARN  [StandardBootstrap] [Adapter.warnOnErrorHandlerBehaviour()] [Adapter(MyInterlokInstance)] has a MessageErrorHandler with no behaviour; messages may be discarded upon exception
```

Be aware that if no initial log4j configuration is available on the classpath on startup then you will not have any logging until after checkout/update and logging reconfiguration is completed which will make it very hard to verify whether you have the configuration correct. In this example, you can see that the logging configuration has actually changed because the log4j2 configuration PatternLayout contains the method name in addition to the classname.

[VersionControlSystem]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/management/vcs/VersionControlSystem.html