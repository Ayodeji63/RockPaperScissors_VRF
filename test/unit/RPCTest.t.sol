// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {RPC} from "../../src/RPC.sol";

contract RPCTest is Test {
    RPC private rpc;
    address public PLAYER_1 = makeAddr("player1");
    address public PLAYER_2 = makeAddr("player2");
    uint public constant STARTING_USER_BALANCE = 100 ether;
    uint public constant entranceFee = 10 ether;

    event FirstPlayerJoined(address indexed player, uint indexed gameId);
     event SecondPlayerJoined(address indexed player, uint indexed gameId);

    function setUp() external {
        vm.startBroadcast();
        rpc = new RPC(entranceFee);
        vm.deal(PLAYER_1, STARTING_USER_BALANCE);
        vm.deal(PLAYER_2, STARTING_USER_BALANCE);
        vm.stopBroadcast();
    }

    function test__EmitsEventOnPlayerJoinGame() public {
        vm.startPrank(PLAYER_1);
        vm.expectEmit(true, true, false, false, address(rpc));
        emit FirstPlayerJoined(PLAYER_1, 0);
        rpc.joinGame{value: entranceFee}(0, 0);
        vm.stopPrank();
    }

    function test__EmitsEventOnSecondPlayerJoinGame() public {
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, 0);

        vm.prank(PLAYER_2);
        vm.expectEmit(true, true, false, false, address(rpc));
        emit SecondPlayerJoined(PLAYER_2, 0);
        rpc.joinGame{value: entranceFee}(0, 1);
    }
}