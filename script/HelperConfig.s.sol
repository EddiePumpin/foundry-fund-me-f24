// 1. Deploy mocks when we are on a local anvil chain.
// 2. Keep track of contract address across different chains

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script {
    NetworkConfig public activeNetworkConfig;

    uint8 public constant DECIMALS = 8;
    int256 public constant INITIAL_PRICE = 2000e8;

    struct NetworkConfig {
        address priceFeed; // ETH/USD price feed address
    }

    constructor() {
        if (block.chainid == 11155111) {
            activeNetworkConfig = getSepoliaEthConfig();
        } else if (block.chainid == 1) {
            activeNetworkConfig = getMainnetEthConfig();
        } else {
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory) {
        // priceFeed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306});
        return sepoliaConfig;
    }

    function getMainnetEthConfig() public pure returns (NetworkConfig memory) {
        // priceFeed address
        NetworkConfig memory ethConfig = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419});
        return ethConfig;
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            // This line is saying have set our priceFeed? It is not address 0 means we have set it, so just go ahead and return activeNetworkConfig and don't run the remaining lines of code.
            return activeNetworkConfig; // address(0) is used to represent a null or uninitialized address, which is 0x0000000000000000000000000000000000000000. If it is equal to address(0), it means priceFeed has not been set and it will run the rest of the code.
        }
        // price feed address

        // 1. Deploy the mocks
        // Return the mocks address

        vm.startBroadcast(); // Since we are working with the vm, we can't use the public keywork.
        // The mock will be deployed to the anvil.
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(DECIMALS, INITIAL_PRICE); // How did we get 8 and 2000? From the MockV3Aggregator constructor there are two arguments(decimal and initial_answer). The 8 after e is due to the decimal
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({priceFeed: address(mockPriceFeed)});
        return anvilConfig;
    }
}
