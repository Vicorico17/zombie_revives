`// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {AggregatorV3Interface} from "lib/chainlink-brownie-contracts/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol"; 
import {PriceConverter} from "./PriceConverter.sol";

error ZombieRevive__NotOwner();

contract ZombieRevive {
    using PriceConverter for uint256;

    mapping(address => uint256) private s_playerToRevivesOwned;
    address[] private s_players;

    address private immutable i_owner;
    uint256 public constant REVIVE_PRICE_USD = 1 * 10 ** 18;

    AggregatorV3Interface private s_priceFeed;

    event RevivePurchased(address indexed player, uint256 amount);
    event ReviveUsed(address indexed player);

    constructor(address priceFeedAddress) {
        i_owner = msg.sender;
        s_priceFeed = AggregatorV3Interface(priceFeedAddress);
    }

    function buyRevives() public payable {
        uint256 convertedAmount = msg.value.getConversionRate(s_priceFeed);
        require(convertedAmount >= REVIVE_PRICE_USD, "Not enough ETH for a revive!");
        
        uint256 reviveAmount = convertedAmount / REVIVE_PRICE_USD;
        s_playerToRevivesOwned[msg.sender] += reviveAmount;
        
        if (s_playerToRevivesOwned[msg.sender] == reviveAmount) {
            s_players.push(msg.sender);
        }
        
        emit RevivePurchased(msg.sender, reviveAmount);
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
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    fallback() external payable {
        buyRevives();
    }

    receive() external payable {
        buyRevives();
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