---
title: Microsoft Office365 Outlook Email (Azure via Graph API)
keywords: interlok
tags: [cookbook, messaging, microsoft, office365, outlook, azure]
sidebar: home_sidebar
permalink: cookbook-outlook365.html
summary: Interlok-Mail now provides a way to use Outlook with Office365
---

Both the Office365 consumer and producer are new additions to
Interlok-Mail, that allow for the receiving and sending of email using
Microsoft Outlook accounts via Azure and their Graph API. One major
benefit of this is the increased security and use of [OAuth2 tokens][1].
It also removes the need to understand the IMAP/SMTP protocols. That
said, it's not without its own set of headaches, particularly revolving
around the setup and configuration of the Azure application.

## Prerequisites

* Active Office365 subscription
* An Azure Active Directory application with application the following
  permissions, and with [Admin Consent][2] granted:
  - Mail.Read
  - Mail.ReadBasic
  - Mail.ReadBasic.All
  - Mail.ReadWrite
  - Mail.Send
  - User.Read
  - User.Read.All
* A user to send/receive email

The Office365 consumer and producer require the above because:
* Daemon applications can work only in Azure AD tenants
* As users cannot interact with daemon applications, incremental
  consent isn't possible
* Users require an Exchange mailbox to send/receive email, and this
  requires an [Office365 subscription][3]

## Azure Application Setup

1. Register an application in the Azure Portal
![Application Registration](images/cookbook/outlook365/o365-1.png)

2. Add a client secret so that the app can identify itself
![Client Secret](images/cookbook/outlook365/o365-2.png)

3. Add the necessary permissions
![Permissions](images/cookbook/outlook365/o365-3.png)

4. Ensure there is a user with an Exchange mailbox
![Users Setup](images/cookbook/outlook365/o365-4.png)

## Interlok-Mail Setup

The application ID, tenant ID, client secret and username are all
required and should match those given in the Azure portal. When sending
mail a list of recipients is also required.

### Consumer Configuration

For the consumer to be able to retrieve messages it requires several key
bits of information, in addition to what is necessary for a polling
consumer:

* Application ID; the unique ID given to the Azure application
* Tenant ID; the unique ID of the tenant that the application is
  associated with
* Client secret; essentially the password the application uses to
  authenticate with Azure
* Username; the email address from which to poll for new messages
* Delete; whether the emails should be deleted instead of marked as read

```xml
    <standalone-consumer>
     <connection class="null-connection"/>
     <consumer class="office-365-mail-consumer">
      <message-factory class="multi-payload-message-factory">
       <default-char-encoding>UTF-8</default-char-encoding>
       <default-payload-id>default-payload</default-payload-id>
      </message-factory>
      <poller class="quartz-cron-poller">
       <cron-expression>0 */5 * * * ?</cron-expression>
      </poller>
      <application-id>47ea49b0-670a-47c1-9303-0b45ffb766ec</application-id>
      <tenant-id>cbf4a38d-3117-48cd-b54b-861480ee93cd</tenant-id>
      <client-secret>NGMyYjY0MTEtOTU0Ny00NTg0LWE3MzQtODg2ZDAzZGVmZmY1Cg==</client-secret>
      <username>user@example.com</username>
      <delete>false</delete>
     </consumer>
    </standalone-consumer>
```

### Producer Configuration

The producer needs much of the same configuration as the consumer:
application ID, tenant ID, client secret, and username of sender. It
also requires a lot of the same information as the standard mail
producer (all of which is resolvable from the Adaptris Message):
subject, comma separated lists of recipients (To/CC/BCC). There is also
the option to save the sent mail.

```xml
    <standalone-producer>
     <unique-id>f7daa8c3-15fc-4fbd-a2a1-c0028c52fa12</unique-id>
     <connection class="null-connection"/>
     <producer class="office-365-mail-producer">
      <application-id>47ea49b0-670a-47c1-9303-0b45ffb766ec</application-id>
      <tenant-id>cbf4a38d-3117-48cd-b54b-861480ee93cd</tenant-id>
      <client-secret>NGMyYjY0MTEtOTU0Ny00NTg0LWE3MzQtODg2ZDAzZGVmZmY1Cg==</client-secret>
      <username>user@example.com</username>
      <subject>Interlok-Mail Office365 Test Message</subject>
      <to-recipients>user@example.com</to-recipients>
      <save>true</save>
     </producer>
    </standalone-producer>
```

## Miscellaneous Notes/URLs


[1]: https://docs.microsoft.com/en-us/azure/active-directory/develop/msal-overview
[2]: https://docs.microsoft.com/en-us/azure/active-directory/develop/scenario-daemon-overview
[3]: https://docs.microsoft.com/en-us/microsoft-365/enterprise/azure-integration?view=o365-worldwide

[8]: https://developer.microsoft.com/en-us/graph/graph-explorer
[9]: https://github.com/Azure-Samples/active-directory-java-native-headless-v2
