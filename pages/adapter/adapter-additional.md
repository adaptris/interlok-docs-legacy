---
title: Additional Resources
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-additional.html
summary: This page describes additional resources that might make for interesting reading.

---

The development and consultancy team blog about various interesting things that they've done with Interlok on [https://interlok.adaptris.net](https://interlok.adaptris.net).

## Docker images

All our releases are published as docker images on [docker hub][].

| Tag | Description
|----|----|
|snapshot| The snapshot build; built against the nightly release; based on the _openjdk:8-jdk_ docker image
|x.y.z | The formal x.y.z release as per the tag on [github][]; based on the _openjdk:8-jdk_ docker image
|snapshot-alpine| The snapshot build; built against the nightly release; based on the _openjdk:8-jdk-alpine_ docker image
|x.y.z-alpine | The formal x.y.z release as per the tag on [github][]; based on the _openjdk:8-jdk-alpine_ docker image
|snapshot-hpcc| The snapshot build; built against the nightly release; installs and runs `dfuplus` from [hpccsystems][] as well as interlok; based on the _centos:7_ image with [https://github.com/Yelp/dumb-init](https://github.com/Yelp/dumb-init)
|x.y.z-hpcc| The formal x.y.z release as per the tag on [github][]; installs and runs `dfuplus` from [hpccsystems][] as well as interlok; based on the _centos:7_ image with [https://github.com/Yelp/dumb-init](https://github.com/Yelp/dumb-init)

## Github projects

There are also some projects on github that showcase various configurations and shows what you can do with Interlok.

| Github project | Description
|----|----|
| [Interlok install builder][] | Building a local installation of interlok with optional dependencies |
| [Interlok hello world][] | An example hello world listener that is also auto-deployed onto Heroku |
| [Interlok soiltype demo][] | A caching interlok instance around [http://rest.soilgrids.org](http://rest.soilgrids.org) giving you a soiltype for a give lat/lon combination |
| [Interlok soiltype demo auth][] | The same as [Interlok soiltype demo][] but with an HTTP authorization layer on top |
| [Interlok API demo][] | A simple example application that exposes a REST interface onto a contacts database |
| [Interlok Salesforce demo][] | Extension of [interlok API demo][]  that integrates with Salesforce to update contacts |
| [Interlok Jira MS Teams][] | Using Interlok as a webhook between Jira and Microsoft Teams (other chat applications are available) and is the configuration associated with [https://interlok.adaptris.net/blog/2018/05/10/jira-interlok-msteams.html](https://interlok.adaptris.net/blog/2018/05/10/jira-interlok-msteams.html)
| [Interlok Load Balanced][] | Running Interlok behind haproxy and is the configuration associated with [https://interlok.adaptris.net/blog/2017/08/31/interlok-docker-and-load-balancing.html](https://interlok.adaptris.net/blog/2017/08/31/interlok-docker-and-load-balancing.html)
| [Interlok failover][] | Docker based example of running Interlok in failover mode |
| [Interlok custom components][] | Example build files for when you need to write your own custom components |
| [Interlok Twilio SMS][] | Real world example of writing your own custom component |


[docker hub]: https://hub.docker.com/r/adaptris/interlok/
[github]: https://github.com/adaptris/interlok/tags
[hpccsystems]: https://hpccsystems.com/
[Interlok hello world]: https://github.com/adaptris-labs/interlok-hello-world
[Interlok soiltype demo]: https://github.com/adaptris-labs/interlok-soiltype-demo
[Interlok API demo]: https://github.com/adaptris-labs/interlok-api-demo
[Interlok Salesforce demo]: https://github.com/adaptris-labs/interlok-salesforce-demo
[Interlok soiltype demo auth]: https://github.com/adaptris-labs/interlok-soiltype-demo-auth
[Interlok Jira MS Teams]: https://github.com/adaptris-labs/interlok-jira-msteams
[Interlok Load Balanced]: https://github.com/mcwarman/interlok-load-balanced
[Interlok failover]: https://github.com/mcwarman/interlok-failover
[Interlok Twilio SMS]: https://github.com/adaptris-labs/interlok-twilio-sms
[Interlok install builder]: https://github.com/adaptris-labs/interlok-install-builder
[Interlok custom components]: https://github.com/adaptris/interlok-custom-component-example