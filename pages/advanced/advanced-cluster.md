---
title: Interlok Clustering
keywords: interlok,cluster
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-cluster.html
summary: This page explains Interlok instance clustering.
---

# Clustering Interlok

As of Interlok __3.10.0__ you can monitor a cluster of Interlok instances.

A "cluster" may mean different things depending on your needs.  Perhaps you want your cluster to be more of a load balancing cluster, or perhaps you want to be able to track auto-scaling instances as they join a named cluster.

For the purposes of this document, by "cluster" we simply mean the ability for each individual Interlok instance to be aware of other instances in the same __named__ cluster.

## Creating a Cluster

Interlok clusters are comprised of two components; very simply a name and the communication method by which each instance can communicate.

### Installation

Interlok clusters require the __[interlok-cluster-manager](https://github.com/adaptris/interlok-cluster-manager)__ component.

If you're manually collecting the required Java libraries for this component then you will need;
 - [interlok-cluster-manager](https://nexus.adaptris.net/nexus/content/repositories/releases/com/adaptris/interlok-cluster-manager/)
 - [JGroups](https://mvnrepository.com/artifact/org.jgroups/jgroups/4.2.3.Final)

Drop the Java libraries into your Interlok lib directory and restart.

### Configuration

You'll need to edit your __bootstrap.properties__ which can be found in the root of your Interlok installations __config__ directory.

There are two required changes;

Make sure the __managementComponents__ property includes __cluster__.  Example;

```
managementComponents = jetty:jmx:cluster
```

The second change is a new property specifically for clustering, which is simply the name of the cluster;
```
clusterName=MyInterlokCluster
```

Every Interlok instance with the same configured __clusterName__ will join the same cluster when starting up.

A further optional property, again in the __bootstrap.properties__ is for extra debug logging during runtime.  Setting this property to __true__ will show additional debug logging every time a clustered instance contacts the current instance.
```
clusterDebug=true
``` 

## Runtime

Make sure you leave port 7878 open for TCP communication between each of your Interlok instances.  Each instance will send pings over this port to alert each other of their existence.  As new instances are spooled up with similar configuration they will automatically join the named cluster.

### Accessing the cluster information

There are currently two ways to do this;
 - JMX
 - Rest services

#### JMX

If you are able to access JMX, then code similar to the below will allow you to access the cluster bean information.  Do note however, you will need to include __interlok-core__ as an extra dependency to your custom code, specifically for the __ExpiringMapCache__ object which is returned from;

```java
ExpiringMapCache cacheOfClusterInstances = clusterManager.getClusterInstances();
```
A very basic example of connecting to JMX is shown below.  However, you will need to make changes to the MBeanServer connection should your code be run outside the Interlok instances JVM.

```java
private static final String CLUSTER_MANAGER_OBJECT_NAME = "com.adaptris:type=ClusterManager,id=ClusterManager";

// Assumes we're running in the same JVM.
MBeanServer mBeanServer = JmxHelper.findMBeanServer();

ClusterManagerMBean clusterManager = JMX.newMBeanProxy(mBeanServer, new ObjectName(CLUSTER_MANAGER_OBJECT_NAME ), ClusterManagenerMBean.class, true)

clusterManager.getClusterInstances().getKeys().forEach(key -> {
  try {
    ClusterInstance instance = (ClusterInstance) clusterManager.getClusterInstances().get(key);
    // Do something with each ClusterInstance
  } catch (CoreException e) {}
});
```
And your ClusterInstance object that you can play with is defined [here](https://github.com/adaptris/interlok-cluster-manager/blob/develop/src/main/java/com/adaptris/mgmt/cluster/ClusterInstance.java);

#### Rest Services

__Installation__

Drop the __interlok-workflow-rest-services.jar__ built from this project in to your Interlok __lib__ directory, then modify your __bootstrap.properties__ to make sure the managementComponents property contains all of "__jetty__", "__jmx__, "__cluster__", " and "__cluster-rest__".
```
managementComponents=jetty:jmx:cluster
```

The __cluster__ component enables basic clustering, __cluster-rest__ enables querying of the known instances.

Optionally, you can also set the property named __rest.cluster-manager.path__, which directly affects the REST API URL path.  The default value is; "__/cluster-manager/*__".

__Running__

Using your favourite HTTP GET/POST tool, make a GET request to the running Interlok instance;
```
http GET http://<host>:<port>/cluster-manager
```

This will return a JSON array, with all of the known cluster instances.

Below is an example of the resulting JSON.

```json
{
  "java.util.Collection": [
    {
      "com.adaptris.mgmt.cluster.ClusterInstance": {
        "cluster-uuid": "97015aa0-f9b8-4bd1-93fb-01922b827d08",
        "jmx-address": "service:jmx:jmxmp://localhost:5555",
        "unique-id": "MyInterlokInstance"
      }
    }
  ]
}
```