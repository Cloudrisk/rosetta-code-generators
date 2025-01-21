package com.regnosys.rosetta.generator.python.util;

import java.util.HashSet;
import java.util.Set;

import org.eclipse.xtext.xbase.lib.StringExtensions;

import com.regnosys.rosetta.rosetta.simple.Attribute;
import com.regnosys.rosetta.types.RAttribute;
import com.regnosys.rosetta.types.REnumType;
import com.regnosys.rosetta.types.RType;

public class PythonTranslator {
    private static final Set<String> PYTHON_KEYWORDS = new HashSet<>();

    static {
        // Initialize the set with Python keywords and soft keywords
        PYTHON_KEYWORDS.add("False");
        PYTHON_KEYWORDS.add("await");
        PYTHON_KEYWORDS.add("else");
        PYTHON_KEYWORDS.add("import");
        PYTHON_KEYWORDS.add("pass");
        PYTHON_KEYWORDS.add("None");
        PYTHON_KEYWORDS.add("break");
        PYTHON_KEYWORDS.add("except");
        PYTHON_KEYWORDS.add("in");
        PYTHON_KEYWORDS.add("raise");
        PYTHON_KEYWORDS.add("True");
        PYTHON_KEYWORDS.add("class");
        PYTHON_KEYWORDS.add("finally");
        PYTHON_KEYWORDS.add("is");
        PYTHON_KEYWORDS.add("return");
        PYTHON_KEYWORDS.add("and");
        PYTHON_KEYWORDS.add("continue");
        PYTHON_KEYWORDS.add("for");
        PYTHON_KEYWORDS.add("lambda");
        PYTHON_KEYWORDS.add("try");
        PYTHON_KEYWORDS.add("as");
        PYTHON_KEYWORDS.add("def");
        PYTHON_KEYWORDS.add("from");
        PYTHON_KEYWORDS.add("nonlocal");
        PYTHON_KEYWORDS.add("while");
        PYTHON_KEYWORDS.add("assert");
        PYTHON_KEYWORDS.add("del");
        PYTHON_KEYWORDS.add("global");
        PYTHON_KEYWORDS.add("not");
        PYTHON_KEYWORDS.add("with");
        PYTHON_KEYWORDS.add("async");
        PYTHON_KEYWORDS.add("elif");
        PYTHON_KEYWORDS.add("if");
        PYTHON_KEYWORDS.add("or");
        PYTHON_KEYWORDS.add("yield");
        PYTHON_KEYWORDS.add("match");
        PYTHON_KEYWORDS.add("case");
        PYTHON_KEYWORDS.add("type");
        PYTHON_KEYWORDS.add("_");
    }

    // Define the set of Python types as a static final field
    private static final Set<String> PYTHON_TYPES = Set.of(
        "int", "str", "Decimal", "date", "datetime", "datetime.datetime",
        "datetime.date", "datetime.time", "time", "bool"
    );

    public static String mangleName(String attrib) {
        // Check if the attribute is a Python keyword or starts with an underscore
        if (PYTHON_KEYWORDS.contains(attrib) || attrib.charAt(0) == '_') {
            return "rosetta_attr_" + attrib;
        }
        return attrib;
    }
    
    private static String toPythonBasicTypeInnerFunction(String rosettaType) {
        // inner private function to convert from Rosetta type to Python type
        // returns null if no matching type
        switch (rosettaType) {
            case "string":
            case "eventType":
            case "calculation":
            case "productType":
                return "str";
            case "time":
                return "datetime.time";
            case "date":
                return "datetime.date";
            case "dateTime":
            case "zonedDateTime":
                return "datetime.datetime";
            case "number":
                return "Decimal";
            case "boolean":
                return "bool";
            case "int":
                return "int";
            default:
                return null;
        }
    }

    public static String getAttributeTypeWithMeta (String attributeType) {
        // inner private function to convert from Rosetta type to Python type
        // returns null if no matching type
        switch (attributeType) {
            case "str":
                return "StringWithMeta";
            case "datetime.time":
                return "TimeWithMeta";
            case "datetime.date":
                return "DateWithMeta";
            case "datetime.datetime":
                return "DateTimeWithMeta";
            case "Decimal":
                return "DecimalWithMeta";
            case "bool":
                return "BoolWithMeta";
            case "int":
                return "IntWithMeta";
            default:
                return attributeType;
        }
    }
    public static String toPythonBasicType(String rosettaType) {
        String pythonType = toPythonBasicTypeInnerFunction(rosettaType);
        return (pythonType == null) ? rosettaType : pythonType;
    }

    public static String toPythonType(RType rt) {
        if (rt == null)
            return null;
        var pythonType = toPythonBasicTypeInnerFunction(rt.getName());
        if (pythonType == null) {
            pythonType = (rt instanceof REnumType) ? ((REnumType)rt).getName() : rt.getName();
            pythonType = StringExtensions.toFirstUpper(pythonType);
        }
        return pythonType;
    }

    public static String toPythonType(RAttribute ra) {
        RType rt = (ra == null) ? null : ra.getRMetaAnnotatedType().getRType();
        if (rt == null)
            return null;
        String rtName = rt.getName();
        if (rtName == null)
            return null;
        String pythonType = toPythonBasicTypeInnerFunction(rtName);
        return (pythonType == null) ? rt.getNamespace() + "." + rtName + "." + rtName : pythonType;
    }

    public static String toPythonType(Attribute rosettaAttributeType) {
        if (rosettaAttributeType == null)
            return null;
        String rosettaType = rosettaAttributeType.getTypeCall().getType().getName();
        String pythonType = toPythonBasicTypeInnerFunction(rosettaType);
        return (pythonType == null) ? StringExtensions.toFirstUpper(rosettaType) : pythonType;
    }

    public static boolean isRosettaTypeSupported(String rt) {
        return (toPythonBasicTypeInnerFunction(rt) != null);
    }
    public static boolean isRosettaTypeSupported(RAttribute ra) {

    	if (ra == null) {
            return false;
        }
        RType rt = (ra != null) ? ra.getRMetaAnnotatedType().getRType() : null;
        return (rt != null) ? isRosettaTypeSupported(rt.getName()) : false;
    }
    public static boolean isPythonBasicType(final String pythonType) {
        // Check if the given type is in the set of Python types
        return PYTHON_TYPES.contains(pythonType);
    }
}