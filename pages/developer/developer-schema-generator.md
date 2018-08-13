---
title: Schema Generator
keywords: interlok
sidebar: home_sidebar
tags: [developer]
permalink: developer-schema-generator.html
---

The adapter config file is an XML file that is a marshalled representation of the Adapter configuration class hierarchy. At this time the data binder that reads and generates the file is XStream. The adapter config file is often edited by hand and so is prone to errors.

A schema for the adapter config file has been developed, it is written in Relax NG, and can be used to validate the config file. Validation alerts the user to structure and content issues within the file other than checking that the XML file is well-formed or not.

Relax NG was chosen over DTDs, XSDs, and Schematron since it addresses the context based validation requirement of the configuration, i.e. where the contents of an XML element are based on the value of the attribute.

## Getting Started ##

The project to use is called schema, located under hg-core-components.
The Ant file contains all the necessary tasks to validate your config file.
The following is a typical command that you would run from the schema project root:

```
ant validate-adapter-config -DconfigFile=yourAdapterConfig.xml
```

Or for beautified configs:
```
ant validate-adapter-config -DconfigFile=yourBeautifiedAdapterConfig.xml -DschemaFile=src\test\resources\adapter\beautify\beautified.rng
```

## Generating a Custom Schema ##

By default the schema is generated for the Adapter-Core classes only. The case may arise when you wish to include additional services and other subclasses of adapter-core. In order to do this you just need to inform the Schema Generator of the classpath on which to find such classes.

The generate-adapter-schema Ant task passes an argument called searchclasspath to the generator. This is the classpath that you need to edit in order for your classes to be included in the schema.

There are two ways in which to accomplish this, involving editing the ant task:

1) Edit the argument to the generator

```xml
<java classname="com.adaptris.core.schema.RelaxNGSchemaGenerator">
  <arg value="-searchclasspath"/> <!-- only find subclasses on this given classpath -->
  <arg value="${searchClasspath.value};./myCustomDir;./myCustomJarFile.jar"/>
</java>

```


2) Add your jar to the main classpath in ivy.xml, and then add an additional classpath filter. At present we just filter the main classpath for interlok-core and use that as the search classpath.

```xml
<restrict id="searchClasspath">
  <path refid="main.classpath"/>
  <rsel:name name="interlok-core*.jar"/> <!-- pick up the interlok-core jar from the main classpath -->
  <rsel:name name="myCustomJarFile.jar"/> <!-- pick out your jar from the main classpath -->
</restrict>
```

## Updating the Project ##

Since the schema contains details of all the core classes, any changes to core will impact on the schema. New classes, changes to members etc will all have an impact and will result in test failures.

The project can be run easily from Eclipse using the standard Ivy configuration. Please ensure that you add the `src/resources` and `test/resources` to the classpath. This ensures that the config file and test data files are available.

### The Tests ###

Most of the unit tests will be unaffected by any updates to core. The following are the main ones that need updating:

- `com.adaptris.core.schema.relaxng.lookup.*` - These are reflection based and lookup classes on the classpath. The project is configured to only look at the `interlok-core.jar` file. There are tests that find all services defined, and so any changes to such will need to be reflected in the tests.
- `com.adaptris.core.schema.relaxng.XSDClassAdapterBasicTest` - This class generates several schemas from small components all the way to the full adapter. Each generated schema is checked against its expected version and validated using a sample XML config. For these tests you will need to compare the expected schema against the actual schema and verify the changes.
- `com.adaptris.core.schema.relaxng.XSDBeautifyAdapterTest` - Much like the test above but it deals with a schema that can handle beautified adapter config.

### Additional checks on the generated schema ###

The generated schema can be checked further to identify any issues that may have crept in.

1) This following command checks that the generated schema is in fact a valid relaxng file.

```
ant validate-adapter-config -DschemaFile=./src/test/resources/relaxng.rng -DconfigFile=adapter.rng
```

Should this fail then identify the source of the failure, and then adjust the config for the identified class.

2) Run the schematron rules to find any errors, issues and optimisations that can be performed on the schema. This will generate a html report with analysis results.
```
ant run-schematron
```

Should there be any issues then you may need to tune the schema generated via the config file to ensure a suitable schema gets generated.