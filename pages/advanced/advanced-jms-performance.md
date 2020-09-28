---
title: Interlok JMS performance samples.
keywords: interlok,prometheus,profiler,jms,performance
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-jms-performance.html
summary: Sample JMS bridging performance.
---

While performance will vary greatly with each environment never being truly equal, this document will share performance statistics generated from a set of JMS bridging tests run from an AWS deployment.

## Environment.

Unless otherwise stated all deployed containers are AWS [m5.large](https://aws.amazon.com/ec2/instance-types/m5/) and all instances are deployed to the eu-west-1 region.  
Five separate container instances have been used to host each of the following;
 - Interlok
 - Solace
 - WebsphereMQ
 - ActiveMQ
 - Prometheus / Grafana

![AWS-Environment](./images/jms-performance/aws-setup.png)

#### Interlok

Interlok 3.11 installed onto Linux running Azul Zulu Java 8u265b11. 

#### Solace

In place of an actual appliance we are using the [Solace published AMI](https://aws.amazon.com/marketplace/pp/B077GRGL8Q?qid=1601032125307&sr=0-1&ref_=srh_res_product_title) version 9.6.0.38. 

#### WebsphereMQ

We have taken the [WebsphereMQ developer edition](https://developer.ibm.com/components/ibm-mq/articles/mq-downloads/) version 9.1.5 and installed directly into AWS standard Ubuntu instance.

#### ActiveMQ

For ease of install we have opted for the Websoft9 [ActiveMQ AMI](https://aws.amazon.com/marketplace/pp/B07TSN8CL7?qid=1601032686337&sr=0-1&ref_=srh_res_product_title) version 5.16

#### Prometheus / Grafana

Very simply we have installed both Prometheus and Grafana via their docker images;
 - [Prometheus](https://hub.docker.com/r/prom/prometheus/)
 - [Grafana](https://hub.docker.com/r/grafana/grafana)

We simply then point Prometheus at Interlok to periodically scrape metrics.

## The Tests

All software mentioned above are stock installations with no tuning for performance or otherwise.

Each test run will simply use Interlok to bridge 75,000 messages, each 2kb in size, from one message vendor to another.  Each test will demonstrate a particular API, technology or configuration difference.  
Considering the producer is usually the slowest part of a message bridge, we are including the average time each producer takes as well as the pure number of messages moved from one vendor to another.

### JMS to JMS

Using the standard JMS 1.1 API to move 75,000.

#### WebsphereMQ to Solace

![AWS-Environment](./images/jms-performance/wmq-solace-jms-jms.png)

#### Solace to WebsphereMQ

![AWS-Environment](./images/jms-performance/solace-wmq-jms-jms.png)

#### Solace to ActiveMQ

![AWS-Environment](./images/jms-performance/solace-activemq.png)

#### ActiveMQ to Solace

![AWS-Environment](./images/jms-performance/activemq-solace.png)

### JMS / JCSMP

These tests use a combination of both JMS and the Solace native JCSMP API.

#### WebsphereMQ to Solace (JCSMP)

![AWS-Environment](./images/jms-performance/wmq-solace-jms-jcsmp.png)

#### Solace to Solace (JCSMP)

![AWS-Environment](./images/jms-performance/solace-solace-jcsmp.png)

### JMS 2.0 Asynchronous Producer

![AWS-Environment](./images/jms-performance/solace-wmq-jms-async.png)

### JMS + XA

These tests all use the standard JMS 1.1 API but also include XA transaction handling.

#### Solace to WebsphereMQ and the reverse

This test has an "ack window" of 250.  The left side shows Solace to WebsphereMQ, the right side is the reverse.

![AWS-Environment](./images/jms-performance/xa-solace-wmq-reverse.png)

#### Solace to WebsphereMQ

This test has a smaller "ack window" of 10.

![AWS-Environment](./images/jms-performance/xa-solace-wmq-reverse-10-ack.png)

#### WebsphereMQ to Solace

This test has a smaller "ack window" of 10.

![AWS-Environment](./images/jms-performance/xa-wmq-solace-10-ack.png)



