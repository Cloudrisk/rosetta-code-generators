package com.regnosys.rosetta.generator.python.func

import com.regnosys.rosetta.rosetta.simple.Attribute
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.rosetta.simple.Operation
import com.regnosys.rosetta.rosetta.simple.impl.FunctionImpl
import com.regnosys.rosetta.rosetta.RosettaTyped
import com.regnosys.rosetta.generator.object.ExpandedAttribute
import com.regnosys.rosetta.rosetta.expression.RosettaExpression
import com.regnosys.rosetta.types.RAnnotateType
import com.regnosys.rosetta.types.RType
import com.regnosys.rosetta.rosetta.simple.ShortcutDeclaration
import com.regnosys.rosetta.rosetta.expression.RosettaExpression
import com.regnosys.rosetta.rosetta.expression.RosettaSymbolReference
import com.regnosys.rosetta.rosetta.expression.RosettaOnlyElement
import com.regnosys.rosetta.rosetta.expression.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.expression.RosettaConditionalExpression
import com.regnosys.rosetta.rosetta.expression.ArithmeticOperation
import com.regnosys.rosetta.rosetta.expression.InlineFunction
import com.regnosys.rosetta.rosetta.expression.RosettaBinaryOperation
import com.regnosys.rosetta.types.RosettaTypeProvider
import java.util.ArrayList
import java.util.HashMap
import java.util.List
import java.util.Map
import java.util.Arrays
import com.regnosys.rosetta.rosetta.RosettaModel
import com.google.inject.Inject
import com.regnosys.rosetta.generator.python.util.PythonModelGeneratorUtil
import com.regnosys.rosetta.generator.python.util.PythonTranslator
import org.slf4j.LoggerFactory
import org.slf4j.Logger
import com.regnosys.rosetta.rosetta.RosettaBasicType
import com.regnosys.rosetta.rosetta.RosettaBuiltinType
import com.regnosys.rosetta.rosetta.simple.Condition
import com.regnosys.rosetta.rosetta.expression.ChoiceOperation
import com.regnosys.rosetta.rosetta.expression.OneOfOperation
import com.regnosys.rosetta.rosetta.expression.Necessity
import com.regnosys.rosetta.rosetta.RosettaMetaType
import com.regnosys.rosetta.rosetta.RosettaEnumValue
import com.regnosys.rosetta.generator.java.enums.EnumHelper
import com.regnosys.rosetta.rosetta.RosettaFeature
import com.regnosys.rosetta.rosetta.expression.RosettaExistsExpression
import com.regnosys.rosetta.rosetta.expression.RosettaAbsentExpression
import com.regnosys.rosetta.rosetta.expression.RosettaReference
import com.regnosys.rosetta.rosetta.expression.RosettaNumberLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaBooleanLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaIntLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaStringLiteral
import com.regnosys.rosetta.rosetta.expression.ListLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaCountOperation
import com.regnosys.rosetta.rosetta.expression.RosettaOnlyExistsExpression
import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.expression.RosettaImplicitVariable
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaCallableWithArgs
import com.regnosys.rosetta.rosetta.expression.ModifiableBinaryOperation
import com.regnosys.rosetta.rosetta.simple.OutputOperation
import com.regnosys.rosetta.rosetta.simple.AssignOutputOperation
import com.regnosys.rosetta.rosetta.simple.Segment
import com.regnosys.rosetta.rosetta.expression.MapOperation
import com.regnosys.rosetta.rosetta.expression.ReduceOperation
import com.regnosys.rosetta.rosetta.expression.SortOperation
import com.regnosys.rosetta.rosetta.expression.FilterOperation

class  PythonFunctionGenerator {
	
	static final Logger LOGGER = LoggerFactory.getLogger(PythonFunctionGenerator);
	
	@Inject RosettaTypeProvider typeProvider
	
	var List<String> importsFound = newArrayList
	var if_cond_blocks = new ArrayList<String>()
	
	@Inject
	PythonModelGeneratorUtil utils;
	@Inject PythonTranslator translator
	
	val Object SymbolReference = null
	
	static def toPythonBasicType(String typename) {
		switch typename {
			case 'string':
				'str'
			case 'time':
				'time'
			case 'date':
				'date'
			case 'dateTime':
				'datetime'
			case 'zonedDateTime':
				'datetime'
			case 'number':
				'BigDecimal'
			case 'boolean':
				'bool'
			case 'int':
				'int'
			case 'calculation',
			case 'productType',
			case 'eventType':
				'str'
			default:
				(typename === null) ? null : typename.toFirstUpper
		}
	}
	
	def Map<String, ? extends CharSequence> generate(List<Function> rosettaFunctions, String version) {
		val result = new HashMap
		
		if(rosettaFunctions.size()>0){
			for(Function func: rosettaFunctions){
				val tr = func.eContainer as RosettaModel
				val namespace = tr.name
				try{
					val funcs = func.generateFunctions(version)				
					result.put(utils.toPyFunctionFileName(namespace, func.name), 
						utils.createImports(func.name) + funcs)
				}
				catch(Exception ex){
					LOGGER.error("Exception occurred generating func {}", func.name, ex)	
				}		
			} 
		}
		
		return result
	}

	private def generateFunctions(Function function,String version) {
	    
	    importsFound = getImportsFromAttributes(function)
	    var List<String> updateForwardRefs = newArrayList
	    //updateForwardRefs.add('''«function.name».update_forward_refs()''')
	    
		'''
		«generatesBody(function)»
		
		«FOR dataImport : importsFound SEPARATOR "\n"»«dataImport»«ENDFOR»
					
		'''
		
	}
	
	
    private def generatesBody(Function function) {
 
    	val output = function.output
    	val input = function.inputs
    	val defaultClassName = function.name+"Default"
    	//function.inputs.map[x | x.getTypeCall.class.getMethods].forEach[x| println(x)]
       // println(output.typeCall.type)
       for (f:function.operations){
       		println((f.expression as FilterOperation).function.body)
       }
    	var f = FilterOperation
    	f.methods.forEach(x|println(x))
		'''
		class «function.name»(ABC):
		«IF function.definition !== null»
			"""
			«function.definition»
			"""
		«ENDIF»
			def evaluate(self,«generatesInputs(function)»):
				«output.name» = self.doEvaluate(«generatesInputs(function)»)
				return «output.name»
			
			@abstractmethod
			def doEvaluate(self,«generatesInputs(function)»):
				pass

		Class «defaultClassName»(«function.name»):
			def doEvaluate(self,«generatesInputs(function)»):
				«generateOutput(output)»
				return self.assignOutput(«output.name»,«generatesInputs(function)»)
							
			def assignOutput(self,«output.name»,«generatesInputs(function)»):
				«generateConditions(function)»  
				return «output.name»
		'''
	}
	
	private def generateConditions(Function function) {
		var n_condition = 0;
		var res = '';
		for (Operation op : function.operations) {
		    res += generateConditionBoilerPlate(op, n_condition)+generateExpressionCondition(function,op,n_condition)
			n_condition += 1;
		}
		return res
	}
	
	
	

	private def generateConditionBoilerPlate(Operation op, int n_condition) {
		'''
		def returnResult_«n_condition»():
		«IF op.definition!==null»
			"""
			«op.definition»
			"""
		«ENDIF»
		'''
	}
	
	

	

	private def generateExpressionCondition(Function function, Operation op,int n_condition) {
		if_cond_blocks = new ArrayList<String>()
		var expr = generateExpression(op.expression, 0)
		var blocks = ""
		if (!if_cond_blocks.isEmpty()) {
			blocks = '''	«FOR arg : if_cond_blocks»«arg»«ENDFOR»'''
		}
		return 
		'''
		«blocks»	return «expr»
		«IF op instanceof OutputOperation»
		    «IF op.add»
				addVar«n_condition» = returnResult_«n_condition»()
				«IF op.path != null»
					«function.output.name».«outputWithSegment(op.path)».extend(addVar«n_condition»)
				«ELSE»
					«function.output.name».extend(addVar«n_condition»)
				«ENDIF»
			«ELSE»
				«IF op.path != null»
					«function.output.name».«outputWithSegment(op.path)» = returnResult_«n_condition»()
				«ELSE»
					«function.output.name» = returnResult_«n_condition»()
				«ENDIF»
			«ENDIF»
		«ENDIF»
		
		'''
	}
	
	private def outputWithSegment(Segment s) {
		var output = ""
		output+=s.attribute.name
		var next = s
		while (next.next != null) {
			next = next.next
			output += "."+next.attribute.name
		}
		output
	}
	
	

	def addImportsFromConditions(String variable, String namespace) {
		val import = '''from «namespace».«variable» import «variable»'''
		if (!importsFound.contains(import)) {
			importsFound.add(import)
		}
	}

	def String generateExpression(RosettaExpression expr, int iflvl) {
		switch (expr) {
			RosettaConditionalExpression: {
				// val nslashes = (2**iflvl - 1) as int;
				// val escsec = '\\'.repeat(nslashes) + "'";
				val ifexpr = generateExpression(expr.getIf(), iflvl + 1)
				val ifthen = generateExpression(expr.ifthen, iflvl + 1)
				var elsethen = expr.elsethen !== null && expr.full ? generateExpression(expr.elsethen,
						iflvl + 1) : 'True'

				val if_blocks = '''
					def _then_fn«iflvl»():
						return «ifthen»
					def _else_fn«iflvl»():
						return «elsethen»	
				'''
				if_cond_blocks.add(if_blocks)

				// '''if_cond(«ifexpr», «escsec»«ifthen»«escsec», «escsec»«elsethen»«escsec», self)'''
				'''if_cond_fn(«ifexpr», _then_fn«iflvl», _else_fn«iflvl»)'''
			}
			RosettaFeatureCall: {
				var right = switch (expr.feature) {
					Attribute: {
						expr.feature.name

					}
					RosettaMetaType: {
						expr.feature.name
					}
					RosettaEnumValue: {
						val rosettaValue = expr.feature as RosettaEnumValue
						val value = EnumHelper.convertValues(rosettaValue)

						val symbol = (expr.receiver as RosettaSymbolReference).symbol
						val model = symbol.eContainer as RosettaModel
						addImportsFromConditions(symbol.name, model.name)

						value
					}
					// TODO: RosettaFeature: '''.Select(x => x.«feature.name.toFirstUpper»)'''
					RosettaFeature: {
						expr.feature.name
					}
					default:
						throw new UnsupportedOperationException("Unsupported expression type of " +
							expr.feature.eClass.name)
				}

				if (right == "None")
					right = "NONE"
				var receiver = generateExpression(expr.receiver, iflvl)
				if (receiver === null) {
					'''«right»'''
				} else {
					'''«receiver».«right»'''
				}

			}
			RosettaExistsExpression: {
				val argument = expr.argument as RosettaExpression
				'''((«generateExpression(argument, iflvl)») is not None)'''
			}
			RosettaBinaryOperation: {
				binaryExpr(expr, iflvl)
			}
			RosettaAbsentExpression: {
				val argument = expr.argument as RosettaExpression
				'''((«generateExpression(argument, iflvl)») is None)'''
			}
			RosettaReference: {
				reference(expr, iflvl)
			}
			RosettaNumberLiteral: {
				'''«expr.value»'''
			}
			RosettaBooleanLiteral: {
				if (expr.value == "true")
					'''True'''
				else
					'''False'''
			}
			RosettaIntLiteral: {
				'''«expr.value»'''
			}
			RosettaStringLiteral: {
				'''"«expr.value»"'''
			}
			RosettaOnlyElement: {
				val argument = expr.argument as RosettaExpression
				'''(«generateExpression(argument, iflvl)»)'''
			}
			RosettaEnumValueReference: {
				val value = EnumHelper.convertValues(expr.value)
				'''«expr.enumeration».«value»'''
			}
			RosettaOnlyExistsExpression: {
				var aux = expr as RosettaOnlyExistsExpression;
				'''check_one_of_constraint(self, «generateExpression(aux.getArgs().get(0), iflvl)»)'''
			}
			RosettaCountOperation: {
				val argument = expr.argument as RosettaExpression
				'''len(«generateExpression(argument, iflvl)»)'''
			}
			ListLiteral: {
				'''[«FOR arg : expr.elements SEPARATOR ', '»«generateExpression(arg, iflvl)»«ENDFOR»]'''
			}
			MapOperation: {
				val argument = expr.argument as RosettaExpression
				'''«generateExpression(argument, iflvl)».map(«generateExpression(expr.function.body, iflvl)»)'''
			}
			ReduceOperation: {
				
			}
			SortOperation: {
				
			}
			FilterOperation: {
				val argument = expr.argument as RosettaExpression
				'''list(filter(«generateExpression(expr.function.body, iflvl)»,«generateExpression(argument, iflvl)»))'''
			}
			default:
				throw new UnsupportedOperationException("Unsupported expression type of " + expr?.class?.simpleName)
		}
	}
	
	def mapOperation(MapOperation expr,int lvl) {
		print(expr.function)
	}
	
	def reduceOperation(ReduceOperation expr,int lvl) {
		
	}
	
	def sortOperation(SortOperation expr,int lvl) {
		
	}
	
	def filterOperation(FilterOperation expr) {
		'''.filter(,)'''
		
	}

	protected def String reference(RosettaReference expr, int iflvl) {
		switch (expr) {
			RosettaImplicitVariable: {
			}
			RosettaSymbolReference: {
				symbolReference(expr, iflvl)
			}
		}
	}

	def String symbolReference(RosettaSymbolReference expr, int iflvl) {
		val s = expr.symbol
		switch (s) {
			Function: {
				'''«s.name»'''
			}
			Attribute: {
				'''«s.name»'''
			}
			RosettaEnumeration: {
				'''«s.name»'''
			}
			RosettaCallableWithArgs: {
				callableWithArgsCall(s, expr, iflvl)
			}
			default:
				throw new UnsupportedOperationException("Unsupported callable type of " + s.class.simpleName)
		}
	}
	
	def String callableWithArgsCall(RosettaCallableWithArgs s, RosettaSymbolReference expr, int iflvl) {
		if (s instanceof FunctionImpl)
			addImportsFromConditions(s.getName(), (s.eContainer as RosettaModel).name + "." + "functions")
		else
			addImportsFromConditions(s.name, (s.eContainer as RosettaModel).name)
		var args = '''«FOR arg : expr.args SEPARATOR ', '»«generateExpression(arg, iflvl)»«ENDFOR»'''
		'''«s.name»(«args»)'''

	}

	def String binaryExpr(RosettaBinaryOperation expr, int iflvl) {
		if (expr instanceof ModifiableBinaryOperation) {
			if (expr.cardMod !== null) {
				if (expr.operator == "<>") {
					'''any_elements(«generateExpression(expr.left, iflvl)», "«expr.operator»", «generateExpression(expr.right, iflvl)»)'''
				} else {
					'''all_elements(«generateExpression(expr.left, iflvl)», "«expr.operator»", «generateExpression(expr.right, iflvl)»)'''
				}
			}
		} else {
			switch expr.operator {
				case ("="): {
					'''(«generateExpression(expr.left, iflvl)» == «generateExpression(expr.right, iflvl)»)'''
				}
				case ("<>"): {
					'''(«generateExpression(expr.left, iflvl)» != «generateExpression(expr.right, iflvl)»)'''
				}
				case ("contains"): {
					'''contains(«generateExpression(expr.left, iflvl)», «generateExpression(expr.right, iflvl)»)'''

				}
				case ("disjoint"): {
					'''disjoint(«generateExpression(expr.left, iflvl)», «generateExpression(expr.right, iflvl)»)'''

				}
				case ("join"): {
					'''join(«generateExpression(expr.left, iflvl)», «generateExpression(expr.right, iflvl)»)'''
				}
				default: {
					'''(«generateExpression(expr.left, iflvl)» «expr.operator» «generateExpression(expr.right, iflvl)»)'''
				}
			}
		}
	}

	
	
	
	
	
	private def generateOutput(Attribute output) {
		var out = ""
		val outputName = output.name
    	val outputType = output.getTypeCall.type.name
    	val outputTypeFunc = (!checkBasicType(output)) ?"None":outputType+"()"
		if (output.getCard.unbounded) out = outputName+"=[]"
		else if (output.getCard.inf === 0) out = out = outputName+"None"
		else out=outputName+"="+outputTypeFunc
		'''
		«out»
		'''
	}
	
	
	private def generateAliases(Function function) {
		
	}
	
	/*private def getInputs(Function function) {
		val inputs = new ArrayList<String>();
		val funcInp = function.inputs
		for (inp : funcInp) inputs.add(inp.name)
		return inputs
	}*/
	
	private def getImportsFromAttributes(Function function) {
		var filteredAttributes = new ArrayList
		for (f : function.inputs) if (!checkBasicType(f)) filteredAttributes.add(f)
		if (!checkBasicType(function.output)) filteredAttributes.add(function.output)
		
		val imports = newArrayList
		for (attribute : filteredAttributes) {
			val originalIt = attribute
			val model = function.model
			if (model !== null) {
				val importStatement = '''from «model.name».«translator.toPythonType(originalIt)» import «translator.toPythonType(originalIt)»'''
				imports.add(importStatement)
			}

		}

		// Remove duplicates by converting the list to a set and back to a list
		return imports.toSet.toList
		
	}
	
	private def functionSet(Function function) {
		
	}
	
	private def functionAdd(Function function) {
		
	}
	
	
	def checkBasicType(Attribute attr) {
		val types = Arrays.asList('int', 'str', 'Decimal', 'date', 'datetime', 'datetime.date', 'datetime.time', 'time',
			'bool', 'number')
		return (attr !== null && translator.toPythonType(attr) !== null) ? types.contains(translator.toPythonType(attr).toString()) : false
	}
	
	
	def boolean isConstraintCondition(Condition cond) {
		return cond.isOneOf || cond.isChoice
	}

	private def boolean isOneOf(Condition cond) {
		return cond.expression instanceof OneOfOperation
	}

	private def boolean isChoice(Condition cond) {
		return cond.expression instanceof ChoiceOperation
	}
	
	
 	
	private def generatesInputs(Function function) {
		
		val inputs = orderInputs(function.inputs)
		
		var result=""
		var count =0
		for(Attribute input: inputs){
			count+=1
			result+=input.name
			if(input.card.inf==0)
				result+="=None"
			if(count<inputs.size())
				result+=", "
		}
		'''«result»'''
	}
	private def List<Attribute> orderInputs(List<Attribute> inputs){
		val orderedInputs = new ArrayList<Attribute>();
		
		for(Attribute input: inputs){
			if(input.card.inf!=0)
				orderedInputs.add(input)
		}
		for(Attribute input: inputs){
			if(!orderedInputs.contains(input))
				orderedInputs.add(input)
		}
		orderedInputs
	}
}