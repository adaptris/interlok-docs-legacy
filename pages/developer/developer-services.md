---
title: Writing your own Service
keywords: interlok
sidebar: home_sidebar
permalink: developer-services.html
---

The [Service][] interface allows arbitrary functionality to be applied to [AdaptrisMessage][] objects in a [Workflow][]. It inherits some methods from other interfaces, namely [AdaptrisComponent][] and [StateManagedComponent][], but there are default implementations provided for those. There is only one key method in addition to [AdaptrisComponent]: this is the [doService()][] method which applies the appropriate action on the [AdaptrisMessage][] object.

[AdaptrisComponent][] defines methods common to all major components in the framework such as connections, consumers, producers and services. This is the interface that all components inherit. It primarily defines the component lifecycle methods for the framework. By having these methods we enforce a consistent state transition model within internally when the components are used.

[StateManagedComponent][] defines additional methods for enforcing transitions within the state. Rather than calling the `init()` method within code, you should make use of the various [LifecycleHelper][] methods which will enforce transitions correctly.


## Minimum number of methods ##

If you simply extend [com.adaptris.core.ServiceImp][ServiceImp] then there are 4 methods that you must implement. They are [init()][], [close()][] and [doService(AdaptrisMessage)][doService()]. The only one that is of real interest is [doService(AdaptrisMessage)][doService()]. The others are inherited from [AdaptrisComponent][] and are related to managing the internal state of your service.

{% include important.html content="If you make use of other [AdaptrisComponent] instances, then you should override all lifecycle methods [init()][], [start()][], [stop()][], [close()][] and make sure those instances are transitioned correctly." %}

## Full Example ##

Let's say that the `com.adaptris.whatever` package contains a class `DoSomething` that does something. It defines a constructor and two methods (for the sake of brevity we have skipped the actual implementations as they are not interesting to us).

```java
public DoSomething(String when, String how) {}
public void destroy() {}
public String doSomething(String theThing) throws Exception {}
```

The following class shows an implementation of Service that takes the result of the `doSomething(String)` method and applies that to the [AdaptrisMessage][] payload.

```java
package my.package.name;

import com.adaptris.whatever.*;
import com.adaptris.core.*;
import com.adaptris.core.util.*;
import com.thoughtworks.xstream.annotations.XStreamAlias;
import com.adaptris.util.license.License;
import org.hibernate.validator.constraints.NotBlank;

@XStreamAlias("do-something-service")
public class DoSomethingService extends ServiceImp {

  @NotBlank
  private String how;
  @NotBlank
  private String when;
  private transient DoSomething doSomething;

  @Override
  protected void initService() throws CoreException {
    doSomething = new DoSomething(getWhen(), getHow());
  }

  @Override
  protected void closeService() {
    doSomething.destroy();
  }

  public void doService(AdaptrisMessage msg) throws ServiceException {
    try {
      String payload = msg.getStringPayload();
      msg.setStringPayload(doSomething.doSomething(payload));
    }
    catch(Exception e) {
      ExceptionHelper.rethrowServiceException(e);
    }
  }

  public void setWhen(String when) {
    this. when = when;
  }
  public String getWhen () {
    return this. when;
  }
  public void setHow(String how) {
    this.how = how;
  }
  public String getHow() {
    return this.how;
  }
}

```

So, the summary of what we did is as follows :

- We extended [com.adaptris.core.ServiceImp][ServiceImp] rather than implementing Service directly.
- The `initService()` method instantiates the class that provides the underlying functionality. This assumes that the class in question is fairly heavyweight and should not be re-created for each invocation of doService().
- The `closeService()` method calls `destroy()` on DoSomething to free resources.
- The start and stop methods are not required for this example. They are actually provided by ServiceImp as empty implementations.
- When catching and re-throwing Exceptions we use [ExceptionHelper][] to wrap the exception if it needs it; throwing the exception will cause error handling to be triggered.
- Public getter and setter methods are provided for the fields that are to be marshalled.

{% include tip.html content="The public getters/setters are not required by the marshaller, but will be required by the UI." %}


- The `DoSomething` member variable is marked as __transient__ so that XStream does not attempt to marshal it.
- `@NotBlank` annotations are added to the `how` and `when` member variables as validator hints for both the schema validator and UI that those fields need to be populated.
- An `@XStreamAlias` is added so that we have an alias that we can configure; so now, configuration is `<do-something-service>` rather than `<my.package.name.DoSomethingService>`


# Writing Tests #

Of course, you're going to be writing tests. As we are writing a [Service][] then you can add `com.adaptris:adp-stubs` as a [dependency](developer-compiling.html). This then means you can simply extend `com.adaptris.core.ServiceCase` and implement the required method `retrieveObjectForSampleConfig()`. Simply implementing that method automatically executes some tests for you provided by `ServiceCase`:

- Automatic XML round trip testing; it will reflectively test that your service that has gone through the marshalling process is logically identical to one that was created programatically.
- Generate example XML; this requires that you have a `unit-test.properties` file available on the classpath for the tests.
    - In this file you need to have a property : `ServiceCase.baseDir` which is set to be a directory e.g. `ServiceCase.baseDir=./build/examples`.

So, based on our previous example, our test class could be something like

```java
package my.package.name;

import com.adaptris.core.AdaptrisMessageFactory;
import com.adaptris.core.ServiceException;
import com.adaptris.core.ServiceCase;

@SuppressWarnings("deprecation")
public class DoSomethingTest extends ServiceCase {

  public DoSomethingTest(java.lang.String testName) {
    super(testName);
  }

  public void testService() throws Exception {
    execute(new DoSomethingService(), AdaptrisMessageFactory.getDefaultInstance().newMessage("Hello World"));
  }

  @Override
  protected DoSomethingService retrieveObjectForSampleConfig() {
    DoSomethingService service = new DoSomethingService();
    service.setWhen("This is When");
    service.setHow("And This is How");
    return service;
  }

}

```

Post running the tests; we should have a file `./build/examples/my.package.name.DoSomethingService.xml` which contains (the unique-id is skipped in the example, but will be present):

```xml
<dummy-placeholder-service-element>
 <services>
  <do-something-service>
   <when>This is When<when>
   <how>And This Is How</how>
  </do-something-service>
 </services>
</dummy-placeholder-service-element>
```

There are similar classes that provide test scaffolding for other types of components.


[AdaptrisComponent]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisComponent.html
[Workflow]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Workflow.html
[Service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html
[StateManagedComponent]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/StateManagedComponent.html
[LifecycleHelper]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/util/LifecycleHelper.html
[ServiceImp]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ServiceImp.html
[AdaptrisMessage]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/AdaptrisMessage.html
[ExceptionHelper]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/util/ExceptionHelper.html
[doService()]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/Service.html#doService-com.adaptris.core.AdaptrisMessage-
[init()]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ComponentLifecycle.html#init--
[start()]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ComponentLifecycle.html#start--
[stop()]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ComponentLifecycle.html#stop--
[close()]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/ComponentLifecycle.html#close--
