// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { ISwapper } from "swap-helpers/src/interfaces/ISwapper.sol";
import { IAggregator } from "swap-helpers/src/interfaces/chainlink/IAggregator.sol";

contract MockEthPriceFeed is IAggregator {
    ISwapper public swap;

    constructor(address swapAddress) {
        swap = ISwapper(swapAddress);
    }

    function latestAnswer() external view override returns (int256) {
        return int256(swap.previewBuyB(1 ether) / 10 ** 10);
    }

    function latestTimestamp() external view override returns (uint256) {
        return block.timestamp;
    }

    function latestRound() external pure override returns (uint256) {
        revert("not implemented");
    }

    function getAnswer(uint256) external pure override returns (int256) {
        revert("not implemented");
    }

    function getTimestamp(uint256) external pure override returns (uint256) {
        revert("not implemented");
    }
}
