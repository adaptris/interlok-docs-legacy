---
title: Logging In
keywords: interlok
tags: [getting_started, ui]
sidebar: home_sidebar
permalink: ui-logging-in.html
toc: false
---
The UI is a secured web application and only allows authorised users to log in.

![Login Page](./images/ui-user-guide/login-page.png)

{% include note.html content="After installing the Interlok container, users are able to use the default admin account:<br/>Username: `admin`<br/>Password: `admin`" %}

{% include important.html content="You should change the password on the default account as soon as it's convenient to do so." %}

A non-authenticated user will always be redirected to the login page and will need to sign in with a valid username and password to access the UI. The user can log out of the UI at any time using the Logout menu item on the navigation bar

The default admin user account/password can be changed from admin/admin
to a user defined combination before the first start-up of Interlok by
setting the command line properties interlok.ui.admin.new.db.username
and interlok.ui.admin.new.db.password as such:

    -Dinterlok.ui.admin.new.db.username=superuser
    -Dinterlok.ui.admin.new.db.password=MySecretPassword
