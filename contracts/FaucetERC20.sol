// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IMintableERC20.sol";

pragma solidity ^0.8.9;

/**
 * @title FaucetERC20
 * @author Wakanda Labs
 */
contract FaucetERC20 {
    /* ============ Global Variables ============ */

    /// @notice IMintableERC20 Token address
    IMintableERC20 public immutable token;

    /* ============ Initialize ============ */

    /**
     * @notice Deploy FaucetERC20 contract
     * @param _token Address of the IMintableERC20
     */
    constructor(
        IMintableERC20 _token
    ) {
        token = _token;
    }

    /* ============ External Functions ============ */


    /* ============ Internal Functions ============ */

}
