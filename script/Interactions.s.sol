// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {ZombieRevive} from "../src/ZombieRevive.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

contract BuyRevives is Script {
    uint256 constant REVIVE_AMOUNT = 1;

    function buyRevives(address zombieReviveAddress) public {
        ZombieRevive zombieRevive = ZombieRevive(zombieReviveAddress);
        IERC20 usdc = IERC20(zombieRevive.getUsdcAddress());
        
        vm.startBroadcast();
        usdc.approve(zombieReviveAddress, zombieRevive.s_revivePriceUsd() * REVIVE_AMOUNT);
        zombieRevive.buyRevives(REVIVE_AMOUNT);
        vm.stopBroadcast();
        
        console.log("Bought %s revives", REVIVE_AMOUNT);
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "ZombieRevive",
            block.chainid
        );
        buyRevives(mostRecentlyDeployed);
    }
}

contract UseRevive is Script {
    function useRevive(address zombieReviveAddress) public {
        vm.startBroadcast();
        ZombieRevive(zombieReviveAddress).useRevive();
        vm.stopBroadcast();
        console.log("Used a revive!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "ZombieRevive",
            block.chainid
        );
        useRevive(mostRecentlyDeployed);
    }
}

contract WithdrawUSDC is Script {
    function withdrawUSDC(address zombieReviveAddress) public {
        vm.startBroadcast();
        ZombieRevive(zombieReviveAddress).withdraw();
        vm.stopBroadcast();
        console.log("Withdrawn USDC balance!");
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "ZombieRevive",
            block.chainid
        );
        withdrawUSDC(mostRecentlyDeployed);
    }
}