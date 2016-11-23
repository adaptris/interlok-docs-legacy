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

Each instance in the cluster constantly communicates with every other instance in the cluster via multicast.

Please note, some environments do not enable multicast broadcasting by default, therefore you may require additional networking configuration before Interlok failover clusters can be configured.

### Installation ###

For each Interlok instance you wish to join the failover cluster, you will need only one optional component;

- interlok-failover

Simply copy the jar files from the optional component directory into the lib directory of each Interlok instance in the failover cluster.

## Configuring Basic Interlok Failover ##

Simple configuration is required as detailed below.

### The start script ###

Starting Interlok in failover mode simply requires changing the java main class and passing the name of the chosen bootstrap.properties file as the single parameter.

NOTE: Make sure your chosen bootstrap properties file is on the classpath.

If you choose to create your own Interlok startup script make sure that the following class is set as the main class in the java command;

- com.adaptris.failover.FailoverBootstrap

A short example of a windows start script; the last line setting the main class and the bootstrap.properties parameter;

```
set CLASSPATH=.
set ADAPTRIS_HOME=C:\Adaptris\Interlok3.3
set JAVA_HOME=C:\Java\jdk1.8.0_60\bin

set CLASSPATH=%CLASSPATH%;%ADAPTRIS_HOME%\lib\adp-core.jar;%ADAPTRIS_HOME%\config
for /R %ADAPTRIS_HOME%\lib %%H in (*.jar) do set CLASSPATH=!CLASSPATH!;..\Interlok3.3\lib\%%~nxH

%JAVA_HOME%\java -cp %CLASSPATH% com.adaptris.failover.FailoverBootstrap bootstrap.properties
```

Alternatively you can modify the Interlok LAX file to set the main class like so;

- lax.main.class=com.adaptris.failover.FailoverBootstrap

And then adding the location of the bootstrap.properties file as the single parameter like so;

- lax.command.line.args=bootstrap.properties

### Bootstrap Properties ###

The failover component requires two additional settings and a further three optional settings;

The required settings are the multicast group and port;
- failover.multicast.group
- failover.multicast.port

The optional settings are as follows;

- failover.slave.position  -- Should you wish to preconfigure which slave will start in which position, defaults to 0.
- failover.ping.interval.seconds -- How often (seconds) will each instance attempt to communicate with each other, defaults to 3 seconds.
- failover.instance.timeout.seconds -- The amount of time in seconds when non-communication from an instance is deemed as no longer available, defaults to 20 seconds.

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

Periodically, each instance in the failover cluster will report it's state and information (at TRACE level logging) about all known other online instances.

Example below shows the logging from the slave at position 2, where 4 instances are in the cluster; a master and 3 slaves.

```
TRACE [Failover Monitor Thread] [FailoverManager]
My instance:
[ID: 9a6f9712-72ba-4153-aa96-69c662dd9639 --Type: Slave -- Slave position: 2 -- Last Contact: 13:11:23]

Current master instance:
[ID: 164d4cf5-6baa-434b-81f5-fa04ead32ca6 --Type: Master -- Slave position: 0 -- Last Contact: 13:11:21]

Other online slave instances:
[ID: d600d45c-7971-4e6c-bc28-28ed6a44e730 --Type: Slave -- Slave position: 3 -- Last Contact: 13:11:22]
[ID: 6a20a986-e645-49d0-ac01-c19b1ef13e23 --Type: Slave -- Slave position: 1 -- Last Contact: 13:11:21]
```
