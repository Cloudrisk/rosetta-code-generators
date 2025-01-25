'''run serialization unit tests'''
from pathlib import Path
import os
import json
import importlib
import glob
import argparse
import pytest

from rune.runtime.base_data_class import BaseDataClass
from test_helper.test_helper.dict_comp import dict_comp

JSON_DIR = '/Users/dls/projects/rune/rune-common/serialization/src/test/resources/rune-serializer-round-trip-test/enumtypes/'

def deserialize (rune_string: str) -> BaseDataClass:
    '''generate a rune object from a string'''
    rune_dict = json.loads(rune_string)
    rune_model = rune_dict.pop('@model')
    rune_type = rune_dict.pop('@type')
    rune_model_version = rune_dict.pop('@version')
    rune_in = deserialize_from_dict (rune_type, rune_dict)
    return rune_in

def deserialize_from_dict(rune_type: str, rune_dict: dict) -> BaseDataClass:
    """
    Create an object of the specified class from a dictionary.
    
    :param class_path: Fully qualified class path (e.g., 'module.submodule.ClassName').
    :param data: Dictionary containing the data to initialize the object.
    :return: An instance of the specified class.
    """
    # Import the module and get the class
    rune_class_name = rune_type.rsplit('.')[-1]
    rune_module = importlib.import_module(rune_type)
    print ('.... rune_type:' + rune_type)
    rune_cls = getattr(rune_module, rune_class_name)

    # Ensure the class is a subclass of BaseDataClass (from the rune runtime)
    if not issubclass(rune_cls, BaseDataClass):
        raise TypeError(f"{rune_class_name} is not a subclass of BaseDataClass")

#    rune_dict_str = json.dumps(rune_dict);
#    rune_obj = rune_cls.model_validate_json(rune_dict_str)
    rune_obj = rune_cls.model_validate (rune_dict)
    print ('.... model_validate done')
    rune_obj.resolve_references()
    print ('.... resolve_references done')
    rune_obj.validate_model()
    print ('.... validate_model done')
    return rune_obj

def serialize (rune_out: BaseDataClass) -> str:
    """
    serialize a rune object to a string
    
    :param rune_out - the item to be serialized.
    :return: a string
    """
    rune_dict_out = {'@model': rune_out.__class__.__module__.split('.')[0],
                     '@type': rune_out.__class__.__module__,
                     '@version': '0.0.0'}
    rune_dict_out.update(rune_out.model_dump(exclude_unset=True))
    rune_string = json.dumps(rune_dict_out, indent=2, default=str)
    return rune_string

json_files = glob.glob(JSON_DIR + os.sep + '**/*.json', recursive = True)
inscope_files = []

def process_file(file_name, only_serialize: bool = False):
    '''process a file'''
    print('.... processing file: ', file_name)
    try:
        json_str_in = Path(file_name).read_text(encoding='utf8')
        obj = deserialize(json_str_in)
        json_str_out = serialize(obj)
        if (not only_serialize):
            dict_file_in = json.loads(json_str_in)
            dict_file_out = json.loads(json_str_out)
            assert dict_comp(dict_file_in, dict_file_out), f"failed dict comparison for {file_name}"
    except Exception as error_msg:
        print(error_msg)
    
def process_directory(dir_name, only_serialize: bool = False):
    '''process all files in a directory'''
    dir_files = glob.glob(dir_name + os.sep + '**/*.json', recursive = True)
    for dir_file in dir_files:
        process_file(dir_file, only_serialize)
    
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

@pytest.mark.parametrize("json_file", json_files)
def test_json_file(json_file):
    '''Load data from the JSON file'''
    json_file_name = json_file.split(os.sep)[-1]
    if len(inscope_files) == 0 or json_file_name in inscope_files:
        process_file(os.path.join(JSON_DIR, json_file))
    else:
        assert False, f"test not implemented for {json_file}"

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--test', help='Run Unit Tests', action="store_true")
    parser.add_argument('-p', '--process', 
                        help='Show Deserialized and Serialized Data', 
                        action="store_true")
    parser.add_argument('-f', '--file', help='Test a JSON File')
    parser.add_argument('-d', 
                        '--directory', 
                        help='Test All Files in a Directory')
    args = parser.parse_args()
    if args.test:
        print('run tests')
        pytest_args = ['-v', __file__]  # '-v' for verbose output, '__file__' to specify the current file
        pytest.main(pytest_args)
    elif args.process:
        print('process files')
        process_files()
    elif args.directory:
        print('testing files in the directory: ', args.directory)
        process_directory(args.directory)
    elif args.file:
        print('testing file: ', args.file)
        process_file (args.file)
        rune_str = Path(args.file).read_text(encoding='utf8')
    else:
        parser.print_help()
