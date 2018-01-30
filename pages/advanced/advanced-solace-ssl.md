---
title: Interlok SSL with Solace
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-solace-ssl.html
summary: This page describes how to configure Interlok to use SSL with Solace.
---

## Pre-requisites ##

It is assumed you have a full install of Interlok and already have standard JMS connections to Solace up and running.

You will also need to ask your Solace administrator to provide you with the Solace Message VPN certificate which we will load into our client side Trust Store and a list of accepted ciphers.

Finally you will need a client certificate which you will provide to your Solace administrators and be loaded into our client key store.

## Configuring the client ##

### Creating the Trust Store ###

Here we will be creating the client trust store which Interlok will use to access the Solace Message VPN's certificate.

Using the Java "keytool", which can be found in your local JDK or JRE we will import the Solace Message VPN's certificate into a new Trust Store.

You can create the Trust Store in any directory you wish.  Navigate to the chosen directory on the command line and then import the certificate using the java keytool.

```
 > keytool.exe -import -file C:\SolaceCerts\SolaceCA.cert -alias solaceCA -keystore myTrustStore
```

The documentation for the keytool can be found here: [KeyTool](https://docs.oracle.com/javase/6/docs/technotes/tools/solaris/keytool.html)

### Creating the Key Store ###

Again using the Java KeyTool, navigate to the directory you wish to store the clients key store and run the keytool;

```
> keytool.exe -keystore myKeystore -genkey -alias client
```

Now you can import your client certificate into the key store;

```
> keytool.exe -import -keystore myKeystore -file myClientCetr.cer -alias client
```

Make sure you provide this certificate to your Solace Administrators.

### Configuring Interlok ###

Using our JNDI connection, you will need to add a few Solace specific JNDI properties to your connection.

So the below example of each with a short description of the required value.

```
<connection class="jms-connection">
<unique-id>MySolaceSSLConnection</unique-id>
	<user-name>MyUsername</user-name>
	<password>MyPassword</password>
	<vendor-implementation class="standard-jndi-implementation">
		<jndi-params>
			<key-value-pair>
				<key>Solace_JMS_Authentication_Scheme</key>
				<value>AUTHENTICATION_SCHEME_CLIENT_CERTIFICATE</value>
			</key-value-pair>
			<key-value-pair>
				<key>Solace_JMS_SSL_TrustStore</key>
				<value>Path to the client Trust Store</value>
			</key-value-pair>
			<key-value-pair>
				<key>Solace_JMS_SSL_TrustStorePassword</key>
				<value>Password of the client Trust Store</value>
			</key-value-pair>
			<key-value-pair>
				<key>java.naming.security.principal</key>
				<value>myUsername</value>
			</key-value-pair>
			<key-value-pair>
				<key>Solace_JMS_SSL_KeyStore</key>
				<value>Path to the client Key Store</value>
			</key-value-pair>
			<key-value-pair>
				<key>Solace_JMS_SSL_KeyStorePassword</key>
				<value>Password of the client Key Store</value>
			</key-value-pair>
			<key-value-pair>
				<key>java.naming.factory.initial</key>
				<value>com.solacesystems.jndi.SolJNDIInitialContextFactory</value>
			</key-value-pair>
			<key-value-pair>
				<key>java.naming.provider.url</key>
				<value>solace.host.name</value>
			</key-value-pair>
			<key-value-pair>
				<key>Solace_JMS_SSL_CipherSuites</key>
				<value>List of accepted cipher suites</value>
			</key-value-pair>
			<key-value-pair>
				<key>java.naming.security.credentials</key>
				<value>myPassword</value>
			</key-value-pair>
		</jndi-params>
		<jndi-name>my-connection-factory</jndi-name>
		<extra-factory-configuration class="no-op-jndi-factory-configuration"/>
	</vendor-implementation>
</connection>
```

