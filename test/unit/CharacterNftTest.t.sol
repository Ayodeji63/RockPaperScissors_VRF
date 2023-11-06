// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {CharacterNFT} from "../../src/CharacterNft.sol";
import {DeployCharacterNft} from "../../script/DeployCharacterNft.s.sol";

contract CharacterNftTest is Test {
    DeployCharacterNft public deployer;
    CharacterNFT public characterNFT;
    address public PLAYER_1 = makeAddr("player1");
    uint private STARTING_BALANCE = 100 ether;

    function setUp() public {
        deployer = new DeployCharacterNft();
        (characterNFT) = deployer.run();
        vm.deal(PLAYER_1, STARTING_BALANCE);
    }

    function testShouldMintCharacter() public {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();

        assert(characterNFT.balanceOf(PLAYER_1) != 0);
    }
}
