---
title: Integrating with Terracotta Universal Messaging
keywords: interlok terracotta messaging
tags: [cookbook, messaging]
sidebar: home_sidebar
permalink: cookbook-terracotta-um.html
summary: This document gives a quick start guide to bridging messages to and from Terracotta Universal Messaging system.
---

## Getting Started ##

### Interlok Pre-requisites ###

Before you can start an Interlok instance that is able to consume or produce from or to a Terracotta Universal Messaging system, you must first copy 2 java libraries from the Terracotta install to the "lib" directory at the root of your Interlok install;

- nJMS.jar
- nClient.jar

### Terracotta Universal Messaging ###

The following assumes a stock install of Universal Messaging.

As part of the JMS and JNDI standards only a connection factory and endpoints are required configuration for Interlok connections to be enabled.

With universal messaging you don't necessarily need to create your queues before Interlok starts up; any endpoints configured in your consumers or producers will remotely create the queues for you.

You will however have to configure the access rights on each of your endpoints to allow consumers to pop and producers to push messages.

![QueuePrivs.png](./images/tum/QueuePrivs.png)

We will be configuring Interlok to use JNDI for each of it's connections therefore ConnectionFactories must be created on the server side.

You will either need to create a QueueConnectionFactory/TopicConnectionFactory or the more generic ConnectionFactory, which we will be using in this quick start guide.

Each configured Interlok connection will simply re-use the same connection factory, therefore we only need to create that single connection factory on the server side, simply named "ConnectionFactory".

![ConnectionFactoryCreate.png](./images/tum/ConnectionFactoryCreate.png)

This concludes all required Universal Messaging configuration.

----

## Interlok Configuration ##

For this quick start guide we're going to create 3 channels;

1) Read messages from the file system and send to Universal Messaging queue named SampleQ1.

2) Simple bridge channel, consumes messages from SampleQ1 and send to SampleQ2.

3) Reply channel which consumes from SampleQ2 and dumps the messages back to the file system.

![Channel1.png](./images/tum/Channel1.png)

![Channel2.png](./images/tum/Channel2.png)

![Channel3.png](./images/tum/Channel3.png)

Assuming a stock install of Universal Messaging, means that our JNDI configuration for our connections are very simple, we only need two properties;

- java.naming.factory.initial = com.pcbsys.nirvana.nSpace.NirvanaContextFactory

- java.naming.provider.url = nsp://127.0.0.1:9000/

![JNDIConfig.png](./images/tum/JNDIConfig.png)

Your provider URL will match the url seen in the Universal Messaging manager under the JNDI tab;

![UM_Manager.png](./images/tum/UM_Manager.png)

Finally, in the Bridge channel (channel 2), we have not configured any connection error handlers, therefore default connection error handlers will be assigned.

This can cause a problem if you are not using shared connections, but instead configure the connections at the channel level, which we have done in this example.

Both connections for the second channel will be assigned a default connection error handler, which will cause a conflict.

Therefore we need to set the produce connection error handler to a NullConnectionErrorHandler;

![CEH.png](./images/tum/CEH.png)

This concludes all required Interlok configuration.

## Running the example ##

Once Interlok is running, you can simply drop a text file into the "messages-in" directory at the root of your Interlok installation, which will trigger each channel in turn.

Finally, once the text file has been consumed and sent to SampleQ1 and then picked up by channel 2 which will bridge the message to SampleQ2, your final channel will consume this message and finally return the message contents to the "messages-out" directory, also at the root of your Interlok installation.

Sample TRACE logging from this simple quick start test is shown below.

![SampleLogging.png](./images/tum/SampleLogging.png)



