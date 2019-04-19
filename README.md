# Feature Model based Sling Starter

This page contains instructions on how to build and run the Sling based on a Feature Model.

## Prepare

Download the launcher:

```
curl http://repo1.maven.org/maven2/org/apache/sling/org.apache.sling.feature.launcher/1.0.0/org.apache.sling.feature.launcher-1.0.0.jar -O
```

## Build and Launch

Build the feature model project.

```
mvn clean install
```

Launch the aggregate feature `webconsole.http`:

```
rm -rf launcher && \
java -jar org.apache.sling.feature.launcher-1.0.0.jar \
     -f target/slingfeature-tmp/feature-example-runtime.json
```

Now you can connect to the Sling's webconsole via http://localhost:8080/system/console

## Issues

When this is launched w/o any tweaking then the launcher will list a bunch of missing OSGi dependencies
most of them around javax.* packages.
I found a workaround by listing all the missing packages into a property called **org.osgi.framework.system.packages.extra**
and this solves most of the issues with **javax.xml.stream** package using by these bundles:

* org.apache.servicemix.bundles.jaxb-impl: Apache ServiceMix :: Bundles :: jaxb-impl
* org.apache.servicemix.specs.jaxb-api-2.2: Apache ServiceMix :: Specs :: JAXB API 2.2
* org.apache.servicemix.specs.jaxws-api-2.2: Apache ServiceMix :: Specs :: JAXWS API 2.2

Further investigation reveals that the Felix System Bundle (org.apache.felix.framework) is not exporting javax.*
packages. If I removed for example javax.xml.stream from the property it will not be listed as *Overwritten by
Boot Delegation* but it is not listed as exported underneath. When I start Sling 11 then it will be listed there
as exported.

## Creating the Feature Models

### Preparation

Checkout the Sling Feature Model Converter project (https://github.com/apache/sling-org-apache-sling-feature-modelconverter).
Then add this class to the test classes (I was too lazy to create a project so I highjacked the tests):
```
/*
 * Licensed to the Apache Software Foundation (ASF) under one or more
 * contributor license agreements. See the NOTICE file distributed with this
 * work for additional information regarding copyright ownership. The ASF
 * licenses this file to You under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */
package org.apache.sling.feature.modelconverter;

import org.apache.sling.feature.Bundles;
import org.apache.sling.feature.Configurations;
import org.apache.sling.feature.Extension;
import org.apache.sling.feature.ExtensionType;
import org.apache.sling.feature.Extensions;
import org.apache.sling.feature.builder.FeatureProvider;
import org.apache.sling.feature.io.file.ArtifactHandler;
import org.apache.sling.feature.io.file.ArtifactManager;
import org.apache.sling.feature.io.file.ArtifactManagerConfig;
import org.apache.sling.feature.io.json.FeatureJSONReader;
import org.apache.sling.provisioning.model.Artifact;
import org.apache.sling.provisioning.model.ArtifactGroup;
import org.apache.sling.provisioning.model.Configuration;
import org.apache.sling.provisioning.model.Feature;
import org.apache.sling.provisioning.model.KeyValueMap;
import org.apache.sling.provisioning.model.MergeUtility;
import org.apache.sling.provisioning.model.Model;
import org.apache.sling.provisioning.model.ModelConstants;
import org.apache.sling.provisioning.model.ModelUtility;
import org.apache.sling.provisioning.model.ModelUtility.ResolverOptions;
import org.apache.sling.provisioning.model.ModelUtility.VariableResolver;
import org.apache.sling.provisioning.model.RunMode;
import org.apache.sling.provisioning.model.Section;
import org.apache.sling.provisioning.model.io.ModelReader;
import org.junit.After;
import org.junit.Before;
import org.junit.Test;
import org.mockito.Mockito;
import org.mockito.invocation.InvocationOnMock;
import org.mockito.stubbing.Answer;

import java.io.File;
import java.io.FileReader;
import java.io.IOException;
import java.io.Reader;
import java.io.UncheckedIOException;
import java.net.URISyntaxException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.nio.file.StandardOpenOption;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.Dictionary;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

import static org.junit.Assert.assertEquals;
import static org.junit.Assert.assertFalse;
import static org.junit.Assert.assertNotEquals;
import static org.junit.Assert.assertTrue;
import static org.junit.Assert.fail;

public class SlingProivisiongToFeatureModelConverterTest {
    private Path tempDir;
    private ArtifactManager artifactManager;
    private FeatureProvider featureProvider;

    @Before
    public void setup() throws Exception {
        String tmpDir = System.getProperty("test.prov.files.sling.tempdir");
        if (tmpDir != null) {
            tempDir = Paths.get(tmpDir);
            System.out.println("*** Using directory for generated files: " + tempDir);
        } else {
            tempDir = Files.createTempDirectory(getClass().getSimpleName());
        }
        artifactManager = ArtifactManager.getArtifactManager(
                new ArtifactManagerConfig());
        featureProvider =
            id -> {
                try {
                    File file = artifactManager.getArtifactHandler(id.toMvnUrl()).getFile();
                    try (Reader reader = new FileReader(file)) {
                        return FeatureJSONReader.read(reader, file.toURI().toURL().toString());
                    }
                } catch (IOException e) {
                    throw new UncheckedIOException(e);
                }
            };
    }

    @After
    public void tearDown() throws Exception {
    }

    @Test
    public void testSlingProvisioningToFeatureModule() throws Exception {
        File slingFolder = new File(getClass().getResource("/sling").toURI());
        System.out.println("Sling Folder: " + slingFolder);
        if(slingFolder != null) {
            List<File> files = Arrays.asList(slingFolder.listFiles());
            for (File file : files) {
                ProvisioningToFeature.convert(file, tempDir.toFile(), Collections.emptyMap());
            }
        } else {
            fail("Could not find 'sling' resource folder");
        }
    }
}
```

### Convert Sling Provisioning Model into Feature Model

1. Take the provisioning model from Sling 11
2. Copy the text files to **src/test/resources/sling** folder (create it if not already there)
3. Delete all files if sling.out exists otherwise create it
4. Run the conversion with:

```
mvn clean install  \
  -Dtest.prov.files.sling.tempdir=/Volumes/UserHD/Users/achaefa/Development/madplanet.com/apache/sling-dev/sling.git.dev/sling-org-apache-sling-feature-modelconverter/sling.out
```

### Incorporate into Sling Feature Model Starter

1. Copy the sling.out files from above into the Sling Feature Model Starter folder: sling-featuremodel-starter/src/main/features
2. Adjust ID to something like: "id": "${project.groupId}:${project.artifactId}:slingosgifeature:boot:${project.version}
3. Replace all OSGi version variables with the actual values in the bundle ids
4. Remove all **provisioning.model.name** variables
5. Make any REPOINIT section to be of type TEXT (**"repoinit:JSON|true":[** to **"repoinit:TEXT|true":[**)
6. Add this property **framework-properties** to the launchpad_launchpad.json file:
```
    "org.osgi.framework.system.packages.extra":"javax.annotation.processing,javax.crypto,javax.crypto.spec,javax.imageio,javax.imageio.metadata,javax.imageio.plugins.jpeg,javax.imageio.stream,javax.jcr,javax.jcr.lock,javax.management.modelmbean,javax.naming,javax.jcr.query,javax.jcr.nodetype,javax.jcr.observation,javax.jcr.security,javax.jcr.version,javax.lang.model.element,javax.lang.model.util,javax.lang.model.type,javax.mail,javax.management,javax.management.openmbean,javax.management.remote,javax.lang.model,javax.naming.directory,javax.naming.ldap,javax.naming.spi,javax.net,javax.net.ssl,javax.print,javax.print.attribute,javax.rmi.ssl,javax.security.auth,javax.security.auth.callback,javax.security.auth.login,javax.security.auth.x500,javax.security.auth.spi,javax.sql,javax.security.sasl,javax.swing,javax.swing.border,javax.swing.event,javax.swing.filechooser,javax.swing.tree,javax.swing.table,javax.swing.text,javax.transaction.xa,javax.tools,javax.xml.bind,javax.xml.bind.annotation,javax.xml.namespace,javax.xml.bind.annotation,javax.xml,javax.xml.datatype,javax.xml.namespace,javax.xml.parsers,javax.xml.stream,javax.xml.stream.events,javax.xml.stream.util,javax.xml.transform,javax.xml.transform.dom,javax.xml.transform.sax,javax.xml.transform.stax,javax.xml.transform.stream,javax.xml.validation,javax.xml.xpath,javax.script,org.ietf.jgss,org.xml.sax,org.xml.org.xml.sax.ext,org.xml.sax.helpers,org.xml.sax.ext,org.w3c.dom,org.w3c.dom.bootstrap,org.w3c.dom.css,org.w3c.dom.events,org.w3c.dom.html,org.w3c.dom.ls,org.w3c.dom.ranges,org.w3c.dom.traversal,org.w3c.dom.views",
```
