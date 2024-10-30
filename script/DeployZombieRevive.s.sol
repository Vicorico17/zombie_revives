// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {ZombieRevive} from "../src/ZombieRevive.sol";
import {Script} from "lib/forge-std/src/Script.sol";

contract DeployZombieRevive is Script {
    function run() external returns (ZombieRevive) {
        // You'll need to replace these values with your actual requirements
        address usdcAddress = 0x41E94Eb019C0762f9Bfcf9Fb1E58725BfB0e7582; // Replace with actual USDC address for your network
        uint256 initialRevivePrice = 1e6; // 1 USDC (6 decimals)
        
        vm.startBroadcast();
        ZombieRevive zombieRevive = new ZombieRevive(usdcAddress, initialRevivePrice);
        vm.stopBroadcast();
        
        return zombieRevive;
    }
}
