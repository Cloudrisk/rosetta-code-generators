package com.regnosys.rosetta.generator.csv;

import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

import org.eclipse.emf.ecore.resource.Resource;
import org.eclipse.emf.ecore.resource.ResourceSet;

import com.google.inject.Inject;
import com.regnosys.rosetta.generator.golang.enums.CsvEnumGenerator;
import com.regnosys.rosetta.generator.golang.functions.CsvFunctionGenerator;
import com.regnosys.rosetta.generator.golang.object.CsvModelObjectGenerator;
import com.regnosys.rosetta.generator.external.AbstractExternalGenerator;
import com.regnosys.rosetta.rosetta.RosettaEnumeration;
import com.regnosys.rosetta.rosetta.RosettaMetaType;
import com.regnosys.rosetta.rosetta.RosettaModel;
import com.regnosys.rosetta.rosetta.RosettaNamed;
import com.regnosys.rosetta.rosetta.simple.Data;
import com.regnosys.rosetta.rosetta.simple.Function;

public class CsvCodeGenerator extends AbstractExternalGenerator {

	@Inject
	CsvModelObjectGenerator pojoGenerator;
	@Inject
	private CsvEnumGenerator enumGenerator;
	@Inject
	private CsvFunctionGenerator functionGenerator;

	public GolangCodeGenerator() {
		super("Csv");
		enumGenerator = new CsvEnumGenerator();
	}

	@Override
	public Map<String, ? extends CharSequence> generate(Resource resource, RosettaModel model, String version) {
		return Collections.emptyMap();
	}
	
	@Override	
	public Map<String, ? extends CharSequence> afterAllGenerate(ResourceSet set, Collection<? extends RosettaModel> models, String version) {		
		Map<String, CharSequence> result = new HashMap<>();

		List<Data> rosettaClasses = models.stream().flatMap(m->m.getElements().stream())
				.filter((e)-> e instanceof Data)
				.map(Data.class::cast).collect(Collectors.toList());
		List<RosettaMetaType> metaTypes = models.stream().flatMap(m->m.getElements().stream()).filter(RosettaMetaType.class::isInstance)
				.map(RosettaMetaType.class::cast).collect(Collectors.toList());

		List<RosettaEnumeration> rosettaEnums = models.stream().flatMap(m->m.getElements().stream()).filter(RosettaEnumeration.class::isInstance)
				.map(RosettaEnumeration.class::cast).collect(Collectors.toList());
		
		List<RosettaNamed> rosettaFunctions = models.stream().flatMap(m->m.getElements().stream()).filter(t -> Function.class.isInstance(t))
				.map(RosettaNamed.class::cast).collect(Collectors.toList());

		result.putAll(pojoGenerator.generate(rosettaClasses, metaTypes, version));
		result.putAll(enumGenerator.generate(rosettaEnums, version));
		result.putAll(functionGenerator.generate(rosettaFunctions, version));
		return result;
	}

}
