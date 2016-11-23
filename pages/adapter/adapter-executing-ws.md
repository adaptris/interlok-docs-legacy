---
title: Accessing External Webservices
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: adapter-executing-ws.html
summary: This document is aimed at developers and system administrators who wish to make use to make calls to web-services outside of the domain of Interlok. Depending on how you want to execute the webservice; it will depend on either adp-webservice-cxf or adp-webservice-external.
---

There are two ways of accessing external webservices from Interlok; through a generic [apache-cxf-soap-service][] which calls the webservice with the payload of the current message as the operation argument (the service will look after any required SOAP headers); or by generating a custom service which has its own specific standardised input file.


## Using apache-cxf-soap-service ##

[apache-cxf-soap-service][] is the simplest way of executing a webservice; you just need to know the structure of the webservice document (which can be easily discovered by using SoapUI against the WSDL); map to it, and configure the service appropriately. In the majority of cases, this is the only service you will need. This service relies on the optional `optional/webservice-cxf` package.

### Example ###

If we wanted to call the [WebserviceX.net](http://webservicex.net/ws/default.aspx) currency converter webservice; then we can do that quite easily using [apache-cxf-soap-service][]. For the purposes of our example we are going to do a find out the current GBP to USD exchange rate; and to log the reply message.

```xml
<service-collection class="service-list">
  <services>
    <payload-from-metadata-service>
      <template><![CDATA[<?xml version="1.0"?>
<web:ConversionRate xmlns:web="http://www.webserviceX.NET/">
  <web:FromCurrency>GBP</web:FromCurrency>
  <web:ToCurrency>USD</web:ToCurrency>
</web:ConversionRate>
]]></template>
    </payload-from-metadata-service>
    <apache-cxf-soap-service>
      <unique-id>Call Currency Conversion Service</unique-id>
      <wsdl-url>http://www.webservicex.net/CurrencyConvertor.asmx?WSDL</wsdl-url>
      <port-name>CurrencyConvertorSoap</port-name>
      <service-name>CurrencyConvertor</service-name>
      <namespace>http://www.webserviceX.NET/</namespace>
      <soap-action>&quot;http://www.webserviceX.NET/ConversionRate&quot;</soap-action>
      <wsdl-port-url>http://www.webservicex.net/CurrencyConvertor.asmx</wsdl-port-url>
    </apache-cxf-soap-service>
    <log-message-service/>
  </services>
</service-collection>
```

1. First of all we create the required document
    - we do it here using [payload-from-metadata-service][] because that's an easy way of hard-coding a document.
1. Next we call the currency conversion service using [apache-cxf-soap-service][].
    - The various fields being used should be self-explanatory.
1.  Finally we log the message using [log-message-service][]

## Service Generation ##

This is a more fully featured way of handling a webservice; and is included for completeness. In the majority of cases [apache-cxf-soap-service][] will handle everything you need.  Part of the installation now ships with a tool that will generate Interlok services based on a provided WSDL. These generated services can be seamlessly configured into your Adapter configuration.

This leaves us with a 2 step process;

- Generating the Interlok services
- Configuring the Interlok services


### Pre-requisites ###

You must have apache-ant version 1.6 or later installed to be able to execute the service generator.

### Generation ###

You can check that Ant is installed and configured on your system path by opening a command prompt and typing the command "ant -version".  On windows you should see something like the following;

![Soap Request](./images/external-webservices/figure1.png)

After the generator has run, you will have a new java archive (jar) file.  This new file should then be dropped into the "/lib/" directory of your Adapter installation.

Any java archive files added into the "/lib/" directory will be added to the classpath of the Adapter, meaning any classes or resources contained in that java archive will be available to the Adapter during runtime.

Note: The generator builds a java archive that is very specific to the provided WSDL.  Should the web services change, you will most likely need to re-generate a new java archive.

### Using the Interlok Service Generator ###

The following sections will take you step-by-step through generating Adapter services using the generator tool.  The steps to do so are;

- Update the Interlok "lib" directory
- Copy the generator and configuration scripts
- Configure the generator
- Execute the generator

#### Update Interlok's "lib" directory ####

In the root of your Interlok installation, you will find a directory named "optional".  Copy all of the files from the "/optional/web-service-external/" directory into Interlok's "/lib/" directory (the "/lib/" directory can also be found in the root of your Interlok installation).

Note:  You do not necessarily need to remove these files after this process.  There is no downside to leaving the optional files in the Adapters lib directory.

#### Copy the generator scripts ####

Copy all files from; `/docs/example-xml/optional/webservice-external/generator` into the root of your Interlok installation. These files include the Ant script and configuration for the generator tool.

#### Configure the generator tool ####

In the root of your Interlok installation you should now have a build.properties.template file.  Copy this file and rename it to build.properties.

There are many properties in this file, most of which should be left as the default value.  The below table shows the properties you should modify.

| Property name| Description| Example|
|----|----|----|
| wsdl | The location to find your chosen WSDL.| http://mysite.com/myWsdl.wsdl|
| wsservice.jar.name | The name given to the final artefact that contains all of the generated Interlok services.  This artefact will be a java archive (jar). | myWSAdaptrisServices.jar |

#### Executing the generator ####

Once your configuration is complete, you can simply open a command line prompt and navigate to the root of your Interlok installation and then execute the following ant command;
```
ant clean generate
```
You should then see something like the following;

![Soap Request](./images/external-webservices/figure2.png)

Notice that we are using Apache Ant to execute the tool.  We provide the ant script two commands to execute; clean and generate.

You don't need to call the "clean" command the first time you run the tool.  This will simply delete any previously generated files.

The "generate" command is the task that will create your new java archive with your custom services.

Should there be a problem and something goes wrong, then the output on the command line will provide you with the error details.

### Adapter Configuration ###

After generating the services above, you will need to configure the service(s) into your Interlok configuration.  The following steps will be required;

- Installing your services
- Modifying Interlok configuration
- Composing the input message

### Installing your Services ###

Once the generator has built your java archive file, you can simply copy this file into your Interlok "/lib/" directory.

Once a jar file exists in the "/lib/" directory any java classes or resources contained in that java archive will be available to the running Interlok instance.

### Modifying Interlok Configuration ###

The generator tool, as well as creating a new java archive which contains the new service(s), will also generate 2 documents.

- Sample configuration
- Sample input message

You will find both documents created in the "/build/" directory, in the root of your Interlok installation.

You can simply copy the sample service configuration and paste it into the relevant section(s) in your Adapter configuration.  The default values for all fields will have been completed for you.

#### Sample Input Message ####

The second document produced by the service generator, is the sample input message.

This is the expected payload you will be required to have as input for your new service.  You will need to take care in your Interlok configuration to make sure that the payload of the current message matches the sample input message before your new service is called.

For testing purposes you can simply consume this sample message document and configure your new service as the first service.


[standard-soap-service]: http://development.adaptris.net/javadocs/v3-snapshot/optional/webservice-external/com/adaptris/core/services/wss/SoapService.html
[apache-cxf-soap-service]: http://development.adaptris.net/javadocs/v3-snapshot/optional/webservice-cxf/com/adaptris/core/services/cxf/ApacheSoapService.html
[snapshot]: http://development.adaptris.net/nexus/content/groups/adaptris-snapshots/com/adaptris/adp-webservice-external/
[release]: http://development.adaptris.net/nexus/content/groups/public/com/adaptris/adp-webservice-external/
[payload-from-metadata-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/metadata/PayloadFromMetadataService.html
[log-message-service]: http://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/services/LogMessageService.html

