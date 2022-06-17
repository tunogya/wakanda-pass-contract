// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.9;

interface IGeohash {
    event Divide(uint256 indexed tokenId);

    /**
     * @notice This will burn your original land and mint 32 sub-lands, all of which are yours
     * @param tokenId tokenId of land which you want to divide
     */
    function divide(uint256 tokenId) external;
}
