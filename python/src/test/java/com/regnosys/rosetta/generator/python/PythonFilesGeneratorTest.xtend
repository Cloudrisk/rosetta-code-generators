package com.regnosys.rosetta.generator.python

import com.google.inject.Inject
import com.google.inject.Provider
import java.io.File
import java.io.FileReader
import java.io.IOException
import java.lang.CharSequence
import java.nio.charset.StandardCharsets
import java.nio.file.Files
import java.nio.file.FileVisitOption
import java.nio.file.Path
import java.nio.file.Paths
import java.util.ArrayList
import java.util.Collection
import java.util.Map
import java.util.Properties
import java.util.stream.Collectors
import org.apache.commons.io.FileUtils
import org.apache.maven.model.io.xpp3.MavenXpp3Reader
import org.eclipse.emf.common.util.URI
import org.eclipse.xtext.resource.XtextResourceSet
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.eclipse.xtext.testing.util.ParseHelper
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.^extension.ExtendWith
import org.junit.jupiter.api.Disabled
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import com.regnosys.rosetta.tests.util.ModelHelper
import org.slf4j.LoggerFactory

/*
 * Test Principal
 */
@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class PythonFilesGeneratorTest {

    static val LOGGER = LoggerFactory.getLogger(PythonFilesGeneratorTest);

    @Inject PythonCodeGenerator generator

    @Inject extension ParseHelper<RosettaModel>
    
    @Inject Provider<XtextResourceSet> resourceSetProvider;

    def private Properties getProperties () throws Exception {
        var reader     = new MavenXpp3Reader();
        var model      = reader.read(new FileReader("pom.xml"))
        return model.getProperties();
    }
    def private String getProperty (String property) throws Exception {
        var reader     = new MavenXpp3Reader();
        var model      = reader.read(new FileReader("pom.xml"))
        return model.getProperties().getProperty(property);
    }
    def private void cleanSrcFolder(String folderPath) {
        val folder = new File(folderPath + File.separator + "src")
        if (folder.exists() && folder.isDirectory()) {
            try {
                FileUtils.cleanDirectory(folder)
            } catch (IOException e) {
                LOGGER.error ("Failed to delete folder content: " + e.message)
            }
        } else {
            LOGGER.error (folderPath + " does not exist or is not a directory")
        }
    }
    
    def private writeFiles(String pythonTgtPath, Map<String, ? extends CharSequence> generatedFiles){
        // Assuming 'generatedFiles' is a HashMap<String, CharSequence>
        for (entry : generatedFiles.entrySet) {
            // Split the key into its components and replace '.' with the file separator
            val filePath     = entry.key
            val fileContents = entry.value.toString
            val outputPath  = Path.of(pythonTgtPath + File.separator + filePath)
            Files.createDirectories(outputPath.parent);
            Files.write(outputPath, fileContents.getBytes(StandardCharsets.UTF_8))
        }
        LOGGER.info("Write Files ... wrote: {}", generatedFiles.size ())
        
    }
    def generatePythonFromRosettaModel (RosettaModel m, org.eclipse.emf.ecore.resource.ResourceSet resourceSet) {
        val version = m.version
        val result  = newHashMap
        result.putAll(generator.beforeAllGenerate(resourceSet, #{m}, version))
        result.putAll(generator.beforeGenerate(m.eResource, m, version))
        result.putAll(generator.generate(m.eResource, m, version))
        result.putAll(generator.afterGenerate(m.eResource, m, version))
        result.putAll(generator.afterAllGenerate(resourceSet, #{m}, version))
        result
    }
    def getListOfDSLFiles(String dslSourceDir, String suffix) {
        LOGGER.info("PythonFilesGeneratorTest::getListOfDSLFiles ... looking for files with suffix {} in {}", suffix, dslSourceDir)
        
        if (dslSourceDir === null) {
            throw new Exception('Initialization failure: source dsl path not specified')
        }

        if (suffix === null) {
            throw new Exception('Initialization failure: extension not specified')
        }
        
        val sourcePath = Paths.get(dslSourceDir)
        if (!Files.exists(sourcePath)) {
            throw new Exception("Unable to generate Python from non-existent source directory: " + dslSourceDir)
        }
        
        val result = new ArrayList<Path>()
        val directory = new File(dslSourceDir)
        if (directory.isDirectory) {
            directory.listFiles.filter [ file |
                file.isFile && file.name.endsWith(suffix)
            ].forEach [ file |
                result.add(file.toPath)
            ]
        }
        LOGGER.info("PythonFilesGeneratorTest::getListOfDSLFiles ... found {} dsl files in {}", result.size.toString, dslSourceDir)
        return result    
    }    	
    def getListOfDSLFilesWithRecursion(String dslSourceDir, String suffix) {
        LOGGER.info("PythonFilesGeneratorTest::getListOfDSLFilesWithRecursion ... looking for files with suffix {} in {}", suffix, dslSourceDir)
        
        if (dslSourceDir === null) {
            throw new Exception('Initialization failure: source dsl path not specified')
        }

        if (suffix === null) {
            throw new Exception('Initialization failure: extension not specified')
        }
        
        val sourcePath = Paths.get(dslSourceDir)
        if (!Files.exists(sourcePath)) {
            throw new Exception("Unable to generate Python from non-existent source directory: " + dslSourceDir)
        }
        
        val result = new ArrayList<Path>()
        
        try {
            val stream = Files.walk(sourcePath, FileVisitOption.FOLLOW_LINKS)
            try {
                result.addAll(
                    stream
                        .filter [ path | 
                            Files.isRegularFile(path) && path.toString.endsWith(suffix)
                        ]
                        .collect(Collectors.toList)
                )
            } finally {
                stream.close()
            }
        } catch (IOException e) {
            e.printStackTrace
        }
        LOGGER.info("PythonFilesGeneratorTest::getListOfDSLFilesWithRecursion ... found {} dsl files in {}", result.size.toString, dslSourceDir)
        return result    
    }
    
    def void generatePythonFromDSLFiles (ArrayList<Path> dslFilePathList, String outputPathPropertyName){
        // loop through each of the rosetta dsl definitions
        //  - produce new python from the dsl definitions 
        //  - delete any existing directory and create a new one
        val outputPath = getProperties().getProperty (outputPathPropertyName)
        if (outputPath === null) {
            throw new Exception('Initialization failure: Python target not specified')
        }
        LOGGER.info("PythonFilesGeneratorTest::generatePythonFromDSLFiles ... generating Python from {} rosetta files", dslFilePathList.length.toString ())                  
        // Create a resource set and add the common Rosetta models to it
        LOGGER.info("PythonFilesGeneratorTest::generatePythonFromDSLFiles ... creating resource set and adding common Rosetta models")
        val resourceSet = resourceSetProvider.get 
        parse(ModelHelper.commonTestTypes, resourceSet)
        resourceSet.getResource(URI.createURI('classpath:/model/basictypes.rosetta'), true)
        resourceSet.getResource(URI.createURI('classpath:/model/annotations.rosetta'), true)

        val resources      = dslFilePathList
            .map[resourceSet.getResource(URI.createURI(it.toString()), true)]
            .toList
        LOGGER.info ("PythonFilesGeneratorTest::generatePythonFromDSLFiles ... converted to resources")                  
        val rosettaModels  = resources
            .flatMap[contents.filter(RosettaModel)]
            .toList as Collection<RosettaModel>
        LOGGER.info ("PythonFilesGeneratorTest::generatePythonFromDSLFiles ... created {} rosetta models", rosettaModels.length.toString ())                  
        val generatedFiles = newHashMap
        for (model : rosettaModels) {
            LOGGER.info ("PythonFilesGeneratorTest::generatePythonFromDSLFiles ... processing model: {}", model.name)
            val python = generatePythonFromRosettaModel (model, resourceSet);
            generatedFiles.putAll (python)
        }
        cleanSrcFolder(outputPath)
        writeFiles(outputPath, generatedFiles)
        LOGGER.info ("PythonFilesGeneratorTest::generatePythonFromDSLFiles ... done")
    } 
    @Disabled("Generate CDM from Rosetta Files")
    @Test
    def void generateCDMPythonFromRosetta () {
        // the process: get directory information from the POM, create Python from Rosetta definitions and write out results
        
        try {
            LOGGER.info('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... start')
            generatePythonFromDSLFiles (getListOfDSLFiles(getProperty('cdm.rosetta.source.path'), 'rosetta'), 
            							'cdm.python.output.path')
            LOGGER.info('generateCDMPythonFromRosetta ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error ('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... processing failed with an IO Exception')
            ioE.printStackTrace ()
        }
        catch (ClassCastException ccE) {
            LOGGER.error ('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... processing failed with a ClassCastException')
            ccE.printStackTrace ()
        }
        catch(Exception e) {
            LOGGER.error ('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... processing failed with an Exception')
            e.printStackTrace ()
        }
    }
//    @Disabled("Generate Python Unit Tests from Rosetta Files")
    @Test
    def void generatePythonUnitTests () {
        // the process: get directory information from the POM, create Python from Rosetta definitions and write out results
        try {
            LOGGER.info('generatePythonUnitTests::generatePythonUnitTests ... start')
            generatePythonFromDSLFiles (getListOfDSLFiles(getProperty('unit.test.rosetta.source.path'), 'rosetta'),
            							'unit.test.python.output.path')
            LOGGER.info('generatePythonUnitTests::generatePythonUnitTests ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error ('PythonFilesGeneratorTest::generatePythonUnitTestsFromRosetta ... processing failed with an IO Exception')
            LOGGER.error ('\n' + ioE.toString ())
            ioE.printStackTrace ()
        }
        catch (ClassCastException ccE) {
            LOGGER.error ('PythonFilesGeneratorTest::generatePythonUnitTestsFromRosetta ... processing failed with a ClassCastException')
            LOGGER.error ('\n' + ccE.toString ())
            ccE.printStackTrace ()
        }
        catch(Exception e) {
            LOGGER.error ('PythonFilesGeneratorTest::generatePythonUnitTestsFromRosetta ... processing failed with an Exception')
            LOGGER.error ('\n' + e.toString ())
            e.printStackTrace ()
        }
    }
//    @Disabled("Generate Python Serialization Unit Tests from Rosetta Files")
    @Test
    def void generatePythonSerializationUnitTests () {
        // the process: get directory information from the POM, create Python from Rosetta definitions and write out results
        try {
            LOGGER.info('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... start')
            generatePythonFromDSLFiles (getListOfDSLFilesWithRecursion(getProperty('serialization.test.rosetta.source.path'), 'rosetta'), 
                                        'serialization.test.python.output.path')
            val path = Paths.get(getProperty('serialization.test.python.output.path') + '/__init__.py')
            // Create the file if it does not exist
            if (!Files.exists(path)) {
                Files.createFile(path)
            }
            LOGGER.info('generatePythonSerializationUnitTests ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error ('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... processing failed with an IO Exception')
            LOGGER.error ('\n' + ioE.toString ())
            ioE.printStackTrace ()
        }
        catch (ClassCastException ccE) {
            LOGGER.error ('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... processing failed with a ClassCastException')
            LOGGER.error ('\n' + ccE.toString ())
            ccE.printStackTrace ()
        }
        catch(Exception e) {
            LOGGER.error ('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... processing failed with an Exception')
            LOGGER.error ('\n' + e.toString ())
            e.printStackTrace ()
        }
    }
}