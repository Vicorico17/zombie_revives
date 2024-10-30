// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test, console} from "lib/forge-std/src/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;
    address USER = makeAddr("user");
    uint256 constant AMOUNT_TO_FUND = 1e18;
    uint256 constant STARTING_BALANCE = 10e18; 

    function setUp() external {
        //fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run(); 
        vm.deal(USER, STARTING_BALANCE); //GIVE USER SOME ETH
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: AMOUNT_TO_FUND}();
        _;
    }   

    function test_minDollar() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }

    function test_consoleLog() public pure {
        console.log("hi");
    }

    function testOwnerIsMsgSender() public view{
        assertEq(fundMe.getOwner(), msg.sender);
    }
    function testpriceversioniscorrect() public view {
        assertEq(fundMe.getVersion(), 4);
    }
    function testfundfailswithoutenougheth() public {
        vm.expectRevert(); //next line should fail
        fundMe.fund();
    }
    function testfundupdatesfunding() public funded{
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, AMOUNT_TO_FUND);
    }
    function testonlyownercanwithdraw() public {
        vm.prank(USER); //simulate a user trying to withdraw
        vm.expectRevert(); //expect this function to fail
        fundMe.withdraw();          
    }
    function testaddsfunderstoarrayofFunders() public funded{
        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }
    function testwithdrawwithasinglefunder() public funded {
        // Arrange
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            endingOwnerBalance
        );
    }
    function testwithdrawfrommultiplefunders() public funded{
        //Arrange
        uint160 numFunders = 10;
        uint160 startingIndex = 1;
        uint256 SEND_VALUE = 1 ether;

        for(uint160 i = startingIndex; i < numFunders; i++){
            hoax(address(i), SEND_VALUE); // deal and prank
            fundMe.fund{value: SEND_VALUE}();
        }
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        //Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        //Assert
        assertEq(address(fundMe).balance, 0);
        assertEq(
            startingOwnerBalance + startingFundMeBalance,
            fundMe.getOwner().balance
        );
        
    }
}
