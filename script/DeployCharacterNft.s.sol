// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {console} from "forge-std/console.sol";
import {CharacterNFT} from "../src/CharacterNft.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2Mock} from "@chainlink/contracts/src/v0.8/mocks/VRFCoordinatorV2Mock.sol";
import {DeployRPC} from "./DeployRPC.s.sol";
import {RPC} from "../src/RPC.sol";

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
    DeployRPC public deployer;
    RPC rpc;

    function run() public returns (CharacterNFT, HelperConfig) {
        helperConfig = new HelperConfig();
        CharacterNFT.RankImageUri memory rankImageUri = CharacterNFT
            .RankImageUri({
                s_rank0ImageUri: helperConfig.getRankImageUri().s_rank0ImageUri,
                s_rank1ImageUri: helperConfig.getRankImageUri().s_rank1ImageUri,
                s_rank2ImageUri: helperConfig.getRankImageUri().s_rank2ImageUri,
                s_rank3ImageUri: helperConfig.getRankImageUri().s_rank3ImageUri,
                s_rank4ImageUri: helperConfig.getRankImageUri().s_rank4ImageUri,
                s_rank5ImageUri: helperConfig.getRankImageUri().s_rank5ImageUri,
                s_rank6ImageUri: helperConfig.getRankImageUri().s_rank6ImageUri,
                s_rank7ImageUri: helperConfig.getRankImageUri().s_rank7ImageUri,
                s_rank8ImageUri: helperConfig.getRankImageUri().s_rank8ImageUri,
                s_rank9ImageUri: helperConfig.getRankImageUri().s_rank9ImageUri,
                s_rank10ImageUri: helperConfig
                    .getRankImageUri()
                    .s_rank10ImageUri
            });
        address owner = helperConfig.getOwnerAddress();

        vm.startBroadcast();
        characterNft = new CharacterNFT(rankImageUri, owner);
        vm.stopBroadcast();

        return (characterNft, helperConfig);
    }
}
