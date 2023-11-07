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
    string private STARTER_TOKEN_URI =
        "data:application/json;base64,eyJuYW1lIjogIkNoYXJhY2h0ZXIgTkZUIiwgImRlc2NyaXB0aW9uIjoiQW4gTkZUIHRoYXQgcmVmbGVjdHMgdGhlIG93bmVyJ3MgcmFuay4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAibW9vZGluZXNzIiwgInZhbHVlIjogMTAwfV0sICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSGRwWkhSb1BTSXlNREFpSUdobGFXZG9kRDBpTWpBd0lqNDhjR0YwYUNCbWFXeHNQU0lqWmpKbU1tWXlJaUJrUFNKTk1DQXdhREl3TUhZeU1EQklNSG9pTHo0OFkybHlZMnhsSUdONFBTSXhNREFpSUdONVBTSXhNREFpSUhJOUlqZ3dJaUJtYVd4c1BTSWpZamt5T1dJMklpOCtQSFJsZUhRZ2VEMGlNVEF3SWlCNVBTSXhNVEFpSUdadmJuUXRabUZ0YVd4NVBTSkJjbWxoYkN3Z2MyRnVjeTF6WlhKcFppSWdabTl1ZEMxemFYcGxQU0kwTUNJZ1ptOXVkQzEzWldsbmFIUTlJbUp2YkdRaUlHWnBiR3c5SWlObVptWWlJSFJsZUhRdFlXNWphRzl5UFNKdGFXUmtiR1VpUGxOMFlYSjBaWEk4TDNSbGVIUStQSEJoZEdnZ1pEMGlUVEV3TUNBMk1HTXhNeTR5SURBZ01qUXRNVEF1T0NBeU5DMHlOSE10TVRBdU9DMHlOQzB5TkMweU5DMHlOQ0F4TUM0NExUSTBJREkwSURFd0xqZ2dNalFnTWpRZ01qUjZiVFl1TmlBeE5TNDJZeTB4TGpnZ01TNDRMVFF1T0NBeExqZ3ROaTQySURCc0xUSXdMUzR5TFRndU5pQTRMalpNT1RFZ01UQXpMalpqTVM0NElERXVPQ0EwTGpnZ01TNDRJRFl1TmlBd0lERXVPQzB4TGpnZ01TNDRMVFF1T0NBd0xUWXVOa3c0TmlBMk9DNDRiRGt1TmkwNUxqWjZJaUJtYVd4c1BTSWpabVptSWk4K1BIQmhkR2dnWm1sc2JEMGlJMll6T1dNeE1pSWdaRDBpVFRZd0lEUXdhRE5zTVMwMElERWdOR2d6YkMweUlETWdNaUF4TFRNZ01pMHhJRFF0TVMwMExUTXRNU0F5TFRKNlRUZ3dJREl3YUROc01TMDBJREVnTkdnemJDMHlJRE1nTWlBeExUTWdNaTB4SURRdE1TMDBMVE10TVNBeUxUSjZUVEV5TUNBek1HZ3piREV0TkNBeElEUm9NMnd0TWlBeklESWdNUzB6SURJdE1TQTBMVEV0TkMwekxURWdNaTB5ZWsweE5EQWdNVEJvTTJ3eExUUWdNU0EwYUROc0xUSWdNeUF5SURFdE15QXlMVEVnTkMweExUUXRNeTB4SURJdE1ucE5NVGN3SURVd2FETnNNUzAwSURFZ05HZ3piQzB5SURNZ01pQXhMVE1nTWkweElEUXRNUzAwTFRNdE1TQXlMVEo2SWk4K1BHTnBjbU5zWlNCamVEMGlOakFpSUdONVBTSXhOREFpSUhJOUlqWWlJR1pwYkd3OUlpTm1NemxqTVRJaUx6NDhZMmx5WTJ4bElHTjRQU0l6TUNJZ1kzazlJamN3SWlCeVBTSTJJaUJtYVd4c1BTSWpaak01WXpFeUlpOCtQR05wY21Oc1pTQmplRDBpTVRZd0lpQmplVDBpTXpBaUlISTlJallpSUdacGJHdzlJaU5tTXpsak1USWlMejQ4WTJseVkyeGxJR040UFNJeE5EQWlJR041UFNJeE5qQWlJSEk5SWpZaUlHWnBiR3c5SWlObU16bGpNVElpTHo0OFkybHlZMnhsSUdONFBTSXhNREFpSUdONVBTSXhPREFpSUhJOUlqWWlJR1pwYkd3OUlpTm1NemxqTVRJaUx6NDhMM04yWno0PSJ9";
    RPC private rpc;
    HelperConfig private helperConfig;
    CharacterNFT private characterNFT;
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
    event RPC__GameTied();
    event RecentWinner(address indexed winner, uint indexed tokenId);

    modifier playerMintToken() {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_2);
        characterNFT.mintCharacter();
        _;
    }
    modifier playersJoinedGame() {
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, 0);
        vm.prank(PLAYER_2);
        rpc.joinGame{value: entranceFee}(2, 1);
        _;
    }

    function setUp() external {
        DeployRPC deployer = new DeployRPC();
        (rpc, helperConfig, characterNFT) = deployer.run();
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

    /////////////////////
    // fulfilRandomWords //
    //////////////////////

    modifier skipFork() {
        if (block.chainid != 31337) {
            return;
        }
        _;
    }

    function fulfillRandomWordsAndGetLogs() public returns (address, uint) {
        vm.recordLogs();
        rpc.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        vm.recordLogs();
        VRFCoordinatorV2Mock(vrfCoordinator).fulfillRandomWords(
            uint(requestId),
            address(rpc)
        );
        Vm.Log[] memory _entries = vm.getRecordedLogs();
        bytes32 winner = _entries[2].topics[1];
        bytes32 winnerCharacter = _entries[2].topics[2];
        return (address(uint160(uint256(winner))), uint(winnerCharacter));
    }

    function testFufillRandomWordsPickWinnerResetsAndSendsMoney()
        public
        playerMintToken
        playersJoinedGame
        skipFork
        returns (address recentWinner)
    {
        // Arrange
        fulfillRandomWordsAndGetLogs();
        uint prize = entranceFee * 2;
        assert(uint(rpc.getRGameState()) == 0);
        assert(rpc.getRecentWinner() != address(0));
        assert(
            rpc.getRecentWinner().balance ==
                STARTING_USER_BALANCE + prize - entranceFee
        );
        recentWinner = rpc.getRecentWinner();
        return recentWinner;
    }

    function testFufillRandomWordsPickWinnerResetsEmitEventAndSendsMoney()
        public
        playerMintToken
        playersJoinedGame
        skipFork
    {
        // Arrange
        vm.expectEmit(true, true, false, false, address(rpc));
        emit RecentWinner(PLAYER_2, 1);
        fulfillRandomWordsAndGetLogs();
    }

    function testShouldFlipWinnerRankNum()
        public
        playerMintToken
        playersJoinedGame
        skipFork
    {
        // Arrange
        uint player1InitialRank = characterNFT.getCharacterRank(0);
        uint player2InitialRank = characterNFT.getCharacterRank(1);
        address winner;
        uint winnerCharacterId;
        (winner, winnerCharacterId) = fulfillRandomWordsAndGetLogs();
        uint player1FinalRank = characterNFT.getCharacterRank(0);
        uint player2FinalRank = characterNFT.getCharacterRank(1);

        assert(player1FinalRank == player1InitialRank);
        assert(player2FinalRank > player2InitialRank);
    }

    function testWinnerTokenUri()
        public
        playerMintToken
        playersJoinedGame
        skipFork
    {
        address winner;
        uint winnerCharacterId;
        (winner, winnerCharacterId) = fulfillRandomWordsAndGetLogs();
        assert(
            keccak256(
                abi.encodePacked(characterNFT.tokenURI(uint(winnerCharacterId)))
            ) != keccak256(abi.encodePacked(STARTER_TOKEN_URI))
        );
    }
}
