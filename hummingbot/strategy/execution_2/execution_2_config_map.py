from hummingbot.client.config.config_var import ConfigVar
from hummingbot.client.config.config_validators import (
    is_exchange,
)
from hummingbot.client.settings import (
    required_exchanges,
    EXAMPLE_PAIRS,
)


def symbol_prompt():
    market = execution_2_config_map.get("market").value
    example = EXAMPLE_PAIRS.get(market)
    return "Enter the token symbol to fetch its order book on %s%s >>> " \
           % (market, f" (e.g. {example})" if example else "")


execution_2_config_map = {
    "market": ConfigVar(key="market",
                        prompt="Enter the name of the exchange >>> ",
                        validator=is_exchange,
                        on_validated=lambda value: required_exchanges.append(value)),
    "asset_symbol": ConfigVar(key="asset_symbol",
                              prompt=symbol_prompt)
}
