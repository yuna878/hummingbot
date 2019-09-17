from typing import (
    List,
    Tuple,
)

from hummingbot.strategy.market_symbol_pair import MarketSymbolPair
from hummingbot.strategy.execution_2 import (
    Execution2Strategy
)
from hummingbot.strategy.execution_2.execution_2_config_map import execution_2_config_map
from hummingbot.client.settings import (
    EXAMPLE_PAIRS,
)


def start(self):
    try:
        market = execution_2_config_map.get("market").value.lower()
        asset_symbol: str = execution_2_config_map.get("asset_symbol").value

        try:
            symbol_pair: str = EXAMPLE_PAIRS.get(market)
            symbol_split: Tuple[str, str] = self._initialize_market_assets(market, [symbol_pair])[0]
        except ValueError as e:
            self._notify(str(e))
            return

        market_names: List[Tuple[str, List[str]]] = [(market, [symbol_pair])]

        self._initialize_wallet(token_symbols=list(set(symbol_split)))
        self._initialize_markets(market_names)
        self.assets = set(symbol_split)

        maker_data = [self.markets[market], symbol_pair] + list(symbol_split)
        self.market_symbol_pairs = [MarketSymbolPair(*maker_data)]

        strategy_logging_options = Execution2Strategy.OPTION_LOG_ALL

        self.strategy = Execution2Strategy(market_infos=[MarketSymbolPair(*maker_data)],
                                           logging_options=strategy_logging_options,
                                           asset_symbol=asset_symbol)
    except Exception as e:
        self._notify(str(e))
        self.logger().error("Unknown error during initialization.", exc_info=True)
