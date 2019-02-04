---
title: Service Tester - Continuous Delivery
keywords: interlok
tags: [service-tester]
sidebar: home_sidebar
permalink: service-tester-continuous-delivery.html
---
## Overview

Where the Interlok service tester can be used as a part of your continuos delivery pipeline, below is a few examples of how to configure:

{% include important.html content="If you are using service-tester along with JSON assertions then you should exclude `com.vaadin.external.google:android-json` from the dependency tree. This can cause conflicts with normal Interlok JSON processing." %}

## Examples

### Gradle

#### Configuration

```javascript
ext {
  adpCoreVersion = project.hasProperty('adpCoreVersion') ? project.getProperty('adpCoreVersion') : '3.6-SNAPSHOT'
}
apply plugin: 'java'

configurations {
  antJunit
  all*.exclude group: 'org.codehaus.woodstox'
  all*.exclude group: 'org.fasterxml.woodstox'
  all*.exclude group: 'org.eclipse.jetty.orbit', module: 'javax.mail.glassfish'
  all*.exclude group: 'com.vaadin.external.google', module: 'android-json'  
}

repositories {
  mavenCentral()
  maven { url "https://nexus.adaptris.net/nexus/content/groups/public" }
  maven { url "https://nexus.adaptris.net/nexus/content/repositories/snapshots" }
  maven { url "https://nexus.adaptris.net/nexus/content/repositories/releases" }
}

dependencies {
  compile ("com.adaptris:interlok-service-tester:$adpCoreVersion") { changing= true}
  antJunit ("org.apache.ant:ant-junit:1.8.2")
}

sourceSets {
  test {
    resources {
      srcDir "$projectDir/test/resources"
    }
  }
}

check.dependsOn -= test
task test(overwrite: true) {
  doLast {
    javaexec {
      main = 'com.adaptris.tester.runners.TestExecutor'
      classpath = sourceSets.test.runtimeClasspath
      args "--serviceTest"
      args "$projectDir/test/src/test.xml"
      args "--serviceTestOutput"
      args "$buildDir/test-results/"
    }
  }
}

task junitReport {
  doLast {
    ant.taskdef(
      name: 'junitreport',
      classname: 'org.apache.tools.ant.taskdefs.optional.junit.XMLResultAggregator',
      classpath: configurations.antJunit.asPath
    )

    ant.junitreport(todir: "$buildDir/test-results") {
      fileset(dir: "$buildDir/test-results", includes: 'TEST-*.xml')
      report(todir: "$buildDir/test-results/html", format: "frames"	)
    }
  }
}

check.dependsOn += test
test.dependsOn += processTestResources
test.finalizedBy junitReport
```

#### Execution

```
$ ./gradlew check
:processTestResources UP-TO-DATE
:test
Running [service-tests.payload-from-metadata-service]
Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.726 sec
:junitReport
Trying to override old definition of datatype junitreport
:check

BUILD SUCCESSFUL in 9s
3 actionable tasks: 2 executed, 1 up-to-date
```

### Ant

#### Configuration

```xml
<project basedir="." default="test" name="interlok-hello-world" xmlns:ivy="antlib:org.apache.ivy.ant">

  <property file="ivy.properties"/>
  <target name="init-ivy">
    <property name="ivy.dir" value="${basedir}/ivy"/>
    <property name="ivy.jar.file" value="${ivy.dir}/ivy.jar"/>
    <property name="ivy.install.version" value="2.3.0"/>
    <property name="ivy.repo" value="nexus-snapshots"/>
    <property name="ivy.xml.file" value="${basedir}/ivy.xml"/>
    <property name="ivy.logging" value="quiet"/>
    <property name="build.dir" value="${basedir}/target"/>
    <property name="tests.output.dir" value="${build.dir}/testoutput"/>
    <property name="test.resources.dir" value="${basedir}/test/resources"/>
  </target>

  <target name="download-ivy" depends="init-ivy" unless="skip.ivy.download">
    <echo message="Downloading ivy..."/>
    <get src="http://repo1.maven.org/maven2/org/apache/ivy/ivy/${ivy.install.version}/ivy-${ivy.install.version}.jar" dest="${ivy.jar.file}" usetimestamp="true"/>
  </target>

  <target name="install-ivy" depends="download-ivy" description="Install ivy">
    <path id="ivy.lib.path">
      <pathelement location="${ivy.jar.file}"/>
    </path>
    <taskdef resource="org/apache/ivy/ant/antlib.xml" uri="antlib:org.apache.ivy.ant" classpathref="ivy.lib.path"/>
  </target>

  <target name="prepare-ivy" depends="install-ivy" description="Loads all the ivy definitions and settings">
    <ivy:settings file="${ivy.dir}/ivy-settings.xml" />
    <ivy:resolve file="${ivy.xml.file}" refresh="true" showprogress="false" log="${ivy.logging}"/>
    <ivy:cachepath pathid="classpath.service-tester" conf="compile" type="jar,zip,bundle,hk2-jar,maven-plugin"/>
  </target>

  <target name="test" depends="prepare-ivy">
    <mkdir dir="${build.dir}"/>
    <mkdir dir="${tests.output.dir}"/>
    <mkdir dir="${tests.output.dir}/report"/>
    <java classname="com.adaptris.tester.runners.TestExecutor" fork="true" failonerror="false" dir="${basedir}" resultproperty="java.result">
      <arg value="--serviceTest"/>
      <arg value="${basedir}/test/src/test.xml"/>
      <arg value="--serviceTestOutput"/>
      <arg value="${tests.output.dir}"/>
      <classpath refid="classpath.service-tester"/>
      <classpath>
        <pathelement location="${test.resources.dir}"/>
      </classpath>
    </java>
    <junitreport todir="${tests.output.dir}">
      <fileset dir="${tests.output.dir}">
        <include name="TEST-*.xml" />
      </fileset>
      <report format="frames" todir="${tests.output.dir}/report"/>
    </junitreport>
  </target>
</project>
```

#### Execution

```
$ ant test
Buildfile: C:\repo\code\adaptris\github\interlok-hello-world\build.xml

init-ivy:

download-ivy:
     [echo] Downloading ivy...
      [get] Getting: http://repo1.maven.org/maven2/org/apache/ivy/ivy/2.3.0/ivy-2.3.0.jar
      [get] To: C:\repo\code\adaptris\github\interlok-hello-world\ivy\ivy.jar
      [get] Not modified - so not downloaded

install-ivy:

prepare-ivy:
[ivy:resolve] :: Apache Ivy 2.3.0 - 20130110142753 :: http://ant.apache.org/ivy/ ::
[ivy:resolve] :: loading settings :: file = C:\repo\code\adaptris\github\interlok-hello-world\ivy\ivy-settings.xml

test:
     [java] Running [service-tests.payload-from-metadata-service]
     [java] Tests run: 1, Failures: 0, Errors: 0, Skipped: 0, Time elapsed: 0.566 sec
[junitreport] Processing C:\repo\code\adaptris\github\interlok-hello-world\target\testoutput\TESTS-TestSuites.xml to C:\Users\warmanm\AppData\Local\Temp\null734705140
[junitreport] Loading stylesheet jar:file:/C:/tools/apache-ant-1.10.1/lib/ant-junit.jar!/org/apache/tools/ant/taskdefs/optional/junit/xsl/junit-frames.xsl
[junitreport] Transform time: 407ms
[junitreport] Deleting: C:\Users\warmanm\AppData\Local\Temp\null734705140

BUILD SUCCESSFUL
Total time: 8 seconds
```