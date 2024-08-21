// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { StdCheats } from "forge-std/StdCheats.sol";
import { IERC20, IWETH } from "mock-tokens/src/interfaces/IWETH.sol";
import { ISwapper } from "swap-helpers/src/interfaces/ISwapper.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract MockEthSwapper is StdCheats, ISwapper {
    using SafeERC20 for IERC20;
    using SafeERC20 for IWETH;

    IERC20 public immutable DAI = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
    IWETH public immutable WETH = IWETH(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    address public tokenA = address(DAI);
    address public tokenB = address(WETH);

    uint256 public ethPrice = 2500 * (10 ** 18);

    function previewSellA(uint256 amountA) public view override returns (uint256) {
        return amountA * (10 ** 18) / ethPrice;
    }

    function previewSellB(uint256 amountB) public view override returns (uint256) {
        return amountB * ethPrice / (10 ** 18);
    }

    function previewBuyA(uint256 amountA) public view override returns (uint256) {
        return amountA * (10 ** 18) / ethPrice;
    }

    function previewBuyB(uint256 amountB) public view override returns (uint256) {
        return amountB * ethPrice / (10 ** 18);
    }

    function sellA(uint256 amountA, uint256 minAmountB, address receiver) public override returns (uint256 amountOut) {
        amountOut = previewSellA(amountA);
        require(amountOut >= minAmountB, "slippage");
        DAI.safeTransferFrom(msg.sender, address(this), amountA);
        deal(address(this), amountOut);
        WETH.deposit{ value: amountOut }();
        WETH.transfer(receiver, amountOut);
    }

    function sellB(uint256 amountB, uint256 minAmountA, address receiver) public override returns (uint256 amountOut) {
        amountOut = previewSellB(amountB);
        require(amountOut >= minAmountA, "slippage");
        WETH.safeTransferFrom(msg.sender, address(this), amountB);
        deal(address(DAI), address(this), amountOut);
        DAI.transfer(receiver, amountOut);
    }

    function buyA(uint256 amountA, uint256 maxAmountB, address receiver) public override returns (uint256 amountIn) {
        amountIn = previewBuyA(amountA);
        require(amountIn <= maxAmountB, "slippage");
        WETH.safeTransferFrom(msg.sender, address(this), amountIn);
        deal(address(DAI), address(this), amountA);
        DAI.transfer(receiver, amountA);
    }

    function buyB(uint256 amountB, uint256 maxAmountA, address receiver) public override returns (uint256 amountIn) {
        amountIn = previewBuyB(amountB);
        require(amountIn <= maxAmountA, "slippage");
        DAI.safeTransferFrom(msg.sender, address(this), amountIn);
        deal(address(this), amountB);
        WETH.deposit{ value: amountB }();
        WETH.transfer(receiver, amountB);
    }

    function setEthPrice(uint256 newPrice) public {
        ethPrice = newPrice;
    }
}
