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
# This script converts the local Sling Launchpad Starter Provisioning Model into a Feature
# Model and starts it with the Feature Launcher. See file pm2fm.sling.arfile to PM 2 FM
# configuration.
#

baseDir=`pwd`
slingDevHome=$baseDir/..
conversionDir=$baseDir/sling-conversion
conversionBinDir=$conversionDir/bin
conversionLibDir=$conversionDir/lib
fmVersion=1.0.2
laucherName=org.apache.sling.feature.launcher
contentExtensionName=org.apache.sling.feature.extension.content
apiRegionsExtensionName=org.apache.sling.feature.extension.apiregions

if [ "$slingDevHome" ==  "" ]; then
    echo "No Sling Dev Home (Parameter 1 or SLING_DEV) is provided -> exit"
    exit
fi

if [ ! -d $conversionDir ]; then
    mkdir $conversionDir
fi

# Install the PM 2 FM Converter
if [ -d $conversionBinDir ]; then
    rm -rf $conversionBinDir
fi
if [ -d $conversionLibDir ]; then
    rm -rf $conversionLibDir
fi

unzip $slingDevHome/sling-org-apache-sling-feature-modelconverter/target/org.apache.sling.feature.modelconverter-*.zip -d $conversionDir
cp -R $conversionDir/org.apache.sling.feature.modelconverter*/bin $conversionDir
cp -R $conversionDir/org.apache.sling.feature.modelconverter*/lib $conversionDir
rm -rf $conversionDir/org.apache.sling.feature.modelconverter*

# Obtain Feature Artifacts

curl http://repo1.maven.org/maven2/org/apache/sling/$laucherName/$fmVersion/$laucherName-$fmVersion.jar -O
curl http://repo1.maven.org/maven2/org/apache/sling/$contentExtensionName/$fmVersion/$contentExtensionName-$fmVersion.jar -O
curl http://repo1.maven.org/maven2/org/apache/sling/$apiRegionsExtensionName/$fmVersion/$apiRegionsExtensionName-$fmVersion.jar -O

# Do the PM 2 FM Conversion

cd $conversionDir
if [ -d fm.out ]; then
    rm -rf fm.out/*
fi
sh ./bin/pm2fm @../pm2fm.sling.arfile
cd ..

# Copy generated FM files to target
if [ ! -d target ]; then
   mkdir target
else
   rm -rf target/*
fi
if [ ! -d target/fm ]; then
   mkdir target/fm
fi

cp -R $conversionDir/fm.out/* target/fm

# Build Project

mvn install

# Launch Sling

java -cp $laucherName-$fmVersion.jar:$contentExtensionName-$fmVersion.jar:$apiRegionsExtensionName-$fmVersion.jar \
      org.apache.sling.feature.launcher.impl.Main \
      -f target/slingfeature-tmp/feature-example-runtime.json
