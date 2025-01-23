import json
import importlib
rune_string='{"@model" : "serialization", "@type" : "serialization.test.basic.Root", "@version" : "0.0.0", "basicSingle" : {"booleanType" : true,"numberType" : 123.456,"parameterisedNumberType" : 123.99,"parameterisedStringType" : "abcDEF","stringType" : "foo","timeType" : "12:00:00"}}'
rune_dict = json.loads(rune_string)
rune_model = rune_dict.pop('@model')
rune_type = rune_dict.pop('@type')
rune_model_version = rune_dict.pop('@version')
rune_class = rune_type.rsplit('.')[-1]
# rune_module = importlib.import_module(rune_type)
from serialization.test.basic.Root import Root