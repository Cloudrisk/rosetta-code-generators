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

JSON_DIR = '/Users/dls/projects/rune/rune-common/serialization/src/test/resources/rune-serializer-round-trip-test/'

def deserialize(rune_string: str) -> BaseDataClass:
    '''generate a rune object from a string'''
    rune_dict = json.loads(rune_string)
    rune_model = rune_dict.pop('@model')
    rune_type = rune_dict.pop('@type')
    rune_model_version = rune_dict.pop('@version')
    rune_in = deserialize_from_dict(rune_type, rune_dict)
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
    rune_cls = getattr(rune_module, rune_class_name)
    # Ensure the class is a subclass of BaseDataClass (from the rune runtime)
    if not issubclass(rune_cls, BaseDataClass):
        raise TypeError(f"{rune_class_name} is not a subclass of BaseDataClass")
    rune_obj = rune_cls.model_validate(rune_dict)
    rune_obj.resolve_references()
    rune_obj.validate_model()
    return rune_obj

def serialize(rune_out: BaseDataClass) -> str:
    """
    serialize a rune object to a string
    
    :param rune_out - the item to be serialized.
    :return: a string
    """
    rune_dict_out = {'@model': rune_out.__class__.__module__.split('.')[0],
                     '@type': rune_out.__class__.__module__,
                     '@version': '0.0.0'}
    rune_dict_str = rune_out.model_dump_json(exclude_unset=True)
    rune_dict_out.update(json.loads(rune_dict_str))
    rune_string = json.dumps(rune_dict_out, indent=2, default=str)
    return rune_string

def extract_dir_and_file (path_name):
    return Path(path_name).parent.name + '/' + os.path.basename(path_name)

def process_file(path_name, only_serialize: bool = False) -> bool:
    '''process a file'''
    file_name =  extract_dir_and_file(path_name)
    try:
        json_str_in = Path(path_name).read_text(encoding='utf8')
        obj = deserialize(json_str_in)
        json_str_out = serialize(obj)
        if not only_serialize:
            dict_file_in = json.loads(json_str_in)
            dict_file_out = json.loads(json_str_out)
            result = dict_comp(dict_file_in, dict_file_out)
            result_str = 'serialization matches' if result else 'serialization does not match'
            print('.... processed file: ', file_name, ' result: ', result_str)
            return result
    except Exception as error_msg:
        print('.... something failed for file', file_name, ' exception:', error_msg)
        return False

def process_directory(dir_name):
    '''process all files in a directory'''
    path_names = glob.glob(dir_name + os.sep + '**/*.json', recursive=True)
    results = []
    for path_name in path_names:
        results.append({"path_name": path_name, "result": process_file (path_name)})
    print('---- result summary for dir:', dir_name)
    for result in results:
        file_name = extract_dir_and_file(result['path_name'])
        if (result['result']):
            print('file:', file_name, '...', 'serialization matches')
        else:
            print('file:', file_name, '...', 'something failed')
            process_file(result['path_name'])

def process_files(dir_name):
    '''skip tests and show deserialized and serialized data'''
    dir_files = glob.glob(dir_name + os.sep + '**/*.json', recursive=True)
    for dir_file in dir_files:
        json_str_in = Path(dir_file).read_text(encoding='utf8')
        obj = deserialize(json_str_in)
        json_str_out = serialize(obj)
        print ("json in:",json_str_in, "\njson_str_out:", json_str_out)

@pytest.mark.parametrize("json_file", glob.glob(JSON_DIR + os.sep + '**/*.json', recursive=True))
def test_json_file(json_file):
    '''Load data from the JSON file'''
    assert process_file(json_file), f"failed dict comparison for {json_file}"

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--test', help='Run Unit Tests', action="store_true")
    parser.add_argument('-p', '--process', help='Show Deserialized and Serialized Data')
    parser.add_argument('-f', '--file', help='Test a JSON File')
    parser.add_argument('-d', '--directory', help='Test All Files in a Directory')
    args = parser.parse_args()
    if args.test:
        print('run tests')
        pytest_args = ['-v', __file__]  # '-v' for verbose output, '__file__' to specify the current file
        pytest.main(pytest_args)
    elif args.process:
        print('process files')
        process_files(args.process)
    elif args.directory:
        print('testing files in the directory: ', args.directory)
        process_directory(args.directory)
    elif args.file:
        try:
            print('testing file: ', args.file)
            process_file(args.file)
        except Exception as error_msg:
            print ('procesing file:', args.file, ' created exception:', error_msg)
                        
    else:
        parser.print_help()
