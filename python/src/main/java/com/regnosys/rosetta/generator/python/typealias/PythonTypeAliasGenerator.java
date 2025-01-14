package com.regnosys.rosetta.generator.python.typealias;

import com.google.inject.Inject;
import com.regnosys.rosetta.generator.python.PythonCodeGenerator;
import com.regnosys.rosetta.generator.python.util.PythonModelGeneratorUtil;
import com.regnosys.rosetta.rosetta.RosettaMetaType;
import com.regnosys.rosetta.rosetta.RosettaModel;
import com.regnosys.rosetta.rosetta.RosettaTypeAlias;
import com.regnosys.rosetta.rosetta.TypeCallArgument;
import com.regnosys.rosetta.types.RObjectFactory;
import com.regnosys.rosetta.types.RDataType;
import com.regnosys.rosetta.types.RChoiceType;
import com.regnosys.rosetta.types.RAttribute;
import com.regnosys.rosetta.types.RMetaAttribute;
import com.regnosys.rosetta.utils.DeepFeatureCallUtil;
import com.regnosys.rosetta.rosetta.simple.Data;
import com.regnosys.rosetta.generator.python.util.PythonTranslator;
import com.regnosys.rosetta.generator.python.util.Util;
import java.util.HashMap;
import java.util.List;
import java.util.ArrayList;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class PythonTypeAliasGenerator {

    private static final Logger LOGGER = LoggerFactory.getLogger(PythonTypeAliasGenerator.class);

    public Map<String, ? extends CharSequence> generate(Iterable<RosettaTypeAlias> rtas, String version) {
        HashMap<String, String> result = new HashMap<String, String>();

        LOGGER.info("Processing Type Aliases");
        for (RosettaTypeAlias rta : rtas) {
    		System.out.println("..... rta: " + rta.toString() + 
    				" getTypeCall: " + rta.getTypeCall().getType());
    		for (TypeCallArgument tca : rta.getTypeCall().getArguments()) {
    			System.out.println ("..... tca: " + tca.getParameter() + " value: " + tca.getValue());
    		}
    	}
        return result;
    }
}


