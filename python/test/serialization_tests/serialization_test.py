'''run serialization unit tests'''
from pathlib import Path
import os
import json
import importlib
import glob
import argparse
import pytest
import datetime
from rune.runtime.base_data_class import BaseDataClass
from typing import Any, Dict, Annotated
from test_helper.test_helper.dict_comp import dict_comp

JSON_DIR = '/Users/dls/projects/rune/rune-common/serialization/src/test/resources/rune-serializer-round-trip-test/basic'

def deserialize (rune_string: str) -> BaseDataClass:
    '''generate a rune object from a string'''
    rune_dict = json.loads(rune_string)
    rune_model = rune_dict.pop('@model')
    rune_type = rune_dict.pop('@type')
    rune_model_version = rune_dict.pop('@version')
    rune = deserialize_from_dict (rune_type, rune_dict)
    return rune

def deserialize_from_dict(rune_type: str, rune_dict: Dict[str, Any]) -> BaseDataClass:
    """
    Create an object of the specified class from a dictionary.
    
    :param class_path: Fully qualified class path (e.g., 'module.submodule.ClassName').
    :param data: Dictionary containing the data to initialize the object.
    :return: An instance of the specified class.
    """
    # Import the module and get the class
    print('deserialize_from_dict ... getting cls ... obj_class_path:' + rune_type)
    rune_class = rune_type.rsplit('.')[-1]
    print('deserialize_from_dict ... rune_class:' + rune_class)
    rune_module = importlib.import_module(rune_type)
    print('deserialize_from_dict ... rune_module:' + rune_module)
    rune_cls = getattr(rune_module, rune_class)
    print('deserialize_from_dict ... cls:' + rune_cls)

    # Ensure the class is a subclass of BaseDataClass (from the rune runtime)
    if not issubclass(rune_cls, BaseDataClass):
        raise TypeError(f"{rune_class} is not a subclass of BaseDataClass")

    print('rune_class: ' + rune_class + ' cls:' + rune_cls + '\ndata\n' + rune_dict)
    rune_obj = rune_cls.model_validate (rune_dict)
    return rune_obj

def serialize (rune: BaseDataClass) -> str:
    """
    serialize a rune object to a string
    
    :param obj - the item to be serialized.
    :return: a string
    """
    
    rune_header = {'@model': rune.__class__.__module__.split('.')[0], 
                  '@type': rune.__class__.__module__,
                  '@version': '0.0.0'}
    rune_string = json.dumps(rune_header, indent=2) + os.linesep + rune.model_dump_json(indent=2)
    return rune_string

json_files = glob.glob(JSON_DIR + os.sep + '**/*.json', recursive = True)
inscope_files = []

@pytest.mark.parametrize("json_file", json_files)
def test_json_file(json_file):
    '''Load data from the JSON file'''
    json_file_name = json_file.split(os.sep)[-1]
    if len(inscope_files) == 0 or json_file_name in inscope_files:
        json_str = Path(os.path.join(JSON_DIR, json_file)).read_text(encoding='utf8')
        try:
            obj = deserialize(json_str)
            print(obj)
            json_str_out = serialize(obj)
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
            json_str_in = Path(os.path.join(JSON_DIR, json_file)).read_text(encoding='utf8')
            try:
                results = deserialize(json_str_in)
                json_str_out = serialize (results['obj'])
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
        rune_str = Path(os.path.join(JSON_DIR, args.execute)).read_text(encoding='utf8')
        print('json_str:', rune_str)
        try:
            rune = deserialize(rune_str)
            print (rune)
        except Exception as ex:
            print('error processing file:', args.execute, '\nexception\n', ex, 'n', rune_str)
    else:
        parser.print_help()
