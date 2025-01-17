package com.regnosys.rosetta.generator.python.typealias;

import com.google.inject.Inject;
import com.regnosys.rosetta.rosetta.RosettaTypeAlias;
import com.regnosys.rosetta.rosetta.TypeCall;
import com.regnosys.rosetta.rosetta.TypeCallArgument;
import com.regnosys.rosetta.rosetta.TypeParameter;
import com.regnosys.rosetta.types.RObjectFactory;
import com.regnosys.rosetta.types.RDataType;
import com.regnosys.rosetta.types.RAttribute;
import com.regnosys.rosetta.types.RMetaAttribute;
import com.regnosys.rosetta.types.RType;
import com.regnosys.rosetta.types.TypeSystem;
import com.regnosys.rosetta.rosetta.expression.RosettaIntLiteral;
import com.regnosys.rosetta.rosetta.expression.RosettaNumberLiteral;
import com.regnosys.rosetta.rosetta.expression.RosettaStringLiteral;


import java.util.HashMap;
import java.util.Map;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Extracts parameterized types and establishes aliases for them
 */


public class PythonTypeAliasGenerator {

// todp: use better type checking for base types and parameters
	
	@Inject
	TypeSystem typeSystem;
	
    private static final Logger LOGGER = LoggerFactory.getLogger(PythonTypeAliasGenerator.class);

    private HashMap<String, Object> translateIntParameters (TypeCall tc) {
    	HashMap<String, Object> typeParam = new HashMap<>();
		typeParam.put ("base_type", "int");
    	for (TypeCallArgument tca : tc.getArguments()) {
    		switch (tca.getParameter().getName()) {
    			case "digits":
    				typeParam.put ("max_digits", ((RosettaIntLiteral) tca.getValue()).getValue());
    				break;
		    	case "fractionalDigits":
					typeParam.put ("decimal_places", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
		    	case "min":
					typeParam.put ("ge", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
		    	case "max":
					typeParam.put ("le", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
				default:
					break;
    		}
    	}
    	return typeParam;
    }
    private HashMap<String, Object> translateNumberParameters (TypeCall tc) {
    	HashMap<String, Object> typeParam = new HashMap<>();
		typeParam.put ("base_type", "Decimal");
    	for (TypeCallArgument tca : tc.getArguments()) {
    		switch (tca.getParameter().getName()) {
    			case "digits":
    				typeParam.put ("max_digits", ((RosettaIntLiteral) tca.getValue()).getValue());
    				break;
		    	case "fractionalDigits":
					typeParam.put ("decimal_places", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
		    	case "min":
					typeParam.put ("ge", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
		    	case "max":
					typeParam.put ("le", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
				default:
					break;
    		}
    	}
    	return typeParam;
    }
    
    private HashMap<String, Object> translateStringParameters (TypeCall tc) {
    	HashMap<String, Object> typeParam = new HashMap<>();
		typeParam.put ("base_type", "str");
    	for (TypeCallArgument tca : tc.getArguments()) {
    		switch (tca.getParameter().getName()) {
    			case "minLength":
    				typeParam.put ("min_length", ((RosettaIntLiteral) tca.getValue()).getValue());
    				break;
		    	case "maxLength":
					typeParam.put ("max_length", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
		    	case "pattern":
					typeParam.put ("pattern", ((RosettaStringLiteral) tca.getValue()).getValue());
					break;
				default:
					break;
    		}
    	}
    	return typeParam;
    }

    
    public Map<String, HashMap<String, Object>> generate(Iterable<RosettaTypeAlias> rtas, String version) {
        Map<String, HashMap<String, Object>> result = new HashMap<String, HashMap<String, Object>>();
        // TODO:
        // 1) can the base type be determined by something other than their name (ie is the base type held somewhere)
        // 2) can the parameter types be determined by something other than their name (ie is the parameter type held somewhere)
        for (RosettaTypeAlias rta : rtas) {
        	TypeCall tc = rta.getTypeCall() ;
        	System.out.println ("----- " + rta.getModel().getName() + " ... " + rta.getName());
        	String className = rta.getModel().getName() + "." + rta.getName();
        	switch (tc.getType().getName()) {
    		case "int": {
    			result.put (className, translateIntParameters(tc));
        		break;
    		}
    		case "number": {
    			result.put (className, translateNumberParameters(tc));
        		break;
    		}
    		case "string": {
    			result.put (className, translateStringParameters(tc));
        		break;
    		}
        	default:
        		LOGGER.error("Base type (" + tc.getType().getName() + ") not supported for parametrization");
        		break;
    		
        	}
    	}
        return result;
    }
}
