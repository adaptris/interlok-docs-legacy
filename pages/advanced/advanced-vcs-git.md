---
title: Version Control with GIT
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-vcs-git.html
summary: Configure Interlok to automatically check out config from GIT when starting.
---

{% include note.html content="This depends on the artifact com.adaptris:interlok-vcs-git. In 3.8.0; adp-vcs-git was renamed to interlok-vcs-git" %}

## Configuration ##

### Basic Configuration ###

All configuration for version control will live in bootstrap.properties.  The following basic properties must be set (if not set, then no VCS operations are performed):

| Property | Description |
|----|----|
| vcs.workingcopy.url | This is the URL to the local directory where all files will be checked out to. |
| vcs.remote.repo.url | This is the URL to your remote Git repository |

All files from the remote location will be checked out to your local directory location. Standard Git URL and protocol formats are supported such as `file://`, `http://`, `https://` and `git@github.com:`.

### Authentication ###

Additional bootstrap properties will control the various authentication schemes available to Git.

| Property | Description |
|----|----|
| vcs.username | Your Git username |
| vcs.password | The password associated with your username  May be [treated as a password](advanced-password-handling.html) |
| vcs.ssh.keyfile.url | The URL to your local keyfile |
| vcs.ssh.passphrase | Your passphrase for your local keyfile. May be [treated as a password](advanced-password-handling.html)  |
| vcs.ssl.certificate.url | The URL to your certificate file (if using SSL based certificate authentication) |
| vcs.ssl.password | Your password matched with your certificate file. May be [treated as a password](advanced-password-handling.html)  |


### Optional ###

| Property | Description |
|----|----|
| vcs.implementation | since 3.5.1 Which VCS implementation to load |
| vcs.revision | The revision/tag/branch to checkout; by default this will be the latest revision for the remote URL, and will be logged. |
| vcs.always.reset | Whether or not to always discard any uncommitted changes when updating; defaults to false |
| log4j12Url | __Deprecated__: use loggingConfigUrl instead.|
| loggingConfigUrl | since 3.1.0 If specified then then an attempt is made to re-configure the logging (log4j1.2 or log4j2) subsystem with the referenced URL. This is done after any checkout/update is performed.|
| vcs.ssh.proxy | since 3.5.0; if required, you can specify a proxy server here `192.168.1.1:3128` to use an HTTP proxy to access the target remote SSH URL |
| vcs.ssh.proxy.type | since 3.5.1; if required, specify the type of proxy here `HTTP`, `SOCKS4`, `SOCKS5` (defaults to `HTTP`) |
| vcs.ssh.proxy.username | since 3.5.0; if required the proxy username |
| vcs.ssh.proxy.password | since 3.5.0; if required the proxy password |
| vcs.auth | The authentication method to use, either "SSH" or "UsernamePassword", defaults to the later. |

## Example ##

If we take an example bootstrap.properties. Note that this project does exist on github.com, and is currently enabled for public view-only access (so the bootstrap.properties should be usable as-is).

```properties
managementComponents=jetty:jmx

# The adapter configuration file is VCS managed; so we refer to the local working copy.
adapterConfigUrl=file://localhost/./config/interlok-config-example/adapter.xml

# Our Log4j is VCS managed; so we can refer to the local working copy.
loggingConfigUrl=file://localhost/./config/interlok-config-example/log4j2.xml

# Again, the jetty.xml is checked in, so let's refer to the local working copy.
webServerConfigUrl=./config/interlok-config-example/jetty.xml

# This controls how we connect to Git.
vcs.implementation=Git
vcs.workingcopy.url=file://localhost/./config/interlok-config-example
vcs.remote.repo.url=https://github.com/adaptris/interlok-config-example.git
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
INFO  [main] [RuntimeVersionControlLoader] Found version control system for [Git]
INFO  [main] [GitVCS] GIT: Checking local repository [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example]
INFO  [main] [GitVCS] GIT: [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example] does not exist, performing fresh checkout.
INFO  [main] [GitVCS] GIT: Performing checkout to [C:\Users\lchan\work\runtime\v3-nightly\config\interlok-config-example]
TRACE [main] [JGitApi] GIT: Check out [https://github.com/adaptris/interlok-config-example.git]
TRACE [main] [JGitApi] GIT: Pulling changes for branch [master]
TRACE [main] [JGitApi] GIT: Check out to revision/tag/branch [master]
INFO  [main] [GitVCS] GIT: Updated configuration to revision: 2cbc3b1e601f2472d933c5950d7a60b44f795267
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

### Logging ###

Be aware that if no initial log4j configuration is available on the classpath on startup then you will not have any logging until after checkout/update and logging reconfiguration is completed which will make it very hard to verify whether you have the configuration correct. In the example above, you can see that the logging configuration has actually changed because the log4j2 configuration PatternLayout contains the method name in addition to the classname subsequent to checking out the configuration.

You may also notice an error in the logging similar to this;

```
java.io.IOException: Cannot run program "bash" (in directory "C:\Users\myUser"): CreateProcess error=2, The system cannot find the file specified
        at java.lang.ProcessBuilder.start(ProcessBuilder.java:1048)
        at java.lang.Runtime.exec(Runtime.java:620)
        at org.eclipse.jgit.util.FS.readPipe(FS.java:431)
        at org.eclipse.jgit.util.FS_Win32.discoverGitPrefix(FS_Win32.java:113)
        at org.eclipse.jgit.util.FS.gitPrefix(FS.java:517)
        at org.eclipse.jgit.util.SystemReader$Default.openSystemConfig(SystemReader.java:92)
        at org.eclipse.jgit.internal.storage.file.FileRepository.<init>(FileRepository.java:171)
        at org.eclipse.jgit.storage.file.FileRepositoryBuilder.build(FileRepositoryBuilder.java:92)
        at com.adaptris.vcs.git.api.JGitApi.getRepository(JGitApi.java:252)
        at com.adaptris.vcs.git.api.JGitApi.getBareRepository(JGitApi.java:239)
        at com.adaptris.vcs.git.api.JGitApi.updateCopy(JGitApi.java:296)
        at com.adaptris.vcs.git.api.JGitApi.update(JGitApi.java:119)
        at com.adaptris.vcs.git.GitVCS.update(GitVCS.java:86)
        at com.adaptris.core.management.UnifiedBootstrap.o00000(UnifiedBootstrap.java:81)
        at com.adaptris.core.management.UnifiedBootstrap.createAdapter(UnifiedBootstrap.java:70)
        at com.adaptris.core.management.oOOO.o00000(CmdLineBootstrap.java:67)
        at com.adaptris.core.management.StandardBootstrap.standardBoot(StandardBootstrap.java:59)
        at com.adaptris.core.management.StandardBootstrap.boot(StandardBootstrap.java:37)
        at com.adaptris.core.management.StandardBootstrap.main(StandardBootstrap.java:72)
Caused by: java.io.IOException: CreateProcess error=2, The system cannot find the file specified
        at java.lang.ProcessImpl.create(Native Method)
        at java.lang.ProcessImpl.<init>(ProcessImpl.java:386)
        at java.lang.ProcessImpl.start(ProcessImpl.java:137)
        at java.lang.ProcessBuilder.start(ProcessBuilder.java:1029)
        ... 18 more

```

The reason for this error is in FS_Win32.java:113 JGit tries to find native git by running the command "which git" in a bash process. If native git isn't installed or bash or git are not configured on the system PATH then this command fails. JGit logs an error to leave a trace message that this attempt to find native git failed but will work ok anyway. JGit tries to find native git in order to locate the system wide git configuration which is located in a path relative to the native git installation. If it doesn't find a native git installation JGit can't locate this system wide git configuration and hence will ignore it.

If you do see this error, you can ignore it knowing that version control with Git will work anyway.

[VersionControlSystem]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/management/vcs/VersionControlSystem.html
[public repository]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/
