package com.regnosys.rosetta.generator.python.util

import java.util.function.Function
import java.util.Iterator
import java.util.NoSuchElementException
import com.regnosys.rosetta.rosetta.RosettaType
import com.regnosys.rosetta.rosetta.RosettaModel

class Util {

    static def <T> Iterable<T> distinct(Iterable<T> parentIterable) {
        return new DistinctByIterator(parentIterable, [it])
    }

    static def <T, U> Iterable<T> distinctBy(Iterable<T> parentIterable, Function<T, U> extractFunction) {
        return new DistinctByIterator(parentIterable, extractFunction)
    }

    static def <T> boolean exists(Iterable<? super T> iter, Class<T> clazz) {
        !iter.filter(clazz).empty
    }

    static def String getNamespace(RosettaModel rm) {
        return rm.getName.split("\\.").get(0)
    }

    private static class DistinctByIterator<T, U> implements Iterable<T> {
        val Iterable<T> iterable
        val Function<T, U> extractFunction
    
        new(Iterable<T> iterable, Function<T, U> extractFunction) {
            this.iterable = iterable
            this.extractFunction = extractFunction
        }
    
        override iterator() {
            val parentIterator = iterable.iterator
            val read = newHashSet
    
            return new Iterator<T>() {
                var T readNext = null
    
                override hasNext() {
                    while (readNext === null && parentIterator.hasNext) {
                        val next = parentIterator.next
                        val compareVal = extractFunction.apply(next)
                        if (read.add(compareVal)) {
                            readNext = next
                        }
                    }
                    return readNext !== null
                }
    
                override next() {
                    if (!hasNext) throw new NoSuchElementException("read past end of iterator")
                    val result = readNext
                    readNext = null
                    return result
                }
            }
        }
    }
    static def String fullname(RosettaType clazz) {
        return '''«clazz.model.name».«clazz.name»''';
    }

    static def String packageName(RosettaType clazz) { 
        return clazz.model.name;
    }
}
