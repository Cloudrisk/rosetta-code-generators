'''run serialization unit tests'''
from pathlib import Path
import os
import json
import importlib
import glob
import argparse
import pytest
from pydantic import BaseModel
from typing import Any, Dict
from test_helper import dict_comp
from rosetta.runtime.utils import BaseDataClass 

JSON_DIR = '/Users/dls/projects/rune/rune-common/regnosys/rune-common/serialization/src/test/resources/rune-serializer-round-trip-test/extension'

def create_object_from_dict(class_path: str, data: Dict[str, Any]) -> BaseModel:
    """
    Create an object of the specified class from a dictionary.
    
    :param class_path: Fully qualified class path (e.g., 'module.submodule.ClassName').
    :param data: Dictionary containing the data to initialize the object.
    :return: An instance of the specified class.
    """
    # Import the module and get the class
    module_path, class_name = class_path.rsplit('.', 1)
    module = importlib.import_module(module_path)
    cls = getattr(module, class_name)

    # Ensure the class is a subclass of Pydantic's BaseModel
    if not issubclass(cls, BaseModel):
        raise TypeError(f"{class_name} is not a subclass of Pydantic BaseModel")

    # Recursively create objects for nested dictionaries with '@type'
    def process_nested_dict(d: Dict[str, Any]) -> Dict[str, Any]:
        for key, value in d.items():
            if isinstance(value, dict):
                if '@type' in value:
                    nested_class_path = value.pop('@type')
                    d[key] = create_object_from_dict(nested_class_path, value)
                else:
                    # Recursively process the nested dictionary
                    d[key] = process_nested_dict(value)
            elif isinstance(value, BaseModel):
                # Convert Pydantic model instance to dictionary
                d[key] = value.dict()
        return d

    # Process the input data
    processed_data = process_nested_dict(data)

    # Remove the '@type' key if it exists at the top level
    processed_data.pop('@type', None)

    # Create and return the object
    return cls(**processed_data)

def read_to_rune_from_string (json_str_in: str):
    '''generate a rune object from a string'''
    rune_dict = json.loads(json_str_in)
    new_obj_model = rune_dict.pop('@model')
    new_obj_type = rune_dict.pop('@type')
    new_obj_model_version = rune_dict.pop('@version')
    new_obj = create_object_from_dict (new_obj_type, rune_dict)
    return {'obj_model': new_obj_model,
            'obj_type': new_obj_type,
            'obj_model_version': new_obj_model_version,
            'obj': new_obj}

def write_to_string_from_rune (obj_out, obj_model_out, obj_type_out, obj_model_version_out) -> str:
    '''write a rune object to a string'''
    rune_dict = {}
    rune_dict.update ({'@model': obj_model_out,
                       '@type' : obj_type_out, 
                       '@version' : obj_model_version_out})
    rune_dict.update (obj_out.model_dump(exclude_defaults=True))
    return json.dumps(rune_dict)

json_files = glob.glob(JSON_DIR + os.sep + '**/*.json', recursive = True)
inscope_files = []

@pytest.mark.parametrize("json_file", json_files)
def test_json_file(json_file):
    '''Load data from the JSON file'''
    json_file_name = json_file.split(os.sep)[-1]
    if len(inscope_files) == 0 or json_file_name in inscope_files:
        json_str = Path(os.path.join(JSON_DIR, json_file)).read_text(encoding='utf8')
        try:
            results = read_to_rune_from_string(json_str)
            print(results)
            json_str_out = write_to_string_from_rune (results['obj'],
                                                      results['obj_model'],
                                                      results['obj_type'],
                                                      results['obj_model_version'])
            dict_in = json.loads(json_str)
            dict_out = json.loads(json_str_out)
            assert dict_comp(dict_in, dict_out), f"failed dict comparison for {json_file_name}"
        except Exception as error_msg:
            print(error_msg)
            assert False
    else:
        assert False, f"test not implemented for {json_file}"

def main():
    '''Run pytest programmatically'''
    pytest_args = ['-v', __file__]  # '-v' for verbose output, '__file__' to specify the current file
    pytest.main(pytest_args)
    
def process_files ():
    '''skip tests and show deserialized and serialized data'''
    for json_file in json_files:
        json_file_name = json_file.split(os.sep)[-1]
        in_scope = len(inscope_files) == 0 or json_file_name in inscope_files
        print('reading: ' + json_file_name + ' is in scope: ' + str(in_scope))
        if in_scope:
            json_str = Path(os.path.join(JSON_DIR, json_file)).read_text(encoding='utf8')
            try:
                results = read_to_rune_from_string(json_str)
                json_str_out = write_to_string_from_rune (results['obj'],
                                                        results['obj_model'],
                                                        results['obj_type'],
                                                        results['obj_model_version'])
                print(json_str_out)
            except Exception as ex:
                print('error processing file:', json_file, '\nexception\n', ex)

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--test', help='Run Unit Tests', action="store_true")
    parser.add_argument('-p', '--process', 
                        help='Show Deserialized and Serialized Data', 
                        action="store_true")
    parser.add_argument('-x', '--execute', help='Execute Test On a Specific JSON')
    args = parser.parse_args()
    if args.test:
        print('run tests')
        main()
    elif args.process:
        print('process files')
        process_files()
    elif args.execute:
        print('testing file: ', args.execute)
        json_str = Path(os.path.join(JSON_DIR, args.execute)).read_text(encoding='utf8')
        print('json_str:', json_str)
        try:
            rune = read_to_rune_from_string(json_str)
            print (rune['obj'])
        except Exception as ex:
            print('error processing file:', args.execute, '\nexception\n', ex, 'n', json_str)
    else:
        parser.print_help()
