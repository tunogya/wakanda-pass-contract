// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "./MintableERC721.sol";
import "./MintableERC20.sol";

/**
 * @title Meteorite
 * @dev Meteorite NFT can mint CarbonCredit and Vibranium Tokens
 * @author Wakanda Labs
 */
contract Meteorite is MintableERC721 {
    MintableERC20 immutable CARBON_CREDIT_ADDRESS;
    MintableERC20 immutable VIBRANIUM_ADDRESS;

    constructor(
        address _admin,
        MintableERC20 _carbon_credit,
        MintableERC20 _vibranium
    ) MintableERC721("Meteorite", "METE", _admin) {
        CARBON_CREDIT_ADDRESS = _carbon_credit;
        VIBRANIUM_ADDRESS = _vibranium;
    }

}