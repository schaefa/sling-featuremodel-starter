# Feature Model based Sling Starter

This page contains instructions on how to build and run the Sling based on a Feature Model.

# Setup

This project depends on the latest code from the **sling-org-apache-sling-feature-modelconverter**
project on branch **standalone-app**. Change to the project an build with:
```
mvn clean install
```
Then check out the **sling-org-apache-sling-starter** project as this will
be the source of the conversion.

# Conversion and Launch

This project provides a convenience script to convert and launch Sling with
FM launcher: **do.sling.conversion.sh**.
The argument file **pm2fm.sling.arfile** contains all the arguments necessary
to do the conversion with the Sling Feature Model Converter. Adjust the
**-i** flag as this points to your local Sling Launchpad Folder that is
providing the PM files. The rest should not be changed.

**Attention**: in this file we assume that SLING_DEV_HOME is pointing to the
folder where Sling is developed. Set the env variable or replace $SLING_DEV_HOME
with the correct folder path.

Build and Launch with:
```
sh do.sling.conversion.sh
```

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