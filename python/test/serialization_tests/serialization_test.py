'''run serialization unit tests'''
from pathlib import Path
import os
import json
import importlib
from test_helper import dict_comp

def read_from_string (json_str: str):
    '''generate a rune object from a string'''
    rune_dict = json.loads(json_str)
    new_obj_model = rune_dict.pop('@model')
    new_obj_type = rune_dict.pop('@type')
    new_obj_model_version = rune_dict.pop('@version')
    module = importlib.import_module(new_obj_type)
    cls_name = new_obj_type.split('.')[-1]
    cls = getattr(module, cls_name)
    new_obj = cls.model_validate_json(json.dumps(rune_dict))
    return {'obj_model': new_obj_model,
            'obj_type': new_obj_type,
            'obj_model_version': new_obj_model_version,
            'obj': new_obj}

def write_to_string (obj_out, obj_model_out, obj_type_out, obj_model_version_out) -> str:
    '''write a rune object to a string'''
    rune_dict = {}
    rune_dict.update ({'@model': obj_model_out,
                       '@type' : obj_type_out, 
                       '@version' : obj_model_version_out})
    rune_dict.update (obj_out.model_dump(exclude_defaults=True))
    return json.dumps(rune_dict)

TEST_FILE_PATH = '/Users/dls/projects/rune/rune-common/serialization/src/test/resources/rune-serializer-round-trip-test/data'

def test_data ():
    '''generate tests for a path'''
    path = os.path.join(TEST_FILE_PATH, 'data-types.json')
    execute_test_for_path(path)
    execute_test_for_path(path)
    
def execute_test_for_path(path: Path):
    '''execute a path'''
    json_str_in = Path(path).read_text(encoding='utf8')
    results = read_from_string(json_str_in)
    json_str_out = write_to_string (results['obj'], results['obj_model'], results['obj_type'], results['obj_model_version'])
    dict_in = json.loads(json_str_in)
    dict_out = json.loads(json_str_out)
    assert dict_comp(dict_in, dict_out), "test_data - failed corrected dict comparison"


if __name__ == "__main__":
    test_data ()