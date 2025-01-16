package com.regnosys.rosetta.generator.python.typealias;

import com.google.inject.Inject;
import com.regnosys.rosetta.generator.python.PythonCodeGenerator;
import com.regnosys.rosetta.generator.python.util.PythonModelGeneratorUtil;
import com.regnosys.rosetta.rosetta.ParametrizedRosettaType;
import com.regnosys.rosetta.rosetta.RosettaMetaType;
import com.regnosys.rosetta.rosetta.RosettaModel;
import com.regnosys.rosetta.rosetta.RosettaType;
import com.regnosys.rosetta.rosetta.RosettaTypeAlias;
import com.regnosys.rosetta.rosetta.TypeCall;
import com.regnosys.rosetta.rosetta.TypeCallArgument;
import com.regnosys.rosetta.rosetta.TypeParameter;
import com.regnosys.rosetta.types.RObjectFactory;
import com.regnosys.rosetta.types.RDataType;
import com.regnosys.rosetta.types.RChoiceType;
import com.regnosys.rosetta.types.RAttribute;
import com.regnosys.rosetta.types.RMetaAttribute;
import com.regnosys.rosetta.types.RType;
import com.regnosys.rosetta.utils.DeepFeatureCallUtil;
import com.regnosys.rosetta.rosetta.simple.Data;
import com.regnosys.rosetta.generator.python.util.PythonTranslator;
import com.regnosys.rosetta.generator.python.util.Util;
import com.regnosys.rosetta.rosetta.expression.RosettaExpression;
import com.regnosys.rosetta.rosetta.expression.RosettaIntLiteral;
import com.regnosys.rosetta.rosetta.expression.RosettaNumberLiteral;
import com.regnosys.rosetta.rosetta.expression.RosettaStringLiteral;


import java.util.HashMap;
import java.util.List;
import java.util.AbstractMap;
import java.util.ArrayList;
import java.util.Map;
import java.math.BigInteger;

import org.eclipse.emf.common.util.EList;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PythonTypeAliasGenerator {

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
		typeParam.put ("base_type", "number");
    	for (TypeCallArgument tca : tc.getArguments()) {
    		switch (tca.getParameter().getName()) {
    			case "digits":
    				typeParam.put ("max_digits", ((RosettaIntLiteral) tca.getValue()).getValue());
    				break;
		    	case "fractionalDigits":
					typeParam.put ("decimal_places", ((RosettaIntLiteral) tca.getValue()).getValue());
					break;
		    	case "min":
					typeParam.put ("ge", ((RosettaNumberLiteral) tca.getValue()).getValue());
					break;
		    	case "max":
					typeParam.put ("le", ((RosettaNumberLiteral) tca.getValue()).getValue());
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
        LOGGER.info("Processing Type Aliases");
        for (RosettaTypeAlias rta : rtas) {
        	TypeCall rtc = rta.getTypeCall();
        	RosettaModel rm = rta.getModel();
        	RosettaType rt = rtc.getType();
        	String className = rm.getName() + "." + rta.getName();
    		EList<TypeCallArgument> arg = rtc.getArguments();
			HashMap<String, Object> typeParam = new HashMap<>();
			ParametrizedRosettaType prt = ((ParametrizedRosettaType) rta);
			EList<TypeParameter> params = ((ParametrizedRosettaType) rt).getParameters();
        	System.out.println("..... rta: " + rta);
        	System.out.println("..... rm: " + rm);
        	System.out.println("..... rt: " + rt);
        	System.out.println("..... prt: " + prt);
        	System.out.println("..... params: " + params);
        	for (TypeCallArgument tca : arg) {
        		TypeParameter tp =  tca.getParameter();
        		System.out.println("..... tca: " + tca);
        		System.out.println("..... tca: " + tca.getValue());
        		System.out.println(".....  tp.name: " + tp.getName());
        		if(tp.getName().equals("pattern")) {
            		System.out.println(".....  tp value: " + ((RosettaStringLiteral) tca.getValue()).getValue());
        		} else {
            		System.out.println(".....  tp value: " + ((RosettaIntLiteral) tca.getValue()).getValue());
        		}

        	}
    		switch (rt.getName()) {
        		case "int": {
        			result.put (className, translateIntParameters(rtc));
	        		break;
        		}
        		case "number": {
        			result.put (className, translateNumberParameters(rtc));
            		break;
        		}
        		case "string": {
        			result.put (className, translateStringParameters(rtc));
            		break;
        		}
            	default:
            		System.out.println ("unknown type");
        	}
    	}
        return result;
    }
}
