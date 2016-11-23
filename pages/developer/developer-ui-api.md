---
title: Interlok UI API
keywords: interlok
sidebar: home_sidebar
permalink: developer-ui-api.html
summary: The UI has its own API. This can be used to do some simple operations, if you want to create your own simple dashboard, instead of using our awesome spectacular UI.
---

## Real World Example ##

There is a working example of the UI API in action within the cm-dashboard project (the Cirrus UI).

The cirrus ui lists the Interlok containers within it's given community:
![Cirrus UI - Interlok Container Details Page](./images/ui-api/1-Cirrus-UI-Adapter-Details-Page.png)

by selecting the manage operation for a given Interlok container:
![Cirrus UI - Interlok Container Details Page manage button](./images/ui-api/2-Cirrus-UI-Adapter-Details-Page-manage-btn.png)

you can view the manage Interlok container page:
![Cirrus UI - Manage Interlok container Page](./images/ui-api/3-Cirrus-UI-Manage-Adapter-Page.png)

This manage Interlok container page is using the interlok ui api to obtain data & perform functions on this selected Interlok container. All the Interlok containers in this community are registered with one ui Interlok container, which is having the ui api accessed by this webapp. In essence, this page is its own Interlok container ui.

## Swagger Goodness ##

The Interlok UI API is accessible via restful web services. You can see all the available operations by using the swagger interface.

learn more about swagger:

[http://swagger.io/](http://swagger.io/)

[http://swagger.io/swagger-ui/](http://swagger.io/swagger-ui/)


So, if you point to (change this URL for you own hostname)

[http://localhost:8080/adapter-web-gui/access/swagger.json](http://localhost:8080/adapter-web-gui/access/swagger.json)

you will see the json file containing all the webservices data.
![Swagger JSON](./images/ui-api/4-swagger-json.png)


If you install the swagger ui into the same host that your Interlok ui is in...

so download swagger-ui and copy that folder into the adapter's webapp folder, then point to (For Example)

[http://localhost:8080/swagger-ui-2.1.4/dist/index.html](http://localhost:8080/swagger-ui-2.1.4/dist/index.html)

![Swagger UI Page](./images/ui-api/5-local-swagger-ui-page.png)

you then put in the json url into the input box and press explore
![Local Swagger UI With Data](./images/ui-api/6-local-swagger-with-data.png)

you can then use this page to develop against and make your own Interlok UI:
![Local Swagger Doing Operation](./images/ui-api/7-local-swagger-doing-operation.png)

## Yeah, but... ##

Of course, you can use Interloks own MBeans to gain data and operate functions.

[https://docs.oracle.com/javase/tutorial/jmx/mbeans/](https://docs.oracle.com/javase/tutorial/jmx/mbeans/)

![JConsole MBeans](./images/ui-api/8-MBeans.png)


OR, if you just want users to see metric data and not config or be able to use start/stop operations, you can setup a read only user in the ui : [Interlok UI Security](ui-security.html)
