// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IChildToken.sol";

/**
 * @title MintableERC20
 * @author Wakanda Labs
 */
contract MintableERC20 is AccessControl, ERC20Permit, ERC20Burnable, IChildToken {
    using SafeERC20 for IERC20;

    /* ============ ROLES ============ */

    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant DEPOSITOR_ROLE = keccak256("DEPOSITOR_ROLE");

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
            "CarbonCredit/admin-not-zero-address"
        );
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
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
     * @notice called when user wants to withdraw tokens back to root chain
     * @dev Should burn user's tokens. This transaction will be verified when exiting on root chain
     * @param amount amount of tokens to withdraw
     */
    function withdraw(uint256 amount) external {
        _burn(msg.sender, amount);
    }

    /**
     * @notice called when token is deposited on root chain
     * @dev Should be callable only by ChildChainManager
     * Should handle deposit by minting the required amount for user
     * Make sure minting is done only by this function
     * @param user user address for whom deposit is being done
     * @param depositData abi encoded amount
     */
    function deposit(address user, bytes calldata depositData)
    external
    override
    onlyRole(DEPOSITOR_ROLE)
    {
        uint256 amount = abi.decode(depositData, (uint256));
        _mint(user, amount);
    }
}
