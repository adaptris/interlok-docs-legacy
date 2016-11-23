---
title: Clustered Workflows / Services
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-vertx.html
summary: This page describes how to configure Interlok workflow/service clustering (since 3.5.0)
---

## Clustering Implementation ##

Interlok uses [VertX][] version 3.3.2 and [Hazelcast][] version 3.7.1 for the clustering management.

### Installation ###

For each Interlok instance you wish to join a cluster, you will need only the optional component [interlok-vertx][]. Copy the required jar files and its dependencies into the lib directory of each Interlok instance in the cluster. Use your preferred method for obtaining the files.

## Workflow Clustering ##

A common use case is to consume a message from any configured endpoint and then to farm the service-list processing out to any one of a number of running workflow instances. In this case we introduce workflow clustering. We start with a workflow that has a consumer.  Once a message has been consumed our clustered-workflow can delegate the message to an another instance in the cluster.

```
...
<clustered-workflow>
  <unique-id>MyClusterName</unique-id>

  <consumer>
		...
  </consumer>

  <target-component-id class="constant-data-input-parameter">
    <value>MyClusterName</value>
  </target-component-id>

  <service-collection>
		...
  </service-collection>

  <producer>
		...
  </producer>

```

### Creating a cluster ###

To create a cluster you simply need multiple clustered-workflows each with the same unique-id, either in different channels in the same Interlok instance, or across multiple Interlok instances.

### Sending a message to a cluster ###

The __target-component-id__ specifies the cluster (clustered-workflow.unique-id) that any consumed messages will be sent to for processing.  The above example specifies the target-component-id exactly the same as it's own workflow unique-id.
This means that the current clustered-workflow is also part of the processing cluster and may therefore be chosen to process the message.

There are two send modes; __single__ and __all__.

__single__ simply means the message will be sent to one and only one instance in the cluster for processing.

__all__ means the message will be sent to all running clustered-workflow instances in the cluster.

```
...
<clustered-workflow>
  <unique-id>MyClusterName</unique-id>

  <target-send-mode>single</target-send-mode>

```

### Configuring the clustered-workflow with a consumer ###

First a technical note:  The standard-workflow will consume a message, then process the service-list and finally the producer before consuming the next message.  The clustered-workflow is slightly different; it will consume a message then send the message to the cluster and immediately look to consume the next message.

Therefore the next message consumed may well happen before the previous message has been processed completely.

For this reason you can configure how many messages at most will be consumed without being fully processed.  This is achieved with the __queue-capacity__ option.

> Note:  This is only available for target-send-mode="single"

An example;

Assume a JMS queue has 100 messages waiting to be processed, we then configure our clustered-workflow (that includes the JMS consumer) to have a queue-capacity of 10.

```
...
<clustered-workflow>
  <unique-id>MyClusterName</unique-id>

  <consumer>
		...
  </consumer>

  <queue-capacity>10</queue-capacity>
		...

```

In this example the workflow consumes 10 messages and farms them out to the cluster for processing.  As each message is fully processed and the reply is received, only then will the next message be consumed.

The default value for the queue-capacity is 10.

### Configuring the receiving clustered-workflow instances ###

Each clustered-workflow that is a member of a cluster will act both as a sender and a receiver.  If your clustered-workflow consumes a message then the clustered-workflow will send the message out to the cluster for processing.

At the same time the clustered-workflow is always listening for messages being sent from other clustered-workflow instances (that are a member of the same cluster) to process, therefore the workflow configuration is identical whether you are consuming a message or intended as a clustered instance to receive and process the message.

You may however choose not to have any consumers in some of your clustered workflow instances.  This way you consume a message from one clustered-workflow and simply farm the processing out to one of the clustered instances and get the reply back.

With this configuration, essentially the clustered instances only exist to process the service-list and not to consume new messages.

Conversely if you do choose to have consumers on each clustered-workflow instance within your cluster, you will have created a load-balancing cluster, each instance able to consume and process messages.

### Message replies ###

Once the target(remote) clustered-workflow has completed the service-list processing it will send the message back to the original workflow (clustered-workflow that consumed the message) as a reply, but only if you use the target-send-mode of __"single"__.

The original clustered-workflow will run the message-error-handler should the message have produced an error during service-list processing on the remote instance or will run it's own producer should you have one configured.

### What if I want to send a message to all instances ###

Because we can never be sure exactly how many instances are running in the cluster, we do not wait for replies from any/all instances.

In this case the message is handled in a "fire and forget" manner.  Each message is simply sent to each known instance in the cluster and then forgotten about, no replies happen and therefore any configured producer on the consuming workflow is ignored.

## Service Clustering ##

Service clustering works in much the same way workflow clustering works, with a couple of differences.

### Creating a cluster ###

To create a cluster you simply need multiple clustered-services each with the same unique-id, either in different workflows in the same Interlok instance, or across multiple Interlok instances.

### Sending a message to a cluster ###

Simply add an instance of the clustered-service in one of your service-lists inside a workflow and specify the target-component-id.

The __target-component-id__ specifies the cluster (clustered-workflow.unique-id or clustered-service.unique-id) that any message will be sent to for processing.

The cluster name to target can be either a clustered-service or a clustered-workflow cluster.

This can be very useful if you simply want to transfer a message from one workflow to another without having to produce and consume again.

There are two send modes; __single__ and __all__.

__single__ simply means the message will be sent to one and only one instance in the cluster for processing.

__all__ means the message will be sent to all running clustered-workflow instances in the cluster.

> Note: When this service executes in a service-list of a workflow, the message is sent to the cluster and then immediately the next service in the list can be run.  This may happen before the remote instance finishes processing the message!

It is important to remember that no reply is ever waited for.  If a reply comes in, it will be processed as explained later, but further services in the current service-list or even the producer for the workflow will be executed regardless of whether the remote clustered-service completes it's processing or not.


```
...
<clustered-service>
  <unique-id>MyClusterName</unique-id>

  <target-send-mode>single</target-send-mode>

```

### Configuring the receiving clustered-service instances ###

Exactly like the clustered-workflows the clustered-service can act as both a sender and a receiver.  The sender is the service that is part of a service-list in a workflow that is currently processing a message.  The receiver is the clustered-service that processes the message sent to it by the former.

The receiving clustered-service will have another Service (or could be a service-list) wrapped that is executed for each message received.

An example:

The following configuration, will send a message to the cluster named "cluster 1".

```
<adapter>
  <unique-id>clustered-Service-Example</unique-id>
  <channel-list>
    <channel>
      <unique-id>Channel1</unique-id>
      <workflow-list>
        <standard-workflow>
          <unique-id>consumer-workflow</unique-id>

          <consumer class="">
            ...
          </consumer>

          <service-collection class="service-list">
            <unique-id>ServiceList</unique-id>
            <services>
              <clustered-service>
                <unique-id>clustered-service-1</unique-id>
                <target-component-id class="constant-data-input-parameter">
                  <value>cluster 1</value>
                </target-component-id>

                <reply-service class="log-message-service">
                  <unique-id>log-service</unique-id>
                </reply-service>
              </clustered-service>
            </services>
          </service-collection>

          <producer class="">
            ...
          </producer>

        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>

```

The receiving clustered-service instance will simply perform the log-message-service;

```
<adapter>
  <unique-id>clustered-Receiver-Adapter</unique-id>
  <channel-list>
    <channel>
      <unique-id>Channel1</unique-id>
      <workflow-list>
        <standard-workflow>
          <unique-id>clustered-receiver-workflow</unique-id>

          <service-collection class="service-list">
            <unique-id>ServiceList</unique-id>
            <services>
              <clustered-service>
                <unique-id>cluster 1</unique-id>

                <service class="log-message-service">
                  <unique-id>log-messages-service1</unique-id>
                </service>

              </clustered-service>
            </services>
          </service-collection>

        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>

```


### What about replies? ###

In the same way clustered-workflows receive a reply after the remote instance has processed, the same happens for clustered-services.

Looking at the above example you will notice that the sending clustered-service also configures a reply-service.  in this case it is a very simple log-message-service, but it could equally be a service-list.

Should the reply services fail, you can also configure a reply-processing-exception-handler;

```
	<clustered-service>
		<unique-id>clustered-service-1</unique-id>
		<target-component-id class="constant-data-input-parameter">
			<value>cluster 1</value>
		</target-component-id>

		<reply-service class="log-message-service">
			<unique-id>log-service</unique-id>
		</reply-service>

		<reply-processing-exception-handler class="">
			...
		</reply-processing-exception-handler>
	</clustered-service>
```


[VertX]: http://vertx.io/
[Hazelcast]: https://hazelcast.com/
[interlok-vertx]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-vertx/