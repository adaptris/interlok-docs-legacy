---
title: Writing your own Producer
keywords: interlok
sidebar: home_sidebar
tags: [developer]
permalink: developer-producers.html
---


Within the Interlok framework, an [AdaptrisMessageProducer][] is responsible for sending the message to the target system. If the target system supports request-reply then extend [RequestReplyProducerImp][] otherwise extend [ProduceOnlyProducerImp][]

- You can get access to the configured [AdaptrisConnection][] instance by using the `retrieveConnection` method.
- Call `this.encode(AdaptrisMessage)` to encode the message with any configured [AdaptrisMessageEncoder][] implementation (optional).

{% include tip.html content="An example quickstart project for services is available on github : [https://github.com/adaptris/interlok-custom-component-example](https://github.com/adaptris/interlok-custom-component-example)" %}


## Example ##

Our [previous example of a Connection](developer-connections.html) defined our connection; now we need to work with the `ClientConnection` interface:

```java
public interface ClientConnection {
  public boolean sendMessage(String to, byte[] message) throws IOException;
}
```


Our [AdaptrisMessageProducer][] implementation can use `ClientConnection` to send messages.


```java
@XStreamAlias("my-client-producer")
public class MyClientProducer extends ProduceOnlyProducerImp {

  public MyClientProducer() {
  }

  @Override
  public void init() throws CoreException {
  }

  @Override
  public void start() throws CoreException {
  }

  @Override
  public void stop() {
  }

  @Override
  public void close() {
  }

  @Override
  public void prepare() throws CoreException {}

  public void produce(AdaptrisMessage m, ProduceDestination d) throws ProduceException {
    try {
      String to = getDestination().getDestination(m);
      ClientConnection conn = retrieveConnection(MyClientConnection.class).createConnection();
      conn.sendMessage(to, this.encode(m));
    }
    catch (Exception e) {
      throw new ProduceException(e);
    }
  }
```

So, the summary of what we did is as follows :

- We extended [com.adaptris.core.ProduceOnlyProducerImp][ProduceOnlyProducerImp] and implemented the required methods.

{% include tip.html content="The target system only supports asynchronous messaging so we have not extended [RequestReplyProducerImp][]" %}

- The lifecycle methods do nothing; this pre-supposes that `ClientConnection` is pretty lightweight and can be disposed of via garbage collection.
- We can figure out where we are sending messages to from the [ProduceDestination][] implementation.
- We call `retrieveConnection` to find the configured connection object.
- We catch and throw a `ProduceException` to trigger error-handling behaviour.
- We call `this.encode(AdaptrisMessage)` which encodes the message (or not).
- There is no additional configuration required.
- An `@XStreamAlias` is added so that we have an alias that we can configure; so now, configuration is `<producer class="my-client-producer"/>` rather than the fully qualified classname.



[AdaptrisMessageProducer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisMessageProducer.html
[AdaptrisMessageConsumer]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisMessageConsumer.html
[AdaptrisConnection]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisConnection.html
[AdaptrisConnectionImp]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisConnectionImp.html
[AdaptrisMessageEncoder]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/AdaptrisMessageEncoder.html
[ProduceOnlyProducerImp]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/ProduceOnlyProducerImp.html
[RequestReplyProducerImp]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/RequestReplyProducerImp.html
[ProduceDestination]: https://development.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.8-SNAPSHOT/com/adaptris/core/ProduceDestination.html