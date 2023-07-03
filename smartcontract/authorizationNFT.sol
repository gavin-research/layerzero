// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract MyNFTCollection is ERC721 {
    using Strings for uint256;

    string private _vbaseURI ;

    constructor(string memory baseURI) ERC721("Redondos", "RDD") {
        _vbaseURI = baseURI;
    }

    function _baseURI() internal view override returns (string memory) {
        return _vbaseURI;
    }

    function setBaseURI(string memory baseURI) external {
        _vbaseURI = baseURI;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return string(abi.encodePacked(_vbaseURI, "/", tokenId.toString(), ".json"));
    }

    function mint(address to, uint256 tokenId) public {
        _mint(to, tokenId);
    }
}

contract NFTCollectionCreator {
    MyNFTCollection public collection;

    constructor(string memory baseURI) {
        collection = new MyNFTCollection(baseURI);
    }

    function createCollection() public {
        for (uint256 i = 1; i <= 10; i++) {
            collection.mint(msg.sender, i);
        }
    }
}
