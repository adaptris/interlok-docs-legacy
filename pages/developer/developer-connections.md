---
title: Writing your own Connection
keywords: interlok
sidebar: home_sidebar
tags: [developer]
permalink: developer-connections.html
---

Within the Interlok framework, an [AdaptrisConnection][] object tends to wrap any behaviour that is required to setup a persistent connection to an application; such as making a connection over a socket. There are other reasons that might cause you to think about writing an [AdaptrisConnection][]; you may want to retro-fit a resource-intensive component so that you can avoid each [AdaptrisMessageProducer][] or [AdaptrisMessageConsumer][] instance from maintaining its own instance.

Generally speaking, any [AdaptrisConnection][] implementation will simply be a wrapper around the underlying connection implementation. For cases like that, you need to extend [AdaptrisConnectionImp][] and implement the required methods the methods `initConnection()`, `startConnection()`, `stopConnection()`, `closeConnection()` with the appropriate functionality for the connection.

- Unless you intend for the class to be a proxy for all the methods on the underlying connection, then make the underlying connection class available for use by associated [AdaptrisMessageProducer][], [AdaptrisMessageConsumer][] and [Service][] implementations.
- If the connection is configured at the channel level or as a shared component; then multiple producers (or consumers) will use the same object instance. It is important to have a strategy to handle this if the underlying connection is not thread-safe.


## Example ##

Our target system has a Java API that exposes a ClientFactory object which has the following methods (details skipped):

```java
public class ClientFactory {
  public ClientConnection createConnection(String user, char[] password) throws IOException {
  }
  public void init() throws Exception {
  }
  public void destroy() {
  }
}
```


Our [AdaptrisConnection][] implementation would simply wrap the `ClientFactory` and expose `ClientConnection` to whichever component requires it.


```java
@XStreamAlias("my-client-connection")
public class MyClientConnection extends AdaptrisConnectionImp {

  private String user;
  private string password;
  private transient ClientFactory factory = null;
  public MyClientConnection() {
  }

  @Override
  protected void initConnection() throws CoreException {
    factory = new ClientFactory();
    try {
      factory.init();
    } catch (Exception e) {
     ExceptionHelper.rethrowCoreException(e);
    }
  }

  @Override
  protected void startConnection() throws CoreException {
  }

  @Override
  protected void stopConnection() {
  }

  @Override
  protected void closeConnection() {
    factory.destroy();
  }

  @Override
  public boolean isEnabled(License license) throws CoreException {
    return license.isEnabled(LicenseType.Enterprise);
  }

  public ClientConnection createConnection() throws IOException, PasswordException  {
    return factory.createConnection(getUser(), Password.decode(getPassword());
  }

  public void setUser(String s) {
    this.user=s;
  }
  public String getUser () {
    return user;
  }
  public void setPassword(String pw) {
    password = pw;
  }
  public String getPassword() {
    return this.password;
  }

```

So, the summary of what we did is as follows :

- We extended [com.adaptris.core.AdaptrisConnectionImp][AdaptrisConnectionImp] and implemented the required lifecycle methods, rather than implementing [AdaptrisConnection][] directly.

{% include note.html content="We could extend [AllowRetriesConnection][] if the `ClientFactory` allowed reconnection attempts." %}

- The `init()` method instantiates the factory that provides our connection. This assumes that the class in question is fairly heavyweight and should not be re-created each time we want a connection.
- When catching and re-throwing Exceptions we use [ExceptionHelper][] to wrap the exception if it needs it; throwing the exception will cause error handling to be triggered

- The `close()` method calls `destroy()` on ClientFactory to free resources.
- The start and stop methods are required but empty implementations.
- Public getter and setter methods are provided for the fields that are to be marshalled

{% include tip.html content="The public getters/setters are not required by the marshaller, but will be required by the UI." %}

- The `ClientFactory` member variable is marked as __transient__ so that XStream does not attempt to marshal it.
- We use [com.adaptris.security.password.Password][Password] to decode the password; discussed in [Password Handling](advanced-password-handling.html)
- An `@XStreamAlias` is added so that we have an alias that we can configure; so now, configuration is `<consume-connection class="my-client-connection">` rather than the fully qualified classname.



[Service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html
[AdaptrisMessageProducer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageProducer.html
[AdaptrisMessageConsumer]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessageConsumer.html
[AdaptrisConnection]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisConnection.html
[AdaptrisConnectionImp]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisConnectionImp.html
[Password]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/security/password/Password.html
[AllowRetriesConnection]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AllowsRetriesConnection.html
[ExceptionHelper]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/util/ExceptionHelper.html
