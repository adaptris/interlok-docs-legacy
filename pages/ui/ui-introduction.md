---
title: Introduction to the UI
keywords: interlok
tags: [getting_started, ui]
sidebar: home_sidebar
permalink: ui-introduction.html
---
## Management Overview ##

The UI Dashboard page facilitates Interlok management. Listing all the registered Interlok containers Adapters (auto-discovered and manually added), it gives real-time updates about their status. The dashboard page also allows you to control (start/stop) the Interlok containers Adapters, Channels and Workflows. Other useful features include the failed message retry feature, the ability to quickly view the containers config, a java garbage collector request feature and much more.

## Monitoring Overview ##

The Runtime Widgets page allows you to configure UI widgets which allow you to monitor various statistics and logs for the Interlok containers Adapters, Channels and Workflows. Widgets include component summary details, message counts charts, failed message information, container platform details, memory data, message metrics, and many more that can be configured to meet your monitoring requirements.

## Configuration Overview ##

The Configuration page is an easy to use interface for creating or altering Interlok Adapter configuration. This tool allows components such as Channels, Workflows, and Services to be easily added, removed or modified. Components can also be templated to allow easy reuse of common configuration solutions and then finished configurations can be applied to any registered Interlok containers Adapters. Handy features include inline help, field validation, service testing, drag and drop service re-ordering, compare to previously saved configuration, and more can be used to help you develop rich solutions easily.

## Installation ##

The Interlok UI is installed by default when a new installation of the Adaptris Interlok is completed. The web application is reachable using any modern internet browser at http://localhost:8080/adapter-web-gui/. The Adaptris Interlok container will need to be started to be able to use the UI. If no Adapter instances are registered in the web application database the UI will auto-discover the local Adapter running inside the Interlok container.


### JMX Service URL ###

In order for the UI web application to be able to detect its local Adapter, the UI will have to know the JMX URL to use to connect to the Adapter. This is configured in the bootstrap.properties file (See Adapter documentation) with the property jmxserviceurl. The default value for a new install is service:jmx:jmxmp://localhost:5555

{% include tip.html content="The bootstrap.properties can normally be found in the 'config' directory of your Interlok install directory" %}

If you reconfigure the Interlok Adapter to use a different a different URL for its JMX services, then you will need to update the above setting in order to retain the auto-detect feature. Otherwise, you'll need to manually add your Adapter to the UI, which will be explained further on in this guide.

## Update ##

After an Interlok update if you are experiencing some weird behaviour in the UI please force refresh your browser cache with one of the following key combinations:

- Windows: Ctrl + F5
- Mac	/Apple: Apple + R or command + R
- Linux: F5

If this does not solve the issue try to clear the browser cache following the browser documentation.
