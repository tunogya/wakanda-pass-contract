// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

/**
 * @title IMintableERC20
 * @author Wakanda Labs
 * @notice
 */
interface IMintableERC20 is IERC20 {
    /**
     * @notice Allows the user who has Minter Role to mint tokens for a user account
     * @dev May be overridden to provide more granular control over minting
     * @param user Address of the receiver
     * @param amount Amount of tokens to mint
     */
    function mint(address user, uint256 amount) external;

    /**
     * @notice called when user wants to withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param amount amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external;

    /**
     * @notice called when token is deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required amount for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded amount
     */
    function deposit(address user, bytes calldata depositData) external;
}