// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IGeohash.sol";

/**
 * @title Geohash
 * @dev Geohash use geohash algorithm. Each NFT can be cut into smaller pieces
 * @author Wakanda Labs
 */
contract Geohash is ERC721, ERC721Enumerable, ERC721URIStorage, IGeohash {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // The alphabet(32ghs) uses all digits 0-9 and almost all lower case letters except "a", "i", "l" and "o"
    // https://en.wikipedia.org/wiki/Geohash
    bytes constant alphabet = "0123456789bcdefghjkmnpqrstuvwxyz";

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
    function divide(uint256 tokenId_) external {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId_),
            "Geohash: transfer caller is not owner nor approved"
        );
        string memory parentURI_ = tokenURI(tokenId_);
        _burn(tokenId_);
        _batchMint(parentURI_);
    }

    /**
     * @notice Query tokenId by tokenURI
     * @dev abi.encodePacked will have many-to-one parameters and encodings, but every geohash is unique
     * @param tokenURI_ tokenURI you want to query
     * @return tokenId_ the query token's id which is not necessarily 100% valid
     * @return exists_ if the query token is exist, return true
     */
    function tokenByURI(string memory tokenURI_) external view returns (uint256 tokenId_, bool exists_) {
        tokenId_ = uint256(
            keccak256(abi.encodePacked(tokenURI_))
        );
        exists_ = _exists(tokenId_);
    }

    /**
     * @notice Batch mint by parentURI
     * @dev abi.encodePacked will have many-to-one parameters and encodings, but every geohash is unique
     * @param parentURI_ all URI was build by alphabet
     */
    function _batchMint(string memory parentURI_) internal {
        for (uint8 i = 0; i < alphabet.length; i++) {
            uint256 newId = uint256(
                keccak256(abi.encodePacked(parentURI_, alphabet[i]))
            );
            _tokenIdCounter.increment();
            _safeMint(_msgSender(), newId);
            _setTokenURI(
                newId,
                string(abi.encodePacked(parentURI_, alphabet[i]))
            );
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
