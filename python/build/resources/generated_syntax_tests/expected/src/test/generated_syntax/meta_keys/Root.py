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
from rune.runtime.base_data_class import BaseDataClass
from rune.runtime.metadata import *
from rune.runtime.utils import *
from rune.runtime.conditions import *
__all__ = ['Root']


class Root(BaseDataClass):
    nodeRef: Optional[test.generated_syntax.meta_keys.NodeRef.NodeRef] = Field(None, description='')
    attributeRef: Optional[test.generated_syntax.meta_keys.AttributeRef.AttributeRef] = Field(None, description='')
