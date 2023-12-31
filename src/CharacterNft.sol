// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract CharacterNFT is ERC721 {
    //? Errors
    error CharacterNFT__CantFlipImageUri();
    error CharacterNFT__OnlyRpcContract();
    error CharacterNFT__OnlyOwner();
    //? Types Declaration

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

    //? Events
    event CharachterMinted(uint256 indexed tokenId);
    event RankIncreased(uint256 indexed tokenId, uint256 indexed characterRank);
    //? State Variables

    uint256 private s_tokenCounter;
    RankImageUri private s_rankImageUri;
    address private s_rpcContract;
    address private immutable i_owner;
    mapping(uint256 => uint256) public s_ranksNum;

    constructor(RankImageUri memory rankImageUri, address owner) ERC721("Charachter NFT", "CH") {
        s_tokenCounter = 0;
        s_rankImageUri = rankImageUri;
        i_owner = owner;
    }

    modifier onlyVrfCoordinatorContract() {
        if (msg.sender != s_rpcContract) {
            revert CharacterNFT__OnlyRpcContract();
        }
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != i_owner) {
            revert CharacterNFT__OnlyOwner();
        }
        _;
    }

    function mintCharacter() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_ranksNum[s_tokenCounter] = 0;
        emit CharachterMinted(s_tokenCounter);
        s_tokenCounter++;
    }

    function setvrfCoordinatorContract(address rpcContract) external onlyOwner {
        s_rpcContract = rpcContract;
    }

    function FlipRankNum(uint256 tokenId, bool winOrLose) external {
        uint256 currentRank = s_ranksNum[tokenId];
        uint256 tokenRank;

        if (winOrLose && currentRank < 10) {
            s_ranksNum[tokenId] = currentRank + 1;
            tokenRank = s_ranksNum[tokenId];
        } else if (!winOrLose && currentRank > 0) {
            s_ranksNum[tokenId] = currentRank - 1;
            tokenRank = s_ranksNum[tokenId];
        }
        emit RankIncreased(tokenId, tokenRank);
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        uint256 tokenRank = s_ranksNum[tokenId];
        string memory imageURI;
        if (tokenRank == 0) {
            imageURI = s_rankImageUri.s_rank0ImageUri;
        }
        if (tokenRank == 1) {
            imageURI = s_rankImageUri.s_rank1ImageUri;
        }
        if (tokenRank == 2) {
            imageURI = s_rankImageUri.s_rank2ImageUri;
        }
        if (tokenRank == 3) {
            imageURI = s_rankImageUri.s_rank3ImageUri;
        }
        if (tokenRank == 4) {
            imageURI = s_rankImageUri.s_rank4ImageUri;
        }
        if (tokenRank == 5) {
            imageURI = s_rankImageUri.s_rank5ImageUri;
        }
        if (tokenRank == 6) {
            imageURI = s_rankImageUri.s_rank6ImageUri;
        }
        if (tokenRank == 7) {
            imageURI = s_rankImageUri.s_rank7ImageUri;
        }
        if (tokenRank == 8) {
            imageURI = s_rankImageUri.s_rank8ImageUri;
        }
        if (tokenRank == 9) {
            imageURI = s_rankImageUri.s_rank9ImageUri;
        }
        if (tokenRank == 10) {
            imageURI = s_rankImageUri.s_rank10ImageUri;
        }

        return string(
            abi.encodePacked(
                _baseURI(),
                Base64.encode(
                    bytes(
                        abi.encodePacked(
                            '{"name": "',
                            name(),
                            '", "description":"An NFT that reflects the owner\'s rank.", "attributes": [{"trait_type": "moodiness", "value": 100}], "image": "',
                            imageURI,
                            '"}'
                        )
                    )
                )
            )
        );
    }

    ////////////////////
    // View Function //
    ///////////////////

    function getOwnerAddress() public view returns (address) {
        return i_owner;
    }

    function getRpcContract() public view returns (address) {
        return s_rpcContract;
    }

    function getCharacterRank(uint256 tokenId) public view returns (uint256) {
        return s_ranksNum[tokenId];
    }
}
