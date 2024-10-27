// SPDX-License-Identifier: MIT

// Fund
// Withdraw

pragma solidity ^0.8.19

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {FundMe} from "../src/FundMe.sol";


contract FundFundMe is Scripts {
    uint256 constant SEND_VALUE = 0.01 ether;

    // vm.startBroadcast(); and vm.stopBroadcast(); in Foundry indicate the beginning and end of an actual transaction broadcast to the network when testing.
    // This broadcasting setup is particularly useful when performing state-changing operations (e.g., sending Ether or updating the contract state).
        function fundFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).fund{value:SEND_VALUE}();
        vm.stopBroadcast();
        console.log("Funded FundMe with %s", SEND_VALUE);
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainis);
        fundFundMe(mostRecentlyDeployed);
    }
}

contract WithdrawFundMe is Scripts {
       uint256 constant SEND_VALUE = 0.01 ether;
    function withdrawFundMe(address mostRecentlyDeployed) public {
        vm.startBroadcast();
        FundMe(payable(mostRecentlyDeployed)).withdraw(); 
        vm.stopBroadcast();
    }
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("FundMe", block.chainis);
        withdrawFundMe(mostRecentlyDeployed);
    }
}