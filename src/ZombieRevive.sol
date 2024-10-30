// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

error ZombieRevive__NotOwner();

contract ZombieRevive {
    mapping(address => uint256) private s_playerToRevivesOwned;
    address[] private s_players;

    address private immutable i_owner;
    IERC20 private immutable i_usdc;
    uint256 public s_revivePriceUsd;

    event RevivePurchased(address indexed player, uint256 amount);
    event ReviveUsed(address indexed player);

    constructor(address usdcAddress, uint256 initialRevivePrice) {
        i_owner = msg.sender;
        i_usdc = IERC20(usdcAddress);
        s_revivePriceUsd = initialRevivePrice;
    }

    function buyRevives(uint256 amount) public {
        uint256 totalCost = amount * s_revivePriceUsd;
        require(i_usdc.balanceOf(msg.sender) >= totalCost, "Not enough USDC!");
        require(i_usdc.transferFrom(msg.sender, address(this), totalCost), "USDC transfer failed!");
        
        s_playerToRevivesOwned[msg.sender] += amount;
        
        if (s_playerToRevivesOwned[msg.sender] == amount) {
            s_players.push(msg.sender);
        }
        
        emit RevivePurchased(msg.sender, amount);
    }

    function useRevive() external {
        require(s_playerToRevivesOwned[msg.sender] > 0, "No revives available!");
        s_playerToRevivesOwned[msg.sender] -= 1;
        emit ReviveUsed(msg.sender);
    }

    function getRevivesOwned() external view returns (uint256) {
        return s_playerToRevivesOwned[msg.sender];
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) revert ZombieRevive__NotOwner();
        _;
    }

    function withdraw() public onlyOwner {
        uint256 balance = i_usdc.balanceOf(address(this));
        require(i_usdc.transfer(msg.sender, balance), "USDC transfer failed");
    }

    function setRevivePrice(uint256 newPrice) external onlyOwner {
        s_revivePriceUsd = newPrice;
    }

    function getPlayerRevives(address player) external view returns (uint256) {
        return s_playerToRevivesOwned[player];
    }

    function getPlayer(uint256 index) external view returns (address) {
        return s_players[index];
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getUsdcAddress() external view returns (address) {
        return address(i_usdc);
    }
}

//view/pure





// Concepts we didn't cover yet (will cover in later sections)
// 1. Enum
// 2. Events
// 3. Try / Catch
// 4. Function Selector
// 5. abi.encode / decode
// 6. Hash with keccak256
// 7. Yul / Assembly