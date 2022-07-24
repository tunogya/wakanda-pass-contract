// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface IGeohash {
    /**
     * @notice This will burn your original land and mint 32 sub-lands, all of which are yours
     * @param tokenId_ tokenId of land which you want to divide
     */
    function divide(uint256 tokenId_) external;

    /**
     * @notice Query tokenId by tokenURI
     * @param tokenURI_ tokenURI you want to query
     * @return tokenId_ the query token's id which is not necessarily 100% valid
     * @return exists_ if the query token is exist, return true
     */
    function tokenByURI(string memory tokenURI_) external view returns (uint256 tokenId_, bool exists_);
}