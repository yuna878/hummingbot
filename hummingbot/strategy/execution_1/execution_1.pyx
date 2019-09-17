import logging
import pandas as pd
from typing import (
    List,
    Tuple,
    Optional,
    Dict
)

from hummingbot.logger import HummingbotLogger
from hummingbot.strategy.market_symbol_pair import MarketSymbolPair
from hummingbot.strategy.strategy_base import StrategyBase
from hummingbot.client.config.config_var import ConfigVar
from hummingbot.market.market_base cimport MarketBase
from hummingbot.core.utils.exchange_rate_conversion import ExchangeRateConversion


cdef class Execution1Strategy(StrategyBase):
    OPTION_LOG_NULL_ORDER_SIZE = 1 << 0
    OPTION_LOG_REMOVING_ORDER = 1 << 1
    OPTION_LOG_ADJUST_ORDER = 1 << 2
    OPTION_LOG_CREATE_ORDER = 1 << 3
    OPTION_LOG_MAKER_ORDER_FILLED = 1 << 4
    OPTION_LOG_STATUS_REPORT = 1 << 5
    OPTION_LOG_MAKER_ORDER_HEDGED = 1 << 6
    OPTION_LOG_ALL = 0x7fffffffffffffff
    CANCEL_EXPIRY_DURATION = 60.0

    @classmethod
    def logger(cls) -> HummingbotLogger:
        global ds_logger
        if ds_logger is None:
            ds_logger = logging.getLogger(__name__)
        return ds_logger

    def __init__(self,
                 market_infos: List[MarketSymbolPair],
                 asset_symbol: str,
                 logging_options: int = OPTION_LOG_ALL,):

        if len(market_infos) < 1:
            raise ValueError(f"market_infos must not be empty.")

        super().__init__()
        self._market_infos = {
            (market_info.market, market_info.trading_pair): market_info
            for market_info in market_infos
        }
        self._logging_options = logging_options
        self._asset_symbol = asset_symbol

        cdef:
            set all_markets = set([market_info.market for market_info in market_infos])

        self.c_add_markets(list(all_markets))

    def format_status(self) -> str:
        cdef:
            list lines = []
            MarketBase market
            double balance
            double asset_conversion_rate
            list assets_data = []
            list assets_columns = ["Market", "Asset", "Total Balance", "Available Balance", "Conversion Rate"]

        for market_info in self._market_infos.values():
            market, trading_pair, _, _ = market_info
            balance = market.get_balance(self._asset_symbol)
            available_balance = market.get_available_balance(self._asset_symbol)
            asset_conversion_rate = ExchangeRateConversion.get_instance().adjust_token_rate(self._asset_symbol, 1.0)
            assets_data.extend([
                [market.display_name, self._asset_symbol, balance, available_balance, asset_conversion_rate],
            ])

        assets_df = pd.DataFrame(data=assets_data, columns=assets_columns)
        lines.extend(["", "  Assets:"] + ["    " + line for line in str(assets_df).split("\n")])

        return "\n".join(lines)
