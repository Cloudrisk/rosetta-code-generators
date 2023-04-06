import pytest
from cdm.product.asset.RateSpecification import RateSpecification
import sys,os
dirPath = os.path.dirname(__file__)
sys.path.append(os.path.join(dirPath))

from cdm_comparison_test import cdm_comparison_test_from_file
def test_rate_specification ():
	cdm_comparison_test_from_file(dirPath + '/json-samples/original_RateSpecification.json', RateSpecification)

if __name__ == "__main__":
	test_rate_specification()