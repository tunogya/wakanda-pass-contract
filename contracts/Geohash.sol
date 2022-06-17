// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

/**
 * @title Geohash
 * @dev Geohash use geohash algorithm. Each NFT can be cut into smaller pieces
 * @author Wakanda Labs
 */
contract Geohash is ERC721, ERC721Enumerable, ERC721URIStorage {
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
            "Geohash/genesis-not-zero-address"
        );
        for (uint8 i = 0; i < 32; i ++) {
            uint256 tokenId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_genesis, tokenId);
            _setTokenURI(tokenId, string(abi.encodePacked(alphabet[i])));
        }
    }

    /**
     * @notice This will destroy your original land and generate 32 sub-lands, all of which are yours
     * @param tokenId tokenId of land which you want to division
     */
    function division(uint256 tokenId) public {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "Geohash: transfer caller is not owner nor approved");
        string memory parentURI = tokenURI(tokenId);
        _burn(tokenId);
        for (uint8 i = 0; i < 32; i ++) {
            uint256 newId = _tokenIdCounter.current();
            _tokenIdCounter.increment();
            _safeMint(_msgSender(), newId);
            _setTokenURI(newId, string(abi.encodePacked(parentURI, alphabet[i])));
        }
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