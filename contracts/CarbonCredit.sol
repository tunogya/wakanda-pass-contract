// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import "./interfaces/ICarbonCredit.sol";

/**
 * @title CarbonCredit
 * @author Wakanda Labs
 * @notice
 */
contract CarbonCredit is ERC20, AccessControl, ERC20Permit, ICarbonCredit {
    using SafeERC20 for IERC20;

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant BURNER_ROLE = keccak256("BURNER_ROLE");

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
        _grantRole(BURNER_ROLE, _admin);
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

    /**
     * @notice Allows the user who has Burner Role to burn tokens from a user account
     * @dev May be overridden to provide more granular control over burning
     * @param _user Address of the holder account to burn tokens from
     * @param _amount Amount of tokens to burn
     */
    function burn(
        address _user,
        uint256 _amount
    ) external virtual override onlyRole(BURNER_ROLE)
    {
        _burn(_user, _amount);
    }

    /**
     * @notice Allows an operator via the user who has Burner Role to burn tokens on behalf of a user account
     * @dev May be overridden to provide more granular control over operator-burning
     * @param _operator Address of the operator performing the burn action via the burner contract
     * @param _user Address of the holder account to burn tokens from
     * @param _amount Amount of tokens to burn
     */
    function burnFrom(
        address _operator,
        address _user,
        uint256 _amount
    ) external virtual override onlyRole(BURNER_ROLE) {
        if (_operator != _user) {
            _approve(_user, _operator, allowance(_user, _operator) - _amount);
        }
        _burn(_user, _amount);
    }
}
