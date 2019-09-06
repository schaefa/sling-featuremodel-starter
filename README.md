# Feature Model based Sling Starter

This page contains instructions on how to build and run the Sling as a Feature Model.

# Setup

This project depends on the latest releases of Sling Feature projects including the Sling
Feature Maven Plugin as well as the **Sling Feature CP Converter and Sling Feature
Converter Maven Plugin** which must be built locally first before they can be used.

For that please clone these project and built with `mvn clean install` on the
**master** branch:
* sling-org-apache-sling-feature-cpconverter
* sling-feature-converter-maven-plugin

The source for the Sling conversion is provided by the Provisioning Model
of the Sling Starter Project. So you need to clone this project as well
but there is no built required:
* sling-org-apache-sling-starter

# Conversion and Launch

The project is converting assembling and launching (optional) through a
Maven build.

To just build the project:
```
mvn clean install -P launch -Dsling.starter.folder=&lt;Path to your Sling Starter Project>
```
To build and launch:
```
mvn clean install -P launch -P launch -Dsling.starter.folder=&lt;Path to your Sling Starter Project>
```

**ATTENTION**: with `mvn clean` only the target folder is removed but
the Sling Launcher folder (*./aluncher*) is not touched otherwise a clean
rebuilt would whip away the Sling instance (that is the reason why the
launcher folder is not in the target folder).

If there is any issue with the build when starting up stop Sling, copy
away the original **launcher** folder and then rebuilt and launch the
project.

## Notes for Sling

As of now Sling comes up just fine but there is a little issue with the
starter screen.
When opening Sling with **http://localhost:8080** then you will get the
starter page and it will tell you that your are logged in as admin which
is not true. You notice that when you click on **Browse Content** you
will remain on the starter page.
To fix that you need to login first with:
```
http://localhost:8080/system/sling/form/login
```
and then when clicking on Browse Content you will get to the Composum
content browser.

Andreas Schaefer, 6/6/2019