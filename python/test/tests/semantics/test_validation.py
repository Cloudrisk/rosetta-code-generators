# pylint: disable=unused-import,missing-function-docstring,invalid-name
from datetime import date
from cdm.event.common.Trade import Trade
from cdm.event.common.TradeIdentifier import TradeIdentifier
from cdm.product.template.TradableProduct import TradableProduct
from cdm.product.template.Product import Product
from cdm.product.template.TradeLot import TradeLot


def test_trade():
    product = Product()
    tradeLot = TradeLot()
    tradableProduct = TradableProduct(product=product)
    tradeIdentifier=[TradeIdentifier(issuer='Acme Corp')]

    t = Trade(
        tradeDate=date(2023, 1, 1),
        tradableProduct=tradableProduct,
        tradeIdentifier=tradeIdentifier
    )
    exceptions = t.validate_model(raise_exc=False)
    print(exceptions)
    print('Done!')


if __name__ == '__main__':
    test_trade()

# EOF
