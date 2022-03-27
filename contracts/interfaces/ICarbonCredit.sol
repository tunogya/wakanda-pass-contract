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

    /**
     * @notice Allows the user who has Burner Role to burn tokens from a user account
     * @dev May be overridden to provide more granular control over burning
     * @param _user Address of the holder account to burn tokens from
     * @param _amount Amount of tokens to burn
     */
    function burn(address _user, uint256 _amount) external;

    /**
     * @notice Allows an operator via the user who has Burner Role to burn tokens on behalf of a user account
     * @dev May be overridden to provide more granular control over operator-burning
     * @param _operator Address of the operator performing the burn action via the burner contract
     * @param _user Address of the holder account to burn tokens from
     * @param _amount Amount of tokens to burn
     */
    function burnFrom(address _operator, address _user, uint256 _amount) external;
}