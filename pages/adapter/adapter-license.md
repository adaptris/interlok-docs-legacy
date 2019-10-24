---
title: Applying a License
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-license.html
---
The main Interlok runtime no longer needs a license; however some of the optional components may require a license which can be applied using the following method.

## Applying a license ##

If you have purchased an Interlok license, then you can get a license key from our support team. You will need to create a file `config/license.properties` with which contains single property. If you want to host the license key elsewhere, then you need to add a system property `adp.license.location=your location` to the startup parameters (or in bootstrap.properties) of Interlok

```
adp.license.key=<your license key here>
```

## License Types ##

There are generally 3 types of license `Basic`, `Standard`, and `Enterprise`.

The basic license allows you access to the core features of Interlok, and is suitable for simple deployments where you are using Interlok as a on/off ramp for a community. It does not allow you any complex workflow logic and restricts you to using [standard-workflow][] only.

The standard license includes everything in basic, and covers everything that is available in a base distribution (it does not cover everything in the `optional` directory).

The enterprise license unlocks everything.


[standard-workflow]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/StandardWorkflow.html