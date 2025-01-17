package com.regnosys.rosetta.generator.python.object

import com.google.inject.Inject
import com.regnosys.rosetta.generator.python.expressions.PythonExpressionGenerator
import com.regnosys.rosetta.generator.python.util.PythonModelGeneratorUtil
import com.regnosys.rosetta.generator.python.util.PythonTranslator
import com.regnosys.rosetta.generator.python.util.Util
import com.regnosys.rosetta.rosetta.RosettaMetaType
import com.regnosys.rosetta.rosetta.RosettaModel
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.types.RAliasType
import com.regnosys.rosetta.types.RAttribute
import com.regnosys.rosetta.types.RChoiceType
import com.regnosys.rosetta.types.RDataType
import com.regnosys.rosetta.types.RMetaAttribute
import com.regnosys.rosetta.types.RObjectFactory
import com.regnosys.rosetta.types.builtin.RNumberType
import com.regnosys.rosetta.types.builtin.RStringType
import com.regnosys.rosetta.utils.DeepFeatureCallUtil
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import org.eclipse.xtend2.lib.StringConcatenation
import com.regnosys.rosetta.types.TypeSystem

/*
 * Generate Python from Rune Types
 */
class PythonModelObjectGenerator {

    @Inject extension RObjectFactory
    @Inject extension DeepFeatureCallUtil
    @Inject extension PythonModelObjectBoilerPlate
    @Inject 
    TypeSystem typeSystem;
    
    @Inject PythonExpressionGenerator expressionGenerator;

    var List<String> importsFound = newArrayList

    def Map<String, ? extends CharSequence> generate(Iterable<Data> rosettaClasses,
    		Iterable<RosettaMetaType> metaTypes,
    		String version) {
        val result = new HashMap

        for (Data type : rosettaClasses) {
            val model = type.eContainer as RosettaModel
            val nameSpace = Util::getNamespace(model)
            val pythonBody = type.generateBody(nameSpace, version).replaceTabsWithSpaces
            result.put(
                PythonModelGeneratorUtil::toPyFileName(model.name, type.name),
                PythonModelGeneratorUtil::createImports(type.name) + pythonBody
            )
        }
        result;
    }

    def String toPythonType(Data c, RAttribute ra) throws Exception {
        var basicType = PythonTranslator::toPythonType(ra);
        if (basicType === null) {
            throw new Exception("Attribute type is null for " + ra.name + " for class " + c.name)
        }

        var metaAnnotations = ra.RMetaAnnotatedType
        if (metaAnnotations !== null && metaAnnotations.hasMeta) {
            var helperClass = "Attribute";
            var hasRef = false;
            var hasAddress = false;
            var hasMeta = false;
            for (RMetaAttribute meta : metaAnnotations.getMetaAttributes) {
                val mname = meta.getName();
                if (mname == "reference") {
                    hasRef = true;
                } else if (mname == "address") {
                    hasAddress = true;
                } else if (mname == "key" || mname == "id" || mname == "scheme" || mname == "location") {
                    hasMeta = true;
                } else {
                    helperClass += "---" + mname + "---";
                }
            }
            if (hasMeta) {
                helperClass += "WithMeta";
            }
            if (hasAddress) {
                helperClass += "WithAddress";
            }
            if (hasRef) {
                helperClass += "WithReference";
            }
            if (hasMeta || hasAddress) {
                helperClass += "[" + basicType + "]";
            }
            basicType = helperClass + " | " + basicType;
        }
        return basicType
    }

    def Map<String, ArrayList<String>> generateChoiceAliases(RDataType choiceType) {
        if (!choiceType.isEligibleForDeepFeatureCall()) {
            return null
        }
        val deepReferenceMap = new HashMap<String, ArrayList<String>>()
        val deepFeatures = choiceType.findDeepFeatures
        choiceType.getAllAttributes.toMap([it], [
            val attrType = it.getRMetaAnnotatedType.getRType
            deepFeatures.toMap([it], [
                var t = attrType
                if (t instanceof RChoiceType) {
                    t = t.asRDataType
                }
                if (t instanceof RDataType) {
                    if (t.findDeepFeatureMap.containsKey(it.name)) {
                        // look for element in hashmap and create one if none found
                        var deepReference = deepReferenceMap.get(t.name)
                        if (deepReference === null) {
                            deepReference = new ArrayList<String>
                        }
                        // add the deep reference to the array and update the hashmap
                        deepReference.add(it.name)
                        deepReferenceMap.put(t.name, deepReference)
                        return true
                    }
                }
                return false
            ])
        ])
        val choiceAlias = deepFeatures.toMap(
            [deepFeature|'"' + deepFeature.name + '"'], // Key extractor: use deepFeature name as the key
            [ deepFeature | // Value extractor: create and populate the list of aliases
                val aliasList = new ArrayList<String>()

                // Iterate over all non-overridden attributes
                choiceType.getAllAttributes.forEach [ attribute |
                    val attrType = attribute.getRMetaAnnotatedType.getRType
                    var t = attrType

                    // Convert RChoiceType to RDataType if applicable
                    if (t instanceof RChoiceType) {
                        t = t.asRDataType

                    }
                    // Check if t is an instance of RDataType
                    if (t instanceof RDataType) {
                        // Add the new alias to the list.  Add a deep reference if necessary
                        val deepReference = deepReferenceMap.get(t.name)
                        val resolutionMethod = (deepReference !== null &&
                                deepReference.contains(
                                    deepFeature.name)) ? "rosetta_resolve_deep_attr" : "rosetta_resolve_attr"
                        aliasList.add('("' + attribute.name + '", ' + resolutionMethod + ')')
                    }
                ]
                // Return the populated list for this deepFeature
                aliasList
            ]
        )
        return (choiceAlias.isEmpty()) ? null : choiceAlias
    }

    def boolean checkBasicType(RAttribute ra) {
        val rosettaType = (ra !== null) ? ra.getRMetaAnnotatedType.getRType : null
        return (rosettaType !== null && PythonTranslator::checkPythonType(rosettaType.toString()))
    }

    /**
     * Generate the body of the class
     */
    private def generateBody(Data rosettaClass, String nameSpace, String version) {
        var superType = rosettaClass.superType
        if (superType !== null && superType.name === null) {
            throw new Exception("SuperType is null for " + rosettaClass.name)
        }
        importsFound = getImportsFromAttributes(rosettaClass)
        expressionGenerator.importsFound = this.importsFound;
        val classDefinition = generateClass(rosettaClass)

        return '''
            «IF superType!==null»from «(superType.eContainer as RosettaModel).name».«superType.name» import «superType.name»«ENDIF»
            
            «classDefinition»
            
            import «nameSpace» 
            «FOR importLine : importsFound SEPARATOR "\n"»«importLine»«ENDFOR»
        '''
    }

    private def getImportsFromAttributes(Data rosettaClass) {
        val rdt = rosettaClass.buildRDataType
        // get all non-Meta attributes
        val fa = rdt.getOwnAttributes.filter [
            (it.name !== "reference") && (it.name !== "meta") && (it.name !== "scheme")
        ].filter[!checkBasicType(it)]
        val imports = newArrayList
        for (attribute : fa) {
            var rt = attribute.getRMetaAnnotatedType.getRType
            if (rt === null) {
                throw new Exception("Attribute type is null for " + attribute.name + " for class " + rosettaClass.name)
            }
            if (!PythonTranslator::isSupportedBasicRosettaType(rt.getName())) { // need imports for derived types
                imports.add('''import «rt.getQualifiedName»''')
            }
        }
        return imports.toSet.toList
    }

    private def generateChoiceMapStrings(Map<String, ArrayList<String>> choiceAliases) {
        var result = (choiceAliases === null) ? '' : choiceAliases.entrySet.map[e|e.key + ":" + e.value.toString].
                join(",")
        return result
    }

    private def generateClass(Data rosettaClass) {
        val t = rosettaClass.buildRDataType
        val choiceAliases = generateChoiceAliases(t)
        return '''
            class «rosettaClass.name»«IF rosettaClass.superType === null»«ENDIF»«IF rosettaClass.superType !== null»(«rosettaClass.superType.name»):«ELSE»(BaseDataClass):«ENDIF»
                «IF choiceAliases !== null»
                    _CHOICE_ALIAS_MAP ={«generateChoiceMapStrings(choiceAliases)»}
                «ENDIF»
                «IF rosettaClass.definition !== null»
                    """
                    «rosettaClass.definition»
                    """
                «ENDIF»
                «generateAllAttributes(rosettaClass)»
                «expressionGenerator.generateConditions(rosettaClass)»
        '''
    }

    private def CharSequence generateAllAttributes(Data rosettaClass) {
        // generate all the attributes for this class
        // TODO: add aliases here
        val allAttributes = rosettaClass.buildRDataType.getOwnAttributes
        if (allAttributes.size() === 0 && rosettaClass.conditions.size() === 0) {
        	return "pass";
        }
      	var _builder = new StringConcatenation();
        var firstElement = true;
        for (RAttribute attribute : allAttributes) {
        	if (firstElement) {
        		firstElement = false;
        	} else {
	            _builder.appendImmediate("", "");
	        }
          	_builder.append(generateAttribute(rosettaClass, attribute));
        }
		return _builder;      	
    }

    private def generateAttribute(Data rosettaClass, RAttribute ra) {
		/*
		 * translate the attribute to its representation in Python
		 */
        // TODO: use builder and remove block quotes
        var attString    = ""
        val attrRMAT     = ra.getRMetaAnnotatedType();
        var attrRT       = attrRMAT.getRType(); 
		// TODO: depending on how meta is handled the function toPythonType could be removed or made to use the stripped alias
        var attrTypeName = toPythonType(rosettaClass, ra);
        // strip out the alias if there is one.  
        // if so, align the attribute type name to the to the underlying type
        if (attrRT instanceof RAliasType) {
			attrRT = typeSystem.stripFromTypeAliases(attrRT);
			// because this is an alias, reset the attribute type name
			attrTypeName = PythonTranslator::toPythonType(attrRT);
        }
        var attrName = PythonTranslator.mangleName(ra.name) // mangle the attribute name if it is a python keyword
        val attrDesc = (ra.definition === null) ? '' : ra.definition.replaceAll('\\s+', ' ')
		val attrProp = new HashMap<String, String>();
		// get parameters if there are any (applies to string and number)
		if (attrRT instanceof RStringType) {
			// TODO: there seems to be a default for strings to have min_length = 0 
			attrRT.getPattern().ifPresent [ value | attrProp.put ("pattern", '"' + '^r' + value.toString() + '*$"')];
        	attrRT.getInterval().getMin().ifPresent [value | 
        		if (value > 0) {
	        		attrProp.put ("min_length", value.toString())
        		}
        		]
        	attrRT.getInterval().getMax().ifPresent [value | attrProp.put ("max_length", value.toString())]
		} else if (attrRT instanceof RNumberType) {
			// TODO: determine whether there's an issue with letting integers pass through this mechanism
			if (!attrRT.isInteger()) {
				attrRT.getDigits().ifPresent [ value | attrProp.put ("max_digits", value.toString())];
				attrRT.getFractionalDigits().ifPresent [ value | attrProp.put ("decimal_places", value.toString())];
	        	attrRT.getInterval().getMin().ifPresent [value | attrProp.put ("ge", value.toPlainString())]
	        	attrRT.getInterval().getMax().ifPresent [value | attrProp.put ("le", value.toPlainString())]
			} else {
				attrTypeName = 'int';
			}
        }
		// process the cardinality of the attribute 
		// ... it is a list if it is multi or the upper bound is greater than 1 
		// ... it is optional if it is equal to 0
		// otherwise it is required
        var lowerCardinality = ra.cardinality.getMin();
        var upperCardinality = (!ra.cardinality.isMulti()) ? ra.cardinality.getMax.get () : -1 // set the default to -1 if unbounded
        var upperCardString  = (ra.cardinality.isMulti()) ? "None" : ra.cardinality.getMax.get.toString()
        var fieldDefault     = (upperCardinality == 1 && lowerCardinality == 1) ? '...' : 'None' // mandatory field -> cardinality (1..1)
		if (ra.cardinality.isMulti || upperCardinality > 1) { 
        	// is a list
            attString += "List[" + attrTypeName + "]"
            fieldDefault = '[]'
        } else if (lowerCardinality == 0) { 
        	// is optional
            attString += "Optional[" + attrTypeName + "]"
        } else {
            // is required
            attString += attrTypeName
        }
        var needCardCheck = !(
        	(lowerCardinality == 0 && upperCardinality == 1) ||
            (lowerCardinality == 1 && upperCardinality == 1) ||
            (lowerCardinality == 0 && ra.cardinality.isMulti))
		var attrPropAsString = "";
		for (attrPropEntry : attrProp.entrySet()) {
			attrPropAsString += (", " + attrPropEntry.key + "=" + attrPropEntry.value); 
		}  
        if (attrRMAT.hasMeta()) {
        	println ('------ generateAttribute ... has Meta ... attrType.getMeta: ' + attrRMAT.getMetaAttributes())
        }
//		TODO: meta
        '''
            «attrName»: «attString» = Field(«fieldDefault», description="«attrDesc»"«attrPropAsString»)
            «IF ra.definition !== null»
                """
                «ra.definition»
                """
            «ENDIF»
            «IF needCardCheck»
                @rosetta_condition
                def cardinality_«attrName»(self):
                    return check_cardinality(self.«attrName», «lowerCardinality», «upperCardString»)
                
            «ENDIF»
        '''
    }

    def String definition(Data element) {
        element.definition
    }
}
