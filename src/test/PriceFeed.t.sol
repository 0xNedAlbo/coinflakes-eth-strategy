// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import "forge-std/console2.sol";
import { Setup } from "./utils/Setup.sol";
import { CoinflakesEthStrategy } from "../CoinflakesEthStrategy.sol";

contract PriceFeedTest is Setup {
    function setUp() public virtual override {
        super.setUp();
    }

    function test_priceFeedIsBehind() public {
        priceFeed.update();
        skip(CoinflakesEthStrategy(address(strategy)).maxOracleDelay() + 1 minutes);
        airdrop(asset, user, 10_000 ether);

        vm.prank(user);
        asset.approve(address(strategy), 10_000 ether);

        vm.expectRevert(bytes("oracle out of date"));
        vm.prank(user);
        strategy.deposit(10_000 ether, user);
    }

    function test_priceFeedDifference() public {
        priceFeed.update();
        int256 price = priceFeed.latestAnswer();
        uint256 daiAmount = uint256(price) * 10 ** 10;

        airdrop(asset, user, daiAmount);

        vm.prank(user);
        asset.approve(address(strategy), daiAmount);
        vm.prank(management);
        CoinflakesEthStrategy(address(strategy)).setMaxSlippage(100_000_000);
        vm.prank(management);
        priceFeed.setLatestAnswer(price / 2);

        vm.expectRevert(bytes("oracle out of date"));
        vm.prank(user);
        strategy.deposit(daiAmount, user);
    }
}
