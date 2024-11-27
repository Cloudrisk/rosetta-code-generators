#!/bin/bash
MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
cd $MYPATH
./runtime_tests/run_runtime_tests.sh
./rosetta_tests/run_rosetta_tests.sh
