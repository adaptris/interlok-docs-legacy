---
title: Interlok UI Database
keywords: interlok
tags: [developer]
sidebar: home_sidebar
permalink: developer-ui-db.html
summary: The UI has its own Database. 
---

## Interlok UI Database Overview ##

Here is a basic diagram of what the UI Database looks like:

![basic diagram of UI Database - part1](./images/ui-user-guide/db-diagram-part1.png)
![basic diagram of UI Database - part2](./images/ui-user-guide/db-diagram-part2.png)


## Interlok UI Database Schema ##

Here is a simple version of our ui database schema:
Note, Table "alert_rule_config" is listed here, but should be considered deprecated.

```sql

# The UI User 
Table "gui_user" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "first_name" varchar
  "last_name" varchar
  "password" varchar        //Hash of password, PBKDF2 with SHA-1 as the hashing algorithm.
  "password_uuid" longtext  //not used; is for 'forgot password' feature (still in backlog)
  "username" varchar
}

# The Users Role
Table "role" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "description" varchar
  "name" varchar            //"admin", "monitor", "user" or "viewOnly"
}

# Ties together the User and Role
Table "gui_user_roles" {
  "users" int               //"gui_user"."id"
  "roles" int               //"role"."id"
}

# The Adapters registered with the Dashboard
Table "adapter_entity" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "auto_discovered" bit
  "config_last_updated" datetime
  "jmx_env" varchar
  "jmx_password" varchar
  "jmx_uid" varchar         //unique identifier used in the Adapter configuration XML
  "jmx_username" varchar
  "name" varchar
  "ordering" int
  "url" varchar             //JMX URL used to connect to an Adapter
  "tags" varchar            //comma-separated values of tags used for filtering 
}

# The widgets on the runtime page
Table "widget_setting" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "adapter" varchar             //depending on the widget type, either "adapter_entity"."id" or '"adapter_entity"."url"|"adapter_entity"."jmx_uid"' e.g. "service:jmx:jmxmp://localhost:5555|my-super-adapter"
  "component_name" varchar
  "height" varchar
  "position_x" varchar
  "position_y" varchar
  "refresh_time" bigint
  "sub_type" varchar
  "type" varchar                //e.g. "details", "message-counts-chart", "platform-memory-heap-chart", etc.
  "type_name" varchar
  "width" varchar
  "widget_group" int            //"widget_group"."id"
}

# The widget group data
Table "widget_group" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "default_group" bit
  "description" varchar
  "name" varchar
  "gui_user" int                //"gui_user"."id" 
}

# The users VCS Profile
Table "vcs_profile" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "auth_impl" varchar
  "config_file_name" varchar
  "name" varchar
  "password" varchar
  "properties_file_name" varchar
  "remote_repo_url" varchar
  "revision" varchar
  "scope" varchar
  "ssh_keyfile_url" varchar
  "ssh_passphrase" varchar
  "ssh_tunnel_port" int
  "ssl_certificate_url" varchar
  "ssl_password" varchar
  "type" varchar
  "username" varchar
  "working_copy_url" varchar
  "gui_user" int                //"gui_user"."id"
}

# Data collected for the platform widgets 
Table "platform_data" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "adapter" int                 //"adapter_entity"."id"
  "type" varchar
  "value" double
}

# Data collected for the message metrics widgets 
Table "message_metrics_data" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "adapter" int                 //"adapter_entity"."id"
  "component_name" varchar
  "nb_errors" int
  "nb_messages" int
  "size" bigint
  "time_slice" datetime
}

# The alerts data
Table "alert" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "active" bit
  "active_from" datetime        //deprecated
  "active_to" datetime          //deprecated
  "author" varchar              //deprecated
  "title" varchar
  "type" varchar                //"INFORMATION", "WARNING" or "IMPORTANT"
  "value" varchar
}

# The System Preferences
Table "system_preference" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "name" varchar                //"adapterGuiConfigProjecStoreUrl", "adapterGuiConfigTemplatesUrl", "adapterGuiIdGenerator" or "adapterGuiVcsReposUrl"
  "value" varchar               // IF "name"=="adapterGuiIdGenerator" THEN "classNameAndRandomIdGenerator", "guidGenerator" or "randomNameGenerator" ELSE file location
}

# deprecated! (was going to be used to create rules based alerts)
Table "alert_rule_config" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "active" bit
  "alert_rule_class" varchar
  "alert_title" varchar
  "alert_type" varchar
  "alert_value" varchar
  "author" varchar
  "expiry_type" varchar
}

# Data for the log monitor page
Table "log_monitor" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "adapter" int             //"adapter_entity"."id"
  "appender" varchar
  "max_statements" int
  "name" varchar
  "refresh_time" bigint
}

# The filters for the log monitors
Table "log_monitor_filter" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "name" varchar
  "pattern" varchar
  "show_close" bit
  "show_highlight_opts" bit
  "variation" varchar
  "monitor" int             //"log_monitor"."id"
}

# The bookmark data for the Config Page 'Components' sidebar panel
Table "template_bookmark" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "template_id" varchar     //examples: "classpath/channel", "classpath/standard-workflow", "file-system/Soap-Web-Service"
  "gui_user" int            //"gui_user"."id"
}

# The user preference data
Table "user_preference" {
  "id" int PK
  "created" datetime
  "updated" datetime
  "name" varchar            //"actionButtonSize", "adapterManagementTimeout", "alwaysLoadActive", "alwaysShowActionButtons", "autoOpenSettingsOnAdd", "componentContainerAutoCollaspe", "dashboardTableMode", "deleteFileOnIgnoreFailedMsg", "disableRemoveConfirmDialog", "displayNameInComponentTitle", "displayWelcome", "editorVimMode", "enableTechnicalPreview", "hideWidgetChartLastIndex", "prettifyNames", "reverseOrderOfLoggingMonitor"
  "value" varchar           //IF "name"=="actionButtonSize" THEN "small", "normal" or "large" ELSE IF "name"=="adapterManagementTimeout" THEN n ELSE "true" or "false"
  "gui_user" int            //"gui_user"."id"
}
```