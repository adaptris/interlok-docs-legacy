---
title: Annotating your Components
keywords: interlok
sidebar: home_sidebar
permalink: developer-annotations.html
summary: This document is aimed at system developers who wish to create new or custom Interlok components and for those components to be fully integrated into the Interlok framework.
---

The Interlok code base uses annotations for a few reasons and all developers are encouraged to follow those recommendations detailed in this document; To fully incorporate your new components, you will need to make sure that the marshalling engine knows how to translate the configuration of your component into the running Interlok instance.

And of course should an end-user want to incorporate schema validation, a newly generated schema will need to know the details of your component.

## Class Level Annotations ##

### @XStreamAlias ###

XStream alias maps the name of your class to a more simple name that we use in xml configuration.

Upon start-up of Interlok, XStream will maintain a list of these class mappings, which are used to instantiate an instance of your component based on the friendly name of each xml element tag name.

For example if you have the following class and annotation;

```java
@XStreamAlias("add-metadata-service")
public class AddMetadataService extends ServiceImp {
  ...
}
```

This allows us to configure our consumer with a friendly element tag name like this;

```xml
<service class="add-metadata-service">
...
</service>
```

Or even;

```
<add-metadata-service>
...
</add-metadata-service>
```

{% include warning.html content="Your XStreamAlias may render as an XML Element; it needs to be well formed (e.g. don't start with a number; or special characters etc.)." %}


### @GenerateBeanInfo ###

Use this to force XStream to use the public getters and setters when un-marshalling rather than the member variables directly. This is generally useful if the getters and setters in your component have behaviour associated with them that are not simple ```this.x=x``` methods.

For example if you have the following class and annotation;

```java
@GenerateBeanInfo
@XStreamAlias("channel")
public class Channel ... {
  ...
}
```

When this class is un-marshalled, regardless of the non-transient class members only those with public getters and setters will be un-marshalled. This class is deprecated with no replacement as of __3.4.1__. The reason for this is tracked as [INTERLOK-1085](https://adaptris.atlassian.net/browse/INTERLOK-1085). You are encouraged to change your class so that getters and setters have no behaviour.

{% include important.html content="This class is deprecated with no replacement as of __3.4.1__." %}

### @AdapterComponent ###

Use this to so that the component can be discovered by the UI and made available for configuration; it is generally used in conjunction with _@ComponentProfile_

### @ComponentProfile ###

since 3.1.1 you can use this annotation to provide some additional information so that the UI can display some additional information about the component when the selection screen pops up.

```java
@ComponentProfile(summary="A basic single threaded workflow", tag="workflow")
public class StandardWorkflow ... {
  ...
}
```

| Annotation Parameter | Description |
|----|----|
| `summary` | A brief summary of the component |
| `tag` | A comma separated list of tags |
| `recommended` | (since __3.2.0__) an array of classes that are contextually related to this component (e.g. for a producer, it would be the connections you should use with it)  |
| `metadata` | (since __3.4.0__) an array of strings that contain metadata keys that may be created or have an effect on the behaviour of this component |
| `branchSelector` | (since __3.6.2__) if set to true, indicates that this service can be used as the `firstService` as part of a BranchingServiceCollection |


### @DisplayOrder ###

since 3.2.0 you can use this annotation to apply ordering to a component when editing it in the UI. The following rules are generally applied by the UI:

- The component unique ID is always presented first (regardless of your specified order)
- Fields specified as part of _@DisplayOrder_ will always be displayed first in the settings editor.
- Fields marked as _advanced_ will be hidden until _show advanced_settings_ is toggled, and will then be shown as part of the specified order.
- Fields not specified will be displayed after @DisplayOrder fields, in no particular order.
- If @DisplayOrder is omitted, then the fields will be displayed in no particular order.

Generally speaking, only primitive settings (String/int/enum etc.) will be ordered using this annotation; complex objects will always be presented as a separate tab. In the following example, we have fixed the order so that _metadataKey_ is always first; _offset_ will not be displayed until _show advanced settings_ is toggled; and will always be shown before _alwaysReplace_

```java
@DisplayOrder(order = {"metadataKey", "dateFormat", "offset", "alwaysReplace"})
public class AddTimestampMetadataService extends ServiceImp {
  @NotBlank
  @AutoPopulated
  private String dateFormat;
  @NotBlank
  @AutoPopulated
  private String metadataKey;
  private Boolean alwaysReplace;
  @AdvancedConfig
  private String offset;
}
```


## Member Level Annotations ##

### @XStreamImplicit ###

Interlok configuration can become a monolithic monster to maintain and in an attempt to reduce a small amount of the burden we tend to not marshall/unmarshall list wrappers.

For example if your component requires a configurable list of objects;

```java
@XStreamImplicit
private Set<MetadataElement> metadataElements;
```

The above annotation will not marshall or expect when unmarshalling the list container element.  So instead of the following;

```xml
<metadata-elements>
  <metadata-element>
    <key>key2</key>
    <value>val2</value>
  </metadata-element>
  <metadata-element>
    <key>key1</key>
    <value>val1</value>
  </metadata-element>
</metadata-elements>
```

We will have;

```xml
<metadata-element>
  <key>key2</key>
  <value>val2</value>
</metadata-element>
<metadata-element>
  <key>key1</key>
  <value>val1</value>
</metadata-element>
```

The only difference is the list container element "metadata-elements" wrapping the actual list items.

### @MarshallingCDATA ###

Should your component have a member field that should be configurable, therefore marshalled, but may contain characters that are illegal as xml values then you may want to wrap this member value in xml CDATA.

Take the example of our embedded scripting service;

```java
@MarshallingCDATA
private String script;
```

The embedded script could have characters that would normally not be allowed in xml.  Therefore we instruct our XStream marshaller to wrap the value in CDATA as this example shows;

```xml
<script><![CDATA[value = $message.getMetadataValue 'MyMetadataKey';$message.addMetadata('MyMetadataKey', value.reverse);]]></script>
```

### @InputFieldHint ###

This annotation provides a _hint_ to the UI when presenting the information on screen and is available from __3.0.2__ onwards. There are two elements to this annotation `style` and `friendly`.

| Annotation Parameter | Description |
|----|----|
| `style` | contain information about the type of field this is; it is generally used on String fields that might need to be syntax highlighted or treated differently in some way |
| `friendly` | (since __3.4.0__) contains information about what to display in various drop downs or similar. We use it for enums where the enum name may not be as nice as we want it. |
| `expression` | (since __3.6.2__) if set to true, then the UI knows that this field supports the new `%message{key}` style expression.  |
| `external` | (since __3.7.1__) if set to true, then the UI knows that this field supports the new `%sysprop{system-property}` or `%env{environment-variable-name}` style inputs. If you add this, then you need to remember to use `com.adaptris.interlok.resolver.ExternalResolver#resolve(String)` to resolve your configuration item when you actually come to use it.  |

#### style ####

| Style | Description |
|----|----|
| PASSWORD | Tells the UI that this field is a password, so input is masked and an optional checkbox for [Password Encoding](advanced-password-handling.html) |
| SQL | Allows the UI to provide SQL style highlighting on the field. |
| XML | Allows the UI to provide XML style highlighting on the field. |
| DTD | Allows the UI to provide XML/DTD style highlighting on the field. |
| CSS | Allows the UI to provide CSS style highlighting on the field. |
| JAVA | Allows the UI to provide Java style highlighting on the field. |
| JSON | Allows the UI to provide JSON style highlighting on the field. |
| JAVASCRIPT | Allows the UI to provide javascript style highlighting on the field. |
| HTML | Allows the UI to provide HTML highlighting on the field. |

{% include important.html content="If the style is __PASSWORD__ then remember to use _com.adaptris.security.password.Password#decode(String)_ to decode the password at the appropriate time." %}

{% include important.html content="If you are using __external=true__ then remember to use _com.adaptris.interlok.resolver.ExternalResolver#resolve(String)_ to resolve your configuration item when you actually come to use it." %}


```java
import com.adaptris.interlok.resolver.ExternalResolver;
import com.adaptris.security.password.Password;

@InputFieldHint(style = "PASSWORD", external=true)
private String password;

public void init() throws CoreException {
  try {
    String resolvedPassword = Password.decode(ExternalResolver.resolve(getPassword()));
    doLogin(resolvedPassword);
  } catch (Exception e) {
    throw ExceptionHelper.wrapCoreException(e);
  }
}
```


### @InputFieldDefault ###

This annotation provides a _hint_ to the UI as to what the default value for this member is if left unconfigured. The annotation itself is available from __3.4.0__ onwards. Fields that are marked with this annotation will have additional information presented when hovered over.



```java
@InputFieldDefault(value = "false")
private Boolean ignoreErrors;

private boolean ignoreErrors() {
  return getIgnoreErrors()!= null ? getIgnoreErrors().booleanValue() : false;
}
```

### @AdvancedConfig ###

This annotation provides a _hint_ to the UI that this member is considered an advanced option, has a reasonable default (if any), and does not need to be explicitly configured. The annotation itself is available from __3.0.5__ onwards. Fields that are marked with this annotation are not shown by default on the settings popup for the component. It is only displayed if _show advanced settings_ is selected in the UI.

### @AffectsMetadata ###

This annotation is available from __3.4.1__ onwards and is a _hint_ to the UI that this member potentially affects metadata. This is expected to be used so that additional information can be presented to the user around what metadata may have been populated at this stage of the workflow.

```java
@AffectsMetadata
private String metadataKeyToSet;
```

## Javadoc Taglets ##

There are currently 2 custom taglets supported at the class level javadoc; the taglets will need to be explicitly included as part of your javadoc tag to generate the HTML snippets required.

```xml
<javadoc author="false" destdir="${api.doc.dir}"  sourcepath="${src.dir}">
  <taglet name="com.adaptris.taglet.ConfigTaglet">
    <path refid="classpath.ant-tools"/>
  </taglet>
  <taglet name="com.adaptris.taglet.LicenseTaglet">
    <path refid="classpath.ant-tools"/>
  </taglet>
</javadoc>
```

{% include note.html content="You need to include `com.adaptris:adp-core-apt` as a dependency if you are using dependency management." %}

### @license ###

This annotation is suggested for all configurable components.  There are currently 3 values;

- BASIC
- STANDARD
- ENTERPRISE

For example if you add the annotation to your components class level javadoc like this;

```java
/*
 * @license STANDARD
 */
```

Then when the javadoc is generated you will see the following;

```
License Required: STANDARD
```

### @config ###

This annotation is simply used to notify the reader of the simple name used in configuration for your component. As talked about earlier in this document each component is mapped to a simple name purely for ease of configuration. The value of this annotation should match the value of the @XStreamAlias annotation.

An example, if you have the following in your class level javadoc;

```java
/*
 * @config scripting-service
 *
 */
```
Then when the javadoc is generated, you will see the following;

```
In the adapter configuration file this class is aliased as **scripting-service** which is the preferred alternative to the fully qualified classname when building your configuration.
```

##  Validation ##

There are a number of standard validation annotations that are used when validating configuration in the UI and also when generating a RelaxNG schema.
Validation is only applicable to those members that are serialized, you will not need to add these annotations to transient members. The annotations are purely optional but will give you a better experience when interacting with the UI for your component.

### @NotNull ###

This particular non-transient member should always have a value; may not be null. This is checked both in the UI and during schema validation. For example, let us imagine you are creating a new Interlok service that requires the user to configure a string that may not be null, you simply annotate like this;

```java
@NotNull
private String myString = null;
```

### @AutoPopulated ###

This is a custom annotation which only affects the generated schema.  This simple annotation is used to identify fields that are auto-populated on instantiation. If we consider the previous example; then if your string member has a default value, so it can be missing from the configuration file then you can use this annotation to inform the schema to ignore the `@NotNull` annotation.

```java
public MyClass {

  private String myString = null;

  public MyClass() {
    myString = "someValue";
  }
}
```

Then we can simply annotate this member variable like this;

```java
@AutoPopulated
@NotNull
private String myString = null;
```

### @Valid ###

This annotation is used for complex objects and allows us to validate the full object graph of the member variable.

An example might be a new service that requires a configurable complex object like this;

```java
@Valid
private RestartStrategy restartStrategy;
```

It is then assumed that the object RestartStrategy will include annotations for its own member variables, therefore causing validation in a cascading fashion.

### @NotBlank ###

Validate that the annotated string is not NULL or empty.

The difference to `@NotEmpty` is that trailing whitespaces are ignored.

A simple example;
```java
@NotBlank
private String myString = null;
```

### @NotEmpty ###

Asserts that the annotated string, collection, map or array is not null or empty.

A simple example;
```
@NotEmpty
private List<Object> myObjects = null;
```

### @Pattern ###

This annotation allows you to specify a regular expression that the value of the field can be validated against.  Typically this annotation would be used where the value of the field may only be a one of a list of values.

A simple example;
```java
@Pattern(regexp = "payload|xpath|metadata|constant|id")
private String queryType;
```
