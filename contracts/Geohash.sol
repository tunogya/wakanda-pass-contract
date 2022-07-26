// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

import "./interfaces/IGeohash.sol";

/**
 * @title Geohash
 * @dev Geohash use geohash algorithm. Each NFT can be cut into smaller pieces
 * @author Wakanda Labs
 */
contract Geohash is
    ERC721,
    ERC721Enumerable,
    ERC721URIStorage,
    IGeohash,
    IERC721Receiver
{
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    // The alphabet(32ghs) uses all digits 0-9 and almost all lower case letters except "a", "i", "l" and "o"
    // https://en.wikipedia.org/wiki/Geohash
    bytes32 private constant ALPHABET = "0123456789bcdefghjkmnpqrstuvwxyz";

    constructor(string memory name_, string memory symbol_)
        ERC721(name_, symbol_)
    {
        _batchMint("", address(this));
    }

    /**
     * @notice This will burn your original land and mint 32 sub-lands, all of which are yours
     * @param tokenId tokenId of land which you want to divide
     */
    function divide(uint256 tokenId) external {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Geohash: transfer caller is not owner nor approved"
        );
        string memory parentURI_ = tokenURI(tokenId);
        _burn(tokenId);
        _batchMint(parentURI_, _msgSender());
    }

    /**
     * @notice This will burn your original land and mint 32 sub-lands, all of which are yours
     * @param tokenURI_ tokenId of land which you want to divide
     */
    function divideByURI(string memory tokenURI_) external {
        uint256 tokenId = uint256(keccak256(abi.encodePacked(tokenURI_)));
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Geohash: transfer caller is not owner nor approved"
        );
        string memory parentURI_ = tokenURI(tokenId);
        _burn(tokenId);
        _batchMint(parentURI_, _msgSender());
    }

    /**
     * @notice Query tokenId by tokenURI
     * @dev abi.encodePacked will have many-to-one parameters and encodings, but every geohash is unique
     * @param tokenURI_ tokenURI you want to query
     * @return tokenId the query token's id which is not necessarily 100% valid
     * @return exist if the query token is exist, return true
     */
    function tokenByURI(string memory tokenURI_)
        external
        view
        returns (uint256 tokenId, bool exist)
    {
        (tokenId, exist) = _tokenByURI(tokenURI_);
    }

    /**
     * @notice Query tokenId by tokenURI
     * @dev abi.encodePacked will have many-to-one parameters and encodings, but every geohash is unique
     * @param tokenURI_ tokenURI you want to query
     * @return tokenId the query token's id which is not necessarily 100% valid
     * @return exist if the query token is exist, return true
     */
    function _tokenByURI(string memory tokenURI_)
        internal
        view
        returns (uint256 tokenId, bool exist)
    {
        tokenId = uint256(keccak256(abi.encodePacked(tokenURI_)));
        exist = _exists(tokenId);
    }

    /**
     * @notice Batch mint by origin
     * @dev abi.encodePacked will have many-to-one parameters and encodings, but every geohash is unique
     * @param origin all URI was build by alphabet
     * @param to address of the owner of the sub-lands
     */
    function _batchMint(string memory origin, address to) internal {
        for (uint8 i = 0; i < 32; i++) {
            uint256 newId = uint256(
                keccak256(abi.encodePacked(origin, ALPHABET[i]))
            );
            _tokenIdCounter.increment();
            _safeMint(to, newId);
            _setTokenURI(newId, string(abi.encodePacked(origin, ALPHABET[i])));
        }
    }

    // TODO add a function to query tokenURI by tokenId
    function tokenURI(uint256 tokenId) external view returns (string memory) {
        return _tokenURI(tokenId);
    }

    /**
     * @notice Renounce the ownership of the token
     * @param tokenId tokenId you want to renounce
     */
    function renounce(uint256 tokenId) external {
        safeTransferFrom(_msgSender(), address(this), tokenId);
    }

    /**
     * @notice Renounce the ownership of the token
     * @param tokenURI_ tokenURI you want to renounce
     */
    function renounceByURI(string memory tokenURI_) external {
        (uint256 tokenId, ) = _tokenByURI(tokenURI_);
        safeTransferFrom(_msgSender(), address(this), tokenId);
    }

    /**
     * @notice Claim a token from No Man's Land
     * @param tokenId tokenId you want to claim
     */
    function claim(uint256 tokenId) external {
        require(_exists(tokenId), "Geohash: tokenURI does not exist");
        _transfer(address(this), _msgSender(), tokenId);
    }

    /**
     * @notice Claim a token from No Man's Land
     * @param tokenURI_ tokenURI you want to claim
     */
    function claimByURI(string memory tokenURI_) external {
        (uint256 tokenId, bool exist) = _tokenByURI(tokenURI_);
        require(exist, "Geohash: tokenURI does not exist");
        _transfer(address(this), _msgSender(), tokenId);
    }

    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(
        address from_,
        address to_,
        uint256 tokenId
    ) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from_, to_, tokenId);
    }

    function _burn(uint256 tokenId)
        internal
        override(ERC721, ERC721URIStorage)
    {
        super._burn(tokenId);
    }

    function _tokenURI(uint256 tokenId)
    internal
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

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}
