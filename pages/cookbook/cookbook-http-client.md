---
title: Making HTTP Requests
keywords: interlok http
tags: [cookbook, http, messaging]
sidebar: home_sidebar
permalink: cookbook-http-client.html
summary: Interlok comes bundled with an HTTP client (based on the standard JRE HttpURLConnection) which can be used to interact with API interfaces or external systems.
---

One of the more common things that needs to happen is for Interlok to connect to various HTTP servers and get data to enrich the payload currently being processed or to produce the payload to a final HTTP(s) endpoint. This is achievable in two main ways, either as a producer at the end of a workflow, or as a service as part of your processing chain. Producers can always be wrapped within a `StandaloneProducer` or `StandaloneRequestor` instance so they can act as part of a service list. The behaviour of [standard-http-producer][] is fairly self-evident and shouldn't really need much in the way of documentation.

## StandardHttpProducer

This is the basic HTTP producer that allows you to specify the HTTP method, and optionally where any request data is derived from (payload or metadata) and where any response data goes to (payload or metadata). By default, if a non success HTTP status is received from the target HTTP server, then an exception is thrown. If you wish to interrogate the data returned by the server, then you can configure `ignore-server-response-code=true` which will give you the response data for subsequent processing. In all situations, the HTTP status will be stored under the metadata key `adphttpresponse`. Proxy server support can be configured via the standard [java networking properties][].

## HttpRequestService

Having to wrap [standard-http-producer][] inside a `StandaloneRequestor` is a bit of a pain; it gives us additional XML bloat, and doesn't render all that nicely in the UI. We introduced [http-request-service][] to allow us to short-cut that step. It provides simplified configuration and supports the `%message{metadata-key}` syntax for method, content type and URL. It will always throw an exception if a non-success (i.e < 200 & > 299) response code is received from the HTTP server, and always attempts to send the current payload if the method allows it (best practise suggests that `GET` shouldn't have data associated with it, but this can be overriden directly in [standard-http-producer][] if required.).

## HttpBranchingRequestService

You can always use [branching-service-enabler][] wrapping a [http-request-service][] to enable branching but that will only handle a binary _success_ or _failure_ use case (400-599 codes would be interpreted as failures). Using [http-branching-request-service][] gives you different options when handling various HTTP status codes. For instance, you could do something different when presented with a _404_ as opposed to a _403_. Selecting the next service-id is based on a list of `StatusEvaluator` instances; each is queried in turn and the next service-id selected on the first match.

| StatusEvaluator | Behaviour |
|----|----|
|[http-status-exact-match][] | Matches an exact HTTP status, e.g. 200, 400, 500 etc, so matching on 200 will not match 202 (Accepted) |
|[http-status-range-match][] | Matches a range of HTTP statuses, specify a lower and upper boundary (inclusive), e.g. `lower=200, higher=299` will match all _success_ codes. |

## OAUTH

The [get-oauth-token][] service allows pluggable behaviour to support requesting a bearer token from an OAUTH server; you can use this later as your authentation token when making an API request. Currently supported implementations are [Google Cloud][], [Microsoft Azure][], [Salesforce][] and a [generic OAUTH][] implementation that simply sends key value pairs. Each of those are optional components that may require additional dependencies and can be plugged into your configuration as the `access-token-builder` within [get-oauth-token][]. If successful, the token builder stores the token against the specified header (default is _Authorization_) so that you can use it as part of your authentication process (normally via an instance of `HttpURLConnectionAuthenticator`).

Generally speaking; you can handle the OAUTH bearer token using standard services; a combination of a `http-request-service` with JSON parsing/path will generally get you to the correct `Authorization` value (in fact this is all that the [Salesforce][] token builder does); using [get-oauth-token][] just abstracts away some of the manual configuration that you would need to do.

## Apache HTTP

{% include important.html content="in 3.8.0; adp-apache-http was renamed to interlok-apache-http" %}

Because the standard `HttpURLConnection` doesn't support the `PATCH` method (and may never) there is also the [interlok-apache-http][] optional package. This is based on the [Apache HTTP Components][] project which does support the `PATCH` method. It also offers you the capability of configuring a proxy server on a per-producer basis which can be useful in mixed environments. Configuration mirrors that of the standard http components as far as possible but with a different alias for Apache HTTP specific copmonents.


[interlok-apache-http]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-apache-http/
[Apache HTTP Components]: http://hc.apache.org/
[Salesforce]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-salesforce/
[Microsoft Azure]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-azure/
[generic OAUTH]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-generic/
[Google Cloud]: https://nexus.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-gcloud/
[get-oauth-token]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/http/oauth/GetOauthToken.html
[standard-http-producer]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/http/client/net/StandardHttpProducer.html
[http-request-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/http/client/net/HttpRequestService.html
[http-status-exact-match]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/http/client/ExactMatch.html
[http-status-range-match]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/http/client/RangeMatch.html
[java networking properties]: https://docs.oracle.com/javase/8/docs/api/java/net/doc-files/net-properties.html
[branching-service-enabler]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/services/BranchingServiceEnabler.html
[http-branching-request-service]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/http/client/net/BranchingHttpRequestService.html
