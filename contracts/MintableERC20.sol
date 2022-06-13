// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IMintableERC20.sol";

/**
 * @title MintableERC20
 * @author Wakanda Labs
 */
contract MintableERC20 is AccessControl, ERC20Permit, IMintableERC20 {
    using SafeERC20 for IERC20;

    /* ============ ROLES ============ */

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /* ============ Initialize ============ */

    /**
     * @notice Deploy ChildMintableERC20 smart contract
     * @param _name token name
     * @param _symbol token symbol
     * @param _admin admin, default has the role of MINTER_ROLE
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _admin
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        require(
            address(_admin) != address(0),
            "MintableERC20/admin-not-zero-address"
        );
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
    }

    /* ============ External Functions ============ */

    /**
     * @notice Allows the user who has Minter Role to mint tokens for a user account
     * @dev May be overridden to provide more granular control over minting
     * @param user address of the receiver
     * @param amount amount of tokens to mint
     */
    function mint(
        address user,
        uint256 amount
    ) external virtual override onlyRole(MINTER_ROLE)
    {
        _mint(user, amount);
    }

    /* ============ Internal Functions ============ */
}
