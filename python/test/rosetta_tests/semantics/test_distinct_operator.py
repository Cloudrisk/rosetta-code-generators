from __future__ import annotations
'''filter unit tests'''
import pytest
from enum import Enum
from typing import List, Optional
import datetime
import inspect
from decimal import Decimal
from pydantic import Field
from rosetta.runtime.utils import (
    BaseDataClass, rosetta_condition, rosetta_resolve_attr, rosetta_resolve_deep_attr
)
from rosetta.runtime.utils import *

## distinct fails --> unhashable type
class BCenters(BaseDataClass):
    """
    Test class business centers enum
    """
    name: Optional[str] = Field(None, description="")


__all__ = ['DistincTest']


class DistincTest(BaseDataClass):
    """
    Class to test distinct in a condition
    """
    bcenters: List[BCenters] = Field([], description="")
    """
    """
    field1: Optional[int] = Field(None, description="")
    """
    """

    @rosetta_condition
    def condition_0_TestCond(self):
        """
        Test condition
        """
        item = self

        def _then_fn0():
            return True

        def _else_fn0():
            return False

        return if_cond_fn(((rosetta_attr_exists(rosetta_resolve_attr(self, "field1")) and set(
            rosetta_resolve_attr(self, "bcenters"))) and all_elements(
            rosetta_count(rosetta_resolve_attr(self, "bcenters")), "=", 5)), _then_fn0, _else_fn0)


def test_distinct():
    bc1=BCenters(name="CAMO")
    bc2=BCenters(name="CAOT")
    bc3=BCenters(name="CATO")
    bc4=BCenters(name="CAVA")
    bc5=BCenters(name="CAWI")
    dtest=DistincTest(bcenters=[bc1,bc2,bc3,bc4,bc4,bc5],field1=2)
    with pytest.raises(Exception):
        dtest.validate_model()