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

ROSETTARUNTIMEDIR="../../src/main/resources/runtime"
SERIALIZATIONTESTSDIR="../../target/serialization_unit_tests"
echo "**** Install Dependencies ****"
$PYEXE -m pip install "pydantic>=2.6.1,<2.10"
$PYEXE -m pip install pytest
echo "**** Install Runtime ****"
$PYEXE -m pip install $MYPATH/$ROSETTARUNTIMEDIR/rosetta_runtime-2.1.0-py3-none-any.whl --force-reinstall
echo "**** Build and Install Helper ****"
cd $MYPATH/test_helper
$PYEXE -m pip wheel --no-deps --only-binary :all: . || processError
$PYEXE -m pip install test_helper-0.0.0-py3-none-any.whl
rm test_helper-0.0.0-py3-none-any.whl

echo "**** Build and Install Generated Unit Tests ****"
cd $MYPATH/$SERIALIZATIONTESTSDIR
$PYEXE -m pip wheel --no-deps --only-binary :all: . || processError
$PYEXE -m pip install python_*-0.0.0-py3-none-any.whl
cd $MYPATH
# run tests
$PYEXE -m pytest -p no:cacheprovider .
# rm -rf .pytest