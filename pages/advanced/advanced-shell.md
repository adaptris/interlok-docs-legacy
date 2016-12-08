---
title: Management using a remote shell
keywords: interlok
tags: [advanced]
sidebar: home_sidebar
permalink: advanced-shell.html
---

Interlok supports an integrated Java shell called [CRaSH][]. You can use [CRaSH][] to `ssh` into your running interlok instance.

## Usage ##

To login to an interlok shell; `ssh` to host of the interlok instance providing the port and authentication details set in the [configuration](#crash-properties):

```bash
$ ssh localhost -p 2222 -l admin
Password authentication
Password:

      , ,
   .`//'.\\',             _____             ______   ______  ___    _       __
 .'/////\\\\',      /\   | ___ '.     /\   \_____ '.\__  __||___'. | |    .'  |
,//////  \\\\\.    //\\  \|   '. '.  //\\        '. '  ||       `.`| |   / /``
./////    \\\\\.  //  \\        ; : //  \\   ____,' ;  ||   _____;;| |   . .
.////      \\\,. //    \\       . ;//    \\ | ____.`   ||  '  ___. | |   | |
,//.---------'. //      \\  __.' .//      \\||         ||   `.`.   | |  .` .
 ,'----------. //        \\\   .'//        \\|         ||     `.`. | | ` .`
  ` -------.   ``         `` ``` ``         ```        ``       `` ``````
     `````                   Integration Anywhere

 Interlok Version: 3.4.1
             Host: localhost

%
```

Once logged in commands that are available can be viewed by using the `help` command:

```bash
% help
Try one of these commands with the -h or --help switch:

NAME      DESCRIPTION
adapter   Interlok Adapter Management
channel   Interlok Channel Management
interlok  Interlok Management Command
local     Interlok JMX Connection Management
man       format and display the on-line manual pages
remote    Interlok (remote) JMX Connection Management
version   Display Interlok version information
workflow  Interlok Workflow Management
help      provides basic help
```

_NOTE: Similar to normal shell commands, the interlok shell commands have manuals:_

```bash
% man local
NAME
       local - Interlok JMX Connection Management

SYNOPSIS
       local [-h | --help] COMMAND [ARGS]

DESCRIPTION
       Provides a connection to the Local JMX MBeanServerConnection

PARAMETERS
       [-h | --help]
           Display this help message

COMMANDS
       connection
           returns MBeanServerConnection connection
```

### Example Command Usage ###

Interlok shell provides two styles of commands, a single monolithic command and a pipe style command for chaining commands together.

Both of the following examples will restart the adapter:

#### Monolithic `interlok` command ####

```bash
% interlok connect --local
Connected locally

% interlok adapter restart
Adapter (MyInterlokInstance) restarted

% interlok disconnect
Connection closed
```

#### Pipe style commands ####

```bash
% local connection | adapter restart
Adapter (MyInterlokInstance) restarted
```

The style of command used is down to personal preference, but some features are only available in one command style. For example: Workflow and Channel argument completion is only available in the monolithic style command.

## Installation ##

The interlok shell libraries are not shipped by default as part of the traditional installer.  You will need to download the `com.adaptris:interlok-shell` artefacts and dependencies manually; download them directly from our [public repository][] or use [Ant+Ivy](advanced-ant-ivy-deploy.html) to deploy them.

_NOTE: interlok shell requires the interlok instance to be started with a jdk._

## Configuration ##

To enable interlok shell changes will need to be made to `bootstrap.properties`, as well an additional properties file `crash.properties`.

### Bootstrap properties ###

The following property changes will need to be made to `bootstrap.properties`, see [example](#example-bootstrapproperties) below:

| Property             | Description                                                         |
|----------------------|---------------------------------------------------------------------|
| managementComponents | New management component `crash` needs to be added                  |
| crash.config.dir     | New Property  - Location of the `crash.properties`                  |
| crash.command.dir    | New Property  - Directory for user created command (needs to exist) |


### Crash Properties ###

The new properties file `crash.properties` has lots of options which are documented on the [CRaSH][] website; see [example](#example-crashproperties) below:

| Property                    | Type                         | Description                                                                        |
|-----------------------------|------------------------------|------------------------------------------------------------------------------------|
| crash.ssh.port              | SSH Configuration            | SSH Port                                                                           |
| crash.ssh.keypath           | SSH Configuration            | SSH key path                                                                       |
| crash.ssh.keygen            | SSH Configuration            | Boolean - Automatically generate host key (works only if ssh.keypath is specified) |
| crash.ssh.idle_timeout      | SSH Configuration            | The idle-timeout for ssh sessions in milliseconds                                  |
| crash.ssh.auth_timeout      | SSH Configuration            | The authentication timeout for ssh sessions in milliseconds                        |
| crash.ssh.default_encoding  | SSH Configuration            | The default SSH encoding                                                           |
| crash.vfs.refresh_period    | VFS Configuration            | VFS refresh rate period                                                            |
| crash.auth                  | Authentication Configuration | Authentication type - Available options `simple`, `jass`, `key`                    |
| crash.auth.simple.username  | Authentication Configuration | Type `simple` - The username                                                       |
| crash.auth.simple.password  | Authentication Configuration | Type `simple` - The password                                                       |
| crash.auth.jaas.domain      | Authentication Configuration | Type `jass` - The jaas authentication domain                                       |
| crash.auth.key.path         | Authentication Configuration | Type `key` - The key path                                                          |

## Example Configuration ##

### Example - bootstrap.properties ###

```properties
adapterConfigUrl.0=file://localhost/./config/adapter.xml
managementComponents=jmx:jetty:crash
webServerConfigUrl=./config/jetty.xml
jmxserviceurl=service:jmx:jmxmp://localhost:5555

# Force jboss logging to use slf4j
sysprop.org.jboss.logging.provider=slf4j

enableLocalJndiServer=true
startAdapterQuietly=false

crash.command.dir=file://localhost./config/commands
crash.config.dir=file://localhost/./config
```

### Example - crash.properties ###


```properties
# SSH configuration
crash.ssh.port=2222
#crash.ssh.keypath=/path/to/the/key/file

# Automatically generate host key (works only if ssh.keypath is specified)
#crash.ssh.keygen=false

# The idle-timeout for ssh sessions in milliseconds
crash.ssh.idle_timeout=600000

# The authentication timeout for ssh sessions in milliseconds
crash.ssh.auth_timeout=600000

# The default SSH encoding
crash.ssh.default_encoding=UTF-8

# Telnet configuration
crash.telnet.port=5000

# VFS configuration
crash.vfs.refresh_period=1

# Simple authentication
crash.auth=simple
crash.auth.simple.username=admin
crash.auth.simple.password=admin

# Jaas authentication
#crash.auth=jaas
#crash.auth.jaas.domain=my-domain

# Key authentication
#crash.auth=key
#crash.auth.key.path=/path/to/key/file
```

[public repository]: https://development.adaptris.net/nexus/content/groups/public/com/adaptris/
[CRaSH]: http://www.crashub.org/