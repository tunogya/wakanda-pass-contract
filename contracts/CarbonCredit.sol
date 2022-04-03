// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/ICarbonCredit.sol";

/**
 * @title CarbonCredit
 * @author Wakanda Labs
 * @notice
 */
contract CarbonCredit is AccessControl, ERC20Permit, ERC20Burnable, ICarbonCredit {
    using SafeERC20 for IERC20;

    /* ============ ROLES ============ */

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    /* ============ Initialize ============ */

    /**
     * @notice Deploy CarbonCredit smart contract.
     * @param _name Address of the owner of the DrawBuffer.
     * @param _symbol Draw ring buffer cardinality.
     * @param _admin Admin.
     */
    constructor(
        string memory _name,
        string memory _symbol,
        address _admin
    ) ERC20(_name, _symbol) ERC20Permit(_name) {
        require(
            address(_admin) != address(0),
            "CarbonCredit/admin-not-zero-address"
        );
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _admin);
    }

    /* ============ External Functions ============ */

    /**
     * @notice Allows the user who has Minter Role to mint tokens for a user account
     * @dev May be overridden to provide more granular control over minting
     * @param _user Address of the receiver
     * @param _amount Amount of tokens to mint
     */
    function mint(
        address _user,
        uint256 _amount
    ) external virtual override onlyRole(MINTER_ROLE)
    {
        _mint(_user, _amount);
    }
}
