// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {VRFCoordinatorV2Interface} from "@chainlink/contracts/src/v0.8/interfaces/VRFCoordinatorV2Interface.sol";
import {VRFConsumerBaseV2} from "@chainlink/contracts/src/v0.8/VRFConsumerBaseV2.sol";

/**
 * @title A Rock Paper Scissors
 * @author Olusanya Ayodeji
 * @notice This contract uses Chainlink VRF to determine the outcome of A Rock Paper Scissors Game.
 * @dev Implements Chainlink VRFv2
 */

contract RPC is VRFConsumerBaseV2 {
    //? errors
    error RPC__NotEnoughEthSent();
    error RPC__GameAlreadyStarted();
    error RPC__GameClosed();
    error RPC__UpKeepNotNeeded();
    error RPC__GameStateNotCalculating();
    error RPC__TransferFailed();

    //? Types Declarations
    enum Choice {
        ROCK,
        PAPER,
        SCISSORS
    }

    enum GameState {
        OPEN,
        CALCULATING,
        CLOSED
    }

    struct Game {
        address payable player1;
        address payable player2;
        Choice choice1;
        Choice choice2;
        uint gameId;
        bool resolved;
    }

    //? State Variables

    //* Chainlink VRF Variables
    VRFCoordinatorV2Interface private immutable i_vrfCoordinator;
    bytes32 private immutable i_gasLane;
    uint64 private immutable i_subscriptionId;
    uint32 private immutable i_callbackGasLimit;
    uint16 private constant REQUEST_CONFIRMATIONS = 3;
    uint32 private constant NUM_WORDS = 1;

    //* Contract Variables
    uint256 private immutable i_entranceFee;
    uint public s_gameId;
    Game public s_game;
    GameState public s_gameState;

    //? Events
    event FirstPlayerJoined(address indexed player);
    event SecondPlayerJoined(address indexed player);
    event RequestedRPCWinner(uint256 indexed requestId);
    event RPC__GameTied();

    constructor(
        uint entranceFee,
        address vrfCoordinator,
        bytes32 gasLane,
        uint64 subscriptionId,
        uint32 callbackGasLimit
    ) VRFConsumerBaseV2(vrfCoordinator) {
        i_entranceFee = entranceFee;
        s_gameId = 0;
        i_gasLane = gasLane;
        i_subscriptionId = subscriptionId;
        i_callbackGasLimit = callbackGasLimit;
        i_vrfCoordinator = VRFCoordinatorV2Interface(vrfCoordinator);
        s_gameState = GameState.OPEN;
    }

    function joinGame(uint choice) external payable {
        if (msg.value < i_entranceFee) {
            revert RPC__NotEnoughEthSent();
        }
        if (s_game.player1 == address(0)) {
            s_game.player1 = payable(msg.sender);
            s_game.choice1 = Choice(choice);
            emit FirstPlayerJoined(msg.sender);
        } else if (s_game.player2 == address(0)) {
            if (s_gameState == GameState.CLOSED) {
                revert RPC__GameClosed();
            }
            if (msg.sender != s_game.player1) {
                s_game.player2 = payable(msg.sender);
                s_game.choice2 = Choice(choice);
                s_game.resolved = true;
                s_gameState = GameState.CALCULATING;
                emit SecondPlayerJoined(msg.sender);
                s_gameId++;
            } else {
                revert RPC__GameAlreadyStarted();
            }
        }
    }

    function checkUpkeep(
        bytes memory /*checkData*/
    ) public view returns (bool upKeepNeeded, bytes memory /*performData */) {
        bool isCalculating = GameState.CALCULATING == s_gameState;
        bool hasBalance = address(this).balance > 0;
        bool hasPlayers = s_game.player1 != address(0) &&
            s_game.player2 != address(0);
        upKeepNeeded = (isCalculating && hasBalance && hasPlayers);
        return (upKeepNeeded, "0x0");
    }

    function performUpkeep(bytes calldata /**performData */) external {
        (bool upkKeepNeeded, ) = checkUpkeep("");
        if (!upkKeepNeeded) {
            revert RPC__UpKeepNotNeeded();
        }

        uint256 requestId = i_vrfCoordinator.requestRandomWords(
            i_gasLane,
            i_subscriptionId,
            REQUEST_CONFIRMATIONS,
            i_callbackGasLimit,
            NUM_WORDS
        );

        emit RequestedRPCWinner(requestId);
    }

    // CEI: Checks, Effects, Interactions

    function fulfillRandomWords(
        uint256 _requestId,
        uint256[] memory _randomWords
    ) internal override {
        if (s_gameState != GameState.CALCULATING) {
            revert RPC__GameStateNotCalculating();
        }
        Game storage _game = s_game;
        address payable winner;

        uint randomResult = _randomWords[0];
        Choice winnerChoice = Choice(randomResult % 3);

        if (winnerChoice == _game.choice1) {
            winner = _game.player1;
        } else if (winnerChoice == _game.choice2) {
            winner = _game.player2;
        } else {
            winner = payable(address(this));
            emit RPC__GameTied();
        }

        if (winner != address(this)) {
            (bool success, ) = winner.call{value: address(this).balance}("");
            if (!success) {
                revert RPC__TransferFailed();
            }
        }

        // reset the game state
        resetGameState();
    }

    // Helper Function to reset game
    function resetGameState() internal {
        s_gameState = GameState.OPEN;
        s_game.player1 = payable(address(0));
        s_game.player2 = payable(address(0));
        s_game.choice1 = Choice.ROCK;
        s_game.choice2 = Choice.ROCK;
        s_game.resolved = false;
    }
}