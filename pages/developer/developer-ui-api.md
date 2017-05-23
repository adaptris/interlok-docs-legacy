---
title: Interlok UI API
keywords: interlok
tags: [developer]
sidebar: home_sidebar
permalink: developer-ui-api.html
summary: The UI has its own API. This can be used to do some simple operations, if you want to create your own simple dashboard, instead of using our awesome spectacular UI.
---

## Swagger Goodness ##

The Interlok UI API is accessible via restful web services. The best way to learn how to use the Interlok UI API is to use Swagger UI. You can see all the available operations by using it.

Learn more about [Swagger](http://swagger.io/) and [Swagger UI](http://swagger.io/swagger-ui/).

Once you've downloaded Swagger UI you should copy it into the `adapter/webapp` folder.
You should be able to access it via [http://localhost:8080/swagger-ui-2.1.4/dist/index.html](http://localhost:8080/swagger-ui-2.1.4/dist/index.html) (where /swagger-ui-2.1.4/dist/ is the name of the folder you copied into `adapter/webapp`).

The default API url in Swagger UI is a pet store example.
Replace it with it the Interlok UI API url [http://localhost:8080/interlok/api/swagger.json](http://localhost:8080/interlok/api/swagger.json).

If you access this url directly you will see the json Swagger definition for the Interlok UI API with a list of all the operations which looks something like: 

```json
{
  "swagger" : "2.0",
  "info" : {
    "description" : "Interlok UI Api web service documentation.",
    "version" : "3.6-SNAPSHOT",
    "title" : "Interlok UI Api Documentation"
  },
  "basePath" : "/interlok/api",
  "tags" : [ {
    "name" : "/adapter/failed-messages"
  }, {
    "name" : "/channel"
  }, {
    "name" : "/adapter/metrics"
  }, {
    "name" : "/channel/failed-messages"
  }, {
    "name" : "/adapter/platform"
  }, {
    "name" : "/workflow/metrics"
  }, {
    "name" : "/workflow/failed-messages"
  }, {
    "name" : "/adapter/component-checker"
  }, {
    "name" : "/channel/metrics"
  }, {
    "name" : "/adapter"
  }, {
    "name" : "/workflow"
  } ],
  "paths" : {
    "/external/adapter" : {
      "get" : {
        "tags" : [ "/adapter" ],
        "summary" : "List all register adapters",
        "description" : "",
        "operationId" : "list",
        "consumes" : [ "application/xml", "application/json" ],
        "produces" : [ "application/json", "application/xml" ],
        "parameters" : [ {
          "name" : "pageSize",
          "in" : "query",
          "required" : false,
          "type" : "integer",
          "default" : -1,
          "format" : "int32"
        }, {
          "name" : "page",
          "in" : "query",
          "required" : false,
          "type" : "integer",
          "default" : -1,
          "format" : "int32"
        } ],
        "responses" : {
          "200" : {
            "description" : "successful operation",
            "schema" : {
              "type" : "array",
              "items" : {
                "$ref" : "#/definitions/AdapterEntity"
              }
            }
          }
        }
      },
      "post" : {
        "tags" : [ "/adapter" ],
        "summary" : "Add an adapter",
        "description" : "",
        "operationId" : "save",
        "consumes" : [ "application/json", "application/xml" ],
        "produces" : [ "application/json", "application/xml" ],
        "parameters" : [ {
          "in" : "body",
          "name" : "body",
          "required" : false,
          "schema" : {
            "$ref" : "#/definitions/AdapterEntity"
          }
        } ],
        "responses" : {
          "200" : {
            "description" : "successful operation",
            "schema" : {
              "$ref" : "#/definitions/AdapterEntity"
            }
          }
        }
      }
    },
...
```

Back to the Swagger UI, you should get a list of all the Interlok UI API operations e.g.

![Local Swagger UI With Data](./images/ui-api/swagger-with-interlok-data.png)

You can then use this page to test the api against your own Interlok UI API:

![Local Swagger Doing Operation](./images/ui-api/swagger-with-interlok-data-opened.png)

## Real World Example ##

There is a working example of the UI API in action within the cm-dashboard project (the Cirrus UI).

The cirrus ui lists the Interlok containers within it's given community:

![Cirrus UI - Interlok Container Details Page](./images/ui-api/1-Cirrus-UI-Adapter-Details-Page.png)

by selecting the manage operation for a given Interlok container:

![Cirrus UI - Interlok Container Details Page manage button](./images/ui-api/2-Cirrus-UI-Adapter-Details-Page-manage-btn.png)

you can view the manage Interlok container page:

![Cirrus UI - Manage Interlok container Page](./images/ui-api/3-Cirrus-UI-Manage-Adapter-Page.png)

This manage Interlok container page is using the interlok ui api to obtain data & perform functions on this selected Interlok container. All the Interlok containers in this community are registered with one ui Interlok container, which is having the ui api accessed by this webapp. In essence, this page is its own Interlok container ui.

## Yeah, but... ##

Of course, you can use Interloks own MBeans to gain data and operate functions.

[https://docs.oracle.com/javase/tutorial/jmx/mbeans/](https://docs.oracle.com/javase/tutorial/jmx/mbeans/)

![JConsole MBeans](./images/ui-api/8-MBeans.png)


OR, if you just want users to see metric data and not config or be able to use start/stop operations, you can setup a read only user in the ui : [Interlok UI Security](ui-security.html)
