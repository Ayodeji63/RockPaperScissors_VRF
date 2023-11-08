// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {Test, console} from "forge-std/Test.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {CharacterNFT} from "../src/CharacterNft.sol";
import {RPC} from "../src/RPC.sol";
import {Vm} from "forge-std/Vm.sol";

contract CreateSubscription is Script {
    function CreateSubscriptionUsingConfig() public returns (uint64) {
        HelperConfig helperConfig = new HelperConfig();
        (, address vrfCoordinator, , , , , uint deployerKey) = helperConfig
            .activeNetworkConfig();
        return createSubscription(vrfCoordinator, deployerKey);
    }

    function createSubscription(
        address vrfCoordinator,
        uint256 deployerKey
    ) public returns (uint64) {
        console.log("Creating subscription on ChainId", block.chainid);
        vm.startBroadcast(deployerKey);
        uint64 subId = VRFCoordinatorV2Mock(vrfCoordinator)
            .createSubscription();
        vm.stopBroadcast();
        console.log("Your sub Id is", subId);
        console.log("Please update subscription in HelperConfig");
        return subId;
    }

    function run() external returns (uint64) {
        return CreateSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script {
    uint96 public constant FUND_AMOUNT = 3 ether;

    function fundSubscription(
        address vrfCoordinator,
        uint64 subId,
        address link,
        uint256 deployerKey
    ) public {
        console.log("Fundung subscription ", subId);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID", block.chainid);
        if (block.chainid == 31337) {
            vm.startBroadcast(deployerKey);
            VRFCoordinatorV2Mock(vrfCoordinator).fundSubscription(
                subId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(deployerKey);
            LinkToken(link).transferAndCall(
                vrfCoordinator,
                FUND_AMOUNT,
                abi.encode(subId)
            );
            vm.stopBroadcast();
        }
    }

    function fundSubscriptionConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            address vrfCoordinator,
            ,
            uint64 subId,
            ,
            address link,
            uint256 deployerKey
        ) = helperConfig.activeNetworkConfig();
        fundSubscription(vrfCoordinator, subId, link, deployerKey);
    }

    function run() external {
        fundSubscriptionConfig();
    }
}

contract AddConsumer is Script {
    function addConsumer(
        address rpc,
        address vrfCoordinator,
        uint64 subId,
        uint256 deployerKey
    ) public {
        console.log("Adding consumer contract: ", rpc);
        console.log("Using vrfCoordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);
        vm.startBroadcast(deployerKey);
        VRFCoordinatorV2Mock(vrfCoordinator).addConsumer(subId, rpc);
        vm.stopBroadcast();
    }

    function addConsumerUsingConfig(address rpc) public {
        HelperConfig helperConfig = new HelperConfig();
        (
            ,
            address vrfCoordinator,
            ,
            uint64 subId,
            ,
            ,
            uint deployerKey
        ) = helperConfig.activeNetworkConfig();
        addConsumer(rpc, vrfCoordinator, subId, deployerKey);
    }

    function run() external {
        address rpc = DevOpsTools.get_most_recent_deployment(
            "Rpc",
            block.chainid
        );
        addConsumerUsingConfig(rpc);
    }
}

contract MintCharacter is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "CharacterNFT",
            block.chainid
        );
        mintCharacterOnContract(mostRecentlyDeployed);
    }

    function mintCharacterOnContract(address contractAddress) public {
        vm.startBroadcast();
        CharacterNFT(contractAddress).mintCharacter();
        vm.stopBroadcast();
    }
}

contract JoinGame is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "RPC",
            block.chainid
        );
        joinGameOnContract(mostRecentlyDeployed);
    }

    function joinGameOnContract(address contractAddress) public {
        vm.startBroadcast();
        RPC(contractAddress).joinGame(0, 0);
        vm.stopBroadcast();
    }
}

contract PerformUpkeep is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "RPC",
            block.chainid
        );
        perFormUpkeepOnContract(mostRecentlyDeployed);
    }

    function perFormUpkeepOnContract(address contractAddress) public {
        vm.startBroadcast();
        RPC(contractAddress).performUpkeep("0x");
        vm.stopBroadcast();
    }
}

contract CheckUpKeep is Script {
    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "RPC",
            block.chainid
        );
        checkUpkeepOnContract(mostRecentlyDeployed);
    }

    function checkUpkeepOnContract(address contractAddress) public {
        vm.startBroadcast();
        RPC(contractAddress).checkUpkeep("0x");
        vm.stopBroadcast();
    }
}

contract FulfillRandomWords is Script {
    uint entranceFee;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint deployerKey;

    RPC rpc;

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "RPC",
            block.chainid
        );
        address helperConfigAddress = DevOpsTools.get_most_recent_deployment(
            "RPC",
            block.chainid
        );
        fulfillRandomWordsOnContract(mostRecentlyDeployed, helperConfigAddress);
    }

    function fulfillRandomWordsAndGetLogs(
        address _vrf,
        address _rpc
    ) public returns (address, uint) {
        vm.recordLogs();
        RPC(_rpc).performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        vm.recordLogs();
        VRFCoordinatorV2Mock(_vrf).fulfillRandomWords(
            uint(requestId),
            address(_rpc)
        );
        Vm.Log[] memory _entries = vm.getRecordedLogs();
        bytes32 winner = _entries[2].topics[1];
        bytes32 winnerCharacter = _entries[2].topics[2];
        return (address(uint160(uint256(winner))), uint(winnerCharacter));
    }

    function fulfillRandomWordsOnContract(
        address contractAddress,
        address helperConfigAddress // I changed the variable name to avoid shadowing
    ) public {
        vm.startBroadcast();
        HelperConfig helperConfig = HelperConfig(helperConfigAddress);
        (
            entranceFee,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            deployerKey
        ) = helperConfig.activeNetworkConfig();
        fulfillRandomWordsAndGetLogs(vrfCoordinator, contractAddress);
        vm.stopBroadcast();
    }
}
