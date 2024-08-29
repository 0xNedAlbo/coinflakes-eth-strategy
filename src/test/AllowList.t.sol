// SPDX-License-Identifier: MIT
pragma solidity >=0.8.18;

import "forge-std/src/console2.sol";

import { Setup, ERC20, IStrategyInterface } from "./utils/Setup.sol";
import { Slippage } from "swap-helpers/src/utils/Slippage.sol";

import { CoinflakesEthStrategy, IERC20 } from "../CoinflakesEthStrategy.sol";

contract ShutdownTest is Setup {
    using Slippage for uint256;

    function setUp() public virtual override {
        super.setUp();
    }

    function test_unallowed_deposits(address depositor) public {
        vm.assume(depositor != user);
        airdrop(asset, depositor, minFuzzAmount);

        vm.prank(depositor);
        IERC20(asset).approve(depositor, minFuzzAmount);

        vm.expectRevert("ERC4626: deposit more than max");
        vm.prank(depositor);
        strategy.deposit(minFuzzAmount, depositor);
    }
}
