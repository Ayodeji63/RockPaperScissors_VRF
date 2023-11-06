// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DeployRPC} from "../../script/DeployRPC.s.sol";
import {DeployCharacterNft} from "../../script/DeployCharacterNft.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {RPC} from "../../src/RPC.sol";
import {CharacterNFT} from "../../src/CharacterNft.sol";

contract CharcterRpcTest is Test {
    DeployRPC public deployRpc;
    DeployCharacterNft public deployCharcterNft;
    HelperConfig public helperConfig;
    RPC public rpc;
    CharacterNFT public characterNft;

    address public PLAYER_1 = makeAddr("player1");
    address public PLAYER_2 = makeAddr("player2");
    uint public STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployRpc = new DeployRPC();
        (rpc, ) = deployRpc.run();
        deployCharcterNft = new DeployCharacterNft();
        (characterNft, helperConfig) = deployCharcterNft.run();
        vm.deal(PLAYER_1, STARTING_BALANCE);
        vm.deal(PLAYER_2, STARTING_BALANCE);
    }

    function testShouldSetvrfCoordinatorContract() public {
        address owner = helperConfig.getOwnerAddress();
        (, address vrfCoordinator, , , , , ) = helperConfig
            .activeNetworkConfig();
        vm.prank(owner);
        characterNft.setvrfCoordinatorContract(address(vrfCoordinator));
        assert(characterNft.getRpcContract() == address(vrfCoordinator));
    }
}
