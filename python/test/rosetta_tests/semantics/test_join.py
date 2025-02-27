from rosetta_dsl.test.semantic.join_operator.JoinTest import JoinTest
import pytest
def test_join_operator_passes():
    jtest= JoinTest(field1="a",field2="b")
    jtest.validate_model()

def test_join_operator_fails():
    jtest= JoinTest(field1="a",field2="c")
    with pytest.raises(Exception):
        jtest.validate_model()