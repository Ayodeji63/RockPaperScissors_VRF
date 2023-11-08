// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {RPC} from "../src/RPC.sol";

import {DeployCharacterNft} from "./DeployCharacterNft.s.sol";
import {CharacterNFT} from "../src/CharacterNft.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {CreateSubscription, FundSubscription, AddConsumer} from "./Interactions.s.sol";

contract DeployRPC is Script {
    event DeployRPC_SubscriptionFunded();

    DeployCharacterNft public deployer;
    CharacterNFT public characterNft;

    function run() external returns (RPC, HelperConfig, CharacterNFT) {
        deployer = new DeployCharacterNft();
        (characterNft, ) = deployer.run();

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

        if (subscriptionId == 0) {
            // Create a new Subscription
            CreateSubscription createSubscription = new CreateSubscription();
            subscriptionId = createSubscription.createSubscription(
                vrfCoordinator,
                deployerKey
            );

            // Fund It!
            FundSubscription fundSubscription = new FundSubscription();
            fundSubscription.fundSubscription(
                vrfCoordinator,
                subscriptionId,
                link,
                deployerKey
            );

            emit DeployRPC_SubscriptionFunded();
        }
        address owner = helperConfig.getOwnerAddress();
        vm.startBroadcast();
        RPC rpc = new RPC(
            entranceFee,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            address(characterNft),
            owner
        );
        vm.stopBroadcast();
        vm.prank(owner);
        characterNft.setvrfCoordinatorContract(address(rpc));

        AddConsumer addConsumer = new AddConsumer();
        addConsumer.addConsumer(
            address(rpc),
            vrfCoordinator,
            subscriptionId,
            deployerKey
        );

        return (rpc, helperConfig, characterNft);
    }
}
