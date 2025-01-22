package com.regnosys.rosetta.generator.python

import com.google.inject.Inject
import org.eclipse.xtext.testing.InjectWith
import org.eclipse.xtext.testing.extensions.InjectionExtension
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.Disabled
import org.slf4j.LoggerFactory
import com.regnosys.rosetta.tests.RosettaInjectorProvider
import java.io.IOException
import java.nio.file.Paths
import java.nio.file.Files
import org.junit.jupiter.api.^extension.ExtendWith
import com.regnosys.rosetta.generator.python.PythonCodeGeneratorUtils;
import java.util.stream.Collectors
import static org.junit.jupiter.api.Assertions.*
import org.junit.jupiter.api.Test

/*
 * Test Principal
 */
@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class PythonFilesGeneratorTest {

    static val LOGGER = LoggerFactory.getLogger(PythonFilesGeneratorTest)

    @Inject PythonCodeGeneratorUtils utils

    @Disabled("Generate CDM from Rosetta Files")
    @Test
    def void generateCDMPythonFromRosetta() {
        try {
            LOGGER.info('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... start')

            // Retrieve properties
            val rosettaSourcePath = utils.getProperty('cdm.rosetta.source.path')
            // Check if properties exist
            if (rosettaSourcePath === null || rosettaSourcePath.isEmpty) {
                LOGGER.error("Property 'cdm.rosetta.source.path' does not exist or is empty")
                return
            }
            val pythonOutputPath = utils.getProperty('cdm.python.output.path')
            if (pythonOutputPath === null || pythonOutputPath.isEmpty) {
                LOGGER.error("Property 'cdm.python.output.path' does not exist or is empty")
                return
            }
    
            // Proceed with the test
            utils.generatePythonFromDSLFiles(utils.getFileList(rosettaSourcePath, 'rosetta'), pythonOutputPath)
            LOGGER.info('generateCDMPythonFromRosetta ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... processing failed with an IO Exception')
            ioE.printStackTrace()
        }
        catch (ClassCastException ccE) {
            LOGGER.error('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... processing failed with a ClassCastException')
            ccE.printStackTrace()
        }
        catch(Exception e) {
            LOGGER.error('PythonFilesGeneratorTest::generateCDMPythonFromRosetta ... processing failed with an Exception')
            e.printStackTrace()
        }
    }

//    @Disabled("generatePythonUnitTests")
    @Test
    def void generatePythonUnitTests() {
        try {
            // Retrieve properties
            val rosettaSourcePath = utils.getProperty('unittest.rosetta.source.path')
            // Check if properties exist
            if (rosettaSourcePath === null || rosettaSourcePath.isEmpty) {
                LOGGER.error("Property 'unittest.rosetta.source.path' does not exist or is empty")
                return
            }
            val pythonOutputPath = utils.getProperty('unittest.python.output.path')
            if (pythonOutputPath === null || pythonOutputPath.isEmpty) {
                LOGGER.error("Property 'unittest.python.output.path' does not exist or is empty")
                return
            }
    
            // Proceed with the test

            LOGGER.info('generatePythonUnitTests::generatePythonUnitTests ... start')
            utils.generatePythonFromDSLFiles(utils.getFileList(rosettaSourcePath, 'rosetta'), pythonOutputPath)
            LOGGER.info('generatePythonUnitTests::generatePythonUnitTests ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonUnitTestsFromRosetta ... processing failed with an IO Exception')
            LOGGER.error('\n' + ioE.toString())
            ioE.printStackTrace()
        }
        catch (ClassCastException ccE) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonUnitTestsFromRosetta ... processing failed with a ClassCastException')
            LOGGER.error('\n' + ccE.toString())
            ccE.printStackTrace()
        }
        catch(Exception e) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonUnitTestsFromRosetta ... processing failed with an Exception')
            LOGGER.error('\n' + e.toString())
            e.printStackTrace()
        }
    }

    @Test
    def void generatePythonSerializationUnitTests() {
        try {
            LOGGER.info('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... start')

            // Retrieve properties
            val rosettaSourcePath = utils.getProperty('serialization.test.rune.source.path')
            // Check if properties exist
            if (rosettaSourcePath === null || rosettaSourcePath.isEmpty) {
                LOGGER.error("Property 'unittest.rosetta.source.path' does not exist or is empty")
                return
            }
            val pythonOutputPath = utils.getProperty('serialization.test.python.output.path')
            if (pythonOutputPath === null || pythonOutputPath.isEmpty) {
                LOGGER.error("Property 'unittest.python.output.path' does not exist or is empty")
                return
            }
    
            utils.generatePythonFromDSLFiles(utils.getFileListWithRecursion(rosettaSourcePath, 'rosetta'), pythonOutputPath)

            val path = Paths.get(pythonOutputPath + '/__init__.py')
            if (!Files.exists(path)) {
                Files.createFile(path)
            }
            LOGGER.info('generatePythonSerializationUnitTests ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... processing failed with an IO Exception')
            LOGGER.error('\n' + ioE.toString())
            ioE.printStackTrace()
        }
        catch (ClassCastException ccE) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... processing failed with a ClassCastException')
            LOGGER.error('\n' + ccE.toString())
            ccE.printStackTrace()
        }
        catch(Exception e) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonSerializationUnitTests ... processing failed with an Exception')
            LOGGER.error('\n' + e.toString())
            e.printStackTrace()
        }
    }

    @Test
    def void testGeneratedSyntax() {
        try {
            LOGGER.info('PythonFilesGeneratorTest::testGeneratedSyntax ... start')
    
            // Retrieve properties
            val sourcePath = utils.getProperty('unittest.generated.syntax.source.path')
            // Check if properties exist
            if (sourcePath === null || sourcePath.isEmpty) {
                LOGGER.error("Property 'unittest.generated.syntax.source.path' does not exist or is empty")
                return
            }
            val targetPath = utils.getProperty('unittest.generated.syntax.target.path')
            if (targetPath === null || targetPath.isEmpty) {
                LOGGER.error("Property 'unittest.generated.syntax.targetpath' does not exist or is empty")
                return
            }
            val expectedPath = utils.getProperty('unittest.generated.syntax.expected.path')
            if (expectedPath === null || expectedPath.isEmpty) {
                LOGGER.error("Property 'unittest.generated.syntax.expected.path' does not exist or is empty")
                return
            }
    
            // Generate Python from DSL files
            utils.generatePythonFromDSLFiles(utils.getFileListWithRecursion(sourcePath, 'rosetta'), targetPath)
            
            // Verify generated code against expected code
            var generatedFiles = utils.getFileListWithRecursion(targetPath, 'py');
    
            // TODO: keep testing if one file fails
            for (generatedFile : generatedFiles) {
                val fileName = generatedFile.getFileName.toString
                if (fileName != "__init__.py" && fileName != "version.py") {
	                // Calculate the relative path from the targetPath
	                val expectedFilePathString = generatedFile.toString.replace(targetPath, expectedPath)
	                
	                val expectedFilePath = Paths.get(expectedFilePathString)
	            
	                if (Files.exists(expectedFilePath)) {
	                    val expectedCode = Files.readString(expectedFilePath)
	                    val generatedCode = Files.readString(generatedFile)
	    
	                    // Assert that the expected code matches the generated code
	                    assertTrue(generatedCode.contains(expectedCode), 
	                        "Mismatch in generated code for file: " + generatedFile.toString + 
	                        "\nExpected:\n" + expectedCode + 
	                        "\nGenerated:\n" + generatedCode)
	                } else {
	                    fail("Expected file does not exist ... generated file: " + generatedFile.toString + " expected path: " + expectedFilePath.toString)
	                }
                }
            } 
            LOGGER.info('generatePythonCodeGeneratorUnitTests ... done')
        } 
        catch (IOException ioE) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonCodeGeneratorUnitTests ... processing failed with an IO Exception')
            LOGGER.error('\n' + ioE.getMessage())
        }
        catch (ClassCastException ccE) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonCodeGeneratorUnitTests ... processing failed with a ClassCastException')
            LOGGER.error('\n' + ccE.getMessage())
        }
        catch(Exception e) {
            LOGGER.error('PythonFilesGeneratorTest::generatePythonCodeGeneratorUnitTests ... processing failed with an Exception')
            LOGGER.error('\n' + e.getMessage())
        }
    }    
}