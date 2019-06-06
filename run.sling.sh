#!/bin/bash

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements. See the NOTICE file distributed with this
# work for additional information regarding copyright ownership. The ASF
# licenses this file to You under the Apache License, Version 2.0 (the
# "License"); you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.

#
# Script that just launches a previously converted. If the /launcher folder is
# delete beforehand a new Sling instance is created otherwise it just restarts
# Sling
#

baseDir=`pwd`
fmVersion=1.0.2
laucherName=org.apache.sling.feature.launcher
contentExtensionName=org.apache.sling.feature.extension.content
apiRegionsExtensionName=org.apache.sling.feature.extension.apiregions

# Launch Sling

java \
     -cp $laucherName-$fmVersion.jar:$contentExtensionName-$fmVersion.jar:$apiRegionsExtensionName-$fmVersion.jar \
     org.apache.sling.feature.launcher.impl.Main \
     -f target/slingfeature-tmp/feature-example-runtime.json \
     -v

# Add this to the line below 'java' to enable debugging
#     -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=5005 \
