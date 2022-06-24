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

    // token URI => tokenId
    mapping(string => uint256) _tokenURIResolver;

    constructor(
        string memory name_,
        string memory symbol_
    ) ERC721(name_, symbol_) {
        _batchMint("");
    }

    /**
     * @notice This will burn your original land and mint 32 sub-lands, all of which are yours
     * @param tokenId_ tokenId of land which you want to divide
     */
    function divide(uint256 tokenId_) public {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "Geohash: transfer caller is not owner nor approved"
        );
        string memory parentURI_ = tokenURI(tokenId_);
        _burn(tokenId_);
        _deleteTokenURIResolver(parentURI_);
        _batchMint(parentURI_);
    }

    function tokenByURI(string memory tokenURI_) public view returns (uint256) {
        uint256 tokenId_ = _tokenURIResolver[tokenURI_];
        require(_exists(tokenId_), "Geohash: URI nonexistent token");
        return tokenId_;
    }

    function _batchMint(string memory parentURI_) internal {
        require(
            bytes(parentURI_).length > 0 || totalSupply() == 0,
            "Geohash: Only init once"
        );

        for (uint8 i = 0; i < 32; i++) {
            uint256 newId = uint256(
                keccak256(abi.encodePacked(parentURI_, alphabet[i]))
            );
            _tokenIdCounter.increment();
            _safeMint(_msgSender(), newId);
            _setTokenURI(
                newId,
                string(abi.encodePacked(parentURI_, alphabet[i]))
            );
            _setTokenURIResolver(
                newId,
                string(abi.encodePacked(parentURI_, alphabet[i]))
            );
        }
    }

    /**
     * @notice Resolver tokenURI to tokenId
     */
    function _setTokenURIResolver(uint256 tokenId_, string memory tokenURI_)
        internal
    {
        require(_exists(tokenId_), "Geohash: URI set of nonexistent token");
        _tokenURIResolver[tokenURI_] = tokenId_;
    }

    function _deleteTokenURIResolver(string memory tokenURI_) internal {
        if (_tokenURIResolver[tokenURI_] != 0) {
            delete _tokenURIResolver[tokenURI_];
        }
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId_
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from_, to_, tokenId_);
    }

    function _burn(uint256 tokenId_)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId_);
    }

    function tokenURI(uint256 tokenId_)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId_);
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
