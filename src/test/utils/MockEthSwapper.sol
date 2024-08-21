// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { IERC20, IWETH } from "swap-helpers/src/EthSwapper.sol";
import { ISwapper } from "swap-helpers/src/interfaces/ISwapper.sol";

contract MockEthSwapper is ISwapper {
    IERC20 public immutable DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public immutable WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address public tokenA = DAI;
    address public tokenB = WETH;

    constructor() {
        tokenA = DAI;
        tokenB = WETH;
    }

    function previewSellA(uint256 amountA) external view override returns (uint256) { }

    function previewSellB(uint256 amountB) external view override returns (uint256) { }

    function previewBuyA(uint256 amountA) external view override returns (uint256) { }

    function previewBuyB(uint256 amountB) external view override returns (uint256) { }

    function sellA(uint256 amountA, uint256 minAmountB, address receiver) external override returns (uint256) { }

    function sellB(uint256 amountB, uint256 minAmountA, address receiver) external override returns (uint256) { }

    function buyA(uint256 amountA, uint256 maxAmountB, address receiver) external override returns (uint256) { }

    function buyB(uint256 amountB, uint256 maxAmountA, address receiver) external override returns (uint256) { }
}
