---
title: Saved Config Projects
keywords: interlok
tags: [ui]
sidebar: home_sidebar
permalink: ui-saved-config-projects.html
toc: false
summary: The saved config projects list allows you to easily save and re-open adapter configuration projects.
---

## Getting Started ##

To navigate to the saved config projects modal, you use the Saved project button from the top navigation bar.

The config action bar:
![Config page with Saved Projects button showing](./images/ui-user-guide/config-saved-projects-button.png)

## Saved Config Projects Modal ##

You can manage a previously saved config project in the modal:

![Config page saved config projects modal](./images/ui-user-guide/config-saved-config-projects.png)

For each config you can do the following actions:

- **Open Config:** This will open the selected config project in the config page.
- **Apply Config:** This will directly apply the selected config project. If more than one adapter is configured in the webapp you will be prompted to select one.
- **Download Config:** Download your config project as a ZIP file. This ZIP file will contains the adapter.xml, any included X-Include files, any added variables.properties file and a config-project.json file.
- **Delete Config:** This will deleted permanently the config project from the webapp.
- **Select config to compare with:** This will open a new modal that shows the differences between the current config loaded in the page and the config from the selected config project.

You can also upload a config XML file or a config project ZIP file in the webapp using the upload button at the bottom of the modal.

## Save a Config Project ##

You can save the current config in the page using the 'Save Project' button in the config page action bar.
Clicking on the 'Save Project' button will prompt you for the name of the project. By default the Adapter unique id will be used.

![Config page save config project modal](./images/ui-user-guide/config-save-config-project.png)



