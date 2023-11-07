// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {CharacterNFT} from "../../src/CharacterNft.sol";
import {DeployCharacterNft} from "../../script/DeployCharacterNft.s.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";
import {RPC} from "../../src/RPC.sol";
import {DeployRPC} from "../../script/DeployRPC.s.sol";
import {Vm} from "forge-std/Vm.sol";

contract CharacterNftTest is Test {
    DeployCharacterNft public deployer;
    DeployRPC public deployRpc;
    CharacterNFT public characterNFT;
    HelperConfig public helperConfig;
    RPC public rpc;
    address public PLAYER_1 = makeAddr("player1");
    address public PLAYER_2 = makeAddr("player2");
    uint public s_player1tokenId;
    uint public s_plater2tokenId;
    uint public entranceFee = 0.01 ether;
    uint private STARTING_BALANCE = 100 ether;
    address vrfCoordinator;
    string private STARTER_TOKEN_URI =
        "data:application/json;base64,eyJuYW1lIjogIkNoYXJhY2h0ZXIgTkZUIiwgImRlc2NyaXB0aW9uIjoiQW4gTkZUIHRoYXQgcmVmbGVjdHMgdGhlIG93bmVyJ3MgcmFuay4iLCAiYXR0cmlidXRlcyI6IFt7InRyYWl0X3R5cGUiOiAibW9vZGluZXNzIiwgInZhbHVlIjogMTAwfV0sICJpbWFnZSI6ICJkYXRhOmltYWdlL3N2Zyt4bWw7YmFzZTY0LFBITjJaeUI0Yld4dWN6MGlhSFIwY0RvdkwzZDNkeTUzTXk1dmNtY3ZNakF3TUM5emRtY2lJSGRwWkhSb1BTSXlNREFpSUdobGFXZG9kRDBpTWpBd0lqNDhjR0YwYUNCbWFXeHNQU0lqWmpKbU1tWXlJaUJrUFNKTk1DQXdhREl3TUhZeU1EQklNSG9pTHo0OFkybHlZMnhsSUdONFBTSXhNREFpSUdONVBTSXhNREFpSUhJOUlqZ3dJaUJtYVd4c1BTSWpZamt5T1dJMklpOCtQSFJsZUhRZ2VEMGlNVEF3SWlCNVBTSXhNVEFpSUdadmJuUXRabUZ0YVd4NVBTSkJjbWxoYkN3Z2MyRnVjeTF6WlhKcFppSWdabTl1ZEMxemFYcGxQU0kwTUNJZ1ptOXVkQzEzWldsbmFIUTlJbUp2YkdRaUlHWnBiR3c5SWlObVptWWlJSFJsZUhRdFlXNWphRzl5UFNKdGFXUmtiR1VpUGxOMFlYSjBaWEk4TDNSbGVIUStQSEJoZEdnZ1pEMGlUVEV3TUNBMk1HTXhNeTR5SURBZ01qUXRNVEF1T0NBeU5DMHlOSE10TVRBdU9DMHlOQzB5TkMweU5DMHlOQ0F4TUM0NExUSTBJREkwSURFd0xqZ2dNalFnTWpRZ01qUjZiVFl1TmlBeE5TNDJZeTB4TGpnZ01TNDRMVFF1T0NBeExqZ3ROaTQySURCc0xUSXdMUzR5TFRndU5pQTRMalpNT1RFZ01UQXpMalpqTVM0NElERXVPQ0EwTGpnZ01TNDRJRFl1TmlBd0lERXVPQzB4TGpnZ01TNDRMVFF1T0NBd0xUWXVOa3c0TmlBMk9DNDRiRGt1TmkwNUxqWjZJaUJtYVd4c1BTSWpabVptSWk4K1BIQmhkR2dnWm1sc2JEMGlJMll6T1dNeE1pSWdaRDBpVFRZd0lEUXdhRE5zTVMwMElERWdOR2d6YkMweUlETWdNaUF4TFRNZ01pMHhJRFF0TVMwMExUTXRNU0F5TFRKNlRUZ3dJREl3YUROc01TMDBJREVnTkdnemJDMHlJRE1nTWlBeExUTWdNaTB4SURRdE1TMDBMVE10TVNBeUxUSjZUVEV5TUNBek1HZ3piREV0TkNBeElEUm9NMnd0TWlBeklESWdNUzB6SURJdE1TQTBMVEV0TkMwekxURWdNaTB5ZWsweE5EQWdNVEJvTTJ3eExUUWdNU0EwYUROc0xUSWdNeUF5SURFdE15QXlMVEVnTkMweExUUXRNeTB4SURJdE1ucE5NVGN3SURVd2FETnNNUzAwSURFZ05HZ3piQzB5SURNZ01pQXhMVE1nTWkweElEUXRNUzAwTFRNdE1TQXlMVEo2SWk4K1BHTnBjbU5zWlNCamVEMGlOakFpSUdONVBTSXhOREFpSUhJOUlqWWlJR1pwYkd3OUlpTm1NemxqTVRJaUx6NDhZMmx5WTJ4bElHTjRQU0l6TUNJZ1kzazlJamN3SWlCeVBTSTJJaUJtYVd4c1BTSWpaak01WXpFeUlpOCtQR05wY21Oc1pTQmplRDBpTVRZd0lpQmplVDBpTXpBaUlISTlJallpSUdacGJHdzlJaU5tTXpsak1USWlMejQ4WTJseVkyeGxJR040UFNJeE5EQWlJR041UFNJeE5qQWlJSEk5SWpZaUlHWnBiR3c5SWlObU16bGpNVElpTHo0OFkybHlZMnhsSUdONFBTSXhNREFpSUdONVBTSXhPREFpSUhJOUlqWWlJR1pwYkd3OUlpTm1NemxqTVRJaUx6NDhMM04yWno0PSJ9";

    event CharachterMinted(uint indexed tokenId);
    event RankIncreased(uint indexed tokenId, uint indexed characterRank);

    function setUp() public {
        deployer = new DeployCharacterNft();
        deployRpc = new DeployRPC();
        (rpc, helperConfig, characterNFT) = deployRpc.run();
        vm.deal(PLAYER_1, STARTING_BALANCE);
    }

    modifier playerMintToken() {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        vm.prank(PLAYER_2);
        characterNFT.mintCharacter();
        _;
    }

    modifier playersJoinedGame() {
        vm.prank(PLAYER_1);
        vm.recordLogs();
        characterNFT.mintCharacter();
        Vm.Log[] memory _entries = vm.getRecordedLogs();
        bytes32 tokenId1 = _entries[1].topics[1];
        s_player1tokenId = uint(tokenId1);
        vm.prank(PLAYER_1);
        rpc.joinGame{value: entranceFee}(0, s_player1tokenId);
        vm.prank(PLAYER_2);
        vm.recordLogs();
        characterNFT.mintCharacter();
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 tokenId2 = entries[1].topics[1];
        s_plater2tokenId = uint(tokenId2);
        vm.prank(PLAYER_2);
        rpc.joinGame{value: entranceFee}(2, s_plater2tokenId);
        _;
    }

    function testShouldMintCharacter() public {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();
        assert(characterNFT.balanceOf(PLAYER_1) != 0);
    }

    function testShouldEmitEventWhenCharacterIsMinted() public {
        vm.prank(PLAYER_1);
        vm.expectEmit(true, false, false, false, address(characterNFT));
        emit CharachterMinted(0);
        characterNFT.mintCharacter();
    }

    function testShouldSetOwner() public view {
        address owner = characterNFT.getOwnerAddress();
        assert(owner == helperConfig.getOwnerAddress());
    }

    function testShouldRevertIfNotOnwer() public {
        vm.prank(PLAYER_1);
        vm.expectRevert(
            abi.encodePacked(CharacterNFT.CharacterNFT__OnlyOwner.selector)
        );
        characterNFT.setvrfCoordinatorContract(address(rpc));
    }

    function testShouldSetvrfCoordinatorContract() public {
        address owner = helperConfig.getOwnerAddress();

        vm.prank(owner);
        characterNFT.setvrfCoordinatorContract(address(rpc));
        assert(characterNFT.getRpcContract() == address(rpc));
    }

    function testTokenUriForStarter() public {
        vm.prank(PLAYER_1);
        characterNFT.mintCharacter();

        string memory tokenUri = characterNFT.tokenURI(0);
        assert(
            keccak256(bytes(abi.encodePacked(tokenUri))) ==
                keccak256(bytes(abi.encodePacked(STARTER_TOKEN_URI)))
        );
    }

    function testFlipRankNumShouldEmitEvent() public playersJoinedGame {
        vm.prank(address(rpc));
        vm.expectEmit(true, true, false, false, address(characterNFT));
        emit RankIncreased(s_player1tokenId, 1);
        characterNFT.FlipRankNum(s_player1tokenId, true);
    }

    function testFlipRankAndIncreaseRank() public playersJoinedGame {
        vm.startPrank(address(rpc));
        uint player1InitialRank = characterNFT.getCharacterRank(
            s_player1tokenId
        );
        uint player2InitialRank = characterNFT.getCharacterRank(
            s_plater2tokenId
        );
        characterNFT.FlipRankNum(s_player1tokenId, false);
        characterNFT.FlipRankNum(s_plater2tokenId, true);
        uint player1FinalRank = characterNFT.getCharacterRank(s_player1tokenId);
        uint player2FinalRank = characterNFT.getCharacterRank(s_plater2tokenId);
        vm.stopPrank();

        assert(player1FinalRank == player1InitialRank);
        assert(player2FinalRank > player2InitialRank);
    }
}
