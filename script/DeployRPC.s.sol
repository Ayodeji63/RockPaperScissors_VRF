// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RPC} from "../src/RPC.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployRPC is Script {
    function run() external returns (RPC, HelperConfig) {
        HelperConfig helperConfig = new HelperConfig();

        (
            uint entranceFee,
            address vrfCoordinator,
            bytes32 gasLane,
            uint64 subscriptionId,
            uint32 callbackGasLimit,
            address link,
            uint deployerKey
        ) = helperConfig.activeNetworkConfig();

        vm.startBroadcast();
        RPC rpc = new RPC(
            entranceFee,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit
        );
        vm.stopBroadcast();

        return (rpc, helperConfig);
    }
}
