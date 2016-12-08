---
title: Version Control Configuration
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-version-control.html
---

Since 3.0.2 Interlok will support configuration that is controlled by a version control systems automagically. Configuration files can be stored in VCS, checked out/updated prior to any management components / adapter instances starting up. The properties mentioned here are in addition to any properties that are normally defined in `bootstrap.properties`; so you will still need an `adapterConfigUrl=` in order to source the configuration file.

The default version control system is for Subversion via the [SVN Client Adapter from subclipse](http://subclipse.tigris.org) and JavaHL which wraps the core Subversion C API. Check the [version control with subversion](advanced-vcs-svn.html) document.

## Start-Up ##

When Interlok first initialises upon start-up it will search it's classpath looking for version control system libraries. If no libraries are found the log file will show the following INFO:

![No VCS Found](./images/vcs/NoVCSFound.png)

If a [VersionControlSystem][] is available then Interlok will attempt to use it and checkout/update files from VCS:

![VCS Found](./images/vcs/VCSFound.png)

If a version control system is place, then the following behaviour is injected before any unmarshalling / management component initialisation occurs.

- If the local working directory does not exist, then create the directory and then perform a clean checkout from your remote repository.
- If the local working directory exists, perform an update from the remote repository.
    - Only one checkout/update will be performed.  Therefore all configuration files you wish to version should be contained in one remote directory or sub-directory.


## What can be stored in version control ##

What you store in version control is really up to you. Only the `bootstrap.properties` file cannot be controlled via VCS; all other files used by Interlok can be version controlled. Typically you  would include files like (you're not not limited here);

- Base Interlok configuration
- Anything referenced by the base Interlok configuration
    - xinclude files, dynamic services lists.
- XSLT transforms
- Interlok schema
- Interlok variable substitution files
- Interlok license properties
- Interlok log4j configuration

Note that if no log4j configuration is available on first start-up (on the classpath), then logging functionality may be impaired until one becomes available as specified by the `log4j12Url` property.


[VersionControlSystem]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/management/vcs/VersionControlSystem.html