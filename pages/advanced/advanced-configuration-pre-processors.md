---
title: Configuration Pre Processing
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-configuration-pre-processors.html
summary: Pre-processors allow us to perform actions on the Interlok configuration before it is unmarshalled and the Interlok instance starts up.
---


Pre-processors allow us to perform actions on the Interlok configuration before it is unmarshalled and the Interlok instance starts up. The original configuration will not be modified by this process and the following general rules will apply:

- Multiple pre-processors may be configured, which will be executed in the order they are configured.
- Each pre-processor configured will have access to the referenced configuration file and may change that content.
- The first pre-processor will have access to the configuration verbatim from the configuration file.
    - Each subsequent pre-processor will be handed over the configuration from the previous pre-processor.
- Standard ENTITY references are handled in a pre-processor dependent way; we recommend that you don't use ENTITY if you are using pre-processors.

{% include note.html content="The original configuration file will not be modified." %}

## Configuration of Pre-Processors ##

Although each pre-processor may require their own separate configuration file(s); pre-processors are activated if `bootstrap.properties` contains a `preProcessors` key. All configuration pre-processors are optional, and may require additional libraries to be copied into your installation.

Each pre-processor can be configured colon separated as the value to this property. e.g

```
preProcessors=variableSubstitution:schema
```

{% include note.html content="All configuration pre-processors are optional, and may require additional libraries to be copied into your installation." %}

## Available Pre-Processors ##

|PreProcessor Name| Description |
|----|----|
| variableSubstitution| Perform variable substitution based on a previously defined property file (requires `optional/varsub`)|
| systemProperties | Perform variable substition based on system properties (_since 3.0.1_ and requires `optional/varsub`)|
| environmentVariables | Perform variable substition based on environment Variables (_since 3.0.1_ and requires `optional/varsub`)|
| schema | Validate (optional generation) of adapter configuration against a specified schema file (requires `optional/schema`)|
| xinclude | Include other XML documents into configuration using `<xi:include>` tags (requires `optional/xinclude`)|
| xslt | Execute a transform on the configuration file before unmarshalling (requires `optional/xinclude`)|


## Variable Substitution ##

This pre-processor allows you to configure place-holders in your Interlok configuration, which will be swapped out with values configured in a separate property file. The idea is that multiple environments that require almost identical configuration can more easily be set-up by simply duplicating the main Interlok configuration files across all environments.

Typically broker URL's, usernames, passwords and destination values would be a fair use for variable substitution.

### Additional Configuration ###

The following properties can be specified in the bootstrap.properties to control the behaviour of the variable substitution;

| Property | Default | Mandatory | Description |
|----|----|----|----|
| variable-substitution.varprefix | ${ | No | The value here will be prefixed to the variable name to search for in the configuration to be switched out. |
| variable-substitution.varpostfix | } | No | The value here will be appended to the variable name to search for in the configuration to be switched out. |
| variable-substitution.properties.url | | Yes | The URL to the property file containing the list of substitutions; in the form of variableName=Value. Multiple files are supported by adding a unique suffix for each filename which are then sorted before processing. |
| variable-substitution.url.useHostname | false | No | _since 3.7.1_ if set to true, then each URL defined by `variable-substitution.properties.url` will be formatted passing in the hostname as the 1st parameter. |
| variable-substitution.impl | simple | No | The substitution engine that will perform the variable substitution. Since 3.1.0 _simple_, _simpleWithLogging_, _strict_, _strictWithLogging_ are available.  |

<br/>

If you have in your bootstrap.properties :

```
preProcessors=variableSubstitution
variable-substitution.properties.url.1=file://localhost//path/to/my/shared-variables
variable-substitution.properties.url.3=file://localhost//path/to/my/variables-%1$s
variable-substitution.properties.url.2=file://localhost//path/to/my/local-variables
variable-substitution.url.useHostname=true
```

Assuming that your hostname is _localhost.localdomain_ then the following files will be read `/path/to/my/shared-variables`, `/path/to/my/local-variables`, `/path/to/my/variables-localhost.localdomain` (in that order due to sort order) to resolve any variables. The last defined property takes precedence. After reading in the variables, let's assume that it contains :

```
broker.url=tcp://localhost:2506
broker.backup.url=tcp://my.host:2507
```
Then all instances of "${broker.url}" and "${broker.backup.url}" will be replaced within your Interlok configuration before Interlok starts up. In addition to a pre-processor there is also a [xstream-varsub-marshaller][] that can be used where you might normally configure a [xstream-marshaller][].

{% include tip.html content="In addition to a pre-processor there is also a [xstream-varsub-marshaller][] that can be used where you might normally configure a [xstream-marshaller][]." %}

Since __3.0.1__ variable definitions may refer to other variable definitions, system properties, and environment variables. They will be resolved in that order so a variable definition will always take precedence over a system property and so on. This means that on a Windows machine, the following properties file would be perfectly acceptable

```
adapter.unique.id=Interlok
adapter.fs.base.url=file://localhost/c:/adaptris/interlok/fs/${adapter.unique.id}/${user.name}
adapter.consume.fs.url=${adapter.fs.base.url}/${COMPUTERNAME}/in
```

* `${adapter.unique.id}` will be resolved from the previous definintion.
* `${user.name}` will be resolved from the standard java system property
* `${COMPUTERNAME}` will be resolved from the environment.

Since __3.1.0__ additional implementations have been made available which will have slightly different behaviour based on whether variable substitution has occurred for all variable definitions found in configuration. _simple_ and _simpleWithLogging_ will log a warning after performing substitutions if there are any remaining variables that have not been substituted

```
TRACE [main] [VariableSubstitution] Replacing ${adapter.unique.id} with interlok-xxe
WARN  [main] [VariableSubstitution] ${adapter.transform.url} is undefined for variable substitution
```

_strict_ and _strictWithLogging_ will throw an exception after performing substitutions if there are any remaining variables that have not been substituted and may terminate the adapter process.

```
TRACE [main] [VariableSubstitution] Replacing ${adapter.unique.id} with interlok-xxe
Exception in thread "main" com.adaptris.core.CoreException: ${adapter.transform.url} is undefined for variable substitution
        at com.adaptris.core.varsub.D.o00000(SimpleStringSubstitution.java:59)
        at com.adaptris.core.varsub.D.doSubstitution(SimpleStringSubstitution.java:49)
```

## System Properties ##

Similar to variable substitution this pre-processor allows you to configure place-holders in your Interlok configuration, these will be swapped out for the corresponding system property values. The idea is that multiple environments that require almost identical configuration can more easily be set-up by simply duplicating the main Interlok configuration files across all environments and modifying the system properties when starting up the Interlok instance. It is generally expected that you would use the variable substition pre-processor and define variables which refer to the system properties required; this pre-processor included for completeness and behaviour follows that of variable substitution processor.

### Additional Configuration ###

The following properties can be specified in the bootstrap.properties to control the behaviour of the system properties pre-processor

| Property | Default | Mandatory | Description |
|----|----|----|----|
| system-properties.varprefix | ${ | No | The value here will be prefixed to the variable name to search for in the configuration to be switched out. |
| system-properties.varpostfix | } | No | The value here will be appended to the variable name to search for in the configuration to be switched out. |
| system-properties.impl | simple | No | The substitution engine that will perform the variable substitution. Since 3.1.0 _simple_, _simpleWithLogging_, _strict_, _strictWithLogging_ are available. |


If you have in your bootstrap.properties:

```
preProcessors=systemProperties
```

Then any system properties present within configuration (such as `${user.dir}` or `${user.name}`) will be replaced within your Interlok configuration unmarshalling happens. Note that on Windows `${user.dir}` will contain backslashes; which means that it will be unsuitable as a URL reference.

## Environment Variables ##

Similar to variable substitution this pre-processor allows you to configure place-holders in your Interlok configuration, these will be swapped out for the corresponding environment variables. The idea is that multiple environments that require almost identical configuration can more easily be set-up by simply duplicating the main Interlok configuration files across all environments and modifying the environment when starting up the Interlok instance. It is generally expected that you would use the variable substition pre-processor and define variables which refer to the environment variables required; this pre-processor included for completeness and behaviour follows that of variable substitution processor.

### Additional Configuration ###

The following properties can be specified in the bootstrap.properties to control the behaviour of the environment variables pre-processor

| Property | Default | Mandatory | Description |
|----|----|----|----|
| environment-variables.varprefix | ${ | No | The value here will be prefixed to the variable name to search for in the configuration to be switched out. |
| environment-variables.varpostfix | } | No | The value here will be appended to the variable name to search for in the configuration to be switched out. |
| environment-variables.impl | simple | No | The substitution engine that will perform the variable substitution. Since 3.1.0 _simple_, _simpleWithLogging_, _strict_, _strictWithLogging_ are available. |

If you have in your bootstrap.properties:

```
preProcessors=environmentVariables
```

Then any environment variables present within configuration (such as `${COMPUTERNAME}` on Windows or `${HOSTNAME}` on Linux) will be replaced within your Interlok configuration before unmarshalling happens.


## Schema validation ##

This pre-processor allows you to validate your configuration with an Interlok RelaxNG schema.  Optionally the schema file itself may also be generated before validation. If your configuration file is validated successfully the log file will contain the location of the schema file used and the success of the validation. Should the configuration file not be validated, then Interlok will not start-up and the log file will detail the validation errors.

### Further Configuration ###

The following properties can be specified in the bootstrap.properties to control the behaviour of the schema validation;

| Property | Default | Mandatory | Versions | Description |
|----|----|----|----|
| schema.file.url | | Yes | all | The url to the Interlok RelaxNG schema file.  Note, the schema file itself does not have to exist, if you specify the regeneration (below). |
| schema.regenerate | false | No | all | Set to 'true' if you want to re-create the RelaxNG schema before we validate your configuration. |
| schema.classpath.screen.patterns | `.*adp-core.*\\.jar` | No | Up to 3.6.6 only |A comma separated list of regular expressions used to match all the jars that should be searched for valid components.|
| schema.package.patterns | `com.adaptris,-com.adaptris.core.stubs` | No | since 3.7.0 | A comma separated list of packages that should be searched for valid components. You can blacklist a package by using a `-` at the front of the package (the default blacklists the `com.adaptris.core.stubs` package which is just for unit-testing custom components)|

### Example ###

```
preProcessors=schema
schema.file.url=file://localhost//path/to/my/schema.rng
```

If the schema already exists, your configuration will be validated against that schema when you start Interlok; otherwise an exception may be thrown.

```
preProcessors=schema
schema.file.url=file://localhost//path/to/my/schema.rng
schema.regenerate=true
```

Regardless of whether the schema file exists or not a new file will be generated and then your configuration will be validated against it.

```
preProcessors=schema
schema.file.url=file://localhost//path/to/my/schema.rng
schema.regenerate=true
schema.package.patterns=io.github.adaptris,com.mycompany
```

Regardless of whether the schema file exists or not a new file will be generated and then your configuration will be validated against it. Also, as well as checking the default `com.adaptris` packages it will also check the `io.github.adaptris` and `com.mycompany` package (including sub packages)

## XInclude ##

The XInclude pre-processor allows you to inject xml documents into your Interlok configuration before Interlok starts up. There is also a [xstream-xinclude-marshaller][] that can be used where you might normally configure a [xstream-marshaller][].

### Example ###

If you have in your bootstrap.properties;

```
preProcessors=xinclude
```

And you have an Interlok Configuration file like this;

```xml
<?xml version="1.0"?>
<adapter xmlns:xi="http://www.w3.org/2001/XInclude">
  <unique-id>xinclude_adapter</unique-id>
  <channel-list>
    <xi:include href="file://localhost/opt/adaptris/interlok/config/channel.xml"/>
  </channel-list>
</adapter>
```

- We have used an absolute path for the href rather than a relative one; the xinclude library is somewhat ambiguous how relative paths are processed.

And you have an xml document named channel.xml that looks like this;

```xml
<channel>
  <auto-start>true</auto-start>
  <unique-id>SEND</unique-id>

  <workflow-list>
    <standard-workflow>
      <unique-id>SendMessage</unique-id>
      <consumer class="polling-trigger">
        <destination class="configured-consume-destination">
          <configured-thread-name>SendMessage</configured-thread-name>
        </destination>
        <template>hello world</template>
        <poller class="quartz-cron-poller">
          <cron-expression>*/7 * * * * ?</cron-expression>
        </poller>
      </consumer>
      <service-collection class="service-list"/>
    </standard-workflow>
  </workflow-list>
</channel>
```

During initialization of Interlok, the XInclude pre-processor will pick up the directive `<xi:include href="....` from the Interlok configuration and inject the channel.xml content directly into your Interlok configuration to look like this;

```xml
<?xml version="1.0"?>
<adapter xmlns:xi="http://www.w3.org/2001/XInclude">
  <unique-id>xinclude_adapter</unique-id>
  <channel-list>
    <channel>
      <auto-start>true</auto-start>
      <unique-id>SEND</unique-id>

      <workflow-list>
        <standard-workflow>
          <unique-id>SendMessage</unique-id>
          <consumer class="polling-trigger">
            <destination class="configured-consume-destination">
              <configured-thread-name>SendMessage</configured-thread-name>
            </destination>
            <template>hello world</template>
            <poller class="quartz-cron-poller">
              <cron-expression>*/7 * * * * ?</cron-expression>
            </poller>
          </consumer>
          <service-collection class="service-list"/>
        </standard-workflow>
      </workflow-list>
    </channel>
  </channel-list>
</adapter>
```

## XSLT ##

For whatever reason, you may want to execute a transform on the configuration XML before proceeding to the unmarshalling stage (a common use-case is to duplicate workflows *before* unmarshalling). You can do this with the xslt preprocessor.

### Additional Configuration ###

The following properties can be specified in the bootstrap.properties to control the behaviour of the xslt pre-processor.

| Property | Default | Mandatory | Description |
|----|----|----|----|
| xslt.preprocessor.url | | Yes | The XSLT to execute, passing in the current adapter configuration. |
| xslt.preprocessor.params.XXXX | | No | Values here will be passed in as a stylesheet parameter called `XXXX`; you will have `<xsl:param name="XXXX"/>` in your stylesheet etc.|
| xslt.preprocessor.environment.params | false | No | Whether or not system properties and environment variables are passed as stylesheet parameters; be aware that any `xslt.preprocessor.params.*` values will take precedence. |
| xslt.preprocessor.transformerImpl | | No | Specify the XML TransformFactory to use, if not specified defaults to `TransformerFactory.newInstance()` which uses the JVM default |

### Example ###

You already have a stylesheet written, stored in the config directory as *duplicate.xslt*...

```
preProcessors=xslt
xslt.preprocessor.url=file://localhost/./config/duplicate.xslt
xslt.preprocessor.params.duplicates=5
```

Will execute your XSLT; passing in `5` as the transform parameter *duplicates*.

# Writing your own pre-processor #

If you need to extend the pre-processor behaviour with your own functionality (e.g. you might want to verify the checksum of the file) then you will need to implement  [ConfigurationPreProcessor][] and the implementation should have a constructor taking in a [BootstrapProperties][] object.

Pre-processors are generally configured by their short names (though it is possible to use the fully qualified classname). To generate a short name you need to include a file in the `META-INF/com/adaptris/core/preprocessor` directory of the jar file. The name of the file should be the short name (e.g. `variableSubstitution`).  The property file contains a single property __class__ which refers to the fully qualified name of your pre-processor. For the variable substitution pre-processor we have a file `META-INF/com/adaptris/core/preprocessor/variableSubstitution` which contains

```
class=com.adaptris.core.varsub.VariableSubstitutionPreProcessor
```


[ConfigurationPreProcessor]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/runtime/ConfigurationPreProcessor.html
[BootstrapProperties]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/management/BootstrapProperties.html
[xstream-varsub-marshaller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-varsub/3.9-SNAPSHOT/com/adaptris/core/varsub/XStreamMarshaller.html
[xstream-marshaller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-core/3.9-SNAPSHOT/com/adaptris/core/XStreamMarshaller.html
[xstream-xinclude-marshaller]: https://nexus.adaptris.net/nexus/content/sites/javadocs/com/adaptris/interlok-xinclude/3.9-SNAPSHOT/com/adaptris/core/xinclude/XStreamMarshaller.html
