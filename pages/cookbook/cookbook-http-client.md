---
title: Making HTTP Requests
keywords: interlok
tags: [cookbook]
sidebar: home_sidebar
permalink: cookbook-http-client.html
summary: Interlok comes bundled with an HTTP client (based on the standard JRE HttpURLConnection) which can be used to interact with API interfaces or external systems.
---

One of the more common things that needs to happen is for Interlok to connect to various HTTP servers and get data to enrich the payload currently being processed or to produce the payload to a final HTTP(s) endpoint. This is achievable in two main ways, either as a producer at the end of a workflow, or as a service as part of your processing chain. Producers can always be wrapped within a `StandaloneProducer` or `StandaloneRequestor` instance so they can act as part of a service list. The behaviour of [standard-http-producer][] is fairly self-evident and shouldn't really need much in the way of documentation.

## StandardHttpProducer

This is the basic HTTP producer that allows you to specify a HTTP method, and optionally where any request data is derived from (payload or metadata) and where any response data goes to (payload or metadata). By default, if a non success HTTP status is received from the target HTTP server, then an exception is thrown. If you wish to interrogate the data returned by the server, then you can configure `ignore-server-response-code=true` which will give you the response data for subsequent processing. In all situations, the HTTP status will be stored under the metadata key `adphttpresponse`. Proxy server support can be configured via the standard [java networking properties][].

## HttpRequestService

[http-request-service][] allows us to short-cut having to wrap a [standard-http-producer][] inside a `StandaloneProducer` or similar. It provides simplified configuration and supports the `%message{metadata-key}` syntax for method, content type and URL. It will always throw an exception if a non-success (i.e < 200 & > 299) response code is received from the HTTP server, and always attempts to send the current payload if the method allows it (best practise suggests that `GET` shouldn't have data associated with it).

## HttpBranchingRequestService

You can always use [branching-service-enabler][] wrapping a [http-request-service][] to enable branching but that will only handle a binary _success_ or _failure_ use case. [http-branching-request-service][] gives you different options when handling various HTTP status codes. For instance, you could do something different when presented with a _404_ as opposed to a _403_. Selecting the next service-id is based on a list of `StatusEvaluator` instances; each is queried in turn and the next service-id selected on the first match.

| StatusEvaluator | Behaviour |
|----|----|
|[http-status-exact-match][] | Matches an exact HTTP status, e.g. 200, 400, 500 etc, so matching on 200 will not match 202 (Accepted) |
|[http-status-range-match][] | Matches a range of HTTP statuses, specify a lower and upper boundary (inclusive), e.g. `lower=200, higher=299` will match all _success_ codes. |

## OAUTH

[get-oauth-token][] is a service that allows for pluggable behaviour to support requesting a bearer token from an OAUTH server for you to use as your authentation token when making an API request. Currently supported implementations are [Google Cloud][], [Microsoft Azure][], and [Salesforce][]. Each of those are optional components that may require additional depdendencies and can be plugged into your configuration as a `access-token-builder` within [get-oauth-token][]. If successful, the token builder stores the token against the specified header (default is _Authorization_) so that you can use it as part of your authentication process (normally via an instance of `HttpURLConnectionAuthenticator`).

Generally speaking; you can handle the OAUTH bearer token using standard services; a combination of a `http-request-service` with JSON parsing/path will generally get you to the correct `Authorization` value (in fact this is all that the [Salesforce][] token builder does); using [get-oauth-token][] just abstracts away some of the manual configuration that you would need to do.

## Apache HTTP

Because the standard `HttpURLConnection` doesn't support the `PATCH` method (and may never) there is also the [adp-apache-http][] optional package. This is based on the [Apache HTTP Components][] project which does support the `PATCH` method. It also offers you the capability of configuring a proxy server on a per-producer basis which can be useful in mixed environments. Configuration mirrors that of the standard http components as far as possible but with a different alias for Apache HTTP specific copmonents.


[adp-apache-http]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-apache-http/
[Apache HTTP Components]: http://hc.apache.org/
[Salesforce]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-salesforce/
[Microsoft Azure]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-azure/
[Google Cloud]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-oauth-gcloud/
[get-oauth-token]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/oauth/GetOauthToken.html
[standard-http-producer]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/client/net/StandardHttpProducer.html
[http-request-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/client/net/HttpRequestService.html
[http-status-exact-match]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/client/ExactMatch.html
[http-status-range-match]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/client/RangeMatch.html
[java networking properties]: https://docs.oracle.com/javase/8/docs/api/java/net/doc-files/net-properties.html
[branching-service-enabler]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/BranchingServiceEnabler.html
