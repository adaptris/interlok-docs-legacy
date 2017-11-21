---
title: Config Page sidebar
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-config-sidebar.html
toc: false
summary: The Config Page sidebar allows you to drag and drop components into your adapter configuration.
---

## Getting Started ##

To open the config pages sidebar, you use the sidebar button which is next to the Apply Config button.

The Config page sidebar toggle button:

![Config page sidebar toggle button](./images/ui-user-guide/config-sidebar.png)

## Introduction sidebar ##

The introduction panel lists and explains the component types used in the UI Config page has links to Interlok doc and javadoc sites.

![Config page sidebar intro](./images/ui-user-guide/config-sidebar-intro.png)

## Components sidebar##

The components panel allows to add Interlok component in the Config page by dragging them and dropping them into the relevant area (Since 3.6.5).

The components are organised into three different categories:

  - **By Group:**
    - **Bookmarks:** The list of components bookmarked by a user. A component can be bookmarked by clicking on the start icon on its right side.
	A bookmark can be removed by clicking again on the selected star on its right side.
    - **Deprecated:** The list of deprecated component for the current version of the UI.
	It is advised to avoid using deprecated component as they may be removed in following releases.
    - **Popular:** List some popular components.
  - **By Tag:** You can select a tag in the dropdown and that will display all the components attached to this tag.
  A search bar is available when the list has more than ten components.
  - **By Type:** You can select a component type in the dropdown and that will display all the component and templates available in the UI for this type.
  A search bar is available when the list has more than ten components.


![Config page sidebar components](./images/ui-user-guide/config-sidebar-components.png)

## Clipboard sidebar##

The clipboard panel allows to add Interlok copied component in the Config page by dragging them and dropping them into the relevant area (Since 3.6.6).

The component are copied into the Clipboard by clicking on the **Copy** ![Config copy button](./images/ui-user-guide/config-copy-button.png) button on each of them or by using the **Copy to Clipboard** button the Salesforce config page.

The clipboard is a FIFO list (First in first out) and contains up to four components of each type and up to six service components.

{% include note.html content="Data from the Clipboard is stored in the browser session storage and will be cleared on log out or when the browser tab or window is closed." %}

![Config page sidebar clipboard](./images/ui-user-guide/config-sidebar-clipboard.png)

## Shortcuts sidebar ##

The shortcuts panel list few keyboard shortcuts that can be used in the Config page.

![Config page sidebar shortcuts](./images/ui-user-guide/config-sidebar-shortcuts.png)


