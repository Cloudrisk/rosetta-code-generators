'''run serialization unit tests'''
from pathlib import Path
import os
import json
import glob
import argparse
import pytest

from rune.runtime.base_data_class import BaseDataClass
from test_helper.test_helper.dict_comp import dict_comp

JSON_DIR = '/Users/dls/projects/rune/rune-common/serialization/src/test/resources/rune-serializer-round-trip-test/'

def extract_dir_and_file (path_name):
    return Path(path_name).parent.name + '/' + os.path.basename(path_name)

def process_file(path_name, compare: bool = True) -> bool:
    '''process a file'''
    file_name =  extract_dir_and_file(path_name)
    try:
        json_str_in = Path(path_name).read_text(encoding='utf8')
        obj = BaseDataClass().rune_deserialize(json_str_in)
        json_str_out = obj.rune_serialize()
        if compare:
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

@pytest.mark.parametrize("json_file", glob.glob(JSON_DIR + os.sep + '**/*.json', recursive=True))
def test_json_file(json_file):
    '''Load data from the JSON file'''
    assert process_file(json_file), f"failed dict comparison for {json_file}"

if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument('-t', '--test', help='Run Unit Tests', action="store_true")
    parser.add_argument('-f', '--file', help='Test a JSON File')
    parser.add_argument('-d', '--directory', help='Test All Files in a Directory')
    args = parser.parse_args()
    if args.test:
        print('run tests')
        pytest_args = ['-v', __file__]  # '-v' for verbose output, '__file__' to specify the current file
        pytest.main(pytest_args)
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
