---
title: Servicing HTTP requests.
keywords: interlok http
tags: [cookbook, http, messaging]
sidebar: home_sidebar
permalink: cookbook-http-server.html
summary: Interlok comes bundled with an HTTP server (based on jetty) which can be used to as an entrypoint into a workflow.
---

One of the more common integration scenarios that we encounter is to use Interlok as an API gateway; whether it is to overlay caching or authentication on an existing API, or to handle API calls itself. Interlok comes bundled with Jetty which is used to serve the UI and can used as entrypoint into a workflow. The connection for any HTTP based workflow should be one of [jetty-embedded-connection][], [jetty-http-connection][], or [jetty-https-connection][]. [jetty-embedded-connection][] makes use of the [jetty management component](adapter-bootstrap.html#management-components) if you have enabled it. If you aren't using the this management component then you should use one of the other connection types which will allow you to configure specific embedded jetty instances on a per-connection basis. Using [jetty-embedded-connection][] will allow you the greatest flexibility in terms of configuration as you have full access to the `jetty.xml` configuration file.

{% include note.html content="Sometimes, for whatever reason, you don't want to use Jetty (if you _really can't_, then you're running Interlok using Java 7 and need to ask yourself _WHY?_). In this case you have access to  [interlok-legacyhttp][] which fulfils this niche. It depends on the built in JRE/Sun HTTP Server implementation and isn't as configurable as the jetty instance." %}

There is currently only a single message consumer type: [jetty-message-consumer][]. The destination for the consumer should match the URI endpoint that you wish to listen on (e.g. /path/to/my/api); wildcards are supported and will be dependent on the servlet implementation of the underlying jetty instance. Parameters from the URI can be stored as metadata (or object metadata) with an optional prefix, as can any HTTP transport headers.

There are a number of supporting components that make will help you configure a workflow that provides the behaviour you need.

## Access Control

### JettyLoginServiceFactory

This component allows you to plugin an `LoginService` implementation that ca restrict access specific URLs. The only implementation is [jetty-hash-login-service][] which creates the standard Jetty `HashLoginService` that is an implementation of a UserRealm that stores users and roles in-memory via a HashMap. This only protects a given URL on a username/password basis (as opposed to checking other HTTP transport headers or similar).

### VerifyIdentityService

[verify-identity-service] is a service based implementation that is not dissimilar in scope to [jetty-hash-login-service][]. It allows you to allow/deny access based on the payload content and associated metadata (which may have been derived from URI parameters or HTTP transport headers). It is generally more flexible that [jetty-hash-login-service][] as you are within a workflow, so the full power of Interlok is at your disposal. In a rather contrived example we can unpick the standard HTTP transport header `Authorization: Basic base64(username:password)` and cross reference that against a user in an arbitrary database. Ultimately, [verify-identity-service][] simply checks that the associated metadata keys match each other (i.e. the value associated with `requestUser` must match `db_user`, ditto `requestPassword` + `db_password`).

```xml
<copy-metadata-service>
  <metadata-keys>
    <key-value-pair>
      <key>Authorization</key>
      <value>__DecodedAuth</value>
    </key-value-pair>
  </metadata-keys>
</copy-metadata-service>
<replace-metadata-value>
  <metadata-key-regexp>__DecodedAuth</metadata-key-regexp>
  <search-value>Basic\s+(.*)$</search-value>
  <replacement-value>$1</replacement-value>
</replace-metadata-value>
<metadata-base64-decode>
  <metadata-key-regexp>__DecodedAuth</metadata-key-regexp>
</metadata-base64-decode>
<copy-metadata-service>
  <metadata-keys>
    <key-value-pair>
      <key>__DecodedAuth</key>
      <value>requestUser</value>
    </key-value-pair>
    <key-value-pair>
      <key>__DecodedAuth</key>
      <value>requestPassword</value>
    </key-value-pair>
  </metadata-keys>
</copy-metadata-service>
<replace-metadata-value>
  <metadata-key-regexp>requestUser</metadata-key-regexp>
  <search-value>^(.*):.*$</search-value>
  <replacement-value>$1</replacement-value>
</replace-metadata-value>
<replace-metadata-value>
  <metadata-key-regexp>requestPassword</metadata-key-regexp>
  <search-value>^.*:(.*)$</search-value>
  <replacement-value>$1</replacement-value>
</replace-metadata-value>
<!-- Now we have the requestUser and requestPassword let's look up the user in the database
     Assume that db_user + db_password is populated by JdbcDataQueryService.
-->
<verify-identity-service>
  <unique-id>VerifyUsernamePassword</unique-id>
  <builder class="metadata-identity-builder">
    <metadata-key>requestUser</metadata-key>
    <metadata-key>requestPassword</metadata-key>
  </builder>
  <verifier class="simple-metadata-user-identity-verifier">
    <metadata-map>
      <key-value-pair>
        <key>requestUser</key>
        <value>db_user</value>
      </key-value-pair>
      <key-value-pair>
        <key>requestPassword</key>
        <value>db_password</value>
      </key-value-pair>
    </metadata-map>
  </verifier>
</verify-identity-service>
```

## JettyRoutingService

[jetty-routing-service][] allows you to listen on a wildcard URI, and based on the HTTP method / URI pattern, route messages within a [branching-service-collection][]. So, if we have a consumer that is configured to listen on `/contacts/*`. Based on the HTTP method, and the pattern, you need to have different behaviour, simulating a simplified CRUD api. The simplest way to visualize this is to have an example.

```xml
<branching-service-collection>
  <unique-id>HTTP Router</unique-id>
  <first-service-id>route</first-service-id>
  <services>
    <jetty-routing-service>
      <unique-id>route</unique-id>
      <route>
        <url-pattern>^/contacts$</url-pattern>
        <method>GET</method>
        <service-id>list</service-id>
      </route>
      <route>
        <url-pattern>^/contacts/(.*)$</url-pattern>
        <method>GET</method>
        <metadata-key>ContactId</metadata-key>
        <service-id>retrieve</service-id>
      </route>
      <route>
        <url-pattern>^/contacts/(.*)$</url-pattern>
        <method>DELETE</method>
        <metadata-key>ContactId</metadata-key>
        <service-id>delete</service-id>
      </route>
      <default-service-id>NotHandled</default-service-id>
    </jetty-routing-service>
    <service-list>
       <unique-id>list</unique-id>
       ...
    </service-list>
    <service-list>
       <unique-id>retrieve</unique-id>
       ...
    </service-list>
    <service-list>
       <unique-id>delete</unique-id>
       ...
    </service-list>
    <service-list>
       <unique-id>NotHandled</unique-id>
       ...
    </service-list>
  </services>
</branching-service-collection>
```

* If the URI is `/contacts` and the method is `GET` then we branch to the _list_ service; which can then list all the contacts in the database.
* If the URI is `/contacts/12345` and the method is `GET` then we branch to the _retrieve_ service; which can retrieve the contact details. `ContactId` will contain `12345`
* If the URI is `/contacts/12345` and the method is `DELETE` then we branch to the _delete_ service; which can delete the contact where `ContactId=12345`
* If the URI doesn't match, then we branch to the _NotHandled_ service; which can just return a 404 or similar code.

## JettyResponseService / StandardResponseProducer

Both [jetty-standard-response-producer][] and [jetty-response-service][] perform the same function. The first is a producer (which can be wrapped by `StandaloneProducer` for insertion into a service list), and the second is just a service that abstracts that wrapping away from you (to avoid XML bloat, and to have cleaner UI representation). [jetty-response-service][] simply wraps [jetty-standard-response-producer][] under the covers, and supports the `%message{metadata-key}` syntax for content-type and http-status. [jetty-standard-response-producer][] has more configuration options.


[interlok-legacyhttp]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-legacyhttp/
[jetty-embedded-connection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/EmbeddedConnection.html
[jetty-http-connection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/HttpConnection.html
[jetty-https-connection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/HttpsConnection.html
[jetty-message-consumer]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/JettyMessageConsumer.html
[jetty-hash-login-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/HashLoginServiceFactory.html
[verify-identity-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/security/access/VerifyIdentityService.html
[branching-service-collection]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/BranchingServiceCollection.html
[jetty-routing-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/JettyRoutingService.html
[jetty-response-service]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/JettyResponseService.html
[jetty-standard-response-producer]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/http/jetty/StandardResponseProducer.html