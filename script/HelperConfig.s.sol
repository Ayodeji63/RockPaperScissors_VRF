// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Test, Console} from "forge-std/Test.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        uint entranceFee;
        uint vrfCoordinator;
        bytes32 gasLane;
        uint64 subscriptionId;
        uint32 callbackGasLimit;
        address link;
        uint deployerKey;
    }

    NetworkConfig public activeNetworkConfig;
    NetworkConfig public networkConfig;
    uint256 public constant DEFAULT_ANVIL_KEY =
        0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;

    constructor() {}

    function getSepoliaEthConfig() public view returns (NetworkConfig memory) {
        return
            NetworkConfig({
                entranceFee: 0.01 ether,
                vrfCoordinator: 0x8103B0A8A00be2DDC778e6e7eaa21791Cd364625,
                gasLane: 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92,
                subscriptionId: 0,
                callbackGasLimit: 500000,
                link: 0x779877A7B0D9E8603169DdbD7836e478b4624789,
                deployerKey: vm.envUint("PRIVATE_KEY")
            });
    }

    function getOrCreateAnvilEthConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.vrfCoordinator != address(0)) {
            return activeNetworkConfig;
        }

        uint96 baseFee = 0.25 ether;
        uint96 gasPriceLink = 1e9;

        vm.startBroadcast();
        VRFCoordinatorV2Mock vrfCoordinatorMock = new VRFCoordinatorV2Mock(
            baseFee,
            gasPriceLink
        );
        LinkToken link = new LinkToken();
        vm.stopBroadcast();

        networkConfig = NetworkConfig({
            entranceFee: 0.01 ether,
            vrfCoordinator: address(vrfCoordinatorMock),
            gasLane: 0xff8dedfbfa60af186cf3c830acbc32c05aae823045ae5ea7da1e45fbfaba4f92,
            subscriptionId: 0,
            callbackGasLimit: 500000,
            link: address(link),
            deployerKey: DEFAULT_ANVIL_KEY
        });

        return networkConfig;
    }
}
