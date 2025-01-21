package com.regnosys.rosetta.generator.python.object

import com.google.inject.Inject
import com.regnosys.rosetta.generator.python.util.PythonTranslator
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.types.RAliasType
import com.regnosys.rosetta.types.RAttribute
import com.regnosys.rosetta.types.RObjectFactory
import com.regnosys.rosetta.types.TypeSystem
import com.regnosys.rosetta.types.builtin.RNumberType
import com.regnosys.rosetta.types.builtin.RStringType
import java.util.ArrayList
import java.util.HashMap
import org.eclipse.xtend2.lib.StringConcatenation
import java.util.Map

/*
 * Generate Python from Rune Attributes
 */
class PythonAttributeProcessor {

    @Inject extension RObjectFactory
    @Inject TypeSystem typeSystem;

    def CharSequence generateAllAttributes(Data rosettaClass, Map<String, String> metaDataKeys) {
        // generate Python for all the attributes in this class
        val allAttributes = rosettaClass.buildRDataType.getOwnAttributes
		// it is an empty class if there are no attribute and no conditions
        if (allAttributes.size() === 0 && rosettaClass.conditions.size() === 0) {
            return "pass";
        }
        // add each attribute
        var _builder = new StringConcatenation();
        var firstElement = true;
        for (RAttribute ra : allAttributes) {
            if (firstElement) {
                firstElement = false;
            } else {
                _builder.appendImmediate("", "");
            }
            _builder.append(generateAttribute(rosettaClass, ra, metaDataKeys));
        }
        return _builder;
    }

    def generateAttribute(Data rosettaClass, RAttribute ra, Map<String, String> metaDataKeys) {
        /*
         * translate the attribute to its representation in Python
         */
        // TODO: use builder and remove block quotes
        val attrRMAT   = ra.getRMetaAnnotatedType();
        var attrRType  = attrRMAT.getRType();
        // TODO: confirm refactoring of type properly handles enums
        var attrTypeName = null as String;
        // strip out the alias if there is one and align the attribute type name to the to the underlying type
        if (attrRType instanceof RAliasType) {
            attrRType = typeSystem.stripFromTypeAliases(attrRType);
            attrTypeName = PythonTranslator::toPythonType(attrRType); // alias must be of underlying type number or string
        } else {
            attrTypeName = PythonTranslator::toPythonType(ra);
        }
        // an empty attribute name is cause for an exception
        if (attrTypeName === null) {
            throw new Exception("Attribute type is null for " + ra.name + " in class " + rosettaClass.name);
        }
        var attrName = PythonTranslator.mangleName(ra.name) // mangle the attribute name if it is a Python keyword
        val attrDesc = (ra.definition === null) ? '' : ra.definition.replaceAll('\\s+', ' ')
        // get the properties / parameters if there are any (applies to string and number)
        val attrProp = new HashMap<String, String>();
        if (attrRType instanceof RStringType) {
            // TODO: there seems to be a default for strings to have min_length = 0 
            attrRType.getPattern().ifPresent[value|attrProp.put("pattern", '"' + '^r' + value.toString() + '*$"')];
            attrRType.getInterval().getMin().ifPresent [ value |
                if (value > 0) { 
                    attrProp.put("min_length", value.toString())
                }
            ]
            attrRType.getInterval().getMax().ifPresent[value|attrProp.put("max_length", value.toString())]
        } else if (attrRType instanceof RNumberType) {
            // TODO: determine whether there's an issue with letting integers pass through this mechanism
            if (!attrRType.isInteger()) {
                attrRType.getDigits().ifPresent[value|attrProp.put("max_digits", value.toString())];
                attrRType.getFractionalDigits().ifPresent[value|attrProp.put("decimal_places", value.toString())];
                attrRType.getInterval().getMin().ifPresent[value|attrProp.put("ge", value.toPlainString())]
                attrRType.getInterval().getMax().ifPresent[value|attrProp.put("le", value.toPlainString())]
            } else { 
                attrTypeName = 'int';
            }
        }
        var attrPropAsString = "";
        for (attrPropEntry : attrProp.entrySet()) {
            attrPropAsString += (", " + attrPropEntry.key + "=" + attrPropEntry.value);
        }
        // process the cardinality of the attribute 
        // ... it is a list if it is multi or the upper bound is greater than 1 
        // ... it is optional if it is equal to 0
        // otherwise it is required
        var lowerCardinality = ra.cardinality.getMin();
        var upperCardinality = (!ra.cardinality.isMulti()) ? ra.cardinality.getMax.get() : -1 // set the default to -1 if unbounded
        var upperCardString  = (ra.cardinality.isMulti()) ? "None" : ra.cardinality.getMax.get.toString()
        var fieldDefault = (upperCardinality == 1 && lowerCardinality == 1) ? '...' : 'None' // mandatory field -> cardinality (1..1)
		var cardinalityPrefix = "";
		var cardinalitySuffix = "";
		
        if (ra.cardinality.isMulti || upperCardinality > 1) {
            // is a list
        	cardinalityPrefix = "list[";
        	cardinalitySuffix = "]"
            fieldDefault = '[]'
        } else if (lowerCardinality == 0) {
            // is optional
        	cardinalityPrefix = "Optional[";
        	cardinalitySuffix = "]"
        } 
		// process meta data
        var metaPrefix = "";
        var metaSuffix = "";
		val validators = new ArrayList<String>()
		val attributeIsMetaKey = metaDataKeys.containsKey (attrTypeName);
		if (attributeIsMetaKey) {
			validators.add ('@key');
		}
		// check whether the attribute has meta 
        if (attrRMAT.hasMeta()) {
            for (ma : attrRMAT.getMetaAttributes()) {
                // TODO: handle all meta types
                if (ma.getName().equals("reference")) {
                    validators.add("@ref");
                } else if (ma.getName().equals("key")) {
                    validators.add("@key");
                    println ('---- meta ... key');
                } else if (ma.getName().equals("id")) {
                    validators.add("@key");
                    println ('---- meta ... id');
                } else if (ma.getName().equals("scheme")) {
                    validators.add("@scheme");
                } else {
                	println ('---- unprocessed meta ... name: ' + ma.getName())
                }
            }
		}
        if (!validators.isEmpty()) {
        	if (!attributeIsMetaKey)  {
        		attrTypeName = PythonTranslator.getAttributeTypeWithMeta (attrTypeName);
        	}
			var isFirst = true;
            metaPrefix = "Annotated[";
            metaSuffix = ", " + attrTypeName + ".serializer(), " + attrTypeName + ".validator(";
            for (validator : validators) {
            	if (isFirst) {
            		isFirst = false;
            	} else {
            		metaSuffix += ","
            	}
            	metaSuffix += "'" + validator + "'";
            }
            metaSuffix += ")]"
        }
        var definition = ra.definition;
        var needCardCheck = !(
            (lowerCardinality == 0 && upperCardinality == 1) || (lowerCardinality == 1 && upperCardinality == 1) ||
            (lowerCardinality == 0 && ra.cardinality.isMulti))
        '''
            «attrName»: «cardinalityPrefix»«metaPrefix»«attrTypeName»«metaSuffix»«cardinalitySuffix» = Field(«fieldDefault», description="«attrDesc»"«attrPropAsString»)
            «IF definition !== null»
                """
                «definition»
                """
            «ENDIF»
            «IF needCardCheck»
                @rosetta_condition
                def cardinality_«attrName»(self):
                    return check_cardinality(self.«attrName», «lowerCardinality», «upperCardString»)
                
            «ENDIF»
        '''
    }
    def getImportsFromAttributes(Data rosettaClass) {
        val rdt = rosettaClass.buildRDataType
        // get all non-Meta attributes
        val fa = rdt.getOwnAttributes.filter [
            (it.name !== "reference") && (it.name !== "meta") && (it.name !== "scheme")
        ].filter[!PythonTranslator::isRosettaTypeSupported(it)]
        val imports = newArrayList
        for (attribute : fa) {
            var rt = attribute.getRMetaAnnotatedType.getRType
            if (rt === null) {
                throw new Exception("Attribute type is null for " + attribute.name + " for class " + rosettaClass.name)
            }
            if (!PythonTranslator::isRosettaTypeSupported(rt.getName())) { // need imports for derived types
                imports.add('''import «rt.getQualifiedName»''')
            }
        }
        return imports.toSet.toList
    }
}