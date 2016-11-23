---
title: Change log
keywords: interlok
tags: [getting_started]
sidebar: home_sidebar
permalink: changelog.html
summary: This is the change log summarizing the key changes in Interlok for each release.
toc: false
---

## Version 3.5.0 ##

Release Date : 2018-11-18

### Bugs

- [INTERLOK-243](https://adaptris.atlassian.net/browse/INTERLOK-243) - Enum config values don't work with user friendly display name
- [INTERLOK-771](https://adaptris.atlassian.net/browse/INTERLOK-771) - VSC-Git Jars Not Delivered as part of baseline deliverable
- [INTERLOK-1086](https://adaptris.atlassian.net/browse/INTERLOK-1086) - UI Config - support TransactionManager for shared components
- [INTERLOK-1106](https://adaptris.atlassian.net/browse/INTERLOK-1106) - Change the default URL for javadocs
- [INTERLOK-1188](https://adaptris.atlassian.net/browse/INTERLOK-1188) - UI Doc - Link to ui user security doc page in the ui api doc page is broken
- [INTERLOK-1191](https://adaptris.atlassian.net/browse/INTERLOK-1191) - Validation-api breaks Webservices and Restful components
- [INTERLOK-1193](https://adaptris.atlassian.net/browse/INTERLOK-1193) - XSLT Broken: java.lang.NoClassDefFoundError: org/apache/commons/lang3/StringUtils
- [INTERLOK-1195](https://adaptris.atlassian.net/browse/INTERLOK-1195) - When loading an existing XML config into the UI and trying to apply it there is no OK box on both Safari and Chrome
- [INTERLOK-1196](https://adaptris.atlassian.net/browse/INTERLOK-1196) - When logging in there is a glass fish error reported on the UI
- [INTERLOK-1197](https://adaptris.atlassian.net/browse/INTERLOK-1197) - ClassCastException when using 3.4.1 with profiler based failover
- [INTERLOK-1198](https://adaptris.atlassian.net/browse/INTERLOK-1198) - UI - Logging not working on edge because the event origin is undefined
- [INTERLOK-1204](https://adaptris.atlassian.net/browse/INTERLOK-1204) - ant test does not work with openjdk-8-102 (azul systems)
- [INTERLOK-1227](https://adaptris.atlassian.net/browse/INTERLOK-1227) - removed dependency on jquery flot js files
- [INTERLOK-1248](https://adaptris.atlassian.net/browse/INTERLOK-1248) - Typo in the add adpter button title



### Improvements

- [INTERLOK-739](https://adaptris.atlassian.net/browse/INTERLOK-739) - Use Vert X as a wrapper for adapter components
- [INTERLOK-912](https://adaptris.atlassian.net/browse/INTERLOK-912) - UI VCS - add SSH support for VCS Profiles
- [INTERLOK-1009](https://adaptris.atlassian.net/browse/INTERLOK-1009) - Support alternative password encryption methods
- [INTERLOK-1133](https://adaptris.atlassian.net/browse/INTERLOK-1133) - Sort out the browser tab title
- [INTERLOK-1138](https://adaptris.atlassian.net/browse/INTERLOK-1138) - Add a MBean to FSConsumer to display "how many files there are to process"
- [INTERLOK-1143](https://adaptris.atlassian.net/browse/INTERLOK-1143) - JMS Translators - producer should default to the same message implementation as the consumer
- [INTERLOK-1146](https://adaptris.atlassian.net/browse/INTERLOK-1146) - Make logging monitor tabs re-orderable
- [INTERLOK-1147](https://adaptris.atlassian.net/browse/INTERLOK-1147) - UI API - Extend the REST API to "test service-collection"
- [INTERLOK-1151](https://adaptris.atlassian.net/browse/INTERLOK-1151) - Create an AggregatingFTPConsumer
- [INTERLOK-1156](https://adaptris.atlassian.net/browse/INTERLOK-1156) - UI Config - improve the change-type dropdown selector
- [INTERLOK-1167](https://adaptris.atlassian.net/browse/INTERLOK-1167) - UI Config - Improve the auto generated component names
- [INTERLOK-1169](https://adaptris.atlassian.net/browse/INTERLOK-1169) - UI - improve the welcome splash modal so it always fits on a single screen
- [INTERLOK-1171](https://adaptris.atlassian.net/browse/INTERLOK-1171) - UI Logging - impl a performance mode for the log monitor page
- [INTERLOK-1173](https://adaptris.atlassian.net/browse/INTERLOK-1173) - UI Config - Generate Adapter Config from swagger.yaml
- [INTERLOK-1175](https://adaptris.atlassian.net/browse/INTERLOK-1175) - UI - Build Framework for Auto Generation of alerts
- [INTERLOK-1176](https://adaptris.atlassian.net/browse/INTERLOK-1176) - UI - Add tests for ConfigController and AlertServiceImpl
- [INTERLOK-1202](https://adaptris.atlassian.net/browse/INTERLOK-1202) - UI Footer - Display UI vesion number in the page footer
- [INTERLOK-1203](https://adaptris.atlassian.net/browse/INTERLOK-1203) - interlok-json - Add JsonPath SyntaxIdentifier to be used in SyntaxBranchingService
- [INTERLOK-1205](https://adaptris.atlassian.net/browse/INTERLOK-1205) - Allow CloneMessageServiceList to override metadata
- [INTERLOK-1207](https://adaptris.atlassian.net/browse/INTERLOK-1207) - Interlok Service Testing Framework
- [INTERLOK-1209](https://adaptris.atlassian.net/browse/INTERLOK-1209) - AddTimestampMetadataService should have a "lastmsg" variable.
- [INTERLOK-1211](https://adaptris.atlassian.net/browse/INTERLOK-1211) - Extend FormattedMetadataDestination for key=value
- [INTERLOK-1215](https://adaptris.atlassian.net/browse/INTERLOK-1215) - Interlok Service Test Template
- [INTERLOK-1217](https://adaptris.atlassian.net/browse/INTERLOK-1217) - Add support for SSH via proxies for vcs-git
- [INTERLOK-1218](https://adaptris.atlassian.net/browse/INTERLOK-1218) - Interlok Service Test - WireMock Helper
- [INTERLOK-1247](https://adaptris.atlassian.net/browse/INTERLOK-1247) - Update JSonPathSplitterTest to create useful example-xml
- [INTERLOK-1250](https://adaptris.atlassian.net/browse/INTERLOK-1250) - Change FileDataInputParameter & FileDataOutputParameter to use MessageDrivenDestination


## Version 3.4.1 ##

Release Date : 2016-10-05

> Because of issues with XStream and AliasedJavaBeanConverter not honouring some annotations; if you are using [JmsTransactedWorkflow][] you will need to remove any interceptors manually and reconfigure them after upgrading.

### Bugs


- [INTERLOK-857](https://adaptris.atlassian.net/browse/INTERLOK-857) - Input field rendered too small
- [INTERLOK-959](https://adaptris.atlassian.net/browse/INTERLOK-959) - Hard coded references to bootstrap.properties
- [INTERLOK-1099](https://adaptris.atlassian.net/browse/INTERLOK-1099) - SLF4J bridge should remove all existing handlers
- [INTERLOK-1109](https://adaptris.atlassian.net/browse/INTERLOK-1109) - No way to set statement in JDBC Data Query Service via standard UI
- [INTERLOK-1110](https://adaptris.atlassian.net/browse/INTERLOK-1110) - UI - Upgrade to apache shiro 1.2.6
- [INTERLOK-1112](https://adaptris.atlassian.net/browse/INTERLOK-1112) - Adapter-Web-GUI fails to start depending on optional component dependencies
- [INTERLOK-1113](https://adaptris.atlassian.net/browse/INTERLOK-1113) - jms+jmx depends on spring 3.2 which breaks the UI
- [INTERLOK-1116](https://adaptris.atlassian.net/browse/INTERLOK-1116) - JMSProducerImpl get/set Priority has behaviour
- [INTERLOK-1145](https://adaptris.atlassian.net/browse/INTERLOK-1145) - Still too much pointless logging from the UI
- [INTERLOK-1157](https://adaptris.atlassian.net/browse/INTERLOK-1157) - Jetty Consumer does not support PATCH
- [INTERLOK-1158](https://adaptris.atlassian.net/browse/INTERLOK-1158) - UI Widgets - platform runtime details VM arguments showing a js function
- [INTERLOK-1159](https://adaptris.atlassian.net/browse/INTERLOK-1159) - Initial Adapter start failure leaves channels in an inconsistent state
- [INTERLOK-1161](https://adaptris.atlassian.net/browse/INTERLOK-1161) - Basic Solace Implementation requires both Broker URL and Hostname
- [INTERLOK-1162](https://adaptris.atlassian.net/browse/INTERLOK-1162) - Queue producer template autofills spaces in queue name
- [INTERLOK-1163](https://adaptris.atlassian.net/browse/INTERLOK-1163) - Solace JMS Replicated VPN failover doesn't work with Solace JMS API 7.1.2
- [INTERLOK-1166](https://adaptris.atlassian.net/browse/INTERLOK-1166) - MqSeriesImplementations extends URLVendorImplementation incorrectly

### Improvement

- [INTERLOK-777](https://adaptris.atlassian.net/browse/INTERLOK-777) - Update javamail to 1.5.5
- [INTERLOK-964](https://adaptris.atlassian.net/browse/INTERLOK-964) - Add an annotation that defines that a given member affects metadata
- [INTERLOK-965](https://adaptris.atlassian.net/browse/INTERLOK-965) - UI Config - Add a Generate ID Button on the settings editor
- [INTERLOK-976](https://adaptris.atlassian.net/browse/INTERLOK-976) - UI - Alerts / Notes module required
- [INTERLOK-1031](https://adaptris.atlassian.net/browse/INTERLOK-1031) - Have a CraSH instance embedded as a management component
- [INTERLOK-1033](https://adaptris.atlassian.net/browse/INTERLOK-1033) - UI Widgets - Convert existing Memory and System load chart to C3
- [INTERLOK-1043](https://adaptris.atlassian.net/browse/INTERLOK-1043) - UI - Quick Edit Config & Apply
- [INTERLOK-1049](https://adaptris.atlassian.net/browse/INTERLOK-1049) - XA - Review startup/shutdown
- [INTERLOK-1058](https://adaptris.atlassian.net/browse/INTERLOK-1058) - UI Logging - update the logging monitor to use websockets to gain data
- [INTERLOK-1063](https://adaptris.atlassian.net/browse/INTERLOK-1063) - UI Dashboard - Add "delete" functionality to "ignore error" functionality
- [INTERLOK-1068](https://adaptris.atlassian.net/browse/INTERLOK-1068) - UI - Upgrade the UI to use jersey 2.x
- [INTERLOK-1078](https://adaptris.atlassian.net/browse/INTERLOK-1078) - Use JDBC Batching In Data Query Service
- [INTERLOK-1079](https://adaptris.atlassian.net/browse/INTERLOK-1079) - 'Web Services' Security
- [INTERLOK-1081](https://adaptris.atlassian.net/browse/INTERLOK-1081) - UI Config - improve the visuals of the branching service list
- [INTERLOK-1082](https://adaptris.atlassian.net/browse/INTERLOK-1082) - In settings modal merge the 2 ways to add sub component
- [INTERLOK-1093](https://adaptris.atlassian.net/browse/INTERLOK-1093) - UI Config - Improve the action buttons on the edit component modal
- [INTERLOK-1097](https://adaptris.atlassian.net/browse/INTERLOK-1097) - Add a XALAN based transformer factory
- [INTERLOK-1098](https://adaptris.atlassian.net/browse/INTERLOK-1098) - MimeAggregator + subclasses should allow you to set the content-type
- [INTERLOK-1102](https://adaptris.atlassian.net/browse/INTERLOK-1102) - AdaptrisMessageConsumerImp to be StateManaged
- [INTERLOK-1107](https://adaptris.atlassian.net/browse/INTERLOK-1107) - Shell - Single Message injection command(s)
- [INTERLOK-1108](https://adaptris.atlassian.net/browse/INTERLOK-1108) - Shell - Documentation
- [INTERLOK-1115](https://adaptris.atlassian.net/browse/INTERLOK-1115) - Remove use of org.glassfish.hk2.external
- [INTERLOK-1117](https://adaptris.atlassian.net/browse/INTERLOK-1117) - Add an adapter reload to interlok-shell
- [INTERLOK-1119](https://adaptris.atlassian.net/browse/INTERLOK-1119) - Add a JSON ResultSetTranslator
- [INTERLOK-1120](https://adaptris.atlassian.net/browse/INTERLOK-1120) - Add a monolithic "interlok" command to interlok-shell
- [INTERLOK-1121](https://adaptris.atlassian.net/browse/INTERLOK-1121) - Add tab "Completion" to channel and workflow interlok-shell commands
- [INTERLOK-1124](https://adaptris.atlassian.net/browse/INTERLOK-1124) - Have JDBCDataQueryService report the number of results from the query
- [INTERLOK-1125](https://adaptris.atlassian.net/browse/INTERLOK-1125) - UI - Change the way Branching Service Collection First Service are added
- [INTERLOK-1131](https://adaptris.atlassian.net/browse/INTERLOK-1131) - Add large message support to JSON packages where possible.
- [INTERLOK-1132](https://adaptris.atlassian.net/browse/INTERLOK-1132) - interlok-shell add the ability to set JMX username and password
- [INTERLOK-1134](https://adaptris.atlassian.net/browse/INTERLOK-1134) - Testing Branching Service Collection is "confusing".
- [INTERLOK-1135](https://adaptris.atlassian.net/browse/INTERLOK-1135) - NextServiceID is never displayed during a "test service" unless part of a BranchingServiceCollection test
- [INTERLOK-1143](https://adaptris.atlassian.net/browse/INTERLOK-1143) - JMS Translators - producer should default to the same message implementation as the consumer
- [INTERLOK-1148](https://adaptris.atlassian.net/browse/INTERLOK-1148) - UI Logging - the 2nd line tabs to show a filtered subset of results from the all tab
- [INTERLOK-1152](https://adaptris.atlassian.net/browse/INTERLOK-1152) - Add "Inflight Messages" to REST API
- [INTERLOK-1155](https://adaptris.atlassian.net/browse/INTERLOK-1155) - Shell - Set payload from file in message-inject
- [INTERLOK-1165](https://adaptris.atlassian.net/browse/INTERLOK-1165) - JmsConnection should default a JmsConnectionErrorHandler

## Version 3.4.0 ##

Release Date : 2016-08-22


### Bugs
- [INTERLOK-1006](https://adaptris.atlassian.net/browse/INTERLOK-1006) - PropertyResolver throws a NPE
- [INTERLOK-1012](https://adaptris.atlassian.net/browse/INTERLOK-1012) - AWS does not expose Proxy configuration
- [INTERLOK-1019](https://adaptris.atlassian.net/browse/INTERLOK-1019) - JdbcDataCaptureService doesn't support NamedParameterApplicator
- [INTERLOK-1021](https://adaptris.atlassian.net/browse/INTERLOK-1021) - Simple failover doesn't work with non-default locations for config
- [INTERLOK-1032](https://adaptris.atlassian.net/browse/INTERLOK-1032) - In the log monitor page switching between 2 tabs with different appender keep the previous tab data
- [INTERLOK-1050](https://adaptris.atlassian.net/browse/INTERLOK-1050) - Test Service (BranchingServiceCollection) doesn't branch!
- [INTERLOK-1052](https://adaptris.atlassian.net/browse/INTERLOK-1052) - VCS (git) integration does not hard-reset
- [INTERLOK-1061](https://adaptris.atlassian.net/browse/INTERLOK-1061) - Message Size Chart doesn't allow you to "clear" from the widget
- [INTERLOK-1062](https://adaptris.atlassian.net/browse/INTERLOK-1062) - When applying a message with no metadata to MetadataValueBranchingService the out message will have a blank nextServiceId
- [INTERLOK-1066](https://adaptris.atlassian.net/browse/INTERLOK-1066) - Metrics Chart needs to "show" the date.
- [INTERLOK-1071](https://adaptris.atlassian.net/browse/INTERLOK-1071) - Sometimes getting an IllegalArgumentException with file-sorting + large number of files.
- [INTERLOK-1091](https://adaptris.atlassian.net/browse/INTERLOK-1091) - UI Config - The search box in the add component modal is too small
- [INTERLOK-1096](https://adaptris.atlassian.net/browse/INTERLOK-1096) - When using a filtered-start for shared-components JNDI entries are not removed
- [INTERLOK-1101](https://adaptris.atlassian.net/browse/INTERLOK-1101) - XA : NullPointerException on adapter shutdown
- [INTERLOK-1103](https://adaptris.atlassian.net/browse/INTERLOK-1103) - Unable to stop adapter after XA channel restart


### Improvement

- [INTERLOK-860](https://adaptris.atlassian.net/browse/INTERLOK-860) - UI Runtime - Change the colors of the adapter, channel and workflow bar when adding a new widget to refect the color of the coonfig page
- [INTERLOK-899](https://adaptris.atlassian.net/browse/INTERLOK-899) - UI Widgets - Add capability to save/load widget settings
- [INTERLOK-925](https://adaptris.atlassian.net/browse/INTERLOK-925) - UI Widgets - Widget data should persist
- [INTERLOK-934](https://adaptris.atlassian.net/browse/INTERLOK-934) - UI - Trap JMX connection exceptions
- [INTERLOK-943](https://adaptris.atlassian.net/browse/INTERLOK-943) - UI Widgets - Have mulitple pages of widgets
- [INTERLOK-946](https://adaptris.atlassian.net/browse/INTERLOK-946) - UI Config - Use the default annotation to create help titles/popovers on default boolean labels etc.
- [INTERLOK-963](https://adaptris.atlassian.net/browse/INTERLOK-963) - Simple Failover
- [INTERLOK-972](https://adaptris.atlassian.net/browse/INTERLOK-972) - UI Widgets - convert current charts to use c3
- [INTERLOK-973](https://adaptris.atlassian.net/browse/INTERLOK-973) - UI Widgets - convert page to use a better grid framework
- [INTERLOK-975](https://adaptris.atlassian.net/browse/INTERLOK-975) - Upgrade jacoco to the latest stable version 0.7.7.x
- [INTERLOK-977](https://adaptris.atlassian.net/browse/INTERLOK-977) - UI Config - Improve settings editor select impl dropdown
- [INTERLOK-981](https://adaptris.atlassian.net/browse/INTERLOK-981) - UI Widgets - create new widgets that cover dashboard features
- [INTERLOK-997](https://adaptris.atlassian.net/browse/INTERLOK-997) - Add support for jsch ConfigRepository into a SftpConnection
- [INTERLOK-1000](https://adaptris.atlassian.net/browse/INTERLOK-1000) - UI - Successful config apply should auto-close popup
- [INTERLOK-1011](https://adaptris.atlassian.net/browse/INTERLOK-1011) - Migrate interlok-optional to git + individual projects.
- [INTERLOK-1013](https://adaptris.atlassian.net/browse/INTERLOK-1013) - AWS does not report a version number
- [INTERLOK-1017](https://adaptris.atlassian.net/browse/INTERLOK-1017) - CsvResultSetTranslator needs to support both include+exclude filters.
- [INTERLOK-1020](https://adaptris.atlassian.net/browse/INTERLOK-1020) - JDBC - DataCapture and Query Service common code
- [INTERLOK-1022](https://adaptris.atlassian.net/browse/INTERLOK-1022) - Add explicit support for proxy servers into Apache HTTP
- [INTERLOK-1025](https://adaptris.atlassian.net/browse/INTERLOK-1025) - UI - Message count chart - Zero out server data
- [INTERLOK-1028](https://adaptris.atlassian.net/browse/INTERLOK-1028) - Update the maven js/css ompressor plugin
- [INTERLOK-1034](https://adaptris.atlassian.net/browse/INTERLOK-1034) - JsonJavadocsController should serve the local javadoc instead of the remote one.
- [INTERLOK-1036](https://adaptris.atlassian.net/browse/INTERLOK-1036) - Refactor FixedIntevalPoller for extensibility
- [INTERLOK-1041](https://adaptris.atlassian.net/browse/INTERLOK-1041) - Add the ability to set a maximum for SimpleSequenceNumberService
- [INTERLOK-1055](https://adaptris.atlassian.net/browse/INTERLOK-1055) - Move interlok-guassian-poller to interlok/adapter
- [INTERLOK-1056](https://adaptris.atlassian.net/browse/INTERLOK-1056) - Disable "remove component" user pref should also act on widgets
- [INTERLOK-1060](https://adaptris.atlassian.net/browse/INTERLOK-1060) - GaussianIntervalPoller shouldn't be allowed to set standard deviation of 0
- [INTERLOK-1064](https://adaptris.atlassian.net/browse/INTERLOK-1064) - Add proxy support to SFTP
- [INTERLOK-1069](https://adaptris.atlassian.net/browse/INTERLOK-1069) - Upgrade to bootsrap 3.3.7
- [INTERLOK-1076](https://adaptris.atlassian.net/browse/INTERLOK-1076) - Add tests for VcsController
- [INTERLOK-1080](https://adaptris.atlassian.net/browse/INTERLOK-1080) - Update the runtime page doc
- [INTERLOK-1083](https://adaptris.atlassian.net/browse/INTERLOK-1083) - Create Encoding and Decoding service
- [INTERLOK-1084](https://adaptris.atlassian.net/browse/INTERLOK-1084) - Add option to suppress file deletion in AggregatingFsConsumer



## Version 3.3.0 ##

Release Date : 2016-06-29

### Bugs

- [INTERLOK-390](https://adaptris.atlassian.net/browse/INTERLOK-390) - Uploading a file for testing can be broken due to encoding.
- [INTERLOK-915](https://adaptris.atlassian.net/browse/INTERLOK-915) - Stored Procedure timeouts don't support "0"
- [INTERLOK-921](https://adaptris.atlassian.net/browse/INTERLOK-921) - NullPointerException when using adp vcs subversion and not providing VCS_SSH_PASSPHRASE_KEY
- [INTERLOK-931](https://adaptris.atlassian.net/browse/INTERLOK-931) - UI - Nested Branching services take an age to load
- [INTERLOK-933](https://adaptris.atlassian.net/browse/INTERLOK-933) - AdaptrisMessage#removeHeader does not remove the header
- [INTERLOK-941](https://adaptris.atlassian.net/browse/INTERLOK-941) - Varsub should be able to use the propertyResolver
- [INTERLOK-950](https://adaptris.atlassian.net/browse/INTERLOK-950) - UI Dashboard - weird error appeared without error message (showed function)
- [INTERLOK-974](https://adaptris.atlassian.net/browse/INTERLOK-974) - IVY publish fails if the artefact is "too large"
- [INTERLOK-987](https://adaptris.atlassian.net/browse/INTERLOK-987) - JSON Transform Service - Missing Mapping Spec Options
- [INTERLOK-995](https://adaptris.atlassian.net/browse/INTERLOK-995) - If configured, Kerberos prompts block the adapter for sftp

### Improvements

- [INTERLOK-51](https://adaptris.atlassian.net/browse/INTERLOK-51) - UI Config Page - Improve the javadoc integration within the component info popovers
- [INTERLOK-54](https://adaptris.atlassian.net/browse/INTERLOK-54) - UI - Support pack - Create a support pack for a failed message / adapter that won't start
- [INTERLOK-173](https://adaptris.atlassian.net/browse/INTERLOK-173) - UI Config Page - After changing Shared Connection name, apply config is required
- [INTERLOK-548](https://adaptris.atlassian.net/browse/INTERLOK-548) - Export Config is not integrated into VCS profiles....
- [INTERLOK-602](https://adaptris.atlassian.net/browse/INTERLOK-602) - Advanced components should be able to be added in a workflow from the GUI
- [INTERLOK-642](https://adaptris.atlassian.net/browse/INTERLOK-642) - Add documentation for refreshing the UI javascript cache
- [INTERLOK-661](https://adaptris.atlassian.net/browse/INTERLOK-661) - Improve behaviour for "missing" dashboard adapters
- [INTERLOK-767](https://adaptris.atlassian.net/browse/INTERLOK-767) - Remove Perf4J Service + Annotations
- [INTERLOK-788](https://adaptris.atlassian.net/browse/INTERLOK-788) - Add DisplayOrder annotation to standard configurable components.
- [INTERLOK-806](https://adaptris.atlassian.net/browse/INTERLOK-806) - Unique ID's might need to be displayed in nested lists
- [INTERLOK-809](https://adaptris.atlassian.net/browse/INTERLOK-809) - Document javadocs-location and how to configure
- [INTERLOK-820](https://adaptris.atlassian.net/browse/INTERLOK-820) - UI Config - update export feature to use tabs / tab-tree
- [INTERLOK-828](https://adaptris.atlassian.net/browse/INTERLOK-828) - Implement a Splitter that does it by "Size"
- [INTERLOK-837](https://adaptris.atlassian.net/browse/INTERLOK-837) - Update codemirror to the latest version
- [INTERLOK-887](https://adaptris.atlassian.net/browse/INTERLOK-887) - UI - Config - Settings Labels should reflect the XStreamImplicit itemFieldName value
- [INTERLOK-890](https://adaptris.atlassian.net/browse/INTERLOK-890) - UI Config - review icon used for adding inner components in settings editor
- [INTERLOK-891](https://adaptris.atlassian.net/browse/INTERLOK-891) - Test failover - instances all in "init" state.
- [INTERLOK-895](https://adaptris.atlassian.net/browse/INTERLOK-895) - Need to filter out the aspectj messages to stderr
- [INTERLOK-897](https://adaptris.atlassian.net/browse/INTERLOK-897) - UI User - Read only user has access to force close
- [INTERLOK-901](https://adaptris.atlassian.net/browse/INTERLOK-901) - UI Config - Preview Pane for settings editor
- [INTERLOK-903](https://adaptris.atlassian.net/browse/INTERLOK-903) - UI Config/beta - Setup the initial controllers/js/html for beta page
- [INTERLOK-909](https://adaptris.atlassian.net/browse/INTERLOK-909) - Create an Error logger for the ui to request log files for support packs
- [INTERLOK-910](https://adaptris.atlassian.net/browse/INTERLOK-910) - Optional/Cassandra Fix JdbcResultSet
- [INTERLOK-911](https://adaptris.atlassian.net/browse/INTERLOK-911) - UI Dashboard - Create a UI page that allows user to create a support pack
- [INTERLOK-913](https://adaptris.atlassian.net/browse/INTERLOK-913) - Make use of AdapterRegistryMBean::reloadFromVersionControl()
- [INTERLOK-914](https://adaptris.atlassian.net/browse/INTERLOK-914) - Stored Procedure Parameter Logging
- [INTERLOK-916](https://adaptris.atlassian.net/browse/INTERLOK-916) - UI Widgets - allow widgets to be expanded (2x or full screen)
- [INTERLOK-917](https://adaptris.atlassian.net/browse/INTERLOK-917) - Create a annotation so the ui can instruct user about default values
- [INTERLOK-918](https://adaptris.atlassian.net/browse/INTERLOK-918) - Add test for the SQL Injection protection.
- [INTERLOK-919](https://adaptris.atlassian.net/browse/INTERLOK-919) - UI - create a page for watching log messages for your configured adapters
- [INTERLOK-920](https://adaptris.atlassian.net/browse/INTERLOK-920) - Cope with Statements that sometimes don't return a result set
- [INTERLOK-928](https://adaptris.atlassian.net/browse/INTERLOK-928) - Enable IAM instance role credentials in SQS
- [INTERLOK-936](https://adaptris.atlassian.net/browse/INTERLOK-936) - UI Dashboard - Adapter Order not persisted
- [INTERLOK-938](https://adaptris.atlassian.net/browse/INTERLOK-938) - Upgrade to knockout 3.4.0
- [INTERLOK-939](https://adaptris.atlassian.net/browse/INTERLOK-939) - UI Config - Add component by XML Snippet
- [INTERLOK-942](https://adaptris.atlassian.net/browse/INTERLOK-942) - Upgrade to Fontawsome 4.6.3 + adaptris icons
- [INTERLOK-944](https://adaptris.atlassian.net/browse/INTERLOK-944) - UI Config - Improve settings editor options display
- [INTERLOK-949](https://adaptris.atlassian.net/browse/INTERLOK-949) - Make the nested complex object sortable.
- [INTERLOK-952](https://adaptris.atlassian.net/browse/INTERLOK-952) - Add Interceptor for in flight messages
- [INTERLOK-953](https://adaptris.atlassian.net/browse/INTERLOK-953) - UI Dashboard - Add the InFlight Message count display to the UI
- [INTERLOK-957](https://adaptris.atlassian.net/browse/INTERLOK-957) - Make mkdocs documentation available for download
- [INTERLOK-960](https://adaptris.atlassian.net/browse/INTERLOK-960) - Have a message count chart available by "regexp" on the channel/workflow name
- [INTERLOK-961](https://adaptris.atlassian.net/browse/INTERLOK-961) - Create a JMX Consumer that is fired when a JMX notification is received.
- [INTERLOK-962](https://adaptris.atlassian.net/browse/INTERLOK-962) - AdaptrisPollingConsumer should implement StateManagedComponent
- [INTERLOK-966](https://adaptris.atlassian.net/browse/INTERLOK-966) - UI Dashboard - consider putting inflight icon (airplane) next to adapter status icon (green tick) when inflight active
- [INTERLOK-967](https://adaptris.atlassian.net/browse/INTERLOK-967) - UI Config - metadata from AddFormattedMetadataService not shown on help preview pane
- [INTERLOK-978](https://adaptris.atlassian.net/browse/INTERLOK-978) - Improve the multi select style for the multi adapter widget in the runime page
- [INTERLOK-979](https://adaptris.atlassian.net/browse/INTERLOK-979) - UI Dashboard - remove channel count and add heap used count to main adapter bar
- [INTERLOK-983](https://adaptris.atlassian.net/browse/INTERLOK-983) - EmbeddedJettyConnection needs to be able to add security constraints
- [INTERLOK-984](https://adaptris.atlassian.net/browse/INTERLOK-984) - Add appender suggestion (list) for the selected adapter when adding a new Logger monitor
- [INTERLOK-985](https://adaptris.atlassian.net/browse/INTERLOK-985) - Update dashboard page documentation
- [INTERLOK-986](https://adaptris.atlassian.net/browse/INTERLOK-986) - Update navigation documentation
- [INTERLOK-989](https://adaptris.atlassian.net/browse/INTERLOK-989) - UUID generation takes too much CPU time
- [INTERLOK-992](https://adaptris.atlassian.net/browse/INTERLOK-992) - Remove the number of channels from the Show Channel checbox
- [INTERLOK-996](https://adaptris.atlassian.net/browse/INTERLOK-996) - IdGenerator should be configurable in AdaptrisMessageFactory
- [INTERLOK-1004](https://adaptris.atlassian.net/browse/INTERLOK-1004) - Configurable Security Handler that allows pluggable jetty auths

## Version 3.2.1 ##

Release Date : 2016-04-29

### Bugs
- [INTERLOK-366](https://adaptris.atlassian.net/browse/INTERLOK-366) - Exception while adding an adapter container
- [INTERLOK-410](https://adaptris.atlassian.net/browse/INTERLOK-410) - Validation error when wrapping JettyConsumer in ReliableMessagingConsumer
- [INTERLOK-759](https://adaptris.atlassian.net/browse/INTERLOK-759) - UI Config - Save as template - needs to work with ArrayList (and other non adaptris collections)
- [INTERLOK-776](https://adaptris.atlassian.net/browse/INTERLOK-776) - Metrics Interceptor naming seems to break GUI Charts
- [INTERLOK-807](https://adaptris.atlassian.net/browse/INTERLOK-807) - javadocs in UI are all on one line, breaking pre tags
- [INTERLOK-810](https://adaptris.atlassian.net/browse/INTERLOK-810) - VCS Profile shouldn't force a username+password
- [INTERLOK-833](https://adaptris.atlassian.net/browse/INTERLOK-833) - NPE when a user try to get templates and having a template vcs profile configured without the vcs jars in the classpath
- [INTERLOK-842](https://adaptris.atlassian.net/browse/INTERLOK-842) - UI Config - Save as template - xpath connection issue
- [INTERLOK-845](https://adaptris.atlassian.net/browse/INTERLOK-845) - RegexpMetadataService should not add metadata if the value is null.
- [INTERLOK-849](https://adaptris.atlassian.net/browse/INTERLOK-849) - Export Config fails to put place holders for items inside service lists
- [INTERLOK-854](https://adaptris.atlassian.net/browse/INTERLOK-854) - UI Config - dnd not working in nested service containers that are >2 deep
- [INTERLOK-861](https://adaptris.atlassian.net/browse/INTERLOK-861) - JMS OnException fires > 1 which can cause problems restarting channels
- [INTERLOK-864](https://adaptris.atlassian.net/browse/INTERLOK-864) - Issue with RegexpMetadataQuery allowNulls getter and setter are getAllowNullResults and setAllowNullResults
- [INTERLOK-865](https://adaptris.atlassian.net/browse/INTERLOK-865) - StandardHTTPProducer breaks binary downloads
- [INTERLOK-892](https://adaptris.atlassian.net/browse/INTERLOK-892) - Failover does not work with multiple network interfaces
- [INTERLOK-893](https://adaptris.atlassian.net/browse/INTERLOK-893) - Failover needs a shutdown handler
- [INTERLOK-905](https://adaptris.atlassian.net/browse/INTERLOK-905) - VCS-GIT does not support SSH properly
- [INTERLOK-906](https://adaptris.atlassian.net/browse/INTERLOK-906) - VCS modules do not support encoded passwords consistently.

### Improvements
- [INTERLOK-133](https://adaptris.atlassian.net/browse/INTERLOK-133) - UI Config Page - Diff mode needs a full screen mode
- [INTERLOK-178](https://adaptris.atlassian.net/browse/INTERLOK-178) - UI Config Page - JDBC Statement parameters have no UI
- [INTERLOK-246](https://adaptris.atlassian.net/browse/INTERLOK-246) - adapter-web-gui.war contains too many jars
- [INTERLOK-256](https://adaptris.atlassian.net/browse/INTERLOK-256) - UI Config Page - Focus input field when adding service
- [INTERLOK-363](https://adaptris.atlassian.net/browse/INTERLOK-363) - UI Config Page - add shortcut button to load from auto-save feature
- [INTERLOK-766](https://adaptris.atlassian.net/browse/INTERLOK-766) - Use a port manager for the ui service test to make sure the test use an unused port
- [INTERLOK-790](https://adaptris.atlassian.net/browse/INTERLOK-790) - UI - Config - Improve the performance of the javascript clone operations
- [INTERLOK-799](https://adaptris.atlassian.net/browse/INTERLOK-799) - UI Config - Settings : Cannot change the "Type" of ServiceCollection
- [INTERLOK-815](https://adaptris.atlassian.net/browse/INTERLOK-815) - Update UI doc images with latest UI
- [INTERLOK-816](https://adaptris.atlassian.net/browse/INTERLOK-816) - UI - Add more unit tests to the class utils class to cover recent changes
- [INTERLOK-817](https://adaptris.atlassian.net/browse/INTERLOK-817) - UI Config - Quick add button for producer and consumer
- [INTERLOK-818](https://adaptris.atlassian.net/browse/INTERLOK-818) - UI Config - update settings editor and remove dropdown for add object selection
- [INTERLOK-819](https://adaptris.atlassian.net/browse/INTERLOK-819) - UI Config - update save as template to use tabs
- [INTERLOK-823](https://adaptris.atlassian.net/browse/INTERLOK-823) - UI Config - Pretty name function requires some improvement
- [INTERLOK-825](https://adaptris.atlassian.net/browse/INTERLOK-825) - Amazon SQS support : able to modify ClientConfiguration
- [INTERLOK-836](https://adaptris.atlassian.net/browse/INTERLOK-836) - Get rid of the warning 'The DerbyDialect dialect has been deprecated...'
- [INTERLOK-846](https://adaptris.atlassian.net/browse/INTERLOK-846) - Add a RegexpMetadataService like XPathService
- [INTERLOK-847](https://adaptris.atlassian.net/browse/INTERLOK-847) - Create 'Streaming' JDBC service or consumer.
- [INTERLOK-851](https://adaptris.atlassian.net/browse/INTERLOK-851) - Integration with Apache Kafka
- [INTERLOK-852](https://adaptris.atlassian.net/browse/INTERLOK-852) - Separate web-services external
- [INTERLOK-853](https://adaptris.atlassian.net/browse/INTERLOK-853) - Change connection class hierarchy for Null Connection
- [INTERLOK-855](https://adaptris.atlassian.net/browse/INTERLOK-855) - Fix ui tests broken du to changes onNullConnection
- [INTERLOK-856](https://adaptris.atlassian.net/browse/INTERLOK-856) - Allow JdbcDataQueryService to determine query string from the message
- [INTERLOK-858](https://adaptris.atlassian.net/browse/INTERLOK-858) - Add js tests for global js functions
- [INTERLOK-863](https://adaptris.atlassian.net/browse/INTERLOK-863) - Prevent unnecessary message copy by StandaloneProducer when using StandardHttpProducer
- [INTERLOK-866](https://adaptris.atlassian.net/browse/INTERLOK-866) - Update adapter.xml to MyInterlokInstance for nightly builds
- [INTERLOK-868](https://adaptris.atlassian.net/browse/INTERLOK-868) - UI Dash - Failed Messages screen is not buffered to 100
- [INTERLOK-871](https://adaptris.atlassian.net/browse/INTERLOK-871) - Update CSV with a CSV Result set Translator
- [INTERLOK-873](https://adaptris.atlassian.net/browse/INTERLOK-873) - Add ability to add a formatted string to metadata

## Version 3.2.0 ##

Release Date : 2016-03-18

### Bugs

- [INTERLOK-770](https://adaptris.atlassian.net/browse/INTERLOK-770) - Potential log4j2 loading issue in a Sonic container
- [INTERLOK-773](https://adaptris.atlassian.net/browse/INTERLOK-773) - Remove c3p0:c3p0 from all dependencies.
- [INTERLOK-775](https://adaptris.atlassian.net/browse/INTERLOK-775) - Issue when getting the configuration url via jmx on RHEL5
- [INTERLOK-782](https://adaptris.atlassian.net/browse/INTERLOK-782) - Cannot switch to using xalan due to dependency on net.sf.saxon.trans.LicenseException
- [INTERLOK-789](https://adaptris.atlassian.net/browse/INTERLOK-789) - UI loses xpath property in attachment/body-handler when using MultiAttachmentSmtpProducer with XmlMailCreator
- [INTERLOK-792](https://adaptris.atlassian.net/browse/INTERLOK-792) - ParsingMailConsumerImpl annotated NotNull PartSelector
- [INTERLOK-794](https://adaptris.atlassian.net/browse/INTERLOK-794) - Fix TemplateServiceImplTest
- [INTERLOK-795](https://adaptris.atlassian.net/browse/INTERLOK-795) - Add Connection screen is inconsistent with SharedConnection
- [INTERLOK-798](https://adaptris.atlassian.net/browse/INTERLOK-798) - XML View does not handle the "replace"
- [INTERLOK-804](https://adaptris.atlassian.net/browse/INTERLOK-804) - UI Config - Test-this-service-collection button not working
- [INTERLOK-805](https://adaptris.atlassian.net/browse/INTERLOK-805) - Order is not (always) obeyed on settings screens for nested lists
- [INTERLOK-811](https://adaptris.atlassian.net/browse/INTERLOK-811) - Cannot apply config to current adapter
- [INTERLOK-824](https://adaptris.atlassian.net/browse/INTERLOK-824) - Fix the root issue causing INTERLOK-822
- [INTERLOK-822](https://adaptris.atlassian.net/browse/INTERLOK-822) - UI Config - add connection isn't working when a shared connection is present
- [INTERLOK-829](https://adaptris.atlassian.net/browse/INTERLOK-829) - @XStreamAlias for StandardReponseProducer is wrong.
- [INTERLOK-830](https://adaptris.atlassian.net/browse/INTERLOK-830) - Issue with services order in the worklow or serviceList not been kept when editing component.
- [INTERLOK-832](https://adaptris.atlassian.net/browse/INTERLOK-832) - JDBC advanced connection test - pool size.
- [INTERLOK-838](https://adaptris.atlassian.net/browse/INTERLOK-838) - Aggregating FS Consumer cannot be configured from gui (no template)
- [INTERLOK-839](https://adaptris.atlassian.net/browse/INTERLOK-839) - Can't create valid JSON Path Service config in GUI
- [INTERLOK-841](https://adaptris.atlassian.net/browse/INTERLOK-841) - SharedComponents remain in JNDI even if init() fails
- [INTERLOK-842](https://adaptris.atlassian.net/browse/INTERLOK-842) - UI Config - Save as template - xpath connection issue

### Improvements

- [INTERLOK-112](https://adaptris.atlassian.net/browse/INTERLOK-112) - System CPU Load and JVM Process Load charts should have duration restriction like the JVM memory charts
- [INTERLOK-306](https://adaptris.atlassian.net/browse/INTERLOK-306) - UI Config - Work out ways to better present the connections in relation with the consume/produce components
- [INTERLOK-627](https://adaptris.atlassian.net/browse/INTERLOK-627) - Class level annotation that can define the "sort order" for input fields
- [INTERLOK-628](https://adaptris.atlassian.net/browse/INTERLOK-628) - Apply Order on Settings Screen
- [INTERLOK-655](https://adaptris.atlassian.net/browse/INTERLOK-655) - Change workflow type in the setting modal
- [INTERLOK-713](https://adaptris.atlassian.net/browse/INTERLOK-713) - UI - design changes for the settings editor (thumbnail browser)
- [INTERLOK-721](https://adaptris.atlassian.net/browse/INTERLOK-721) - UI Config Page - Add component - tile view - add the extra info in tooltip
- [INTERLOK-750](https://adaptris.atlassian.net/browse/INTERLOK-750) - Add the abiity to dynamiclly assign a username + password for HTTP.
- [INTERLOK-753](https://adaptris.atlassian.net/browse/INTERLOK-753) - Consider having variable indirection for metadata.
- [INTERLOK-761](https://adaptris.atlassian.net/browse/INTERLOK-761) - Investigate Saxon HE XML to Json stylehseet
- [INTERLOK-764](https://adaptris.atlassian.net/browse/INTERLOK-764) - Add in support for FTP/SSL Implicit mode
- [INTERLOK-769](https://adaptris.atlassian.net/browse/INTERLOK-769) - Metadata Key Standardisation
- [INTERLOK-772](https://adaptris.atlassian.net/browse/INTERLOK-772) - SendEvents should use the ExecutorService already available.
- [INTERLOK-778](https://adaptris.atlassian.net/browse/INTERLOK-778) - JdbcConnectionPool with more properties
- [INTERLOK-779](https://adaptris.atlassian.net/browse/INTERLOK-779) - UI Widgets - Persist the column mode selection per user
- [INTERLOK-780](https://adaptris.atlassian.net/browse/INTERLOK-780) - Create annotation to define which connections are valid for a given consumer / producer
- [INTERLOK-781](https://adaptris.atlassian.net/browse/INTERLOK-781) - Annotate consumers and producers with the expected connection annotation
- [INTERLOK-784](https://adaptris.atlassian.net/browse/INTERLOK-784) - UI Config - fix the order the settings editor tabs
- [INTERLOK-787](https://adaptris.atlassian.net/browse/INTERLOK-787) - UI - Prefs/Config - add new pref for the loading of the active adapter on the config page
- [INTERLOK-785](https://adaptris.atlassian.net/browse/INTERLOK-785) - UI Config - Handle open page with no connectable adapters better
- [INTERLOK-791](https://adaptris.atlassian.net/browse/INTERLOK-791) - A few documentation errors found while testing FS and Mail.
- [INTERLOK-797](https://adaptris.atlassian.net/browse/INTERLOK-797) - UI Config Page - review icons used on the components / settings editor
- [INTERLOK-801](https://adaptris.atlassian.net/browse/INTERLOK-801) - User preference for dialog boxes
- [INTERLOK-803](https://adaptris.atlassian.net/browse/INTERLOK-803) - Refactor StatementParameter
- [INTERLOK-814](https://adaptris.atlassian.net/browse/INTERLOK-814) - Avoid to iterate through extensions and settings too many time in the settings modal

## Version 3.1.1 ##

Release Date : 2016-01-28

### Bugs

- [INTERLOK-717](https://adaptris.atlassian.net/browse/INTERLOK-717) - UI - Add Metadata Service Template fails the validation function even tho it is valid
- [INTERLOK-726](https://adaptris.atlassian.net/browse/INTERLOK-726) - UI Config - Editing the service collection thats selected by the collections selector has no effect
- [INTERLOK-736](https://adaptris.atlassian.net/browse/INTERLOK-736) - UI Config Odd Channel Display Name
- [INTERLOK-737](https://adaptris.atlassian.net/browse/INTERLOK-737) - UI Config - Schema Template not showing wizard input
- [INTERLOK-740](https://adaptris.atlassian.net/browse/INTERLOK-740) - xinclude pre-processor doesn't work with guava 18.
- [INTERLOK-742](https://adaptris.atlassian.net/browse/INTERLOK-742) - UI Config - Save as template not working with metadata key value pairs
- [INTERLOK-744](https://adaptris.atlassian.net/browse/INTERLOK-744) - UI Config - save as template - xpath calculator wrong for XpathMetadataService 'XPath Query'
- [INTERLOK-754](https://adaptris.atlassian.net/browse/INTERLOK-754) - UI - save as template - needs to work with XStreamImplicit itemFieldName
- [INTERLOK-755](https://adaptris.atlassian.net/browse/INTERLOK-755) - UI Config - Post Apply, the Shared connection in jdbc service is reverted to full string url
- [INTERLOK-757](https://adaptris.atlassian.net/browse/INTERLOK-757) - The jdbc service list doesn't display databaseConnection settign in the modal
- [INTERLOK-760](https://adaptris.atlassian.net/browse/INTERLOK-760) - UI Config - JmsConsumer settings show no options for Message Factory
- [INTERLOK-765](https://adaptris.atlassian.net/browse/INTERLOK-765) - UI Config - the add component summary should be present on the search
- [INTERLOK-768](https://adaptris.atlassian.net/browse/INTERLOK-768) - Cannot start the adapter from a HTTP based URL.

### Improvements

- [INTERLOK-224](https://adaptris.atlassian.net/browse/INTERLOK-224) - UI Config Page - add/paste component to a specific index rather than just at the end of the collection
- [INTERLOK-290](https://adaptris.atlassian.net/browse/INTERLOK-290) - Add "pre-processor" functionality into AdaptrisMarshaller
- [INTERLOK-307](https://adaptris.atlassian.net/browse/INTERLOK-307) - UI Config - make it easier to replace consumer,producer&connections - i.e. replace rather than delete&insert
- [INTERLOK-384](https://adaptris.atlassian.net/browse/INTERLOK-384) - Change "display" name from classname to the XStreamAlias
- [INTERLOK-592](https://adaptris.atlassian.net/browse/INTERLOK-592) - Support password authentication for jmxmp
- [INTERLOK-626](https://adaptris.atlassian.net/browse/INTERLOK-626) - UI Needs to handle RequestReplyWorkflow
- [INTERLOK-718](https://adaptris.atlassian.net/browse/INTERLOK-718) - UI - improve performance of the add component function on the config page
- [INTERLOK-719](https://adaptris.atlassian.net/browse/INTERLOK-719) - UI Config Page - improve the display of the raw components folder in the add component modal
- [INTERLOK-720](https://adaptris.atlassian.net/browse/INTERLOK-720) - Handle password support for JMXMP in the UI.
- [INTERLOK-724](https://adaptris.atlassian.net/browse/INTERLOK-724) - Update phantomjs to the latest version
- [INTERLOK-725](https://adaptris.atlassian.net/browse/INTERLOK-725) - UI Config - Add ability to name the root collections when adding a component
- [INTERLOK-727](https://adaptris.atlassian.net/browse/INTERLOK-727) - UI Config - Add ability to 'go to' collection from within a settings editor
- [INTERLOK-728](https://adaptris.atlassian.net/browse/INTERLOK-728) - Add a new class level annotation to provide a summary of the component
- [INTERLOK-731](https://adaptris.atlassian.net/browse/INTERLOK-731) - Improve JDBC DataCapture Logging
- [INTERLOK-733](https://adaptris.atlassian.net/browse/INTERLOK-733) - Document @AdapterComponent
- [INTERLOK-735](https://adaptris.atlassian.net/browse/INTERLOK-735) - UI Config - Event handler using a shared connection
- [INTERLOK-745](https://adaptris.atlassian.net/browse/INTERLOK-745) - Handle password support for JMXMP for external adapter api call using the UI.
- [INTERLOK-747](https://adaptris.atlassian.net/browse/INTERLOK-747) - Add documentation for how to add Shared Connection in the UI
- [INTERLOK-752](https://adaptris.atlassian.net/browse/INTERLOK-752) - Need a way of iterating over the same payload.
- [INTERLOK-756](https://adaptris.atlassian.net/browse/INTERLOK-756) - Allow users to configure attributes on the TransformerFactory
- [INTERLOK-758](https://adaptris.atlassian.net/browse/INTERLOK-758) - JSON SimpleTransformationDriver should support Arrays

## Version 3.1.0 ##

Release Date : 2015-11-20

### Bugs

- [INTERLOK-630](https://adaptris.atlassian.net/browse/INTERLOK-630) - Javadoc hover doesn't work with AdvancedConfig
- [INTERLOK-685](https://adaptris.atlassian.net/browse/INTERLOK-685) - Renew Signing Certificate (expires 2015-11) and projects that rely on it
- [INTERLOK-690](https://adaptris.atlassian.net/browse/INTERLOK-690) - code-signer passwords should not be hard-coded for the build process.
- [INTERLOK-693](https://adaptris.atlassian.net/browse/INTERLOK-693) - Channel accordion doesn't open in the adapter export wizard
- [INTERLOK-699](https://adaptris.atlassian.net/browse/INTERLOK-699) - Cannot initialise from git branch

### Improvements

- [INTERLOK-654](https://adaptris.atlassian.net/browse/INTERLOK-654) - UI Config - Add clipboard functions to components (cut, copy, paste, duplicate)
- [INTERLOK-669](https://adaptris.atlassian.net/browse/INTERLOK-669) - UI Config - hide components from selection during add process that are deprecated
- [INTERLOK-670](https://adaptris.atlassian.net/browse/INTERLOK-670) - UI Config - Add more metadata to template upon creation
- [INTERLOK-671](https://adaptris.atlassian.net/browse/INTERLOK-671) - UI Config - Add new filter to Add component modal to filter adapter-target-version
- [INTERLOK-677](https://adaptris.atlassian.net/browse/INTERLOK-677) - Create an appender for log4j2 that does the same as interlok-logging JMX
- [INTERLOK-678](https://adaptris.atlassian.net/browse/INTERLOK-678) - update various components to use slf4j rather then log4j directly
- [INTERLOK-679](https://adaptris.atlassian.net/browse/INTERLOK-679) - UI Config - Implement the new Collections Input for the root workflow services (and nested services)
- [INTERLOK-687](https://adaptris.atlassian.net/browse/INTERLOK-687) - Add flag(s) to enable/disable XXE in XML Processing
- [INTERLOK-695](https://adaptris.atlassian.net/browse/INTERLOK-695) - variableSubstitution should have "shared variables"
- [INTERLOK-696](https://adaptris.atlassian.net/browse/INTERLOK-696) - varsub should be able to detect if a variable has been defined, and doesn't exist.
- [INTERLOK-697](https://adaptris.atlassian.net/browse/INTERLOK-697) - Deprecated implementations are shown in drop downs.
- [INTERLOK-700](https://adaptris.atlassian.net/browse/INTERLOK-700) - GIT Update to a new branch via bootstrap.properties
- [INTERLOK-702](https://adaptris.atlassian.net/browse/INTERLOK-702) - Update the gui to work with the new changes on vcs-git
- [INTERLOK-703](https://adaptris.atlassian.net/browse/INTERLOK-703) - Remove use of the bare repo from GitVCS
- [INTERLOK-704](https://adaptris.atlassian.net/browse/INTERLOK-704) - Depend on https://subversion.assembla.com/svn/interlok-templates/ for templates
- [INTERLOK-708](https://adaptris.atlassian.net/browse/INTERLOK-708) - HttpProducer should probably have a  DataOutputParameter
- [INTERLOK-716](https://adaptris.atlassian.net/browse/INTERLOK-716) - Templates - update to have all the info that the ui presents on the add by screen

## Version 3.0.6 ##

Release Date : 2015-10-14

### Bugs

- [INTERLOK-542](https://adaptris.atlassian.net/browse/INTERLOK-542) - UI Dashboard - Adapter dashboard gets "stuck" by unreachable adapter
- [INTERLOK-682](https://adaptris.atlassian.net/browse/INTERLOK-682) - Typing DataDestination causes schema tests to fail.

### Improvements

- [INTERLOK-8](https://adaptris.atlassian.net/browse/INTERLOK-8) - Update MSMQ component to support .NET writing to MSMQ
- [INTERLOK-377](https://adaptris.atlassian.net/browse/INTERLOK-377) - Build a JSON equivalent to adp-webservices-internal.war
- [INTERLOK-583](https://adaptris.atlassian.net/browse/INTERLOK-583) - UI Config - Have a process to confirm that config works in remote adapters
- [INTERLOK-590](https://adaptris.atlassian.net/browse/INTERLOK-590) - Need to change the flyway script name
- [INTERLOK-595](https://adaptris.atlassian.net/browse/INTERLOK-595) - Webservices should support "JSON" style as the message.
- [INTERLOK-598](https://adaptris.atlassian.net/browse/INTERLOK-598) - UI Dashboard - show config modal with basic adapter doesn't init correctly
- [INTERLOK-608](https://adaptris.atlassian.net/browse/INTERLOK-608) - UI Dashboard - show adapter version numbers
- [INTERLOK-615](https://adaptris.atlassian.net/browse/INTERLOK-615) - log4j is dead long live log4j - See what's need to be done to upgrade to logj2
- [INTERLOK-616](https://adaptris.atlassian.net/browse/INTERLOK-616) - Port jmxlogger into interlok
- [INTERLOK-619](https://adaptris.atlassian.net/browse/INTERLOK-619) - UI API - Create new rest controller(s) that follows the rest standard to get adapter, channel, workflow details start, stop, get statistics etc
- [INTERLOK-620](https://adaptris.atlassian.net/browse/INTERLOK-620) - UI API - Add swagger (swagger.json) to document the new REST controller(s).
- [INTERLOK-621](https://adaptris.atlassian.net/browse/INTERLOK-621) - UI API - Change the authentication process (Basic?) so other app/scrip can access the ui api
- [INTERLOK-624](https://adaptris.atlassian.net/browse/INTERLOK-624) - Add a NullOutOfStateHandler
- [INTERLOK-635](https://adaptris.atlassian.net/browse/INTERLOK-635) - Validation of configuration should happen during unit-tests.
- [INTERLOK-639](https://adaptris.atlassian.net/browse/INTERLOK-639) - Update MleMarker so that sequence number is a long
- [INTERLOK-644](https://adaptris.atlassian.net/browse/INTERLOK-644) - Add in Json transform / json xpath style support.
- [INTERLOK-648](https://adaptris.atlassian.net/browse/INTERLOK-648) - Add a bootstrap property that forces javax.validation on the created Adapter
- [INTERLOK-649](https://adaptris.atlassian.net/browse/INTERLOK-649) - Failover - Testing and cleanup.
- [INTERLOK-650](https://adaptris.atlassian.net/browse/INTERLOK-650) - UI - Config - Improve the select fields page for create template function
- [INTERLOK-651](https://adaptris.atlassian.net/browse/INTERLOK-651) - Add gzip for the webservice response
- [INTERLOK-653](https://adaptris.atlassian.net/browse/INTERLOK-653) - New Service for Xpath that mirrors JsonPath functionality
- [INTERLOK-656](https://adaptris.atlassian.net/browse/INTERLOK-656) - Cache adapter component beaninfo to get the config faster.
- [INTERLOK-657](https://adaptris.atlassian.net/browse/INTERLOK-657) - Change the logging widget to from hard-coded objectname to dynamic
- [INTERLOK-659](https://adaptris.atlassian.net/browse/INTERLOK-659) - If a template is not part of the expected TemplateType we receive a debu stacktrace
- [INTERLOK-665](https://adaptris.atlassian.net/browse/INTERLOK-665) - Deprecated members should not be shown in config
- [INTERLOK-663](https://adaptris.atlassian.net/browse/INTERLOK-663) - Add in dynamic method support to ApacheHttp + JdkHttp
- [INTERLOK-664](https://adaptris.atlassian.net/browse/INTERLOK-664) - Add in Dynamic Http Response support to JettyConsumer
- [INTERLOK-668](https://adaptris.atlassian.net/browse/INTERLOK-668) - HTTP refactoring
- [INTERLOK-672](https://adaptris.atlassian.net/browse/INTERLOK-672) - Modify UI jmx logging documentation to explain how to configure the new inetlok jmx logging
- [INTERLOK-673](https://adaptris.atlassian.net/browse/INTERLOK-673) - Deprecate additional logfile handler fields
- [INTERLOK-674](https://adaptris.atlassian.net/browse/INTERLOK-674) - Message data destinations, could be more generic.
- [INTERLOK-681](https://adaptris.atlassian.net/browse/INTERLOK-681) - Add a PayloadToMetadataService & reverse

## Version 3.0.5 ##

Release Date : 2015-09-10

### Bugs

- [INTERLOK-563](https://adaptris.atlassian.net/browse/INTERLOK-563) - BranchingServiceCollection doesn't restart services on exception
- [INTERLOK-600](https://adaptris.atlassian.net/browse/INTERLOK-600) - Re-build the build scripts to handle git
- [INTERLOK-601](https://adaptris.atlassian.net/browse/INTERLOK-601) - Password encryption not happening when checking the box
- [INTERLOK-606](https://adaptris.atlassian.net/browse/INTERLOK-606) - CVS - commons snapshot library no longer exists, needs dependency update.
- [INTERLOK-613](https://adaptris.atlassian.net/browse/INTERLOK-613) - Sporadic javascript error in the login page
- [INTERLOK-617](https://adaptris.atlassian.net/browse/INTERLOK-617) - System Preference page throw a 500 error with java 1.7
- [INTERLOK-622](https://adaptris.atlassian.net/browse/INTERLOK-622) - AmazonSQSConsumer does not receive message attributes
- [INTERLOK-629](https://adaptris.atlassian.net/browse/INTERLOK-629) - JmsProducerImp#ttl does not match getter/setter
- [INTERLOK-631](https://adaptris.atlassian.net/browse/INTERLOK-631) - SlowNotification Interceptor - Timing issue during tests
- [INTERLOK-637](https://adaptris.atlassian.net/browse/INTERLOK-637) - Backup Configs fail validation when applied to adapter
- [INTERLOK-638](https://adaptris.atlassian.net/browse/INTERLOK-638) - Tests Broken on Windows 10

### Improvements

- [INTERLOK-74](https://adaptris.atlassian.net/browse/INTERLOK-74) - UI - First time admin login action should force user to create user / change admin password
- [INTERLOK-398](https://adaptris.atlassian.net/browse/INTERLOK-398) - UI - Investigate packaging concerns for a UI API
- [INTERLOK-478](https://adaptris.atlassian.net/browse/INTERLOK-478) - UI Config - service collection testing - restart test needs to retain in data
- [INTERLOK-552](https://adaptris.atlassian.net/browse/INTERLOK-552) - UI Config - integrate templates to work with vcs profiles
- [INTERLOK-553](https://adaptris.atlassian.net/browse/INTERLOK-553) - UI Config - integrate user export/imports with the vcs system
- [INTERLOK-562](https://adaptris.atlassian.net/browse/INTERLOK-562) - Not able to add a placeholder on static metadata for Config Export
- [INTERLOK-569](https://adaptris.atlassian.net/browse/INTERLOK-569) - Provide better feedback after adding a Shared Connection
- [INTERLOK-577](https://adaptris.atlassian.net/browse/INTERLOK-577) - UI Admin Page - Create a module to control admin features on the UI
- [INTERLOK-579](https://adaptris.atlassian.net/browse/INTERLOK-579) - Add an annotation that defines is a settings should be hidden in UI
- [INTERLOK-580](https://adaptris.atlassian.net/browse/INTERLOK-580) - UI Config Page - Create a Basic Mode for the config settings modal
- [INTERLOK-582](https://adaptris.atlassian.net/browse/INTERLOK-582) - Create a validation method in the Adapter Management classes that allow config to be validated
- [INTERLOK-591](https://adaptris.atlassian.net/browse/INTERLOK-591) - Create an Interlok API Client
- [INTERLOK-597](https://adaptris.atlassian.net/browse/INTERLOK-597) - The wizard creation uses '.' into the field keys and when templates are loaded in a wizard the field labels have '.' in it
- [INTERLOK-604](https://adaptris.atlassian.net/browse/INTERLOK-604) - Add a pie chart for the metadata coming from MetadataStatisticsMBean
- [INTERLOK-605](https://adaptris.atlassian.net/browse/INTERLOK-605) - Uograde to font awesome 4.4.0 with adapter, channel and workflow icons
- [INTERLOK-607](https://adaptris.atlassian.net/browse/INTERLOK-607) - Add some documentation for the community template using vcs
- [INTERLOK-610](https://adaptris.atlassian.net/browse/INTERLOK-610) - Metadata Appender Service Via UI Does Not Allow Same Meta Date Key To Be Appended More Than Once.
- [INTERLOK-612](https://adaptris.atlassian.net/browse/INTERLOK-612) - Use the new adapter registry mbean validation method before applying a config
- [INTERLOK-632](https://adaptris.atlassian.net/browse/INTERLOK-632) - Test SQL Server with latest driver.
- [INTERLOK-633](https://adaptris.atlassian.net/browse/INTERLOK-633) - Add a new Http Producer based on Apache HTTP
- [INTERLOK-634](https://adaptris.atlassian.net/browse/INTERLOK-634) - Add a JsonTransformationDriver Impl that uses XStream


## Version 3.0.4 ##

Release Date : 2015-08-03

### Bugs

- [INTERLOK-492](https://adaptris.atlassian.net/browse/INTERLOK-492) - Toggling "show last index plot" on preferences rem...
- [INTERLOK-536](https://adaptris.atlassian.net/browse/INTERLOK-536) - UI Export - the success message appears in wrong place
- [INTERLOK-537](https://adaptris.atlassian.net/browse/INTERLOK-537) - UI Export - Adding variables requires user to press plus button
- [INTERLOK-539](https://adaptris.atlassian.net/browse/INTERLOK-539) - UI Config VCS - When error occurs at checkout or publish, the error message always display the download and reset buttons
- [INTERLOK-545](https://adaptris.atlassian.net/browse/INTERLOK-545) - UI Config - Spaces in SharedComponent's unique-id are replaced with dashes
- [INTERLOK-556](https://adaptris.atlassian.net/browse/INTERLOK-556) - UI Config - save template - fix/remove the UID selections
- [INTERLOK-557](https://adaptris.atlassian.net/browse/INTERLOK-557) - Fix the javadoc servlet that prevent the gui to start if the docs folder doesn't exist.
- [INTERLOK-560](https://adaptris.atlassian.net/browse/INTERLOK-560) - Backslash is not removed from URL variables when using UI Import function
- [INTERLOK-565](https://adaptris.atlassian.net/browse/INTERLOK-565) - Loading or pushing a config to vcs with save the password in the vcs profile.
- [INTERLOK-566](https://adaptris.atlassian.net/browse/INTERLOK-566) - When adding a new Vcs Profile after saving one using the Save & Add New button the default Working Copy Url is not generated.
- [INTERLOK-570](https://adaptris.atlassian.net/browse/INTERLOK-570) - SimpleFactoryConfiguration doesn't support primitive Objects
- [INTERLOK-575](https://adaptris.atlassian.net/browse/INTERLOK-575) - Directory spelt incorrectly in logfile.
- [INTERLOK-576](https://adaptris.atlassian.net/browse/INTERLOK-576) - The export config modal header color is not always the adapter color.
- [INTERLOK-586](https://adaptris.atlassian.net/browse/INTERLOK-586) - Reliable-messaging properties still in adp-core.jar
- [INTERLOK-593](https://adaptris.atlassian.net/browse/INTERLOK-593) - JSONArray Inputs are not supported by JsonXmlTransformationService
- [INTERLOK-594](https://adaptris.atlassian.net/browse/INTERLOK-594) - JsonXmlTransformationService doesn't play nicely with invalid XML
- [INTERLOK-596](https://adaptris.atlassian.net/browse/INTERLOK-596) - Adding a template with '.' in wizard-key doesn't play nicely


### Improvement

- [INTERLOK-57](https://adaptris.atlassian.net/browse/INTERLOK-57) - UI Config Page - pull community templates
- [INTERLOK-376](https://adaptris.atlassian.net/browse/INTERLOK-376) - Move Actional integation into Interlok-optional
- [INTERLOK-386](https://adaptris.atlassian.net/browse/INTERLOK-386) - Injecting message to return a result.
- [INTERLOK-453](https://adaptris.atlassian.net/browse/INTERLOK-453) - Show thread dump on the Platform Thread Details Wi...
- [INTERLOK-526](https://adaptris.atlassian.net/browse/INTERLOK-526) - Allow the use of RFC6167 to define a JMS destination
- [INTERLOK-528](https://adaptris.atlassian.net/browse/INTERLOK-528) - UI Widgets - Remote adapter channels don't always ...
- [INTERLOK-531](https://adaptris.atlassian.net/browse/INTERLOK-531) - Create an Interceptor that sends notifications based on throughput criteria.
- [INTERLOK-540](https://adaptris.atlassian.net/browse/INTERLOK-540) - Update to the latest knockout version 3.3.0
- [INTERLOK-541](https://adaptris.atlassian.net/browse/INTERLOK-541) - Add Solace messaging support
- [INTERLOK-544](https://adaptris.atlassian.net/browse/INTERLOK-544) - UI Config Page - The connection component label ch...
- [INTERLOK-546](https://adaptris.atlassian.net/browse/INTERLOK-546) - MetadataCountsChart Widget doesn't add new graphsinto the chart dynamically when new metadata values are intercepted
- [INTERLOK-549](https://adaptris.atlassian.net/browse/INTERLOK-549) - Clean up bootstrap.properties for the UI
- [INTERLOK-550](https://adaptris.atlassian.net/browse/INTERLOK-550) - UI Config Page - Push a new community template
- [INTERLOK-551](https://adaptris.atlassian.net/browse/INTERLOK-551) - UI Config Page - improve the level of detail shown to a user on template selection
- [INTERLOK-554](https://adaptris.atlassian.net/browse/INTERLOK-554) - UI - Improve the workings of the component factory
- [INTERLOK-561](https://adaptris.atlassian.net/browse/INTERLOK-561) - Last variable name in variables.properties is joint to the one above's value when importing config
- [INTERLOK-567](https://adaptris.atlassian.net/browse/INTERLOK-567) - Add some documentation for the add template to the community repo
- [INTERLOK-568](https://adaptris.atlassian.net/browse/INTERLOK-568) - Add some documentation for gui javadoc
- [INTERLOK-571](https://adaptris.atlassian.net/browse/INTERLOK-571) - In the config page the menu caret doesn't get larger when the Action Button Size is larger
- [INTERLOK-573](https://adaptris.atlassian.net/browse/INTERLOK-573) - SftpClient doesn't log any additional information if additional-debug is on




## Version 3.0.3 ##

Release Date : 2015-06-22


### Bugs

- [INTERLOK-450](https://adaptris.atlassian.net/browse/INTERLOK-450) - Changing preferences in the widget page remove all the widgets
- [INTERLOK-483](https://adaptris.atlassian.net/browse/INTERLOK-483) - UI Add Widgets Page - Log table widget shown twice
- [INTERLOK-484](https://adaptris.atlassian.net/browse/INTERLOK-484) - UI - Dashboard with 5 adapters shown in compact mode is not alligned
- [INTERLOK-486](https://adaptris.atlassian.net/browse/INTERLOK-486) - UI - Dashboard - Show config diagram doesn't fully load for remote adapter config
- [INTERLOK-488](https://adaptris.atlassian.net/browse/INTERLOK-488) - Using variableSubstitution means you can't use ${user.dir} as part of URL.
- [INTERLOK-489](https://adaptris.atlassian.net/browse/INTERLOK-489) - UI Widgets - don't show Channel message count widgets as available if it's workflows have no workflow interceptors that collect the data required
- [INTERLOK-494](https://adaptris.atlassian.net/browse/INTERLOK-494) - ExcelToXML Service breaks when an empty row encounters
- [INTERLOK-496](https://adaptris.atlassian.net/browse/INTERLOK-496) - SharedConnection should use both comp/env/"lookup-name" + lookupName
- [INTERLOK-508](https://adaptris.atlassian.net/browse/INTERLOK-508) - Convert RelaxedFtpConsumer tests to use Mockito
- [INTERLOK-514](https://adaptris.atlassian.net/browse/INTERLOK-514) - FsHelper doesn't handle a relative URL style; unlike URLString
- [INTERLOK-529](https://adaptris.atlassian.net/browse/INTERLOK-529) - Vcs working copy should be checked out if not existing before commiting
- [INTERLOK-530](https://adaptris.atlassian.net/browse/INTERLOK-530) - Use the new adapterRegistry.putConfigurationURL(ObjectName, URL) method when applying config
- [INTERLOK-535](https://adaptris.atlassian.net/browse/INTERLOK-535) - The 'Publish to Vcs' button should be disabled when no vcs provider is available
- [INTERLOK-543](https://adaptris.atlassian.net/browse/INTERLOK-543) - Channel with 2x SharedConnections fails to start.
- [INTERLOK-547](https://adaptris.atlassian.net/browse/INTERLOK-547) - UI Config - Export - shared connection elements have the wrong xpath.



### Improvement
- [INTERLOK-308](https://adaptris.atlassian.net/browse/INTERLOK-308) - UI Dashboard - allow user to load config screen from dashboard adapter bar (and thus selecting the active config)
- [INTERLOK-364](https://adaptris.atlassian.net/browse/INTERLOK-364) - Add a persist(String, URL) method to AdapterRegistry
- [INTERLOK-396](https://adaptris.atlassian.net/browse/INTERLOK-396) - UI - Config - Export component with variable substitution support
- [INTERLOK-433](https://adaptris.atlassian.net/browse/INTERLOK-433) - Cannot add advanced components via templates
- [INTERLOK-434](https://adaptris.atlassian.net/browse/INTERLOK-434) - Add function to add a Shared connection at the add connection stage
- [INTERLOK-443](https://adaptris.atlassian.net/browse/INTERLOK-443) - UI Config - add new pref for the display of component labels
- [INTERLOK-454](https://adaptris.atlassian.net/browse/INTERLOK-454) - Implement/enhance Amazon SQS connection
- [INTERLOK-457](https://adaptris.atlassian.net/browse/INTERLOK-457) - extract of javahl DLL on windows should be magic.
- [INTERLOK-459](https://adaptris.atlassian.net/browse/INTERLOK-459) - Abstract the VersionControlSystemApi
- [INTERLOK-461](https://adaptris.atlassian.net/browse/INTERLOK-461) - Implement a Git VersionControlSystem
- [INTERLOK-467](https://adaptris.atlassian.net/browse/INTERLOK-467) - UI - Config SCM - Initial version - scm profile manager modal
- [INTERLOK-468](https://adaptris.atlassian.net/browse/INTERLOK-468) - UI - Config SCM - Initial version - load scm in config page
- [INTERLOK-469](https://adaptris.atlassian.net/browse/INTERLOK-469) - UI - Config SCM - Initial version - save config to scm
- [INTERLOK-470](https://adaptris.atlassian.net/browse/INTERLOK-470) - UI - Improve the settings.properties
- [INTERLOK-477](https://adaptris.atlassian.net/browse/INTERLOK-477) - Document the availability and location of optional components
- [INTERLOK-479](https://adaptris.atlassian.net/browse/INTERLOK-479) - UI Config - When Applying Templates the Unique ID needs to be handled
- [INTERLOK-480](https://adaptris.atlassian.net/browse/INTERLOK-480) - UI - Non-admin users are shown an error when changing user prefs (but error can be ignored)
- [INTERLOK-481](https://adaptris.atlassian.net/browse/INTERLOK-481) - UI Config - apply config doesn't work when timeout settings are too small
- [INTERLOK-482](https://adaptris.atlassian.net/browse/INTERLOK-482) - Amazon-SQS tests failing
- [INTERLOK-495](https://adaptris.atlassian.net/browse/INTERLOK-495) - AdapterRegistry should support VCS
- [INTERLOK-497](https://adaptris.atlassian.net/browse/INTERLOK-497) - Vcs Api - more methods
- [INTERLOK-500](https://adaptris.atlassian.net/browse/INTERLOK-500) - Vcs new service loader
- [INTERLOK-501](https://adaptris.atlassian.net/browse/INTERLOK-501) - AdapterRegistry needs a putConfigurationURL(ObjectName, URL) method.
- [INTERLOK-502](https://adaptris.atlassian.net/browse/INTERLOK-502) - Add flyway support to the adapter-gui to update the database
- [INTERLOK-504](https://adaptris.atlassian.net/browse/INTERLOK-504) - message-metrics-interceptor should default on all workflows
- [INTERLOK-506](https://adaptris.atlassian.net/browse/INTERLOK-506) - Make StandardErrorDigester with a uniqueId of "ErrorDigest" the default.
- [INTERLOK-507](https://adaptris.atlassian.net/browse/INTERLOK-507) - Add a BranchingService Impl that allows you to use a JSR223 language
- [INTERLOK-509](https://adaptris.atlassian.net/browse/INTERLOK-509) - remote usage of count widgets  is slow/un-usable
- [INTERLOK-510](https://adaptris.atlassian.net/browse/INTERLOK-510) - MessageStatisticsMBean needs a getAll() method
- [INTERLOK-511](https://adaptris.atlassian.net/browse/INTERLOK-511) - Add a JettyPoolingWorkflowInterceptor automatically to PoolingWorkflows where appropriate
- [INTERLOK-513](https://adaptris.atlassian.net/browse/INTERLOK-513) - Add a testConnection method ot the VersionControlSystem classes
- [INTERLOK-515](https://adaptris.atlassian.net/browse/INTERLOK-515) - Subversion error logging isn't useful if initiailisation fails.
- [INTERLOK-516](https://adaptris.atlassian.net/browse/INTERLOK-516) - Amazon-SQS add message attributes to the producer.
- [INTERLOK-517](https://adaptris.atlassian.net/browse/INTERLOK-517) - Add some documentation for the vcs profile page and the vcs in the config page
- [INTERLOK-518](https://adaptris.atlassian.net/browse/INTERLOK-518) - Add a NullMessageAggregator
- [INTERLOK-519](https://adaptris.atlassian.net/browse/INTERLOK-519) - Upgrade maven jetty plugin in the gui pom file to use the same jetty version as the adapter
- [INTERLOK-522](https://adaptris.atlassian.net/browse/INTERLOK-522) - Review all the @since tags
- [INTERLOK-524](https://adaptris.atlassian.net/browse/INTERLOK-524) - Upgrade AMQP to use org.apache.qpid:qpid-jms-client:0.2.0
- [INTERLOK-525](https://adaptris.atlassian.net/browse/INTERLOK-525) - JMX Caller Service
- [INTERLOK-527](https://adaptris.atlassian.net/browse/INTERLOK-527) - Use the MessageStatisticsMBean getStatistics() method
- [INTERLOK-533](https://adaptris.atlassian.net/browse/INTERLOK-533) - Make the RuntimeVersionControlLoader a singleton so it's easier to write test using it
- [INTERLOK-534](https://adaptris.atlassian.net/browse/INTERLOK-534) - Display an error if a user doesn't enter a vcs commit comment



## Version 3.0.2 ##

Release Date : 2015-05-14


### Bugs

- [INTERLOK-214](https://adaptris.atlassian.net/browse/INTERLOK-214) - Dashboard Page - The 'show workflows' option is reset upon a refresh event.
- [INTERLOK-424](https://adaptris.atlassian.net/browse/INTERLOK-424) - GUI unit tests fail with java8
- [INTERLOK-427](https://adaptris.atlassian.net/browse/INTERLOK-427) - Cannot have multiple ehcache.xml configurations.
- [INTERLOK-428](https://adaptris.atlassian.net/browse/INTERLOK-428) - Distributed ehcache - Restarting cache components breaks all caches.
- [INTERLOK-430](https://adaptris.atlassian.net/browse/INTERLOK-430) - FTP Producer does not throw ProduceException if it fails to write the file.
- [INTERLOK-432](https://adaptris.atlassian.net/browse/INTERLOK-432) - NPE thrown by JmsConnectionErrorHandlerImpl
- [INTERLOK-437](https://adaptris.atlassian.net/browse/INTERLOK-437) - BapiXmlGenerator / RfcXmlGenerator cannot use a shared connection
- [INTERLOK-438](https://adaptris.atlassian.net/browse/INTERLOK-438) - BapiXmlGenerator / BapiRfcGenerator cannot be part of an RfcServiceList
- [INTERLOK-444](https://adaptris.atlassian.net/browse/INTERLOK-444) - Presence of ROOT.war in /webapps directory stops jetty message consumer working for embedded connection
- [INTERLOK-447](https://adaptris.atlassian.net/browse/INTERLOK-447) - Platform Memory Heap Chart Hover tooltip is wrong....
- [INTERLOK-451](https://adaptris.atlassian.net/browse/INTERLOK-451) - A NPE occurs when opening the setting modal
- [INTERLOK-462](https://adaptris.atlassian.net/browse/INTERLOK-462) - The javascript component getJsonData return too much data
- [INTERLOK-463](https://adaptris.atlassian.net/browse/INTERLOK-463) - Interlok GUI applies config to the wrong adapter when running multiple adapters on same install
- [INTERLOK-471](https://adaptris.atlassian.net/browse/INTERLOK-471) - Remove license.properties from the nightly builds base-filesystem.zip
- [INTERLOK-472](https://adaptris.atlassian.net/browse/INTERLOK-472) - ui config - add metadata service is not working correctly
- [INTERLOK-487](https://adaptris.atlassian.net/browse/INTERLOK-487) - licenses.zip should be part of runtime-libraries.zip
- [INTERLOK-491](https://adaptris.atlassian.net/browse/INTERLOK-491) - A Standard style "URL" doesn't work with fs-immediate-event-poller


### Improvements

- [INTERLOK-225](https://adaptris.atlassian.net/browse/INTERLOK-225) - UI Config Page - 'Save as Template'
- [INTERLOK-373](https://adaptris.atlassian.net/browse/INTERLOK-373) - include a annotation for input types on the adapter model for non-regular types such as xml or sql etc
- [INTERLOK-379](https://adaptris.atlassian.net/browse/INTERLOK-379) - UI - Write a brief spec outling how the config will integrate into subversion
- [INTERLOK-382](https://adaptris.atlassian.net/browse/INTERLOK-382) - Sonic Container - Interlok testing
- [INTERLOK-392](https://adaptris.atlassian.net/browse/INTERLOK-392) - UI Config - improve string inputs to allow user to convert input into text area
- [INTERLOK-401](https://adaptris.atlassian.net/browse/INTERLOK-401) - com.adaptris.core.http.jetty.ResponseProducer should use MetadataFilter
- [INTERLOK-402](https://adaptris.atlassian.net/browse/INTERLOK-402) - Add a RemoveAllMetadataFilter and modify all producers that can send metadata
- [INTERLOK-413](https://adaptris.atlassian.net/browse/INTERLOK-413) - Upgrade build environment to java8
- [INTERLOK-417](https://adaptris.atlassian.net/browse/INTERLOK-417) - UI - Change Force Close function to report an error to the UI window when in jmxmp mode
- [INTERLOK-419](https://adaptris.atlassian.net/browse/INTERLOK-419) - Preferences -> requestTimeout should be editable. ...
- [INTERLOK-429](https://adaptris.atlassian.net/browse/INTERLOK-429) - The filter-expression should be used to filter valid http methods for MessageConsumer
- [INTERLOK-435](https://adaptris.atlassian.net/browse/INTERLOK-435) - connection-attempts can't be set to -1 via GUI. ...
- [INTERLOK-440](https://adaptris.atlassian.net/browse/INTERLOK-440) - Rendering Options in IdocConsumer should be "or'd" together
- [INTERLOK-441](https://adaptris.atlassian.net/browse/INTERLOK-441) - Parsing Options in IdocProducer should be or'd together
- [INTERLOK-442](https://adaptris.atlassian.net/browse/INTERLOK-442) - IdocFormat should really be an enum
- [INTERLOK-445](https://adaptris.atlassian.net/browse/INTERLOK-445) - Set message factory for LineCountSplitter to DefaultMessageFactory
- [INTERLOK-446](https://adaptris.atlassian.net/browse/INTERLOK-446) - NPE when viewing the "XML" from the dashboard...
- [INTERLOK-448](https://adaptris.atlassian.net/browse/INTERLOK-448) - Change the "Domain" from Adaptris for the MBeans
- [INTERLOK-452](https://adaptris.atlassian.net/browse/INTERLOK-452) - Add a force close button for the adpaters in the dashboard
- [INTERLOK-455](https://adaptris.atlassian.net/browse/INTERLOK-455) - Add a log4jUrl property to bootstrap.properties
- [INTERLOK-456](https://adaptris.atlassian.net/browse/INTERLOK-456) - Make JavaHL / SVNKit reflective
- [INTERLOK-466](https://adaptris.atlassian.net/browse/INTERLOK-466) - AdapterRegistry needs to track the "URLs" that were used to create the adapter.
- [INTERLOK-357](https://adaptris.atlassian.net/browse/INTERLOK-357) - UI Config Setting Editor - add a xpath feature to settings
- [INTERLOK-358](https://adaptris.atlassian.net/browse/INTERLOK-358) - UI Dashboard - enable a tiled-view/compact-view for the listed adapters
- [INTERLOK-383](https://adaptris.atlassian.net/browse/INTERLOK-383) - Update SonicMF to use the UnifiedBootstrap
- [INTERLOK-399](https://adaptris.atlassian.net/browse/INTERLOK-399) - Adapter Boostrap with VCS (subversion)
- [INTERLOK-475](https://adaptris.atlassian.net/browse/INTERLOK-475) - LicenseExpiryWarningEvent interoperability with v2.
- [INTERLOK-476](https://adaptris.atlassian.net/browse/INTERLOK-476) - DefaultAdapterStartupEvent interoperability with v2


## Version 3.0.1 ##

Release Date : 2015-04-08


### Bugs

- [INTERLOK-387](https://adaptris.atlassian.net/browse/INTERLOK-387) - String fields are not preserved if input is "NUMERIC" only.
- [INTERLOK-395](https://adaptris.atlassian.net/browse/INTERLOK-395) - XmlTransformService Swallows Errors
- [INTERLOK-408](https://adaptris.atlassian.net/browse/INTERLOK-408) - Unable to select shared connection in ReliableMessagingConsumer
- [INTERLOK-411](https://adaptris.atlassian.net/browse/INTERLOK-411) - Unable to add EbXmlRoutingAndValidation service
- [INTERLOK-416](https://adaptris.atlassian.net/browse/INTERLOK-416) - ThrottlingInterceptor is blocking adapter stop

### Improvements

- [INTERLOK-381](https://adaptris.atlassian.net/browse/INTERLOK-381) - Add a bootstrap property that controls the name of the AdapterRegistry
- [INTERLOK-382](https://adaptris.atlassian.net/browse/INTERLOK-382) - Sonic Container - Interlok testing
- [INTERLOK-385](https://adaptris.atlassian.net/browse/INTERLOK-385) - Make variableSubstitution pre-processor handle nested variables
- [INTERLOK-391](https://adaptris.atlassian.net/browse/INTERLOK-391) - Add SystemPropertyPreProcessor and EnvironmentPreProcessor as variableSubstitution extensions
- [INTERLOK-393](https://adaptris.atlassian.net/browse/INTERLOK-393) - Review String members that should really be enums
- [INTERLOK-394](https://adaptris.atlassian.net/browse/INTERLOK-394) - SonicMF component requires a full bootstrap.properties
- [INTERLOK-400](https://adaptris.atlassian.net/browse/INTERLOK-400) - Review validation annotations on components
- [INTERLOK-418](https://adaptris.atlassian.net/browse/INTERLOK-418) - Add a Statement Timeout to JDBC Services.
- [INTERLOK-420](https://adaptris.atlassian.net/browse/INTERLOK-420) - If adapter is shutdown then ctrl-c causes an exception to be thrown by the eventHandler
- [INTERLOK-422](https://adaptris.atlassian.net/browse/INTERLOK-422) - Default adapter for "releases" should not say Interlok-Tech-Preview


## Version 3.0.0 ##

Release Date : 2015-03-15

Initial release of Interlok; key highlights are

- [Shared Connections and JNDI](adapter-jndi-guide.html)
- [Pre-processor for configuration files](advanced-configuration-pre-processors.html)
- [Web based UI](ui-introduction.html) that
    - Simplifies and Visualises Configuration
    - Testing via the UI.
    - Real-time monitoring of multiple adapters.
    - Real-time monitoring on failures (with the chance to retry directly from the UI).
    - Performance Diagnostics
- [Adapter XML Schema using RelaxNG](advanced-configuration-pre-processors.html#schema-validation)
- Java 7 / Java 8 only.
- A whole slew of changes under covers that are too numerous to mention


[JmsTransactedWorkflow]: https://development.adaptris.net/javadocs/v3-snapshot/Interlok-API/com/adaptris/core/jms/JmsTransactedWorkflow.html
