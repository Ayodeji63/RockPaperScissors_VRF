// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployRPC} from "../../script/DeployRPC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {RPC} from "../../src/RPC.sol";

contract DeployRPCTest is Test {
    DeployRPC deployer;
    RPC private rpc;
    uint public immutable i_entranceFee = 0.01 ether;
    event DeployRPC_SubscriptionFunded();

    uint entranceFee;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint deployerKey;

    HelperConfig private helperConfig;

    function setUp() external {
        deployer = new DeployRPC();
    }

    function testDeployerRun() public {
        (rpc, helperConfig, ) = deployer.run();
        (
            entranceFee,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            deployerKey
        ) = helperConfig.activeNetworkConfig();

        assert(entranceFee == i_entranceFee);
    }

    function testDeployRpcEmitSubscriptionFunded() public {
        vm.expectEmit(false, false, false, false, address(deployer));
        emit DeployRPC_SubscriptionFunded();
        (rpc, helperConfig, ) = deployer.run();
    }
}
