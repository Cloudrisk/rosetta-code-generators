package com.regnosys.rosetta.generator.python.func;

import com.regnosys.rosetta.rosetta.RosettaEnumValueReference
import com.regnosys.rosetta.rosetta.RosettaEnumeration
import com.regnosys.rosetta.rosetta.RosettaExternalFunction
import com.regnosys.rosetta.rosetta.RosettaRule
import com.regnosys.rosetta.rosetta.RosettaSymbol
import com.regnosys.rosetta.rosetta.expression.InlineFunction
import com.regnosys.rosetta.rosetta.expression.ListLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaBinaryOperation
import com.regnosys.rosetta.rosetta.expression.RosettaConditionalExpression
import com.regnosys.rosetta.rosetta.expression.RosettaConstructorExpression
import com.regnosys.rosetta.rosetta.expression.RosettaExpression
import com.regnosys.rosetta.rosetta.expression.RosettaFeatureCall
import com.regnosys.rosetta.rosetta.expression.RosettaFunctionalOperation
import com.regnosys.rosetta.rosetta.expression.RosettaLiteral
import com.regnosys.rosetta.rosetta.expression.RosettaOnlyExistsExpression
import com.regnosys.rosetta.rosetta.expression.RosettaReference
import com.regnosys.rosetta.rosetta.expression.RosettaSymbolReference
import com.regnosys.rosetta.rosetta.expression.RosettaUnaryOperation
import com.regnosys.rosetta.rosetta.expression.RosettaDeepFeatureCall
import com.regnosys.rosetta.rosetta.simple.Data
import com.regnosys.rosetta.rosetta.simple.Function
import com.regnosys.rosetta.types.RFunction
import com.regnosys.rosetta.types.RObjectFactory
import java.util.HashSet
import java.util.Set
import javax.inject.Inject
import org.eclipse.emf.ecore.EObject
import org.eclipse.xtext.EcoreUtil2

/**
 * Determine the Rosetta dependencies for a Rosetta object
 */
class FunctionDependencyProvider {
    @Inject RObjectFactory rTypeBuilderFactory;

    Set<EObject> visited = new HashSet<EObject>();

    var dependencies = null as Set<EObject>;    
    def Set<EObject> findDependencies(EObject object) {
        if (visited.contains(object)) {
            return newHashSet();
        }
        var dependencies = null as Set<EObject>;
        switch object {
            RosettaBinaryOperation: {
                dependencies = newHashSet(findDependenciesChilds(object.left) +
                    findDependenciesChilds(object.right)
                )
            }
            RosettaConditionalExpression: {
                dependencies = newHashSet(
                    findDependenciesChilds(object.^if) + 
                    findDependenciesChilds(object.ifthen) +
                    findDependenciesChilds(object.elsethen))
            }
            RosettaOnlyExistsExpression: {
                dependencies = findDependenciesFromIterable(object.args)
            }
            RosettaFunctionalOperation: {
                dependencies = newHashSet(findDependenciesChilds(object.argument) + findDependenciesChilds(object.function))
            }
            RosettaUnaryOperation: {
                dependencies = findDependenciesChilds(object.argument)
            }
            RosettaFeatureCall:
                dependencies = findDependenciesChilds(object.receiver)
            RosettaSymbolReference: {
                dependencies = newHashSet(findDependenciesChilds(object.symbol) + findDependenciesFromIterable(object.args))
            }
            Function, Data, RosettaEnumeration: {
                dependencies = newHashSet(object)
            }
            InlineFunction: {
                dependencies = findDependenciesChilds(object.body)
            }
            ListLiteral: {
                dependencies = newHashSet(object.elements.flatMap[findDependenciesChilds])
            }
            RosettaConstructorExpression: {
                val typeDependencies = (object.typeCall?.type !== null) ?  newHashSet(object.typeCall.type) : newHashSet()
                val keyValuePairsDependencies = object.values.map[valuePair | findDependenciesChilds(valuePair.value)].flatten
                dependencies = newHashSet(typeDependencies + keyValuePairsDependencies)
            }
            RosettaExternalFunction,
            RosettaEnumValueReference,
            RosettaLiteral,
            RosettaReference,
            RosettaSymbol,
            RosettaDeepFeatureCall:
                dependencies = newHashSet()
            default:
                if (object !== null)
                    throw new IllegalArgumentException('''«object?.eClass?.name»: generating dependency in a function for this type is not yet implemented.''')
                else
                    dependencies = newHashSet()
        }
        if (dependencies !== null){
            visited.add(object)
        }
        return dependencies
    }
    
    def Set<EObject> findDependenciesChilds(EObject object) {
        switch object {
            RosettaBinaryOperation: {
                dependencies = newHashSet(findDependenciesChilds(object.left) +
                    findDependenciesChilds(object.right)
                )
            }
            RosettaConditionalExpression: {
                dependencies = newHashSet(
                    findDependenciesChilds(object.^if) + 
                    findDependenciesChilds(object.ifthen) +
                    findDependenciesChilds(object.elsethen))
            }
            RosettaOnlyExistsExpression: {
                dependencies = findDependenciesFromIterable(object.args)
            }
            RosettaFunctionalOperation: {
                dependencies = newHashSet(findDependenciesChilds(object.argument) + findDependenciesChilds(object.function))
            }
            RosettaUnaryOperation: {
                dependencies = findDependenciesChilds(object.argument)
            }
            RosettaFeatureCall:
                dependencies = findDependenciesChilds(object.receiver)
            RosettaSymbolReference: {
                dependencies = newHashSet(findDependenciesChilds(object.symbol) + findDependenciesFromIterable(object.args))
            }
            Function, Data, RosettaEnumeration: {
                dependencies = newHashSet(object)
            }
            InlineFunction: {
                dependencies = findDependenciesChilds(object.body)
            }
            ListLiteral: {
                dependencies = newHashSet(object.elements.flatMap[findDependenciesChilds])
            }
            RosettaConstructorExpression: {
                val typeDependencies = (object.typeCall?.type !== null) ?  newHashSet(object.typeCall.type) : newHashSet()
                val keyValuePairsDependencies = object.values.map[valuePair | findDependenciesChilds(valuePair.value)].flatten
                dependencies = newHashSet(typeDependencies + keyValuePairsDependencies)
            }
            RosettaExternalFunction,
            RosettaEnumValueReference,
            RosettaLiteral,
            RosettaReference,
            RosettaSymbol,
            RosettaDeepFeatureCall:
                dependencies = newHashSet()
            default:
                if (object !== null)
                    throw new IllegalArgumentException('''«object?.eClass?.name»: generating dependency in a function for this type is not yet implemented.''')
                else
                    dependencies = newHashSet()
        }
        if (dependencies !== null){
            visited.add(object)
        }
        return dependencies
    }

    def Set<EObject> findDependenciesFromIterable(Iterable<? extends EObject> objects) {
        val allDependencies = objects.map[object | findDependenciesChilds(object)].flatten.toSet
        newHashSet(allDependencies)
    }

    def Set<RFunction> rFunctionDependencies(RosettaExpression expression) {
        val rosettaSymbols = EcoreUtil2.eAllOfType(expression, RosettaSymbolReference).map[it.symbol]
        (rosettaSymbols.filter(Function).map[rTypeBuilderFactory.buildRFunction(it)] +
            rosettaSymbols.filter(RosettaRule).map[rTypeBuilderFactory.buildRFunction(it)]).toSet
    }

    def Set<RFunction> rFunctionDependencies(Iterable<? extends RosettaExpression> expressions) {
        val allFunctionDependencies = expressions.flatMap [
            rFunctionDependencies
        ].toSet
        newHashSet(allFunctionDependencies)
    }

    def void reset() {
        visited.clear();
    }
}
