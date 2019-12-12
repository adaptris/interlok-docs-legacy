---
title: Profiler Monitor in the UI
keywords: interlok
tags: [ui, profiler]
sidebar: home_sidebar
permalink: ui-profiler-monitor.html
summary: Since 3.9.2 the gui has a page that allows you to monitor running adapters using the Interlok Profiler.
---

## Prerequisite ##

As of 3.9.2 the page is still a **beta feature** and therefore the connected user needs to have the user preference **Enable technical preview features** set to true in order to see the Monitor menu item.

{% include note.html content="Interlok will also need some specific jar files to get the profiler monitor page to work. Follow the information [here](developer-profiler.html#setting-up) to set up [Interlok Profiler](developer-profiler.html).<br>" %}

{% include note.html content="The difference with the guide will be that the <b>interlok-profiler.properties</b> file will need to have the following properties:<br><i>com.adaptris.monitor.agent.EventPropagator=JMX</i> instead of <i>com.adaptris.monitor.agent.EventPropagator=MULTICAST</i>" %}


## Getting Started ##

To access the Profiler Monitor page, you use the monitor button on the header navigation bar.

The header navigation bar:
 ![Navigation bar with profiler monitor selected](./images/ui-user-guide/profiler-monitor-header-navigation.png)


## Monitoring ##

Once you've selected an adapter and a channel to monitor a flow diagram will be displayed showing the worklows in the selected channel.
Each workflows displays its services with some near real time message processing information.

![Profiler monitor page](./images/ui-user-guide/profiler-monitor-page.png)

You can navigate into service lists just by clicking on them. To go back you need to use the breadcrumb above the diagram.

The Show Grap toggler above the diagram allows to show / hide a chart that will display the messages average taken per workflow in the selected metrics.
The plot will be added in the chart only if the UI receive data from the profiler (if there is activities in the workflow).

![Profiler monitor page with chart](./images/ui-user-guide/profiler-monitor-page-with-chart.png)

You can add up to five monitors using the "Add a Profiler Monitor" button. Each profiler can use different adapters and/or channels.


{% include note.html content="The profiler monitor page is a prototype and may change substantially in the next releases. It also has several known issues." %}