---
title: "AS4 with Holodeck"
keywords: interlok,as4,holodeck
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-as4-holodeck.html
summary: Getting started with AS4 with Interlok and Holodeck

---
This document is a "getting-started" guide that covers very basic steps on how to integrate file-system based message sending and receiving between Interlok and HolodeckB2B.

## HolodeckB2B installation and configuration.

For full "Getting Started" instructions please follow the guide here;

[Holodeck-b2b.org : getting-started](http://holodeck-b2b.org/documentation/getting-started/)

## Interlok configuration

1.  Download and install the latest version of Interlok

### Sending messages from Interlok

This guide assumes you have followed the getting started guide for HolodeckB2B above. If you have then you will already have messages flowing between two instances of Holodeck.

Currently the only way to send messages from Interlok is to produce the payload to the file system, specifically a directory that Holodeck has access to. Then produce the MMD message (with file extension .mmd) which references the payload location into the /Holodeck-home/data/msg_out.

An example MMD file;

  
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Example messsage meta-data document to send a message using P-Mode ex-pm-push

The message contains a JPEG image as payload
-->
<MessageMetaData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://holodeck-b2b.org/schemas/2014/06/mmd ../repository/xsd/messagemetadata.xsd"
 xmlns="http://holodeck-b2b.org/schemas/2014/06/mmd">
    <CollaborationInfo>
        <AgreementRef pmode="ex-pm-push"/>
        <ConversationId>org:holodeckb2b:test:conversation</ConversationId>
    </CollaborationInfo>
    <PayloadInfo>
        <PartInfo containment="attachment" mimeType="text/xml" location="payloads/simple_document.xml"/>
    </PayloadInfo>
</MessageMetaData>
```

Holodeck watches this directory for .mmd files and then uses the PMode specified in the MMD file to send the document and payload(s) off to the right Message Services Handler, which in our case is simply a second installation of Holodeck.

### Consuming messages from Interlok

There are currently two ways to achieve this. The first is the easiest, simply consume messages from /Holodeck-home/data/msg_in.

In the example above if you were to send a message from your first installation of Holodeck, you would setup your interlok file system consumer to consume from the second Holodeck installations msg_in directory.

The only issue with this method, although it is very easy to get started, is that the payload(s) are stored in separate files. Therefore you would need to consume the xml message, then read the payload locations and finally read those files in, which complicates Interlok configuration.

#### More advanced consuming

The second way to consume messages is a little bit fiddly to setup but makes processing of the messages easier once complete.

First we modify the PMode configuration in your /Holodeck-home/conf/pmodes/ directory. A simple push PMode may look something like this;
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
Example P-Mode configuration for a One-Way/Push scenario. 
    
This configuration reflects the sender of the message.  If you are setting up a test environment based on the "Getting Started" page from the web site 
you should install this P-Mode on instance A. 
-->
<PMode xmlns="http://holodeck-b2b.org/schemas/2014/10/pmode"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://holodeck-b2b.org/schemas/2014/10/pmode ../../repository/xsd/pmode.xsd">
    <id>ex-pm-push</id>
    <mep>http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/oneWay</mep>
    <mepBinding>http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/push</mepBinding>
    <Initiator>
        <PartyId>org:holodeckb2b:example:company:A</PartyId>
        <Role>Sender</Role>
    </Initiator>
    <Responder>
        <PartyId>org:holodeckb2b:example:company:B</PartyId>
        <Role>Receiver</Role>
    </Responder>
    <Agreement>
        <name>http://agreements.holodeckb2b.org/examples/agreement0</name>
    </Agreement>
    <Leg>
        <Protocol>
            <!-- Change the URL below to reflect the location where the receiving MSH is listening for messages -->
            <Address>http://localhost:9090/msh</Address>
        </Protocol>
        <Receipt>
            <NotifyReceiptToBusinessApplication>true</NotifyReceiptToBusinessApplication>
        </Receipt>
        <DefaultDelivery>
            <DeliveryMethod>org.holodeckb2b.deliverymethod.file.FileDeliveryFactory</DeliveryMethod>
            <Parameter>
                <name>format</name>
                <value>ebms</value>
            </Parameter>
            <Parameter>
                <name>deliveryDirectory</name>
                <value>data/msg_in</value>
            </Parameter>
        </DefaultDelivery>
        <UserMessageFlow>
            <BusinessInfo>
                <Action>StoreMessage</Action>
                <Service>
                    <name>Examples</name>
                    <type>org:holodeckb2b:services</type>
                </Service>
            </BusinessInfo>         
            <ErrorHandling>
                <NotifyErrorToBusinessApplication>true</NotifyErrorToBusinessApplication>
            </ErrorHandling>    
            <PayloadProfile>
                <UseAS4Compression>true</UseAS4Compression>
            </PayloadProfile>
        </UserMessageFlow>
    </Leg>
</PMode>
```

The delivery mode tells Holodeck where/how to send messages to your business application. We will change this configuration to use a custom Interlok delivery method.
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!--
Example P-Mode configuration for a One-Way/Push scenario. 
    
This configuration reflects the sender of the message.  If you are setting up a test environment based on the "Getting Started" page from the web site 
you should install this P-Mode on instance A. 
-->
<PMode xmlns="http://holodeck-b2b.org/schemas/2014/10/pmode"
 xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://holodeck-b2b.org/schemas/2014/10/pmode ../../repository/xsd/pmode.xsd">
    <id>ex-pm-push</id>
    <mep>http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/oneWay</mep>
    <mepBinding>http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/push</mepBinding>
    <Initiator>
        <PartyId>org:holodeckb2b:example:company:A</PartyId>
        <Role>Sender</Role>
    </Initiator>
    <Responder>
        <PartyId>org:holodeckb2b:example:company:B</PartyId>
        <Role>Receiver</Role>
    </Responder>
    <Agreement>
        <name>http://agreements.holodeckb2b.org/examples/agreement0</name>
    </Agreement>
    <Leg>
        <Protocol>
            <!-- Change the URL below to reflect the location where the receiving MSH is listening for messages -->
            <Address>http://localhost:9090/msh</Address>
        </Protocol>
        <Receipt>
            <NotifyReceiptToBusinessApplication>true</NotifyReceiptToBusinessApplication>
        </Receipt>
        <DefaultDelivery>
			<DeliveryMethod>com.adaptris.holodeck.InterlokDeliveryFactory</DeliveryMethod>
			<Parameter>
				<name>userMessageServicePath</name>
				<value>conf/interlok-user-wmq.xml</value>
			</Parameter>
			<Parameter>
				<name>signalMessageServicePath</name>
				<value>conf/interlok-signal-wmq.xml</value>
			</Parameter>
        </DefaultDelivery>
        <UserMessageFlow>
            <BusinessInfo>
                <Action>StoreMessage</Action>
                <Service>
                    <name>Examples</name>
                    <type>org:holodeckb2b:services</type>
                </Service>
            </BusinessInfo>         
            <ErrorHandling>
                <NotifyErrorToBusinessApplication>true</NotifyErrorToBusinessApplication>
            </ErrorHandling>    
            <PayloadProfile>
                <UseAS4Compression>true</UseAS4Compression>
            </PayloadProfile>
        </UserMessageFlow>
    </Leg>
</PMode>
```

Notice with this PMode configuration we are using the InterlokDeliveryFactory as the delivery method. We have also specified two parameters;
```xml
			<Parameter>
				<name>userMessageServicePath</name>
				<value>conf/interlok-user-wmq.xml</value>
			</Parameter>
			<Parameter>
				<name>signalMessageServicePath</name>
				<value>conf/interlok-signal-wmq.xml</value>
			</Parameter>
```

The Interlok delivery method will also require two XStream marshalled services. So simply create a small Interlok configuration xml file that only has a service or service-collection.

The first Interlok service is for user messages, these are the standard AS4 messages sent and received by AS4 message handlers, like Holodeck. The second Interlok service configuration is used for receipts.

Our custom Interlok delivery method will unmarshall your service configuration and run the services for all user and receipt messages.

As an example, I have created an interlok-user-wmq.xml configuration and simply has a standalone producer that sends AS4 messages received by Holodeck to WebsphereMQ. It is then a simple job of configuring Interlok to listen on this queue.
```xml
<service-collection class="service-list">
	<unique-id>hopeful-leavitt</unique-id>
	<services>
		<standalone-producer>
			<unique-id>stupefied-goldstine</unique-id>
			<connection class="jms-connection">
				<unique-id>admiring-hamilton</unique-id>
				<user-name></user-name>
				<vendor-implementation class="standard-jndi-implementation">
					<jndi-params>
						<key-value-pair>
							<key>java.naming.factory.initial</key>
							<value>com.sun.jndi.fscontext.RefFSContextFactory</value>
						</key-value-pair>
						<key-value-pair>
							<key>java.naming.provider.url</key>
							<value>file:/F:/Programs/IBM/MQ-JNDI/</value>
						</key-value-pair>
					</jndi-params>
					<jndi-name>ConnectionFactory</jndi-name>
					<extra-factory-configuration class="no-op-jndi-factory-configuration"/>
				</vendor-implementation>
			</connection>
			<producer class="jms-queue-producer">
				<unique-id>clever-golick</unique-id>
				<destination class="configured-produce-destination">
					<destination>queue:///Sample.Q1?ccsid=819</destination>
				</destination>
				<acknowledge-mode>CLIENT_ACKNOWLEDGE</acknowledge-mode>
				<correlation-id-source class="null-correlation-id-source"/>
				<delivery-mode>PERSISTENT</delivery-mode>
				<session-factory class="jms-default-producer-session"/>
			</producer>
		</standalone-producer>
	</services>
</service-collection>
```

The final configuration is to move jar files from your Interlok installation into the /Holodeck-home/lib/ directory. Unfortunately we cannot simply modify the Holodeck startup scripts to include the entire Interlok lib directory on the classpath, because there appears to be several JAR file clashes.

This means we need to copy over only the Jar files we need from Interlok to Holodeck's lib directory. For the example I am using above, I copied interlok-holodeck.jar, interlok-core.jar, XStream.jar, c3p0.jar, interlok-logging.jar and all of the standard Websphere MQ client jars.

Now the real bonus of using this method rather than the simpler file system method is that messages received by Interlok contain the payload(s) (Base64 encoded) of the AS4 messages as well, there are no separate files.

Given the setup above when Holodeck receives a message such as the following;
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!-- 
Example messsage meta-data document to send a message using P-Mode ex-pm-push

The message contains a JPEG image as payload
-->
<MessageMetaData xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
 xsi:schemaLocation="http://holodeck-b2b.org/schemas/2014/06/mmd ../repository/xsd/messagemetadata.xsd"
 xmlns="http://holodeck-b2b.org/schemas/2014/06/mmd">
    <CollaborationInfo>
        <AgreementRef pmode="ex-pm-push"/>
        <ConversationId>org:holodeckb2b:test:conversation</ConversationId>
    </CollaborationInfo>
    <PayloadInfo>
        <PartInfo containment="attachment" mimeType="text/xml" location="payloads/simple_document.xml"/>
    </PayloadInfo>
</MessageMetaData>
```

Our Interlok delivery method will send the following EBMS message to WMQ;
```xml
<ebmsMessage>
	<eb3:UserMessage
		xmlns:eb3="http://docs.oasis-open.org/ebxml-msg/ebms/v3.0/ns/core/200704/">
		<eb3:MessageInfo>
			<eb3:Timestamp>2018-05-17T15:17:42.821Z</eb3:Timestamp>
			<eb3:MessageId>0338216c-8991-467f-a4e1-e3fbf1eba361@DESKTOP-A7UVQ28.home</eb3:MessageId>
		</eb3:MessageInfo>
		<eb3:PartyInfo>
			<eb3:From>
				<eb3:PartyId>org:holodeckb2b:example:company:A</eb3:PartyId>
				<eb3:Role>Sender</eb3:Role>
			</eb3:From>
			<eb3:To>
				<eb3:PartyId>org:holodeckb2b:example:company:B</eb3:PartyId>
				<eb3:Role>Receiver</eb3:Role>
			</eb3:To>
		</eb3:PartyInfo>
		<eb3:CollaborationInfo>
			<eb3:AgreementRef>http://agreements.holodeckb2b.org/examples/agreement0</eb3:AgreementRef>
			<eb3:Service type="org:holodeckb2b:services">Examples</eb3:Service>
			<eb3:Action>StoreMessage</eb3:Action>
			<eb3:ConversationId>org:holodeckb2b:test:conversation</eb3:ConversationId>
		</eb3:CollaborationInfo>
		<eb3:PayloadInfo>
			<eb3:PartInfo
				href="cid:0338216c-8991-467f-a4e1-e3fbf1eba361-71771922@DESKTOP-A7UVQ28.home">
				<eb3:PartProperties>
					<eb3:Property name="MimeType">text/xml</eb3:Property>
				</eb3:PartProperties>
			</eb3:PartInfo>
		</eb3:PayloadInfo>
		<eb3:PayloadInfo>
			<eb3:PartInfo
				href="cid:0338216c-8991-467f-a4e1-e3fbf1eba361-71771922@DESKTOP-A7UVQ28.home">
				<eb3:PartProperties>
					<eb3:Property name="MimeType">text/xml</eb3:Property>
					<eb3:Property name="org:holodeckb2b:ref">pl-1</eb3:Property>
				</eb3:PartProperties>
			</eb3:PartInfo>
		</eb3:PayloadInfo>
	</eb3:UserMessage>
</ebmsMessage>
<Payloads>
	<Payload xml:id="pl-1">PD94bWwgdmVyc2lvbj0iMS4wIiBlbmNvZGluZz0iVVRGLTgiPz4KPGV4YW1wbGUtZG9jdW1lbnQ+CiAgICA8Y29udGVudD4KICAgICAgICBUaGlzIGlzIGp1c3QgYSB2ZXJ5IHNpbXBsZSBYTUwgZG9jdW1lbnQgdG8gc2hvdyB0cmFuc3BvcnQgb2YgWE1MIHBheWxvYWRzIGluIHRoZSBTT0FQIGJvZHkKICAgIDwvY29udGVudD4KPC9leGFtcGxlLWRvY3VtZW50Pgo=
	</Payload>
</Payloads>
</ebmsMessage>
```

Interlok can consume this EBMS message and do as it wishes with payloads and metadata.

Receipts work in the same way, once Holodeck has sent our message off to an AS4 Message Handler Service, we may get a received receipt also called a signal message. The second Interlok service configuration will handle those receipts.

In the above example, I simply duplicated the user-message service configuration, but just changed the queue to where I want the signal/receipt messages to be sent.