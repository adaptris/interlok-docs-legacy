---
title: User Preferences
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-user-preferences.html
---

The GUI web application allows to configure some user properties to change the way a user interact with the ui:

![User Preferences](./images/ui-user-guide/user-preferences.png)

The preferences are:

## Dashboard Page Preferences ##
 - Timeout (ms) for adapter command operations: The timeout for the adapter commands such as Start Adapter, Stop Adapter, Start Channel ... The default value is 120000 ms (2 mins).

## Configuration Page Preferences ##
 - Display names in the component title: Whether to display the component name in the component title or in the body. The default value is false.
 - Prettify names in the component title: The ui can display the component type and uid nicely (remove hyphen, underscore and split camel case uid). The default value is true.
 - Always attempt to load the active adapter (if only one exists): Decides when opening the config page if the application should automatically load the running adapter config or prompt the user for choices. The default value is true. (Since 3.2)
 - Disable the remove component confirm dialog: Before deleting components in the config page the application will prompt the user for confirmation. The prompt can be disabled, very useful when a lot of components need to be deleted. The default value is true. (Since 3.2)
 - Action Button Size: Change the display size of the icons in the config page. The default value is normal.

## Runtime Widget Page Preferences ##
 - Hide the last index plot on the charts: Whether or not charts should hide the last index. The default value is false.
 - Number of Widget per Row: The number of widget to display per row. In small screen the maximum number is 2 widgets per row and on very small screens only one widget will be displayed per row regardless which value has been selected. The default value is 1. (Since 3.2)
