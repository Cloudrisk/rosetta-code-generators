'''sort unit test'''
import pytest

from rosetta_dsl.test.semantic.sum_operator.SumTest import SumTest

def test_sum_passes():
    sum_test = SumTest(aValue=2, bValue=3, target=5)
    sum_test.validate_model()
def test_sum_fails():
    sum_test=SumTest(aValue=1, bValue=5, target=7)
    with pytest.raises(Exception):
        sum_test.validate_model()

if __name__ == "__main__":
    test_sum_passes()
