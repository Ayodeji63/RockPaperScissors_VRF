// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

/**
 * @title A Rock Paper Scissors
 * @author Olusanya Ayodeji
 * @notice This contract uses Chainlink VRF to determine the outcome of A Rock Paper Scissors Game.
 * @dev Implements Chainlink VRFv2
 */

contract RPC {

    //? errors 
    error RPC__NotEnoughEthSent();
    error RPC__GameAlreadyStarted();

    //? Types Declarations
    enum Choice {
        ROCK,
        PAPER,
        SCISSORS
    }

    struct Game {
        address player1;
        address player2;
        Choice choice1;
        Choice choice2;
        uint gameId;
        bool resolved;
    }


    //? State Variables
    uint immutable private i_entranceFee;
    uint public s_gameId;
    mapping (uint=>Game) public games;

    //? Events 
    event FirstPlayerJoined(address indexed player, uint indexed gameId);
     event SecondPlayerJoined(address indexed player, uint indexed gameId);

    constructor(uint entranceFee) {
        i_entranceFee = entranceFee;
        s_gameId = 0;
    }

    function joinGame(uint256 _gameId, uint choice) external payable {
        if (msg.value < i_entranceFee) {
            revert RPC__NotEnoughEthSent();
        }
        Game storage _game = games[_gameId];
        
        if (_game.player1 == address(0)) {
            _game.player1 = msg.sender;
            _game.choice1 = Choice(choice);
            emit FirstPlayerJoined(msg.sender, _gameId);
        } else if (_game.player2 == address(0)) {
            if (msg.sender != _game.player1) {
                _game.player2 = msg.sender;
                _game.choice2 = Choice(choice);
                _game.resolved = true;
                emit SecondPlayerJoined(msg.sender, _gameId);
                s_gameId++;
            } else {
                revert RPC__GameAlreadyStarted(); 
            }
        }

    }
}