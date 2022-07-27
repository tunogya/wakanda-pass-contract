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
        _divide(tokenId);
    }

    /**
     * @notice This will burn your original land and mint 32 sub-lands, all of which are yours
     * @param tokenURI_ tokenId of land which you want to divide
     */
    function divideByURI(string memory tokenURI_) external {
        uint256 tokenId = uint256(keccak256(abi.encodePacked(tokenURI_)));
        _divide(tokenId);
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

    function _divide(uint256 tokenId) internal {
        require(
            _isApprovedOrOwner(_msgSender(), tokenId),
            "Geohash: transfer caller is not owner nor approved"
        );
        string memory parentURI_ = _tokenURI(tokenId);
        _burn(tokenId);
        _batchMint(parentURI_, _msgSender());
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
        string[11] memory parts;
        parts[0] = '<svg width="800" height="600" xmlns="http://www.w3.org/2000/svg" fill="none"><g>';
        parts[1] = '<rect id="svg_1" stroke-width="2" stroke="#222222" fill="white" rx="23" height="398" width="633" y="101.71429" x="84"/>';
        parts[2] = '<path id="svg_2" fill="#222222" d="m218.192,163.612l0,33.942l-5.691,0l0,-6.158c-1.374,2.473 -3.127,4.359 -5.262,5.657c-2.134,1.298 -4.524,1.947 -7.17,1.947c-4.918,0 -8.881,-1.676 -11.889,-5.027c-3.009,-3.351 -4.513,-7.783 -4.513,-13.297c0,-5.589 1.461,-10.034 4.382,-13.336c2.921,-3.302 6.828,-4.952 11.721,-4.952c2.87,0 5.361,0.636 7.471,1.91c2.11,1.273 3.814,3.171 5.111,5.694l0,-6.38l5.84,0zm-5.691,17.286c0,-3.833 -1.056,-6.918 -3.169,-9.255c-2.112,-2.337 -4.864,-3.506 -8.257,-3.505c-3.519,0 -6.266,1.075 -8.238,3.227c-1.973,2.152 -2.956,5.156 -2.951,9.013c0,4.106 0.992,7.272 2.977,9.497c1.985,2.226 4.799,3.339 8.442,3.34c3.495,0 6.235,-1.082 8.22,-3.246c1.984,-2.163 2.976,-5.187 2.977,-9.071l-0.001,0z"/>';
        parts[3] = '<path id="svg_3" fill="#222222" d="m221.164,198.903l0,-57.496l5.88,0l0,38.949l16.514,-15.394l7.826,0l-17.114,15.543l18.65,18.398l-8.202,0l-17.674,-17.916l0,17.916l-5.88,0z"/>';
        parts[4] = '<path id="svg_4" fill="#222222" d="m281.741,163.564l0,33.941l-5.692,0l0,-6.158c-1.373,2.474 -3.127,4.359 -5.261,5.657c-2.134,1.299 -4.525,1.948 -7.171,1.948c-4.919,0 -8.882,-1.676 -11.89,-5.026c-3.007,-3.351 -4.511,-7.784 -4.513,-13.299c0,-5.589 1.461,-10.034 4.382,-13.335c2.921,-3.301 6.828,-4.952 11.721,-4.952c2.871,0 5.361,0.637 7.471,1.91c2.11,1.274 3.813,3.172 5.111,5.694l0,-6.38l5.842,0zm-5.692,17.286c0,-3.833 -1.055,-6.918 -3.165,-9.255c-2.11,-2.337 -4.862,-3.505 -8.257,-3.506c-3.519,0 -6.265,1.076 -8.238,3.228c-1.973,2.152 -2.959,5.156 -2.958,9.014c0,4.105 0.993,7.27 2.977,9.496c1.984,2.225 4.799,3.338 8.444,3.338c3.495,0 6.235,-1.082 8.22,-3.246c1.984,-2.164 2.977,-5.187 2.977,-9.069z"/>';
        parts[5] = '<path id="svg_6" fill="#222222" d="m352.138,140l0,57.496l-5.691,0l0,-6.158c-1.349,2.448 -3.096,4.328 -5.243,5.639c-2.146,1.311 -4.543,1.968 -7.19,1.968c-4.918,0 -8.881,-1.675 -11.889,-5.026c-3.008,-3.351 -4.512,-7.784 -4.513,-13.298c0,-5.564 1.473,-10.003 4.419,-13.316c2.947,-3.314 6.866,-4.971 11.759,-4.972c2.847,0 5.318,0.637 7.414,1.91c2.096,1.274 3.793,3.171 5.09,5.692l0,-29.935l5.844,0zm-5.691,40.692c0,-3.783 -1.061,-6.83 -3.184,-9.142c-2.122,-2.311 -4.918,-3.468 -8.388,-3.47c-3.47,0 -6.179,1.051 -8.127,3.154c-1.947,2.102 -2.92,5.007 -2.92,8.717c0,4.179 0.987,7.449 2.962,9.811c1.974,2.361 4.695,3.542 8.163,3.542c3.595,0 6.41,-1.113 8.445,-3.338c2.034,-2.226 3.05,-5.317 3.049,-9.274z"/>';
        parts[6] = '<path id="svg_7" fill="#222222" d="m389,163.537l0,33.942l-5.692,0l0,-6.157c-1.373,2.473 -3.127,4.359 -5.261,5.657c-2.134,1.298 -4.524,1.947 -7.171,1.947c-4.918,0 -8.881,-1.675 -11.889,-5.026c-3.008,-3.35 -4.512,-7.783 -4.513,-13.298c0,-5.589 1.461,-10.034 4.381,-13.335c2.921,-3.301 6.828,-4.952 11.721,-4.952c2.871,0 5.361,0.636 7.471,1.91c2.111,1.273 3.814,3.171 5.111,5.694l0,-6.382l5.842,0zm-5.692,17.288c0,-3.833 -1.054,-6.918 -3.164,-9.255c-2.11,-2.337 -4.862,-3.506 -8.257,-3.506c-3.52,0 -6.266,1.076 -8.238,3.228c-1.972,2.151 -2.959,5.156 -2.962,9.013c0.001,4.104 0.995,7.27 2.98,9.498c1.986,2.229 4.801,3.342 8.445,3.339c3.494,0 6.234,-1.082 8.219,-3.246c1.985,-2.164 2.977,-5.188 2.977,-9.071z"/>';
        parts[7] = ' <path id="svg_8" fill="#222222" d="m188.09,147.657l-12.572,32.532l-13.864,-32.532l-0.038,0.015l-0.006,-0.015l-9.676,0l7.83,19.125l-5.18,13.407l-13.865,-32.532l-0.038,0.015l-0.006,-0.015l-9.675,0l20.841,50.905l3.175,-8.211l6.991,-18.091l10.768,26.302l3.175,-8.211l16.498,-42.694l-4.358,0z"/>';
        parts[8] = '<text xml:space="preserve" text-anchor="start" font-family="Noto Sans JP" font-size="24" id="svg_9" y="368" x="124" stroke-width="0" stroke="#000" fill="#222222">#';
        parts[9] = _tokenURI(tokenId);
        parts[10] = '</text></g></svg>';
        string memory output = string(abi.encodePacked(parts[0], parts[1], parts[2], parts[3], parts[4], parts[5], parts[6], parts[7], parts[8], parts[9], parts[10]));
        string memory json = Base64.encode(bytes(string(abi.encodePacked('{"name": "', _name, ' #', _tokenURI(tokenId), '", "description": "Welcome to Wakanda Metaverse!", "image": "data:image/svg+xml;base64,', Base64.encode(bytes(output)), '"}'))));
        output = string(abi.encodePacked('data:application/json;base64,', json));
        return output;
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
        (uint256 tokenId,) = _tokenByURI(tokenURI_);
        safeTransferFrom(_msgSender(), address(this), tokenId);
    }

    /**
     * @notice Claim a token from No Man's Land
     * @param tokenId tokenId you want to claim
     */
    function claim(uint256 tokenId) external {
        require(_exists(tokenId), "Geohash: tokenId does not exist");
        _safeTransfer(address(this), _msgSender(), tokenId, "");
    }

    /**
     * @notice Claim a token from No Man's Land
     * @param tokenURI_ tokenURI you want to claim
     */
    function claimByURI(string memory tokenURI_) external {
        (uint256 tokenId, bool exist) = _tokenByURI(tokenURI_);
        require(exist, "Geohash: tokenURI does not exist");
        _safeTransfer(address(this), _msgSender(), tokenId);
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
