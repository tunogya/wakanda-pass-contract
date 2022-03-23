pragma solidity ^0.8.6;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

/**
 * @title CarbonCredit
 * @author Wakanda Labs
 * @notice 
 */
contract CarbonCredit is ERC20, ERC20Burnable, AccessControl, ERC20Permit  {
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

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
        require(address(_admin) != address(0), "CarbonCredit/admin-not-zero-address");
        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(MINTER_ROLE, _admin);
    }

    /**
     * @notice Mint Token.
     * @param to Address receive the token.
     * @param amount Amount of token to be minted.
     */
    function mint(address to, uint256 amount) public onlyRole(MINTER_ROLE) {
        _mint(to, amount);
    }
}
