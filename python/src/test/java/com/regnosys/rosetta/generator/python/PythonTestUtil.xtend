package com.regnosys.rosetta.generator.python;

import com.google.inject.Inject;
import com.regnosys.rosetta.generator.python.PythonCodeGenerator;
import com.regnosys.rosetta.tests.RosettaInjectorProvider;
import com.regnosys.rosetta.tests.util.ModelHelper;
import org.eclipse.xtext.testing.InjectWith;
import org.eclipse.xtext.testing.extensions.InjectionExtension;
import org.junit.jupiter.api.^extension.ExtendWith;
import static org.junit.jupiter.api.Assertions.*

@ExtendWith(InjectionExtension)
@InjectWith(RosettaInjectorProvider)
class PythonTestUtil {

	@Inject extension ModelHelper
	@Inject PythonCodeGenerator generator;

	def generatePython(CharSequence model) {
		val m = model.parseRosettaWithNoErrors
		val resourceSet = m.eResource.resourceSet
		val version = m.version

		val result = newHashMap
		result.putAll(generator.beforeAllGenerate(resourceSet, #{m}, version))
		result.putAll(generator.beforeGenerate(m.eResource, m, version))
		result.putAll(generator.generate(m.eResource, m, version))
		result.putAll(generator.afterGenerate(m.eResource, m, version))
		result.putAll(generator.afterAllGenerate(resourceSet, #{m}, version))

		result
	}
}
