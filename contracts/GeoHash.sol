// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Hash Planet
 * @dev Hash Planet use geohash algorithm. Each NFT can be cut into smaller pieces
 * @author Wakanda Labs
 */
contract HashPlanet is ERC721, ERC721Enumerable, ERC721URIStorage {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // The alphabet(32ghs) uses all digits 0-9 and almost all lower case letters except "a", "i", "l" and "o"
    // https://en.wikipedia.org/wiki/Geohash
    bytes constant alphabet = "0123456789bcdefghjkmnpqrstuvwxyz";

    constructor(
        string memory _name,
        string memory _symbol,
        address _genesis
    ) ERC721(_name, _symbol) {
        require(
            address(_genesis) != address(0),
            "HashPlanet/genesis-not-zero-address"
        );
        for (uint8 i = 0; i < 32; i ++) {
            safeMint(_genesis, string(abi.encodePacked(alphabet[i])));
        }
    }

    /**
     * @param to receiver address
     * @param uri geohash
     */
    function safeMint(address to, string memory uri) internal {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, uri);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
    internal
    override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
    public
    view
    override(ERC721, ERC721URIStorage)
    returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
    public
    view
    override(ERC721, ERC721Enumerable)
    returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}