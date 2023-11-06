// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CharacterNFT} from "../src/CharacterNft.sol";
import {HelperConfig} from "./HelperConfig.s.sol";

contract DeployCharacterNft is Script {
    struct RankImageUri {
        string s_rank0ImageUri;
        string s_rank1ImageUri;
        string s_rank2ImageUri;
        string s_rank3ImageUri;
        string s_rank4ImageUri;
        string s_rank5ImageUri;
        string s_rank6ImageUri;
        string s_rank7ImageUri;
        string s_rank8ImageUri;
        string s_rank9ImageUri;
        string s_rank10ImageUri;
    }

    CharacterNFT public characterNft;
    HelperConfig public helperConfig;

    function run() public returns (CharacterNFT, HelperConfig) {
        helperConfig = new HelperConfig();

        console.log(helperConfig.getRankImageUri().s_rank0ImageUri);
        vm.startBroadcast();
        RankImageUri memory rankImageUri;
        characterNft = new CharacterNFT(rankImageUri, msg.sender);
        vm.stopBroadcast();

        return (characterNft, helperConfig);
    }
}
