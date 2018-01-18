---
title: Servicing HTTP requests.
keywords: interlok http
tags: [cookbook, http, messaging]
sidebar: home_sidebar
permalink: cookbook-http-server.html
summary: Interlok comes bundled with an HTTP server (based on jetty) which can be used to as an entrypoint into a workflow.
---

One of the more common integration scenarios that we encounter is to use Interlok as an API gateway; whether it is to overlay caching or authentication on an existing API, or to handle API calls itself. Interlok comes bundled with Jetty which is used to serve the UI and can used as entrypoint into a workflow. The connection for any HTTP based workflow should be one of [jetty-embedded-connection][], [jetty-http-connection][], or [jetty-https-connection][]. As the name would suggest [jetty-embedded-connection][] makes use of the [jetty management component](adapter-bootstrap.html#management-components) if you have enabled it. If you aren't using the this management component then you should use one of the other connection types which will allow you to configure specific embedded jetty instances on a per-connection basis. Enabling the _jetty management component_ and using [jetty-embedded-connection][] will allow you the greatest flexibility in terms of configuration as you have full access to the `jetty.xml` configuration file.

{% include note.html content="Sometimes, for whatever reason, you don't want to use Jetty (if you _really can't_, then you're running Interlok using Java 7 and need to ask yourself _WHY?_). In this case you have access to  [interlok-legacyhttp][]. It depends on the built in JRE/Sun HTTP Server implementation but won't be as configurable as the jetty instance (and might be removed in later Java versions)." %}

There is currently only a single message consumer type: [jetty-message-consumer][]. The destination for the consumer should match the URI endpoint that you wish to listen on (e.g. /path/to/my/api); wildcards are supported and will be dependent on the servlet implementation of the underlying jetty instance. Parameters from the URI can be stored as metadata (or object metadata) with an optional prefix, as can any HTTP transport headers. If no [jetty-standard-response-producer][] or [jetty-response-service][] is configured as part of the workflow, then a standard HTTP OK response is sent back to the caller with no content.

{% include tip.html content="You can use [http-request-parameter-converter-service][] to convert _html form post_ payloads into metadata, if required." %}

There are a number of supporting components that make will help you configure a workflow that provides the behaviour you need.

## Single or multi-threaded processing

If you use a [standard-workflow][] then requests are processed sequentially in order that they are received (i.e. single-threaded); switch to using [pooling-workflow][] as required. Because [pooling-workflow][] uses an internal thread pool to process requests you will need to either explicitly configure a [jetty-pooling-workflow-interceptor][] on the workflow instance or uniquely identify both the channel and workflow (via their respective unique-ids); this means that the HTTP response is not written prematurely before the response is available.

{% include tip.html content="If you use a [pooling-workflow][] then you should name both the containing channel + workflow, or explicitly configure a [jetty-pooling-workflow-interceptor][] on the worklow." %}

## Access Control

### JettyLoginServiceFactory

This component allows you to plugin an `LoginService` implementation that can restrict access specific URLs. The only implementation is [jetty-hash-login-service][] which creates the standard Jetty `HashLoginService` that is an implementation of a UserRealm that stores users and roles in-memory via a HashMap (for instance using _realm.properties_ from the jetty distribution). This only protects a given URL on a username/password basis (as opposed to checking other HTTP transport headers or similar).

### VerifyIdentityService

The [verify-identity-service][] service is not dissimilar in scope to [jetty-hash-login-service][]; it provides access control to your workflow but happens within your workflow, not outside it. It allows you to allow/deny access based on the payload content and associated metadata (which may have been derived from URI parameters or HTTP transport headers). We consider it generally more flexible that [jetty-hash-login-service][] as you are within a workflow, so the full power of Interlok is at your disposal. In a rather contrived example we can unpick the standard HTTP transport header `Authorization: Basic base64(username:password)` and cross reference that against a user in an arbitrary database. Ultimately, [verify-identity-service][] simply checks that the associated metadata keys match each other (i.e. the value associated with `requestUser` must match that stored against `db_user`, ditto `requestPassword` + `db_password`).

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
     Assume that db_user + db_password is populated by JdbcDataQueryService as metadata.
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

The [jetty-routing-service][] (3.6.4+) service allows you to listen on a wildcard URI, and based on the HTTP method / URI pattern, route messages within a [branching-service-collection][]. So, if we have a consumer that is configured to listen on `/contacts/*`; based on the HTTP method, and the pattern, we want to have different behaviour, simulating a simplified CRUD api. This type of configuration is simplified using [jetty-routing-service][] which would previously have been possible using [embedded-scripting-service][] or similar.

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
* If the URI is `/contacts/12345` and the method is `GET` then we branch to the _retrieve_ service; which can retrieve the contact details. The metadata key `ContactId` will contain `12345`
* If the URI is `/contacts/12345` and the method is `DELETE` then we branch to the _delete_ service; which can delete the contact where `ContactId=12345`
* If the URI doesn't match, then we branch to the _NotHandled_ service; which can just return a 404 or similar code.

## JettyResponseService / StandardResponseProducer

Both [jetty-standard-response-producer][] and [jetty-response-service][] (3.6.5+) perform the same function. The first is a producer (which can be wrapped by `StandaloneProducer` for insertion into a service list), and the second is just a service that abstracts that wrapping away from you (to avoid XML bloat, and to have cleaner UI representation). Under the covers [jetty-response-service][] simply wraps [jetty-standard-response-producer][], and supports the `%message{metadata-key}` syntax for content-type and http-status. If you need full control over configuration then use [jetty-standard-response-producer][].


[interlok-legacyhttp]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/interlok-legacyhttp/
[jetty-embedded-connection]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/EmbeddedConnection.html
[jetty-http-connection]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/HttpConnection.html
[jetty-https-connection]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/HttpsConnection.html
[jetty-message-consumer]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/JettyMessageConsumer.html
[jetty-hash-login-service]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/HashLoginServiceFactory.html
[verify-identity-service]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/security/access/VerifyIdentityService.html
[branching-service-collection]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/BranchingServiceCollection.html
[jetty-routing-service]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/JettyRoutingService.html
[jetty-response-service]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/JettyResponseService.html
[jetty-standard-response-producer]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/StandardResponseProducer.html
[http-request-parameter-converter-service]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/RequestParameterConverterService.html
[embedded-scripting-service]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/services/EmbeddedScriptingService.html
[standard-workflow]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/StandardWorkflow.html
[pooling-workflow]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/PoolingWorkflow.html
[jetty-pooling-workflow-interceptor]: https://development.adaptris.net/javadocs/latest/Interlok-API/com/adaptris/core/http/jetty/JettyPoolingWorkflowInterceptor.html