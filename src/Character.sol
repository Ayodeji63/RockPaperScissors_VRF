// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";

contract Charachter is ERC721 {
    //? Types Declaration
    struct LevelsImageUri {
        string s_level1ImageUri;
        string s_level2ImageUri;
        string s_level3ImageUri;
        string s_level4ImageUri;
        string s_level5ImageUri;
        string s_level6ImageUri;
        string s_level7ImageUri;
        string s_level8ImageUri;
        string s_level9ImageUri;
        string s_level10ImageUri;
    }

    uint private s_tokenCounter;
    LevelsImageUri private s_levelImageUri;

    constructor(
        LevelsImageUri calldata levelImageUri
    ) ERC721("Charachter NFT", "CH") {
        s_tokenCounter = 0;
        s_levelImageUri = levelImageUri;
    }

    function mintCharacter() {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }
}
