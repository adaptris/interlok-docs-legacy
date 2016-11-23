---
title: Navigation
keywords: interlok
tags: [getting_started, ui]
sidebar: home_sidebar
permalink: ui-navigation.html
toc: false
---

Once logged in, a user will be redirected to the Dashboard page. The Navigation bar is available at the top of the page, and is part of the page header. Users can use the options on this bar to navigation to the various parts of the UI.

Navigation bar (with the Dashboard Page as the active page) :
![Navigation bar (with the Dashboard Page as the active page)](./images/ui-user-guide/navigation-bar.png)

Navigation Bar with the user options open (and with the Runtime Widgets Page as the active page):
![Navigation Bar with the user options open (and with the Runtime Widgets Page as the active page)](./images/ui-user-guide/navigation-bar-options-open.png)

> __NOTE__ :
> Shown in images above is the text 'Default Admin', this is actually the logged in users first name and last name. This example is using the default admin account.

Navigation features:

- The active page will be highlighted;
- The dashboard button navigates the page to the Dashboard Page;
- The widgets button takes the user to the Runtime Widgets Page;
- The widgets dropdown button will display 1 more option:
    - The Log Monitor button, which presents a page to monitor the registered adapters logs;
- The config button directs the user to the Configuration Page;
- The users button to the User Administration Page (Only available for admin users);
- The system preferences button navigates to the System Preferences Page (Only available for admin users);
- Clicking on the 'Default Admin' name will display 4 user options:
    - The Account button, which presents a page to allow the user to edit details about their user;
	- The User Preferences button opens a modal dialog to allow the user to edit some configurable preferences;
	- The Vcs Profiles button, which presents a page to allow the user to add, edit or delete Vcs profiles to use in the config page;
	- The Alert Admin button, which presents a page to allow the user to add, edit or delete application Alerts (Only available for Admin and User users);
    - The Logout button that will remove the current logged in users privileges and navigate them back to the Login Page.
- The alert indicator show the number of active alert messages. A click on it will display the active alerts;