// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "./MintableERC20.sol";

/**
 * @title Vibranium
 * @dev Vibranium can only be minted through Meteorite contract
 * @author Wakanda Labs
 */
contract Vibranium is MintableERC20 {
    constructor(
        address _admin
    ) MintableERC721("Wakanda Vibranium", "VBR", _admin) {}


}