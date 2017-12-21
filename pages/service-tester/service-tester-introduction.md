---
title: Service Tester - Introduction
keywords: interlok
tags: [service-tester]
sidebar: home_sidebar
permalink: service-tester-introduction.html
---
## Overview ##

Interlok service tester is testing framework that allows you to unit test Interlok configuration.

The aim is to remove the need to have working consumers and producers but still be able to test the logic within Interlok configuration, such as branching and mappings.

The output of the execution has also been designed to drop into existing continuous integration cycles.

## Installation ##

The interlok-service-tester libraries are not shipped by default as part of the traditional installer.  You will need to download the `com.adaptris:interlok-service-tester` artifact; download it directly from our [public repository][] or use [Ant+Ivy](advanced-ant-ivy-deploy.html) to deploy.

## Execution ##

There are many ways to execute the service tester, the simplest way is to run your service test config via `interlok-boot`:

```
C:\Adaptris\Interlok>java -jar lib\interlok-boot.jar -serviceTest config\service-test.xml
WARN  [main] [Adapter] [Adapter] has a MessageErrorHandler with no behaviour; messages may be discarded upon exception
INFO  [main] [Adapter] Adapter Initialised
INFO  [main] [Adapter] Adapter Started
INFO  [main] [Test] Running [TestList.Test1]
INFO  [main] [Test] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.019 sec
INFO  [main] [Adapter] stopping adapter [e05d61a7-af13-498b-a669-0b34558afd47] if there are polling loops configured this may take some time
INFO  [main] [Adapter] Adapter Stopped
INFO  [main] [Adapter] Adapter Closed
```

## Arguments ##

The following arguments are available to customise service tester execution:

| Argument                   | Description                                                           |
|----------------------------|-----------------------------------------------------------------------|
| `-serviceTest`             | Test configuration location                                           |
| `-serviceTestOutput`       | Output directory for test results (default: `./test-results`)         |
| `-serviceTestPreProcessor` | Pre-processors to execute against test configuration (ex: `xinclude`) |

[public repository]: https://development.adaptris.net/nexus/service/local/artifact/maven/redirect?r=releases&g=com.adaptris&a=interlok-service-tester&v=LATEST