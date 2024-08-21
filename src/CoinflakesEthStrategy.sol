// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { console } from "forge-std/console.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { BaseStrategy } from "@tokenized-strategy/BaseStrategy.sol";

import { ISwapper } from "swap-helpers/src/interfaces/ISwapper.sol";

contract CoinflakesEthStrategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeERC20 for ERC20;

    ISwapper public swap;
    IERC20 public WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);

    uint256 maxSlippage = 5_000_000;

    event SwapChange(address indexed newSwap);
    event MaxSlippageChange(uint256 maxSlippage);

    constructor(
        address swapAddress
    )
        BaseStrategy(0x6B175474E89094C44Da98b954EedeAC495271d0F, "Coinflakes Eth Strategy")
    {
        swap = ISwapper(swapAddress);
    }

    function _deployFunds(uint256 daiAmount) internal override {
        asset.safeTransferFrom(msg.sender, address(this), daiAmount);
        asset.approve(address(swap), daiAmount);
        swap.sellA(daiAmount, 1, address(this));
    }

    function _freeFunds(uint256 daiAmount) internal override {
        uint256 wethAmount = swap.previewBuyA(daiAmount);
        uint256 wethBalance = WETH.balanceOf(address(this));
        console.log("dai amount: ", daiAmount);
        console.log("weth amount: ", wethAmount);
        console.log("weth balance: ", wethBalance);
        if (wethAmount <= wethBalance) {
            WETH.approve(address(swap), wethAmount);
            swap.buyA(daiAmount, wethAmount, address(this));
        } else {
            WETH.approve(address(swap), wethBalance);
            swap.sellB(wethBalance, 1, address(this));
        }
    }

    function _harvestAndReport() internal view override returns (uint256 _totalAssets) {
        uint256 wethBalance = WETH.balanceOf(address(this));
        _totalAssets = swap.previewSellB(wethBalance);
    }

    function changeSwap(address newSwap) public onlyManagement {
        swap = ISwapper(newSwap);
        emit SwapChange(address(swap));
    }

    function setMaxSlippage(uint256 newMaxSlippage) public onlyManagement {
        maxSlippage = newMaxSlippage;
        emit MaxSlippageChange(maxSlippage);
    }
}
