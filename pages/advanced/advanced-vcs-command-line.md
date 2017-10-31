---
title: Version Control with command line executable
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-vcs-command-line.html
summary: Configure Interlok to automatically check out config from VCS when starting.
---

## Configuration ##

[interlok-vcs-command-line][] allows you to configure an arbitrary version control system (rather than the optional [git](advanced-vcs-git.html]) or [subversion](advanced-vcs-svn.html)) for use with the adapter. You will have to make sure that the commandline executable is available to the adapter; and that it already works from the commandline. Authentication will not be handled directly by interlok.

### Repository Configuration ###

All configuration for version control lives in bootstrap.properties.  The following basic properties must be set (if not set, then no VCS operations are performed):

| Property | Description |
|----|----|
| vcs.workingcopy.url | This is the URL to the local directory where all files will be checked out to. |
| vcs.remote.repo.url | This is the URL to your remote Git repository |

All files from the remote location will be checked out to your local directory location.

### Command configuration ###

Additional bootstrap properties are required that control both the checkout and update from vcs.

| Property | Description |
|----|----|
| vcs.command.line.checkout | The checkout command |
| vcs.command.line.update | The update command |

Each property key is also treated as a prefix, and allows you to configure multiple commands to checkout and update a configuration. For instance, if many keys are prefixed by `vcs.command.line.checkout` then they are sorted according to their natural order (alphabetically) and then executed in sequence.

### Optional ###

| Property | Description |
|----|----|
| vcs.implementation | since 3.5.1 Which VCS implementation to load |
| vcs.revision | The revision/tag/branch to checkout; by default this will be the latest revision for the remote URL, and will be logged. |
| log4j12Url | __Deprecated__: use loggingConfigUrl instead.|
| loggingConfigUrl | since 3.1.0 If specified then then an attempt is made to re-configure the logging (log4j1.2 or log4j2) subsystem with the referenced URL. This is done after any checkout/update is performed.|
| vcs.auth | The authentication method to use, either "SSH" or "UsernamePassword", defaults to the later. |

## Example ##

We can use the existing [public config example](https://github.com/adaptris/interlok-config-example) with a slight change in how we access the git repository. For the purposes of our demo we want to create a sparse git checkout which doesn't contain `README.md`.

```properties
managementComponents=jetty:jmx

jmxserviceurl=service:jmx:jmxmp://localhost:5555
adapterConfigUrl=file://localhost/./config/interlok-config-example/adapter.xml
loggingConfigUrl=file://localhost/./config/interlok-config-example/log4j2.xml
webServerConfigUrl=./config/interlok-config-example/jetty.xml

vcs.implementation=CommandLine
vcs.workingcopy.url=file://localhost/./config/interlok-config-example
vcs.remote.repo.url=https://github.com/adaptris/interlok-config-example.git
vcs.revision=master

# Variable substitution can be used.
# Note how we have multiple checkout commands that are executed in sequence
vcs.command.line.checkout.0=git init ${vcs.workingcopy.url}
vcs.command.line.checkout.1=git remote add --no-tags origin ${vcs.remote.repo.url}
vcs.command.line.checkout.2=git config core.sparseCheckout true
vcs.command.line.checkout.3=cp ../scm-sparse-checkout .git/info/sparse-checkout

vcs.command.line.update.0=git pull origin ${vcs.revision}
vcs.command.line.update.1=git read-tree -mu HEAD
```

The  _../scm-sparse-checkout_ file has an absolute path of be _${adapter.home}/config/scm-sparse-checkout_. Commands after the initial command will be executed inside the `vcs.workingcopy.url` directory so take care with relative paths. This file contains the desired sub-trees which will simply be :

```
/*
!README.md
```

If we startup our interlok instance, then we will get logging similar to this (if you check _./config/interlok-config-example_ then there will be no README.md) :

```
Bootstrap of Interlok 3.5-SNAPSHOT(2017-01-16) complete
TRACE [main] [BootstrapProperties] Properties resource is [bootstrap.properties]
INFO  [main] [RuntimeVersionControlLoader] Found version control system for [CommandLine]
INFO  [main] [CommandLineRVC] CommandLine: Checking local repository [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example]
INFO  [main] [CommandLineRVC] CommandLine: [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example] does not exist, performing fresh checkout.
INFO  [main] [CommandLineRVC] CommandLine: Performing checkout to [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example]
DEBUG [main] [CommandLineVCS] Executing command [git init C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example]
DEBUG [main] [CommandLineVCS] Executing command [git remote add --no-tags origin https://github.com/adaptris/interlok-config-example.git]
DEBUG [main] [CommandLineVCS] Executing command [git config core.sparseCheckout true]
DEBUG [main] [CommandLineVCS] Executing command [cp ../scm-sparse-checkout .git/info/sparse-checkout]
INFO  [main] [CommandLineRVC] CommandLine: Performing update to [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example]
DEBUG [main] [CommandLineVCS] Executing command [git pull origin master]
DEBUG [main] [CommandLineVCS] Executing command [git read-tree -mu HEAD]
TRACE [main] [BootstrapProperties] Attempting Logging reconfiguration using file://localhost/./config/interlok-config-example/log4j2.xml
WARN  [main] [ResponseProducer.<init>()] [ResponseProducer] is deprecated, use [com.adaptris.core.http.jetty.StandardResponseProducer] instead
WARN  [main] [JdkHttpProducer.<init>()] [JdkHttpProducer] is deprecated, use [com.adaptris.core.http.client.net.StandardHttpProducer] instead
INFO  [main] [UnifiedBootstrap.createAdapter()] Adapter created
TRACE [main] [ManagementComponentFactory.invokeMethod()] com.adaptris.core.management.webserver.JettyServerComponent#init([java.util.Properties])
TRACE [main] [ManagementComponentFactory.invokeMethod()] com.adaptris.core.management.jmx.JmxRemoteComponent#init([java.util.Properties])
TRACE [main] [PropertyResolver.init()] Parsing PropertyResolver URL [jar:file:/C:/Users/lchan/work/runtime/v3-nightly/lib/adp-core.jar!/META-INF/com/adaptris/core/management/properties/resolver]
TRACE [main] [PropertyResolver.init()] Registered Decoders : {password=com.adaptris.core.management.properties.PasswordDecoder}
TRACE [main] [JmxRemoteComponent.configureSecurity()] JMX Protocol=[jmxmp]
TRACE [main] [JmxRemoteComponent.createJmxWrapper()] JMX Environment : {}
TRACE [main] [JmxRemoteComponent.register()] MBean [com.adaptris:type=JmxConnectorServer] registered
TRACE [StandardBootstrap] [ManagementComponentFactory.invokeMethod()] com.adaptris.core.management.webserver.JettyServerComponent#start()
DEBUG [Thread-3] [JettyServerComponent.run()] Creating Jetty wrapper
TRACE [Thread-3] [JettyServerComponent.connectToUrl()] Connecting to ./config/interlok-config-example/jetty.xml
TRACE [Thread-3] [JettyServerComponent.createServer()] Create Server from XML
TRACE [StandardBootstrap] [ManagementComponentFactory.invokeMethod()] com.adaptris.core.management.jmx.JmxRemoteComponent#start()
WARN  [JMX-Request-0] [Adapter.warnOnErrorHandlerBehaviour()] [Adapter(MyInterlokInstance)] has a MessageErrorHandler with no behaviour; messages may be discarded upon exception
DEBUG [JMX-Request-0] [Adapter.registerWorkflowsInRetrier()] FailedMessageRetrier []
TRACE [JMX-Request-0] [ClosedState.logActivity()] Initialised [NullConnection]
TRACE [JMX-Request-0] [ClosedState.logActivity()] Initialised [DefaultEventHandler(DefaultEventHandler)]
TRACE [JMX-Request-0] [InitialisedState.logActivity()] Started [NullConnection]
TRACE [JMX-Request-0] [ClosedState.logActivity()] Started [DefaultEventHandler(DefaultEventHandler)]
TRACE [JMX-Request-0] [ClosedState.logActivity()] Initialised [NullProcessingExceptionHandler]
TRACE [JMX-Request-0] [ChannelList.init()] Channels that can be manipulated are: [WebServer, WebClient]
```

[interlok-vcs-command-line]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-vcs-command-line/