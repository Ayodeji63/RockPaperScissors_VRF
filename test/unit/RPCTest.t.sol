// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {RPC} from "../../src/RPC.sol";
import {DeployRPC} from "../../script/DeployRPC.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RPCTest is Test {
    RPC private rpc;
    HelperConfig private helperConfig;
    address public PLAYER_1 = makeAddr("player1");
    address public PLAYER_2 = makeAddr("player2");
    uint public constant STARTING_USER_BALANCE = 100 ether;

    //? Chainlink VRF2 Variables
    uint entranceFee;
    address vrfCoordinator;
    bytes32 gasLane;
    uint64 subscriptionId;
    uint32 callbackGasLimit;
    address link;
    uint deployerKey;

    event FirstPlayerJoined(address indexed player);
    event SecondPlayerJoined(address indexed player);

    modifier playersJoinedGame() {
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0);
        vm.prank(PLAYER_2);
        rpc.joinGame{value: entranceFee}(0);
        _;
    }

    function setUp() external {
        DeployRPC deployer = new DeployRPC();
        (rpc, helperConfig) = deployer.run();
        (
            entranceFee,
            vrfCoordinator,
            gasLane,
            subscriptionId,
            callbackGasLimit,
            link,
            deployerKey
        ) = helperConfig.activeNetworkConfig();
        vm.deal(PLAYER_1, STARTING_USER_BALANCE);
        vm.deal(PLAYER_2, STARTING_USER_BALANCE);
    }

    //////////////////////////
    //     Join Game        //

    function test__EmitsEventOnPlayerJoinGame() public {
        vm.startPrank(PLAYER_1);
        vm.expectEmit(true, true, false, false, address(rpc));
        emit FirstPlayerJoined(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0);
        vm.stopPrank();
    }

    function test__EmitsEventOnSecondPlayerJoinGame() public {
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0);

        vm.prank(PLAYER_2);
        vm.expectEmit(true, true, false, false, address(rpc));
        emit SecondPlayerJoined(PLAYER_2);
        rpc.joinGame{value: entranceFee}(1);
    }

    function testGameStateIsCalculatingWhenPlayer2Join()
        public
        playersJoinedGame
    {
        RPC.GameState rState = rpc.getRGameState();
        assert(uint(rState) == 1);
    }

    /////////////////////
    //   checkUpKeep  //
    ///////////////////

    function testCheckUpKeepReturnsFalseIfItHasNoBalance() public view {
        // Arrange
        (bool upkeepNeeded, ) = rpc.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsFalseIfRpcNotCalculating() public {
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0);
        (bool upkeepNeeded, ) = rpc.checkUpkeep("");
        assert(!upkeepNeeded);
    }

    function testCheckUpKeepReturnsTrueIfParametersAreGood()
        public
        playersJoinedGame
    {
        (bool upkeepNeeded, ) = rpc.checkUpkeep("");
        assert(upkeepNeeded);
    }

    ////////////////////
    //  performUpkeep //
    ////////////////////

    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        vm.expectRevert(abi.encodePacked(RPC.RPC__UpKeepNotNeeded.selector));

        rpc.performUpkeep("");
    }

    // function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue()
    //     public
    //     playersJoinedGame
    // {
    //     rpc.performUpkeep("");
    // }
}
