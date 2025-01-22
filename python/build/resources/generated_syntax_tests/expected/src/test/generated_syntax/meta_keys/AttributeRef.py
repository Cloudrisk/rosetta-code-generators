# pylint: disable=line-too-long, invalid-name, missing-function-docstring
# pylint: disable=bad-indentation, trailing-whitespace, superfluous-parens
# pylint: disable=wrong-import-position, unused-import, unused-wildcard-import
# pylint: disable=wildcard-import, wrong-import-order, missing-class-docstring
# pylint: disable=missing-module-docstring
from __future__ import annotations
from typing import Optional
import datetime
import inspect
from decimal import Decimal
from pydantic import Field
from rosetta.runtime.utils import (
    BaseDataClass, rosetta_condition, rosetta_resolve_attr, rosetta_resolve_deep_attr
)
from rosetta.runtime.utils import *

__all__ = ['AttributeRef']


class AttributeRef(BaseDataClass):
    dateField: Optional[Annotated[DateWithMeta, DateWithMeta.serializer(), DateWithMeta.validator(('@key'))]] = Field(None, description='')
    dateReference: Optional[Annotated[DateWithMeta, DateWithMeta.serializer(), DateWithMeta.validator(('@ref'))]] = Field(None, description='')
