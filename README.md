# Tokenized ETH Strategy for Coinflakes DAO

This is an implementation of a Yearn V3 tokenized strategy.

For a more complete overview of how the Tokenized Strategies work please visit the [TokenizedStrategy Repo](https://github.com/yearn/tokenized-strategy).

## How to start

For instructions see [https://github.com/yearn/tokenized-strategy](https://github.com/yearn/tokenized-strategy).

## Strategy

This strategy swaps the allocated funds for WETH through Curve. It uses a Chainlink oracle to check for deviations from the current ETH market price when performing swaps and reports as a safeguard.
