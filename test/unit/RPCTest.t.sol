// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {RPC} from "../../src/RPC.sol";
import {DeployRPC} from "../../script/DeployRPC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {DeployCharacterNft} from "../../script/DeployCharacterNft.s.sol";
import {CharacterNFT} from "../../src/CharacterNft.sol";

contract RPCTest is Test {
    RPC private rpc;
    HelperConfig private helperConfig;
    CharacterNFT private characterNFT;
    address public PLAYER_1 = makeAddr("player1");
    address public PLAYER_2 = makeAddr("player2");
    uint256 public constant STARTING_USER_BALANCE = 100 ether;

    //? Chainlink VRF2 Variables
    uint256 entranceFee;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint256 deployerKey;

    event FirstPlayerJoined(address indexed player);
    event SecondPlayerJoined(address indexed player);
    event RPC__GameTied();

    modifier playersJoinedGame() {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, 0);
        vm.prank(PLAYER_2);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_2);
        rpc.joinGame{value: entranceFee}(2, 1);
        _;
    }

    modifier playerMintToken() {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_2);
        characterNFT.mintCharacter();
        _;
    }

    function setUp() external {
        DeployRPC deployer = new DeployRPC();
        (rpc, helperConfig, characterNFT) = deployer.run();
        (entranceFee, vrfCoordinator, gasLane, subscriptionId, callbackGasLimit, link, deployerKey) =
            helperConfig.activeNetworkConfig();
        vm.deal(PLAYER_1, STARTING_USER_BALANCE);
        vm.deal(PLAYER_2, STARTING_USER_BALANCE);
    }

    //////////////////////////
    //     Join Game        //

    function test__EmitsEventOnPlayerJoinGame() public {
        vm.prank(PLAYER_1);
        vm.recordLogs();
        characterNFT.mintCharacter();
        Vm.Log[] memory _entries = vm.getRecordedLogs();
        bytes32 tokenId1 = _entries[1].topics[1];
        uint256 s_player1tokenId = uint256(tokenId1);
        vm.expectEmit(true, false, false, false, address(rpc));
        emit FirstPlayerJoined(PLAYER_1);
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, s_player1tokenId);
    }

    function testShouldRevertIfEnoughEthIsNotSent() public playerMintToken {
        vm.prank(PLAYER_1);
        vm.expectRevert(abi.encodePacked(RPC.RPC__NotEnoughEthSent.selector));
        uint256 notEnoughEntryFee = 0.001 ether;
        rpc.joinGame{value: notEnoughEntryFee}(0, 0);
    }

    function testShouldRevertIfGamHasStarted() public playersJoinedGame {
        vm.prank(PLAYER_2);
        vm.expectRevert(abi.encodePacked(RPC.RPC__GameAlreadyStarted.selector));
        rpc.joinGame{value: entranceFee}(0, 1);
    }

    function test__EmitsEventOnSecondPlayerJoinGame() public playerMintToken {
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, 0);

        vm.prank(PLAYER_2);
        vm.expectEmit(true, false, false, false, address(rpc));
        emit SecondPlayerJoined(PLAYER_2);
        rpc.joinGame{value: entranceFee}(0, 1);
    }

    function testGameStateIsCalculatingWhenPlayer2Join() public playersJoinedGame {
        RPC.GameState rState = rpc.getRGameState();
        assert(uint256(rState) == 1);
    }

    /////////////////////
    //   checkUpKeep  //
    ///////////////////

    function testCheckUpKeepReturnsFalseIfItHasNoBalance() public view {
        // Arrange
        (bool upkeepNeeded,) = rpc.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRpcNotCalculating() public {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, 0);
        (bool upkeepNeeded,) = rpc.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsTrueIfParametersAreGood() public playersJoinedGame {
        (bool upkeepNeeded,) = rpc.checkUpkeep("");
        assert(upkeepNeeded);
    }

    ////////////////////
    //  performUpkeep //
    ////////////////////

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        vm.expectRevert(abi.encodePacked(RPC.RPC__UpKeepNotNeeded.selector));

        rpc.performUpkeep("");
    }

    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue() public playersJoinedGame {
        rpc.performUpkeep("");
    }

    function testPerformUpKeepUpdateGameStateAndEmitsRequestId() public playersJoinedGame {
        // Act
        vm.recordLogs();
        rpc.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        RPC.GameState rState = rpc.getRGameState();

        // Assert
        assert(uint256(requestId) > 0);
        assert(uint256(rState) == 2);
    }

    /////////////////////
    // fulfilRandomWords //
    //////////////////////

    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    function testFulfilRandomWordsCanOnlyBeCalledAfterPerformUpkeep(uint256 randomRequestId) public skipFork {
        vm.expectRevert("nonexistent request");
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(randomRequestId, address(rpc));
    }

    function testFufillRandomWordsEmitGameTied() public {
        // Arrange
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, 0);

        vm.prank(PLAYER_2);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_2);
        rpc.joinGame{value: entranceFee}(0, 1);

        vm.recordLogs();
        rpc.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        console.log("request id", uint256(requestId));
        vm.expectEmit(false, false, false, false, address(rpc));
        emit RPC__GameTied();
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(uint256(requestId), address(rpc));
    }
}
