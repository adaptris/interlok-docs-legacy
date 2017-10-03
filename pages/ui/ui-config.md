---
title: Configuration Screens
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-config.html
summary: The config page allows you to configure your Interlok container in an easy to use graphically way. Basically, it's a UI way of editing the adapter.xml that controls how the Interlok container behaves. Using this page, you can apply changes to your running container; you can add, edit and delete components such as consumers, producers, services, etc. The UI application will also validate your changes, show you inline help during your editing and allows you to insert components from pre-defined templates.
---

## Getting Started ##

To navigate to the config page, you use the config button from the top navigation bar.

The header navigation bar:
![Navigation bar with config selected](./images/ui-user-guide/config-top-navigation-bar.png)

The config page action:
![The navigation config button](./images/ui-user-guide/config-top-navigation-bar-config-action.png)

## Open/New Config ##

By default the config page will open the active Adapter if only one is configured in the application.

You can also open Adapter configurations from diverse sources.
Just click on the Open Config button and that will open a modal displaying several options.

![Config page action bar](./images/ui-user-guide/config-import-open.png)

- **Active Adapter:** Retrieve a configuration from a running Adapter configured in the application.
- **New:** Create a brand new Adapter configuration.
- **File System:** Open an Adapter configuration file from your file system. It can be an adapter.xml file or a zip file * (since 3.6.5). 
- **Saved Config:** Open an Adapter configuration from the list of previously [saved configurations](ui-saved-configs.html).
- **Auto Saved:** Open an Adapter configuration from the last auto saved configuration.
- **Use Template:** Create a new Adapter configuration from a template.
- **Swagger:** Open an Adapter configuration using a Swagger file from your file system. Simple rest service swagger configuration (yaml or json) get converted to an adapter config with http jetty consumers. (Since 3.5.0)
- **Version Control:** Retrieve a configuration from a Version Control System (Subversion or Git). For this option to be enabled [VCS](advanced-version-control.html) needs to be configured and you need at least one VCS Profile.
- **Import:** Import an Adapter configuration with variable properties.

{% include note.html content="* When using **File System:** with a zip file, the zip file need to be built with an adapter.xml in the zip root. Optionally a variables substitution file called _variables.properties_ can be added. An includes folder can also be added if the adapter.xml uses X-Includes, the folder name will have to be adapter-includes (_'nameOfAdapterXmlFile'_ + _'-includes'_) and contains all the X-Includes files." %}

## Navigating the config page ##

Consider the following example of a typical config page:

![Typical config page example](./images/ui-user-guide/config-page-with-everything-open.png)

In this example, the config page is made up of the following sections:

- Header actions
- Container bar
- Shared Components area
- Channel area
- Workflow area

### Header actions ###

![Config page action bar](./images/ui-user-guide/config-action-bar.png)

This action bar is concerned with the (whole) config actions, such as opening a saved config, uploading a config file from your own store, and creating a new config file.

### Container bar ###

![Config page container area](./images/ui-user-guide/config-container-bar.png)

This bar allows you to interact with the Interlok container; Select a channel; Add a channel; edit the container advanced options; edit the root settings for the Adapter object.

### Shared Components area ###

![Config page container area](./images/ui-user-guide/config-shared-components-area.png)

You can add a connection or a service into the shared connection or shared service area and this connection will automatically becomes a shared one.
You will be able to use shared components where appropriate by selecting it from the "Existing Shared Components" list.

![Select shared connection](./images/ui-user-guide/config-select-shared-connection.png)

![Select shared service](./images/ui-user-guide/config-select-shared-service.png)

### Advanced components area ###

![Config page advanced and shared area](./images/ui-user-guide/config-advanced-components.png)

By clicking on the toggle button in the container title bar you will reveal the advanced extensions area.

### Channel area ###

![Config page channel area](./images/ui-user-guide/config-channel-area.png)

This area covers all your channel interaction requirements, from here, you can edit the channel settings, add workflows, select a workflow, etc.

### Workflow area ###

![Config page workflow area](./images/ui-user-guide/config-workflow-area.png)

This area covers all your workflow interaction requirements, this area allows you to edit the workflow settings, add/edit/delete/re-order services etc.

## Component features ##

The following image shows an active component (a component that has the mouse hovering over it):
![Typical active component annotated](./images/ui-user-guide/component-explained.png)

This component is a typical example and shows:

- **Component type:** This example is a com.adaptris.core.NullConnection, so the component type is a 'Null Connection'.
- **Component type icon:** As this example is a connection, the connection icon is show.
- **Id:** This would display the contents of the 'Unique ID' setting for that component.
- **Edit:** Clicking this would display the settings editor for this component.
- **Replace:** Pressing this would perform a remove & add function, therefore allowing you to easily replace this component. In this example, pressing this would show the add connection modal window.
- **Remove:** Activating this function would remove the component from the configuration, i.e. deleting this connection.
- **Copy:** You can use this function to copy this component to the pages clipboard. You can hold 1 of each component type in the clipboard, which can then be used to Paste it to a given applicable area.
- **Cut:** As copy, but on a Paste command, this would remove the source component.


## Delete component features ##

To delete a given component, you would click on the trash can icon ![Config page delete component action button](./images/ui-user-guide/config-workflow-bar-action-delete.png){: .inline }  that's either in the header bar of that components area or if you hover over a given component it will present itself. Clicking on the trash can would therefore remove that component from the config.

## Add component features ##

To add a given component, you would click on the plus icon ![Config page add component action button](./images/ui-user-guide/dashboard-workflow-control-toggle.png){: .inline }, this will present itself when you hover over a list component, such as the  channel list, workflow list, service list, etc.

When adding a component, after clicking the plus icon, you'll be presented with the add component modal window.

Example of a typical add component modal window:

![Typical add component modal window](./images/ui-user-guide/config-page-add-component.png)

When the add component window opens, it always shows you the initial choice of 'folders', these are 'Raw components' or 'Templates'. As their name suggests, the 'Raw components' folder contains a list of available components for that list, and selecting a component from this folder will add a component to the list with default settings configuring within it. The 'Templates' folder contains components that you have previously saved, using the 'Save as template' feature on the settings editor. You'll notice that the window has a search input that can be used to filter components. This search can be used from the folder view (i.e. you don't have to click raw compoennts and then search).

Example of a typical add component modal window after opening the raw components folder:

![Typical add component modal window raw component contents](./images/ui-user-guide/config-add-component-raw.png)

Example of a typical add component modal window after opening the template components folder:

![Typical add component modal window template folder contents](./images/ui-user-guide/config-add-component-template.png)

Example of a typical add component modal window with results filtered using the search bar:

![Typical add component modal window showing filtering contents](./images/ui-user-guide/config-add-component-filtering.png)

{% include tip.html content="Searching from the root folder with show you results from both the raw components folder and the templates folder." %}

To actually add the component, all you have to do is click on the required compoent and it will add it to the list you selected and show you the settings editor for that new component.

{% include tip.html content="When adding a service if you double click on the plus button the service will be added at the beginning of the service list." %}

## Settings editor features ##

The settings editor is available when you want to edit a component. This is always available by clicking on the edit icon ![Config page edit component action button](./images/ui-user-guide/config-action-edit.png){: .inline }. This editor allows you to edit the settings on a given component.

Example of a typical settings editor:

![Typical edit component modal window](./images/ui-user-guide/config-edit-component.png)

You will notice that there is a input control per field for that given component.
Next to the field name, there is an info icon, which if you hover over this, that fields javadoc part with show. As well as the inline help, if you click on the info icon that’s in the settings editor header, this will open a new browser window with that component type javadoc.

As well as text inputs and radio inputs, there is also implementation selectors; the editor showing implementation selection:
![Typical edit component modal window](./images/ui-user-guide/config-edit-component-impl.png)

This will allow you to select a given implementation for that field, this is handy if you need to select an error handler type for example.

As well as string, number and boolean inputs, there are special inputs for SQL, XML, Script, etc, that allow better editting of those values.

Example of a typical settings editor with a script input:

![Typical edit component modal window with a script input](./images/ui-user-guide/config-edit-componet-custom.png){: .inline }

As well as allowing you to easily edit the values of a component, if you do want to switch to the advanced XML config mode, then you would press the XML icon in the editors header ![Config page edit component xml action button](./images/ui-user-guide/config-xml-editor.png).

Example of a typical settings editor in XML mode:

![typical settings editor in XML mode](./images/ui-user-guide/config-edit-component-xml.png)

The following image shows an annotated settings editor:

![Typical settings editor annotated](./images/ui-user-guide/config-settings-editor-explained.png)

This editor is a typical example and shows:

- **Full Java Class Name:** This is the full java package & class name of the component that is being edited.
- **Base/Root Settings:** Each component is made up of its settings and its inner components, so this 'tab' will show the root settings for this compoenent.
- **Inner Components:** There would typically be a 'tab' per inner component. This example shows that outside the root settings, we have connections, and a vender implentation.
- **Setting Name & Setting Input:** Each of the components settings (and inner components settings) will have a list of configurable fields, made up of the setting label and the setting value.
- **Javadoc popover trigger:** Hovering over this icon with your mouse will show that fields javadoc part.
- **Encode password:** This is a password only feature, but ticking this would encode that feilds value in the XML.
- **Expand input:** Each text input will have the option to expand the input from a single line to a text area (for multiple line input).
- **Change connection type:** This button allows you to switch the component type, for example if you had a FTP Connection, you could switch types to a JMS Connection (or any other connection). This feature will change the base type of the component and attempt to copy any matching field values.
- **Expand window:** Clicking this will toggle the settings editor window size.
- **Toggle Advanced View:** Switching on the advanced view shows all the fields for the given component including all those fields that can be safely left to their defaults.
- **Open side bar:** This button opens a side bar in the modal that will offer several options:
    - Help : Which supplies some basic information / links to help you edit the component
	- Test Compontent : Allows you to test the output of a component
	- Metadata Preview : This panel will list any metadata used by the selected Workflow 
	- Most Occurences : This is a list of values that have been used the most in the current config 
- **XML view and editor:** Switch to the advanced XML config mode
- **Save and close:** Save your changes and close the editor.
- **Create Template:** Create a template from this configured component, which will then be shown as a choice during the add component feature.

## Settings editor sidebar ##

Since 3.5.0, the config settings editor has a useful sidebar. Shown in this video:

<iframe width="560" height="315" src="https://www.youtube.com/embed/VGiSXpCHTTc" frameborder="0" allowfullscreen></iframe>


## Navigating service collections within components ##

In the follow example, a service contains its own service list which also contains its own service list:

![service collection selectors annotated](./images/ui-user-guide/config-service-list-selector.png)

These service lists wouldn't be shown in the settings editor. Instead they are selectable by clicking on the service collection selector icon on the component visible on hover (see above). This then brings up a service collection area which can be operated on in the same manner as the workflows service list area.

## Drag and Drop services ##

Services and service collections are the only components in the config page which can be drag and drop.

- Drag and drop in the same **service collections** will re-order the **service**.
- Drag and drop in a different **service collection** will move the **service** to a different **service collection**.
- Drag and drop from a **service collection** to the **shared service collection** will create a new **shared service** in the **shared components** and use this new **shared service** in the original **service collection**.
- Drag and drop from the **shared service collection** to any other **service collection** will a the **shared service** to the ***service collection**.
