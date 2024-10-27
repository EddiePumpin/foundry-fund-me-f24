// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../../src/FundMe.sol";
import {PriceConverter} from "../../src/PriceConverter.sol";
import {DeployFundMe} from "../../script/DeployFundMe.s.sol";

contract FundMeTest is Test {
    FundMe fundMe;

    address USER = makeAddr("user");
    uint256 constant SEND_VALUE = 0.1 ether; // 100000000000000000
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
        DeployFundMe deployFundMe = new DeployFundMe();
        fundMe = deployFundMe.run();
        vm.deal(USER, STARTING_BALANCE); // This line gives the USER 10 ether
    }

    function testMinimumDollarIsFive() public {
        assertEq(fundMe.MINIMUM_USD, 5e18);
    }

    function testOwnerIsMsgSender() public {
        assertEq(fundMe.owner, msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // The next tnx, should revert
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // This means the next TX will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0); // Try changing address to address[]
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded {
        vm.expectRevert(); // The next tnx, should revert. It will ignore the next vm
        vm.prank(USER);
        fundMe.withdraw();
    }

    function testWithdrawWithASingleFunder() public funded {
        // Arrange(setUp)
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act(Action)
        // uint256 gasStart = gasleft(); // gasLeft is a built-in function in solidity. Let's say we start with 2000 gas
        // vm.txGasPrice(GAS_PRICE); // This will set gas price to GAS_PRICE when we are working on anvil(local blockchain)
        vm.prank(fundMe.getOwner());
        fundMe.withdraw(); // Let's say this cost 200 gas

        // uint256 gasEnd = gasleft(); // Means will be left with 800
        // uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice; // tx.gasprice is another built-in in solidity that tells the current gasprice
        // console.log(gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }

    function testWithdrawWithAMultipleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10; // uint160 has the same length as address.
        uint160 startingFunderIndex = 1; // It is ideal to start with 1 because 0 address revert
        for (uint256 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank
            // vm.default
            hoax(address(i), SEND_VALUE); // If vm.prank and vm.deal is combined, then hoax is used. Since we are hoaxing this line, we are pranking it.
            fundMe.fund{value: SEND_VALUE}();
            // Fund the fundMe
        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;

        // Act
        vm.prankPrank(fundMe.getOwner()); // This is the same as the vm.startBroadcast and vm.stopBroadcast. Anything in-between will be sent by the fundMe.getOwner()
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assertEq(address(fundMe).balance == 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
        );

        function testWithdrawWithAMultipleFundersCheaper() public funded {
        // Arrange
            uint160 numberOfFunders = 10; // uint160 has the same length as address.
            uint160 startingFunderIndex = 1; // It is ideal to start with 1 because 0 address revert
            for (uint256 i = startingFunderIndex; i < numberOfFunders; i++) {
                // vm.prank
                // vm.default
             hoax(address(i), SEND_VALUE); // If vm.prank and vm.deal is combined, then hoax is used. Since we are hoaxing this line, we are pranking it.
                fundMe.fund{value: SEND_VALUE}();
                // Fund the fundMe
            }

            uint256 startingOwnerBalance = fundMe.getOwner().balance;
            uint256 startingFundMeBalance = address(fundMe).balance;

            // Act
            vm.prankPrank(fundMe.getOwner()); // This is the same as the vm.startBroadcast and vm.stopBroadcast. Anything in-between will be sent by the fundMe.getOwner()
            fundMe.cheaperWithdraw();
            vm.stopPrank();

            // Assert
            ssertEq(address(fundMe).balance == 0);
            assertEq(
            startingFundMeBalance + startingOwnerBalance ==
                fundMe.getOwner().balance
           );
        }
    }
}
