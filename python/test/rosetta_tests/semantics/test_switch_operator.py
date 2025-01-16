'''switch unit tests'''
import pytest

from rosetta_dsl.test.semantic.switch_operator.SwitchTest import SwitchTest
from rosetta_dsl.test.semantic.switch_operator.SwitchChoiceGuardTest import SwitchChoiceGuardTest
from rosetta_dsl.test.semantic.switch_operator.TestCriteria import TestCriteria
from rosetta_dsl.test.semantic.switch_operator.AllCriteria import AllCriteria
from rosetta_dsl.test.semantic.switch_operator.AnyCriteria import AnyCriteria
from rosetta_dsl.test.semantic.switch_operator.NegativeCriteria import NegativeCriteria

def test_switch_passes():
    switch_test= SwitchTest(a=2)
    switch_test.validate_model()

def test_switch_fails ():
    switch_test = SwitchTest(a=-1)
    with pytest.raises(Exception):
        switch_test.validate_model()

def test_switch_choice_guard_passes():
    all_criteria= AllCriteria()
    input_criteria=TestCriteria(AllCriteria=all_criteria)
    switch_choice_guard_test= SwitchChoiceGuardTest(inputCriteria=input_criteria)
    switch_choice_guard_test.validate_model()
def test_switch_choice_guard_fails ():
    input_criteria = TestCriteria()
    switch_choice_guard_test = SwitchChoiceGuardTest(inputCriteria=input_criteria)
    with pytest.raises(Exception):
        switch_choice_guard_test.validate_model()

if __name__ == "__main__":
    test_switch_passes()
    test_switch_fails()
    test_switch_choice_guard_passes()