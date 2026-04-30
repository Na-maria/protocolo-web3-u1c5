// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ProtocoloNFT is ERC721, Ownable {
    uint256 private nextTokenId = 1;
    mapping(uint256 => string) private tokenURIs;

    event NFTMintado(address indexed usuario, uint256 indexed tokenId, string uri);

    constructor(address initialOwner)
        ERC721("Protocolo Membership NFT", "PMNFT")
        Ownable(initialOwner)
    {}

    function mint(address to, string memory uri) external onlyOwner returns (uint256) {
        require(to != address(0), "Endereco invalido");
        require(bytes(uri).length > 0, "URI obrigatoria");

        uint256 tokenId = nextTokenId;
        nextTokenId++;

        _safeMint(to, tokenId);
        tokenURIs[tokenId] = uri;

        emit NFTMintado(to, tokenId, uri);
        return tokenId;
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        _requireOwned(tokenId);
        return tokenURIs[tokenId];
    }
}
