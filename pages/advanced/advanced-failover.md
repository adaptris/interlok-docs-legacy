---
title: Interlok Failover
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-failover.html
summary: This page describes how to configure multiple Interlok instances to start up in failover mode (since 3.3)
---

## Failover Mode ##

When multiple instances of Interlok start in failover mode, only one single instance, known as the master, will fully start up ready to process messages.  All other Interlok instances in the cluster will sit and wait in a dormant state (slave) until they are promoted to the master.

In failover mode all instances are started as slaves.

Upon start-up of multiple instances in failover mode, if you have not configured the slave position for each, they will decide the order themselves.

The instance nominated as slave at position 1 will be the next instance to promote itself to master.  If there is currently no master instance running this slave will promote itself immediately.

Should the master stop communicating with the other instances it is then assumed the master instance has gone down, in which case as soon as each slave recognises the lack of communication from the master, the slave in position 1 will promote itself to master.  Each additional slave in positions 2 and above will each promote themselves up one position.

If you start new slaves at any time, all slaves in the cluster may decide to re-order themselves to accomodate the new slave.

Each instance in the cluster constantly communicates with every other instance in the cluster via multicast or direct TCP, dpending on your configuration, specified below.

Please note, some environments do not enable multicast broadcasting by default, therefore you may require additional networking configuration before Interlok failover clusters can be configured using Multicast mode.

### Installation ###

For each Interlok instance you wish to join the failover cluster, you will need only one optional component;

- interlok-failover

Simply copy the jar files from the optional component directory into the lib directory of each Interlok instance in the failover cluster.

## Failover Modes ##

Currently you can choose between Multicast failover or Direct TCP failover.

Direct TCP mode only since Interlok version 3.6.4

The main benfit of multicast failover is that you can add new failover peers as and when you want.  Simply start a new instance of Interlok and the new instance will be added to the failover cluster automatically.

If multicast is not available on your environment then you can configure Direct TCP failover instead.
The main difference here is that you must define each machines host and port for each instance in the failover cluster group in either the bootstrap.proprties, or via java system properties.

Since Interlok version 3.7.4, you may now add new failover peers while using the Direct TCP mode without having to reconfigure the current peers.  Simply make sure your new instance has been configured with each of the host and port numbers of the current failover members, from there the existing members will update their own peer lists as the new instance comes online.

## Configuring Basic Interlok Failover ##

Simple configuration is required as detailed below.

### Starting ###

#### interlok-boot ####

As of 3.7 starting Interlok in failover mode can be done using interlok-boot with `--failover` argument and passing the name of the chosen bootstrap.properties file as a parameter. Note that this is the preferred way to start your interlok instance in failover mode. The lax file can be tailored to use interlok boot.

A short example of a windows start script; the last line setting the argument and the bootstrap.properties parameter;

```
set ADAPTRIS_HOME=C:\Adaptris\Interlok
set JAVA_HOME=C:\Java\jdk1.8\bin

cd %ADAPTRIS_HOME%
%JAVA_HOME%\bin\java -jar lib\interlok-boot.jar --failover bootstrap.properties
```

#### lax file with interlok-boot ####

Leave the `lax.main.class` property as-is, but modify the `lax.command.line.args` to be `--failover bootstrap.properties`; this effectively does the same as the java -jar method.

#### Main Class ####

The main class is `com.adaptris.failover.SimpleBootstrap`; make sure you have all jars in the classpath. Pass in your bootstrap.properties as the single commandline argument; note that here we have skipped over building up the classpath; it's assumed that you can do that.

```
java -cp $CLASSPATH com.adaptris.failover.SimpleBootstrap bootstrap.properties
```

### Bootstrap Properties ###

| Property | Notes |
| failover.socket.mode | if `tcp` switches to direct TCP mode; if not specified multicast mode |
| failover.multicast.group | must be defined when working in multicast mode |
| failover.multicast.port | must be defined when working in multicast mode |
| failover.tcp.port | must be defined if direct TCP mode is enabled |
| failover.tcp.peers | must be defined if direct TCP mode is enabled, and is a `;` separated list of peers |
| failover.tcp.host | optional property that specifies the host name or IP address of the current Interlok instance.  If not specified we will try to determine the local IP address. |
| failover.slave.position | if you wish to preconfigure the slave position in the hierarchy then define this, otherwise one will be assigned |
| failover.ping.interval.seconds | How often each instance will attempt to communicate with each other, defaults to 3 seconds |
| interval.instance.timeout.seconds | How long before an instance is deemed as no longer available, defaults to 20 seconds |


Both `failover.tcp.port` and `failover.tcp.peers` may either be set in the bootstrap.proprties or as java system proprties.

#### Example bootstrap.properties ####

Assumes the local instance can listen for TCP failover events on port 15555 and that there are two further instances in the failover cluster who happen to be running on the same machine (localhost) and are listening on ports 15556 and 15557 respectively.

```
failover.tcp.port=15555
failover.tcp.peers=localhost:15556;localhost:15557
```

#### Example Java system properties ####

Assumes the local instance can listen for TCP failover events on port 4444 and that there are two further instances in the failover cluster who happen to be running on the same machine (localhost) and are listening on ports 15556 and 15557 respectively.

```
java -Dfailover.tcp.port=15555 -Dfailover.tcp.peers=localhost:15556;localhost:15557 -jar lib/interlok-boot.jar -failover
```

## Manual Failover ##

Should you wish to stop the master instance running; either through the JMX API or the Web UI, the slave at position 1 is expected to promote itself to master.

To enable this functionality you must change the default event handler in your Interlok configuration.  This is simply changed like this (notice the failover-event-handler);

```
<adapter>
  <unique-id>MyInterlokInstance</unique-id>
  <event-handler class="failover-event-handler"/>
```

NOTE:  If you manually force a failover, you will not be able to re-start the master instance through the JMX API or Web UI.  The original master instance will need a full restart.

## Runtime Logging ##

Once you have put it all together; then when you start your Interlok instances, you will get additional logging in the log file.

All Interlok instances in the failover cluster will include the following log lines;

```
INFO  [main] [FailoverBootstrap] Starting Interlok instance in failover mode as a slave.
INFO  [main] [FailoverBootstrap] Slave position 1
```

If you do not specify the slave positions, then you will see logging like this;

```
INFO  [main] [FailoverBootstrap] Starting Interlok instance in failover mode as a slave.
INFO  [main] [FailoverBootstrap] No slave position has been set, one will be allocated.
INFO  [Failover Monitor Thread] [FailoverManager] Assigning myself slave position 1
```

Only the master instance (slave at position 1, after it has promoted itself) will additionally show the following lines in the log file;

```
TRACE [Failover Monitor Thread] [FailoverManager] Master not available, promoting myself to master.
INFO  [Failover Monitor Thread] [FailoverBootstrap] Promoting to MASTER
```

If you set the JVM parameter interlok.failover.debug to true, then periodically each instance in the failover cluster will report it's state and information (at TRACE level logging) about all known other online instances.

Example below shows the logging from the slave at position 1, where 4 instances are in the cluster; a master and 3 slaves.

```
TRACE [Failover Monitor Thread] [com.adaptris.failover.FailoverManager] com.adaptris.failover.FailoverManager@7ce58397[
  Self=OnlineInstance[ID=1f0eab39-e917-4b02-b987-bf37d9620c3d,Type=slave,Position=1,last=Thu Jan 01 01:00:00 GMT 1970]
  master=OnlineInstance[ID=10cc907e-f4ca-4cb4-b96f-9547035028c4,Type=master,Position=0,last=Mon Jul 23 12:34:39 BST 2018]
  slaves=[OnlineInstance[ID=9c9fc821-f257-420c-bffa-6838b4baecbc,Type=slave,Position=2,last=Mon Jul 23 12:34:40 BST 2018], OnlineInstance[ID=b22c7478-dafd-4d95-af1d-3b13c8cc9080,Type=slave,Position=3,last=Mon Jul 23 12:34:41 BST 2018]]
]

```
