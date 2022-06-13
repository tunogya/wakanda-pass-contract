// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "./MintableERC20.sol";

/**
 * @title CarbonCredit
 * @dev CarbonCredit can only be minted through Meteorite contract
 * @author Wakanda Labs
 */
contract CarbonCredit is MintableERC20 {
    constructor(
        address _admin
    ) MintableERC721("Wakanda Carbon Credit", "CC", _admin) {}



}