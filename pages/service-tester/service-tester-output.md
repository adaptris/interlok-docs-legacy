---
title: Service Tester - Output
keywords: interlok
tags: [service-tester]
sidebar: home_sidebar
permalink: service-tester-output.html
---
## Output ##

The Interlok service tester produces Ant JUnit XML although it isn't officially supported by JUnit them selves. Many tools support it out of the box (jenkins, etc.).

## Example##

```xml
<testsuite name="TestList.Test1" hostname="LHRL28244" failures="0" errors="0" tests="1" skipped="0" timestamp="2017-12-18T03:22:13" time="0.018244542">
  <properties/>
  <testcase name="TestCase1" time="0.017826098"/>
</testsuite>
```