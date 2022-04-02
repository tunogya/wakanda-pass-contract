// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title CarbonCredit
 * @author Wakanda Labs
 * @notice
 */
interface ICarbonCredit is IERC20 {
    /**
     * @notice Allows the user who has Minter Role to mint tokens for a user account
     * @dev May be overridden to provide more granular control over minting
     * @param _user Address of the receiver
     * @param _amount Amount of tokens to mint
     */
    function mint(address _user, uint256 _amount) external;
}