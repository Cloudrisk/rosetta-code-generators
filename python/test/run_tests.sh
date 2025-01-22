#!/bin/bash
type -P python > /dev/null && PYEXE=python || PYEXE=python3
if ! $PYEXE -c 'import sys; assert sys.version_info >= (3,10)' > /dev/null 2>&1; then
        echo "Found $($PYEXE -V)"
        echo "Expecting at least python 3.10 - exiting!"
        exit 1
fi

export PYTHONDONTWRITEBYTECODE=1

MYPATH="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
ACDIR=$($PYEXE -c "import sys;print('Scripts' if sys.platform.startswith('win') else 'bin')")
$PYEXE -m venv --clear $MYPATH/.pytest
source $MYPATH/.pytest/$ACDIR/activate

RUNTIMENEW="/Users/dls/projects/rune/rune-python-runtime"
ROSETTARUNTIMEDIR="../src/main/resources/runtime"
PYTHONCDMDIR="../target/python"
PYTHONUNITTESTDIR="../target/python/unit_tests"
echo "**** Install Runtime ****"
$PYEXE -m pip install $RUNTIMENEW/rune.runtime*-py3-*.whl --force-reinstall
echo "**** Build and Install Generated Unit Tests ****"
cd $MYPATH/$PYTHONUNITTESTDIR
$PYEXE -m pip wheel --no-deps --only-binary :all: . || processError
$PYEXE -m pip install python_rosetta_dsl-0.0.0-py3-none-any.whl
cd $MYPATH

# run tests
echo "**** Install pytest ****"
$PYEXE -m pip install pytest
$PYEXE -m pytest -p no:cacheprovider $MYPATH/rosetta_tests 

rm -rf .pytest