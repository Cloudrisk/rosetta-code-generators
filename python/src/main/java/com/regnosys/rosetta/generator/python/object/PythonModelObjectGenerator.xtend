package com.regnosys.rosetta.generator.python.object

import com.google.inject.Inject
import com.regnosys.rosetta.generator.python.expressions.PythonExpressionGenerator
import com.regnosys.rosetta.generator.python.object.PythonMetaDataProcessor;

import com.regnosys.rosetta.generator.python.util.PythonModelGeneratorUtil
import com.regnosys.rosetta.generator.python.util.Util
import com.regnosys.rosetta.rosetta.RosettaMetaType
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.types.RObjectFactory
import java.util.HashMap
import java.util.Map
import java.util.List

/*
 * Generate Python from Rune Types
 */
class PythonModelObjectGenerator {

    @Inject extension RObjectFactory

	@Inject PythonMetaDataProcessor pythonMetaDataProcessor;
    @Inject PythonExpressionGenerator expressionGenerator;
    @Inject PythonAttributeProcessor pythonAttributeProcessor;
    @Inject PythonChoiceAliasProcessor pythonChoiceAliasProcessor;

	List<String> importsFound;
	
    /**
     * Generate Python from the collection of Rosetta classes (of type Data)
     * 
     * Inputs:
     * 
     * rosettaClasses - the collection of Rosetta Classes for this model
     * metaDataKeys - a hash map of each "key" type found in meta data found in the classes and attributes of the class
     */
    def Map<String, ? extends CharSequence> generate(Iterable<Data> rosettaClasses, Iterable<RosettaMetaType> metaTypes, String version) {

		var metaDataKeys = pythonMetaDataProcessor.getMetaDataKeys(rosettaClasses.toList);
		
        for (Map.Entry<String, String> entry : metaDataKeys.entrySet()) {
            val key = entry.getKey();
            val value = entry.getValue();
            System.out.println("----- PythonModelObjectGenerator::generate ... metadata source ... Key: " + key + ", Value: " + value);
        }
        
        val result = new HashMap

        for (Data rosettaClass : rosettaClasses) {
            val model = rosettaClass.eContainer as RosettaModel
            val nameSpace = Util::getNamespace(model)
            val pythonBody = generateBody(rosettaClass, metaDataKeys, nameSpace, version).toString.replace('\t', '  ')
            result.put(
                PythonModelGeneratorUtil::toPyFileName(model.name, rosettaClass.getName()),
                PythonModelGeneratorUtil::createImports(rosettaClass.getName()) + pythonBody
            )
        }
        result;
    }

    private def generateBody(Data rosettaClass, Map<String, String> metaDataKeys, String nameSpace, String version) {
    	// generate the body of the class
    	// ... get the imports from the attributes
    	// ... generate the class 
    	// ... create the class string:  
    	// ...... an import that refers to the super class
    	// ...... the class definition
    	// ...... all the imports
        var superType = rosettaClass.superType
        if (superType !== null && superType.name === null) {
            throw new Exception("The class superType exists but its name is null for " + rosettaClass.name)
        }
        importsFound = pythonAttributeProcessor.getImportsFromAttributes(rosettaClass)
        expressionGenerator.importsFound = importsFound;
        val classDefinition = generateClass(rosettaClass, metaDataKeys)

        return '''
            «IF superType!==null»from «(superType.eContainer as RosettaModel).name».«superType.name» import «superType.name»«ENDIF»
            
            «classDefinition»
            
            import «nameSpace» 
            «FOR importLine : importsFound SEPARATOR "\n"»«importLine»«ENDFOR»
        '''
    }

    private def generateClass(Data rosettaClass,  Map<String, String> metaDataKeys) {
        // generate Python from rosettaClass
        // ... first generate choice aliases
        // ... then add the class definition
        // ... then add all attributes
        // ... then add any conditions
        val rosettaDataType = rosettaClass.buildRDataType
        val choiceAliasesAsAString = pythonChoiceAliasProcessor.generateChoiceAliasesAsString(rosettaDataType);
        return '''
            class «rosettaClass.name»«IF rosettaClass.superType === null»«ENDIF»«IF rosettaClass.superType !== null»(«rosettaClass.superType.name»):«ELSE»(BaseDataClass):«ENDIF»
                «choiceAliasesAsAString»
                «IF rosettaClass.definition !== null»
                    """
                    «rosettaClass.definition»
                    """
                «ENDIF»
                «pythonAttributeProcessor.generateAllAttributes(rosettaClass, metaDataKeys)»
                «expressionGenerator.generateConditions(rosettaClass)»
        '''
    }
}
