from hummingbot.strategy.strategy_base cimport StrategyBase
from hummingbot.market.market_base cimport MarketBase
from libc.stdint cimport int64_t

cdef class Execution2Strategy(StrategyBase):
    cdef:
        dict _market_infos

        int64_t _logging_options
        str _asset_symbol
