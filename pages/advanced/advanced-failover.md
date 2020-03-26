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

Currently you can choose between Multicast failover, JGroups or Direct TCP failover.

### Direct TCP ###

Direct TCP mode only since Interlok version __3.6.4__

On some environments you may not have access to multicast, or simply the reach of multicast doesn't reach all of your Interlok nodes.  In this case consider using Direct TCP, where you specify the list of hosts and ports of each node in the failover cluster prior to starting your cluster.

You will add the following properties to your bootstrap.properties file;
```
failover.socket.mode=tcp
failover.tcp.port=4446
failover.tcp.peers=localhost:4444;localhost:4445
```

The first property tells the failover system to use direct TCP for cluster node communication.  The second property specifies the port that this instance will use for TCP communication.  Finally the third property is a "semi-colon" separated list of known nodes in your failover cluster.

Since Interlok version 3.7.4, you may now add new failover peers while using the Direct TCP mode without having to reconfigure the current peers.  Simply make sure your new instance has been configured with each of the host and port numbers of the current failover members, from there the existing members will update their own peer lists as the new instance comes online.

### Multicast ###

Multicast mode is the easiest to configure and if multicast is available for your environment, then you can copy the following configuration into each of your Interlok failover cluster nodes, bootstrap.properties;

```
failover.socket.mode=multicast
failover.multicast.group=224.0.0.4
failover.multicast.port=4446
```
The first property tells the failover system to use multicast for cluster node communication.  The second and third properties specify the multicast address and port.

### JGroups ###

If you wish to have finer control over the network communication between each node in the failover cluster, then you can supply your own JGroups configuration file.  JGroups supports TCP and multicast.  Jgroups also supports discovery of new nodes; in other words you can spawn new nodes in to the cluster at any time and they will be added to the known list of available nodes.

To switch the failover mode to JGroups set the following properties in each of the failover nodes bootstrap.properties;

```
failover.socket.mode=jgroups
failover.jgroups.config.file=./config/jgroups.xml
failover.jgroups.cluster.name=myFailoverCluster
```

The first property tells the failover system to use JGroups configuration for cluster node communication.  The second property specifies the location of your JGroups configuration file.  The third property allows you to set a cluster name, allowing for multiple clusters within your network.

For detailed information on the JGroups configuration file, see [here](http://jgroups.org/manual5/index.html).

Sample JGroups configuration file for TCP communication where the initial Interlok node is listening on port 7878;

```xml
<!--
    TCP based stack, with flow control and message bundling. This is usually used when IP
    multicasting cannot be used in a network, e.g. because it is disabled (routers discard multicast).
    Note that TCP.bind_addr and TCPPING.initial_hosts should be set, possibly via system properties, e.g.
    -Djgroups.bind_addr=192.168.5.2 and -Djgroups.tcpping.initial_hosts=192.168.5.2[7878]
    author: Bela Ban
-->
<config xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xmlns="urn:org:jgroups"
        xsi:schemaLocation="urn:org:jgroups http://www.jgroups.org/schema/jgroups.xsd">
    <TCP bind_addr="localhost"
		 bind_port="7878"
         recv_buf_size="130k"
         send_buf_size="130k"
         max_bundle_size="64K"
         sock_conn_timeout="300"

         thread_pool.min_threads="0"
         thread_pool.max_threads="20"
         thread_pool.keep_alive_time="30000"/>

    <TCPPING async_discovery="true"
             initial_hosts="localhost[7878]"
             port_range="2"/>
    <MERGE3  min_interval="10000"
             max_interval="30000"/>
    <FD_SOCK/>
    <FD timeout="3000" max_tries="3" />
    <VERIFY_SUSPECT timeout="1500"  />
    <BARRIER />
    <pbcast.NAKACK2 use_mcast_xmit="false"
                   discard_delivered_msgs="true"/>
    <UNICAST3 />
    <pbcast.STABLE desired_avg_gossip="50000"
                   max_bytes="4M"/>
    <pbcast.GMS print_local_addr="true" join_timeout="2000"/>
    <UFC max_credits="2M"
         min_threshold="0.4"/>
    <MFC max_credits="2M"
         min_threshold="0.4"/>
    <FRAG2 frag_size="60K"  />
    <!--RSVP resend_interval="2000" timeout="10000"/-->
    <pbcast.STATE_TRANSFER/>
</config>
```
A sample multicast example;

```xml
<!--
  Default stack using IP multicasting. It is similar to the "udp"
  stack in stacks.xml, but doesn't use streaming state transfer and flushing
  author: Bela Ban
-->

<config xmlns="urn:org:jgroups"
        xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
        xsi:schemaLocation="urn:org:jgroups http://www.jgroups.org/schema/jgroups.xsd">
    <UDP
         mcast_port="${jgroups.udp.mcast_port:45588}"
         ip_ttl="4"
         tos="8"
         ucast_recv_buf_size="5M"
         ucast_send_buf_size="5M"
         mcast_recv_buf_size="5M"
         mcast_send_buf_size="5M"
         max_bundle_size="64K"
         enable_diagnostics="true"
         thread_naming_pattern="cl"

         thread_pool.min_threads="0"
         thread_pool.max_threads="20"
         thread_pool.keep_alive_time="30000"/>

    <PING />
    <MERGE3 max_interval="30000"
            min_interval="10000"/>
    <FD_SOCK/>
    <FD_ALL/>
    <VERIFY_SUSPECT timeout="1500"  />
    <BARRIER />
    <pbcast.NAKACK2 xmit_interval="500"
                    xmit_table_num_rows="100"
                    xmit_table_msgs_per_row="2000"
                    xmit_table_max_compaction_time="30000"
                    use_mcast_xmit="false"
                    discard_delivered_msgs="true"/>
    <UNICAST3 xmit_interval="500"
              xmit_table_num_rows="100"
              xmit_table_msgs_per_row="2000"
              xmit_table_max_compaction_time="60000"
              conn_expiry_timeout="0"/>
    <pbcast.STABLE desired_avg_gossip="50000"
                   max_bytes="4M"/>
    <pbcast.GMS print_local_addr="true" join_timeout="2000"/>
    <UFC max_credits="2M"
         min_threshold="0.4"/>
    <MFC max_credits="2M"
         min_threshold="0.4"/>
    <FRAG2 frag_size="60K"  />
    <RSVP resend_interval="2000" timeout="10000"/>
    <pbcast.STATE_TRANSFER />
</config>
```

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

In addition to the properties specified above depending on the chosen mode, there are a few other properties that can also be set;

| Property | Notes |
| failover.tcp.host | Optional property, only used with Direct TCP mode that specifies the host name or IP address of the current Interlok instance.  If not specified we will try to determine the local IP address. |
| failover.slave.position | if you wish to preconfigure the slave position in the hierarchy then define this, otherwise one will be assigned |
| failover.ping.interval.seconds | How often each instance will attempt to communicate with each other, defaults to 3 seconds |
| interval.instance.timeout.seconds | How long before an instance is deemed as no longer available, defaults to 20 seconds |


#### Example Java system properties ####

It is also possible to specify the bootstrap properties described above as system properties instead.

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
