---
title: Dashboard
keywords: interlok
tags: [getting_started, ui]
sidebar: home_sidebar
permalink: ui-dashboard.html
summary: The Dashboard Page is the first page a user is directed to after a successful login action. You can also navigate to this page using the Dashboard menu item in the navigation bar.
---

After an initial login, the Dashboard page will show you the auto-discovered local Adapter component.

A typical dashboard page with a single Adapter registered to it. In this example, the Adapter was auto-detected:
![The Dashboard Page](./images/ui-user-guide/dashboard-page-no-errors.png)

## The Adapter Area ##

The Dashboard Page with annotations shows the various parts of the Dashboard Page:
![The Dashboard Page with annotations](./images/ui-user-guide/dashboard-page-no-errors-with-annotations.png)

- A. This is the registered Adapter Component, there would be one of these areas displayed per registered Adapter;
- B. The Adapter Status, which is represented by:


> | Icon | Description | Meaning |
> |----|----|----|
> |![Dashboard Status Closed](./images/ui-user-guide/dashboard-status-closed.png) | orange banned signal  | the Adapter is closed |
> |![Dashboard Status Stopped](./images/ui-user-guide/dashboard-status-stopped.png) | orange no entry signal | the Adapter has stopped |
> |![Dashboard Status Error](./images/ui-user-guide/dashboard-status-error.png) | red cross | an error occurred |
> |![Dashboard Status Initialised](./images/ui-user-guide/dashboard-status-inialised.png) | black circle | the Adapter has the initialised status |
> |![Dashboard Status Disconnected](./images/ui-user-guide/dashboard-status-disconnected.png) | unlinked blue icon | disconnected (unreachable) |

- C. The current Heap Memory for this Adapter indicated by a gauge; (Since 3.3)
- D. The number of started channels is indicated by a gauge;
- E. The number of failed messages is indicated by a number on a red badge. If the number is 0 the badge will be green. You can click on this block to get the list of failed messages;
- F. The number of in flight messages (message being processed) for the Adapter. (Since 3.3)
- G. This indicates the Adapters last started time and up time if the Adapter is started or the last stopped time and down time if the Adapter has stopped;
- H. This would be the name of the Adapter;
- I. That Adapters JMX Service URL;
- J. The Show Channels checkbox feature will display a list of Channel components with further channel related information;
- K. This is the Adapter Control Bar, which contains various functions that can be performed on the Adapter:

> Button | Meaning
> ------------ | -------------
> ![Dashboard Adapter Control Info](./images/ui-user-guide/dashboard-adapter-control-info.png) | Show the Adapter Information (Version, Java and OS)
> ![Dashboard Adapter Control Show Config](./images/ui-user-guide/dashboard-adapter-control-config.png) | Show the Adapter configuration (xml and diagram)
> ![Dashboard Adapter Control Edit Config](./images/ui-user-guide/dashboard-adapter-control-edit-config.png) | Edit the Adapter configuration (in the config page)
> ![Dashboard Adapter Control Garbage Collect](./images/ui-user-guide/gc-button-icon.png) | Request a Java Garbage Collection on the Adapter
> ![Dashboard Adapter Control Thread Dump](./images/ui-user-guide/dashboard-adapter-control-thread-dump.png) | Generate a thread dump on the Adapter
> ![Dashboard Adapter Control Start](./images/ui-user-guide/dashboard-adapter-control-start.png) | Start the Adapter
> ![Dashboard Adapter Control Pause](./images/ui-user-guide/dashboard-adapter-control-pause.png) | Pause this Adapter from processing messages and allow it to retain any connections it has already initialised
> ![Dashboard Adapter Control Stop](./images/ui-user-guide/dashboard-adapter-control-stop.png) | Stop this Adapter and free up any resources that it has used
> ![Dashboard Adapter Control Force Stop](./images/ui-user-guide/dashboard-adapter-control-force-stop.png) | Under the Stop dropdown. Force Stop this Adapter (doesn't wait for services to finish) and free up any resources that it has used.
> ![Dashboard Adapter Control Reload From Vcs](./images/ui-user-guide/dashboard-adapter-control-reload-from-vcs.png) | Under the Stop dropdown. Reload this Adapter configuration from Vcs and restart it. Only available for User and Admin users and if [version control](advanced-version-control.html#version-control-configuration) is configured for this Adapter. (Since 3.3)
> ![Dashboard Adapter Control Support Pack](./images/ui-user-guide/dashboard-adapter-control-support-pack.png) | Under the Stop dropdown. Download a support pack containing log files and information about this Adapter. (Since 3.3)
> ![Dashboard Adapter Control Refresh](./images/ui-user-guide/dashboard-adapter-control-refresh.png) | Refresh the Adapter status and details
> ![Dashboard Adapter Control Remove](./images/ui-user-guide/dashboard-adapter-control-remove.png) | Remove the Adapter from the dashboard page

- L. This area is for 'top level' functions, i.e. Add another Adapter to the UI or Refresh all the details on the Dashboard Page for all the Registered Adapters.

> __NOTE__ :
> All the data shown on the Dashboard Page is automatically refreshed, so there is no need to manually refresh the page, or use the refresh buttons

## The Channel Area ##

Ticking the Show Channels checkbox in the Adapter control bar will expand the Adapter area and show a list of its Channel components.

Dashboard Page with the Show Channels selector highlighted in pink:
![Dashboard Page with the Show Channels selector highlighted in pink](./images/ui-user-guide/dashboard-page-show-channels-highlighted.png)

The Dashboard Pages Adapter area with expanded channels showing:
![The Dashboard Pages Adapter area with expanded channels showing](./images/ui-user-guide/dashboard-page-with-expanded-channel.png)

The Dashboard Pages Adapter area with expanded channels showing with annotations:
![The Dashboard Pages Adapter area with expanded channels showing](./images/ui-user-guide/dashboard-page-with-expanded-channel-with-annotations.png)

- A. Channel component
- B. Name: The Channel unique Id used in the adapter configuration.
- C. Up/Down Time: This indicate the Channel up time if the Channel is started or the down time if the Channel is stopped.
- D. Failed Messages: The number of failed messages is indicated by a red number next to a red envelope. If the number is 0 the envelope will be grey and the number green.
- E. In flight messages: The number of in flight messages (message being processed) for this Channel. (Since 3.3)
- F. The Show Workflow Control: Allows a user to view the selected channels workflows
- G. The control bar: Allows a user to perform several actions on the Channel, such as start, stop and refresh status

> Button | Meaning
> ------------ | -------------
> ![Dashboard Channel Control Start](./images/ui-user-guide/dashboard-adapter-control-start.png) | Start the Channel
> ![Dashboard Channel Control Pause](./images/ui-user-guide/dashboard-adapter-control-pause.png) | Pause this Channel from processing messages and allow it to retain any connections it has already initialised
> ![Dashboard Channel Control Stop](./images/ui-user-guide/dashboard-adapter-control-stop.png) | Stop this Channel and free up any resources that it has used
> ![Dashboard Channel Control Refresh](./images/ui-user-guide/dashboard-adapter-control-refresh.png) | Refresh the Channel status and details

- H. Status: The status is represented by:

> Icon | Desc. | Meaning
> ------------ | ------------- | ------------
> ![Dashboard Status Channel Started](./images/ui-user-guide/dashboard-status-started.png) | green tick   | the Channel is started
> ![Dashboard Status Channel Closed](./images/ui-user-guide/dashboard-status-closed.png) | orange banned signal  | the Channel is closed
> ![Dashboard Status Channel Stopped](./images/ui-user-guide/dashboard-status-stopped.png) | orange no entry signal | the Channel has stopped
> ![Dashboard Status Channel Error](./images/ui-user-guide/dashboard-status-error.png) | red cross | an error occurred
> ![Dashboard Status Channel Initialised](./images/ui-user-guide/dashboard-status-inialised.png) | black circle | the Channel has the initialised status


## The Workflow Area ##

Ticking the Show Workflows checkbox in the Channel control bar will expand the area and show a list of its Workflow components.

The Dashboard Page with Workflows expanded:
![Dashboard Page with Workflows expanded](./images/ui-user-guide/dashboard-page-with-expanded-workflows.png)

A Channel areas expanded Workflow area:
![Dashboard Page with the Show Workflows selector selected](./images/ui-user-guide/dashboard-channel-component-show-workflows.png)

The Workflow component is split in five parts:

- Name: The Workflow unique Id used in the adapter configuration.
- Last Started/Stopped: The Workflow last started time is indicated if the Workflow is started otherwise the last stopped time is indicated it the Workflow is stopped.
- Up/Down Time: This indicate the Workflow up time if the Workflow is started or the down time if the Workflow is stopped.
- Failed Messages: The number of failed messages is indicated by a red number next to a red envelope. If the number is 0 the envelope will be grey and the number green.
- In flight messages: The number of in flight messages (message being processed) for this Workflow. (Since 3.3)
- The control bar: Allows a user to perform several actions on the Workflow.

> Button | Meaning
> ------------ | -------------
> ![Dashboard Workflow Control Start](./images/ui-user-guide/dashboard-workflow-control-start.png) | Start the Workflow
> ![Dashboard Workflow Control Pause](./images/ui-user-guide/dashboard-workflow-control-pause.png) | Pause this Workflow from processing messages and allow it to retain any connections it has already initialised
> ![Dashboard Workflow Control Stop](./images/ui-user-guide/dashboard-workflow-control-stop.png) | Stop this Workflow and free up any resources that it has used
> ![Dashboard Workflow Control Refresh](./images/ui-user-guide/dashboard-workflow-control-refresh.png) | Refresh the Workflow status and details
> ![Dashboard Workflow Control Show Services](./images/ui-user-guide/dashboard-workflow-control-toggle.png) | Toggle the list of the Workflow Services

- Status: The status is represented by:

> Icon | Desc. | Meaning
> ------------ | ------------- | ------------
> ![Dashboard Status Workflow Started](./images/ui-user-guide/dashboard-status-started.png) | green tick   | the Workflow is started
> ![Dashboard Status Workflow Closed](./images/ui-user-guide/dashboard-status-closed.png) | orange banned signal  | the Workflow is closed
> ![Dashboard Status Workflow Stopped](./images/ui-user-guide/dashboard-status-stopped.png) | orange no entry signal | the Workflow has stopped
> ![Dashboard Status Workflow Error](./images/ui-user-guide/dashboard-status-error.png) | red cross | an error occurred
> ![Dashboard Status Workflow Initialised](./images/ui-user-guide/dashboard-status-inialised.png) | black circle | the Workflow has the initialised status

## The Dashboard on Smaller Screens ##

As with all the pages in the Interlok UI, on smaller screens, such as a tablet, the page will display slightly differently, to make best use of the smaller size constraints.

Examples follow:

Dashboard Page shown on a small screen:

![Dashboard Page shown on a small screen](./images/ui-user-guide/dashboard-page-small.png)

Dashboard Page shown on a smaller screen:

![Dashboard Page shown on a smaller screen](./images/ui-user-guide/dashboard-page-smaller.png)

> __NOTE__ :
> Although pages will look different on smaller screens, most (if not all) of the pages features are still present, but they may be grouped into button drop down selects, or they may be missing their text labels. One feature that's noticeably absent from smaller screens is the Configuration Page, as it's features would be too difficult to use on a phone sized screen.

## The Dashboard Show Config Feature ##

On the Dashboard page, clicking on the Adapters 'Show Config' button will open a modal window containing the Adapter configuration. This is presented in two different formats, XML and Diagram modes; The XML mode is a read-only display of the Adapter configuration in a formatted XML display. The Diagram mode is a visual representation of the Adapter configuration.

Dashboard Page with the show Config button highlighted in pink:
![Dashboard Page with the show Config button highlighted in pink](./images/ui-user-guide/dashboard-page-show-config.png)

After pressing the Show Config button, the Config modal window will appear.

Dashboard Page with the Adapter Config modal showing on the XML view:
![Dashboard Page with the Adapter Config modal showing on the XML view](./images/ui-user-guide/dashboard-config-modal-xml.png)

Shown above is the view that appears after pressing the Show Config button, the Config modal window will appear and the XML view will be shown as default. In this view users are able to collapse and expand XML elements. This is a read only view of the XML config, and any changes made here would not be applied to that Adapter.

Using the diagram button on the top of the config modal will present the user with visual representation of the Adapter configuration.

Dashboard Page with the Adapter Config modal showing on the Diagram view:
![Dashboard Page with the Adapter Config modal showing on the Diagram view](./images/ui-user-guide/dashboard-config-modal-diagram.png)

On the visual representation of the Adapter configuration, the following options available:

- Zoom into the generated diagram
- Zoom out of the generated diagram
- Present a downloadable version of the diagram. This function will open a new window with the full image that the user can save locally.
- The mouse wheel can also be used to zoom in and out of the diagram
- The mouse left button can be clicked and held to allow users to navigate around the zoomed in diagram.

> __NOTE__ :
> This generated diagram represents a simplified Adapter config in a waterfall type manner. The top left corner box represents the Adapter, its children boxes represent the channels and their children represent the workflows. The workflows have been extended using a dashed area to show the consumers, services and producers.

> __ ALSO__ :
> Not every component is shown in this simplified diagram, notable absentees include Workflow Interceptors and Service Collections within a Workflows Service List.

## The Dashboard Failed Message List ##

On the Dashboard Page, if any of the registered Adapters have failed messages, then a disposable alert is shown to warn the user.

Dashboard Page showing failed messages:
![Dashboard Page showing failed messages](./images/ui-user-guide/dashboard-page-with-failed-messages.png)

> __NOTE__ :
> The badge icon on the Failed Messages section of the Adapter area will give a real time count of the amount of failed messages.
>
> In order to get the number of failed message working a 'Standard Message Error Digester' will need to be added to the adapter configuration.

Clicking on the Failed Messages details block will open the Failed Messages modal window containing the last hundred failed messages.

Dashboard Page with the clickable Failed Messages area highlighted in pink:
![Dashboard Page with the clickable Failed Messages area highlighted in pink](./images/ui-user-guide/dashboard-page-failed-messages-area-highlighted.png)

The Dashboard Pages Failed Messages modal window:

![The Dashboard Pages Failed Messages modal window](./images/ui-user-guide/dashboard-page-failed-message-modal.png)


The above image shows a typical Failed Messages modal window page with a handful of failed messages.

The Dashboard Pages Failed Messages modal window with annotations:

![The Dashboard Pages Failed Messages modal window with annotations](./images/ui-user-guide/dashboard-page-failed-message-modal-with-annotations.png)

The above image shows the various parts of the Failed Messages modal window:

- A. This is a summary of a failed message, detailing the message id, the workflow id of where the message failed, the date of the failure and any error messages that were generated upon the failure of the message;
- B. This is the failed message control functions:
    - Retry the failed message.
    - Ignore the failed message; this will remove the message from the UI failed messages list, without retrying it.
	- Create a support pack; this will create and download a zip file with some information about the adapter and the failing message. (Since 3.3)
	- Show more information; this will display the full stack trace of the failing message and the logs traced at the time the message failed. (Since 3.3)
- C. This is the Search Failed Message List feature that includes a free text input, whose value will be used to filter the failed message list. The buttons alongside this input are for clearing the filter, executing the search and selecting the date range respectively;
- D. These commands operate in the same fashion as those in the failed message control functions (detailed in point B), but these operations relate to all the messages displayed in the failed message list (i.e. if you are using the search filter, the actions will only be applied to the displayed messages);
- E. This button can be used to Failed Message modal window.

## Add Adapters To The Dashboard ##

If the local Adapter is not shown (e.g. previously removed) or if a user wishes to monitor another Adapter, the Add Container button of the Dashboard page can be used.

Dashboard Page with the Add Adapter button highlighted in pink:
![Dashboard Page with the Add Adapter button highlighted in pink](./images/ui-user-guide/dashboard-page-add-adapter-highlighted.png)

Clicking on the Add Container button will open the Add Adapter modal window which contains a form that allows you to register an Adapter to the UI.

The Dashboard Pages Add Adapter modal window:

![The Dashboard Pages Add Adapter modal window](./images/ui-user-guide/dashboard-page-add-adapter.png)

The Dashboard Pages Add Adapter modal window with expanded advanced options:

![The Dashboard Pages Add Adapter modal window with expanded advanced options](./images/ui-user-guide/dashboard-page-add-adapter-advanced-options.png)

The Add Adapter form inputs explained:

- **Name:** This property is for display purposes and also an easy way to differentiate Adapters registered within the UI web application.
- **Adapter Unique Id:** This is the Adapter unique identifier used in the Adapter configuration XML file: `<adapter><unique-id>adapterUid</unique-id</adapter>`. This is required for the UI to establish the JMX connection to the Adapter.
- **URL:** The JMX URL used to connect to the Adapter, for example: service:jmx:jmxmp://localhost:5555
- **Advanced Options** - Clicking the Advanced Options link will unveil three more properties, all of which are optional :
    - **Username:** The username needed to establish the JMX connection if you are using password protection for the adapter JMX connection as describe in [Password Protecting JMXMP](../advanced/jmx/index.html#password-protecting-jmxmp-311) (Since 3.1.1)
    - **Password:** The password needed to establish the JMX connection if you are using password protection for the adapter JMX connection as describe in [Password Protecting JMXMP](../advanced/jmx/index.html#password-protecting-jmxmp-311) (Since 3.1.1)
    - **Environment:** Some environment properties needed for the JMX connection. These should be provided as a key value pair list (multiple pairs should be on separated lines), for example: javax.net.ssl.trustStore=/tmp/myStrustsore

Adding more than one Adapter will result in having a list of Adapter components listed on the Dashboard Page.

The Dashboard Page with multiple registered Adapter instances:
![The Dashboard Page with multiple registered Adapter instances](./images/ui-user-guide/dashboard-page-with-2-adapters.png)

On two widgets per row mode:
![The Dashboard Page with multiple registered Adapter instances](./images/ui-user-guide/dashboard-page-with-2-adapters-small.png)
