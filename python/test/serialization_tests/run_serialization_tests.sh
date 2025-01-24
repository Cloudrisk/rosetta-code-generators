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
rm -rf $MYPATH/.pytest
$PYEXE -m venv --clear $MYPATH/.pytest
source $MYPATH/.pytest/$ACDIR/activate

RUNERUNTIMEDIR="../../../../../../rune-python-runtime"
SERIALIZATIONTESTSDIR="../../target/python/serialization_unit_tests"
echo "**** Install Runtime ****"
$PYEXE -m pip install $MYPATH/$RUNERUNTIMEDIR/rune.runtime*-py3-*.whl --force-reinstall
echo "**** Build and Install Helper ****"
cd $MYPATH/test_helper
$PYEXE -m pip wheel --no-deps --only-binary :all: . || processError
$PYEXE -m pip install test_helper-0.0.0-py3-none-any.whl
rm test_helper-0.0.0-py3-none-any.whl

echo "**** Build and Install Generated Unit Tests ****"
$PYEXE -m pip install pytest
cd $MYPATH/$SERIALIZATIONTESTSDIR
$PYEXE -m pip wheel --no-deps --only-binary :all: . || processError
$PYEXE -m pip install python_*-0.0.0-py3-none-any.whl
cd $MYPATH
# run tests
$PYEXE -m pytest -p no:cacheprovider .
# rm -rf .pytest