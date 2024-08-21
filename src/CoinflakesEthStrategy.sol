// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import { console } from "forge-std/console.sol";

import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { BaseStrategy } from "@tokenized-strategy/BaseStrategy.sol";

import { IAggregator } from "swap-helpers/src/interfaces/chainlink/IAggregator.sol";
import { ISwapper } from "swap-helpers/src/interfaces/ISwapper.sol";
import { SwapMath } from "swap-helpers/src/utils/SwapMath.sol";

contract CoinflakesEthStrategy is BaseStrategy {
    using SafeERC20 for IERC20;
    using SafeERC20 for ERC20;

    uint256 public constant MAX_BPS = 10_000_000_000; // 10000 BPS
    ISwapper public swap;
    IAggregator public priceFeed;

    IERC20 public WETH = IERC20(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    uint256 maxSlippage = 100_000_000; // 100 BPS
    uint256 maxOracleDelay = 30 minutes;

    event SwapChange(address indexed newSwap);
    event MaxSlippageChange(uint256 maxSlippage);
    event PriceFeedChange(address indexed priceFeed);
    event MaxOracleDelayChange(uint256 newDelay);

    modifier withOracleSynced() {
        require(priceFeed.latestTimestamp() > block.timestamp - maxOracleDelay, "oracle out of date");
        _;
    }

    constructor(
        address swapAddress,
        address priceFeedAddress
    )
        BaseStrategy(0x6B175474E89094C44Da98b954EedeAC495271d0F, "Coinflakes Eth Strategy")
    {
        swap = ISwapper(swapAddress);
        priceFeed = IAggregator(priceFeedAddress);
    }

    function _deployFunds(uint256 daiAmount) internal override withOracleSynced {
        // Compare swap offer to market price
        int256 marketPrice = priceFeed.latestAnswer();
        require(marketPrice > 0, "invalid price from oracle");
        uint256 marketQuote = daiAmount * (10 ** 8) / uint256(marketPrice);
        uint256 swapQuote = swap.previewSellA(daiAmount);
        require(SwapMath.sellSlippage(marketQuote, swapQuote) <= maxSlippage, "difference from oracle too high");
        // Swap tokens
        asset.safeTransferFrom(msg.sender, address(this), daiAmount);
        asset.approve(address(swap), daiAmount);
        swap.sellA(daiAmount, 1, address(this));
    }

    function _freeFunds(uint256 daiAmount) internal override withOracleSynced {
        // Compare swap off to market price
        int256 marketPrice = priceFeed.latestAnswer();
        require(marketPrice > 0, "invalid price from oracle");
        uint256 swapQuote = swap.previewBuyA(daiAmount);
        uint256 wethBalance = WETH.balanceOf(address(this));
        uint256 marketQuote = daiAmount * (10 ** 8) / uint256(marketPrice);
        require(SwapMath.buySlippage(marketQuote, swapQuote) <= maxSlippage, "difference from oracle too high");
        // Swap tokens
        if (swapQuote <= wethBalance) {
            WETH.approve(address(swap), swapQuote);
            swap.buyA(daiAmount, swapQuote, address(this));
        } else {
            // If there is not enough WETH in the strategy,
            // just sell everything.
            WETH.approve(address(swap), wethBalance);
            swap.sellB(wethBalance, 1, address(this));
        }
    }

    function _harvestAndReport() internal view override withOracleSynced returns (uint256 _totalAssets) {
        uint256 wethBalance = WETH.balanceOf(address(this));
        _totalAssets = swap.previewSellB(wethBalance);
        // Compare swap price to market price
        int256 marketPrice = priceFeed.latestAnswer();
        require(marketPrice > 0, "invalid price from oracle");
        uint256 marketQuote = _totalAssets * (10 ** 8) / uint256(marketPrice);
        require(SwapMath.sellSlippage(marketQuote, _totalAssets) <= maxSlippage, "difference from oracle too high");
    }

    function changeSwap(address newSwap) public onlyManagement {
        swap = ISwapper(newSwap);
        emit SwapChange(address(swap));
    }

    function setMaxSlippage(uint256 newMaxSlippage) public onlyManagement {
        maxSlippage = newMaxSlippage;
        emit MaxSlippageChange(maxSlippage);
    }

    function setPriceFeed(address newPriceFeed) public onlyManagement {
        priceFeed = IAggregator(newPriceFeed);
        emit PriceFeedChange(address(priceFeed));
    }

    function setMaxOracleDelay(uint256 newDelay) public onlyManagement {
        maxOracleDelay = newDelay;
        emit MaxOracleDelayChange(maxOracleDelay);
    }
}
