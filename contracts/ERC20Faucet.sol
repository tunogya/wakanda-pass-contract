// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMintableERC20.sol";

pragma solidity ^0.8.9;

/**
 * @title ERC20Faucet
 * @author Wakanda Labs
 */
contract ERC20Faucet is Ownable {
    /* ============ Global Variables ============ */

    /// @notice IMintableERC20 Token address
    IMintableERC20 public immutable token;

    uint256 public capOfClaim;

    uint256 public claimInterval;

    mapping(address => uint256) public lastClaim;

    /* ============ Initialize ============ */

    /**
     * @notice Deploy ERC20Faucet contract
     * @param _token Address of the IMintableERC20
     */
    constructor(
        IMintableERC20 _token,
        uint256 _capOfClaim,
        uint256 _claimInterval
    ) {
        token = _token;
        capOfClaim = _capOfClaim;
        claimInterval = _claimInterval;
    }

    /* ============ External Functions ============ */

    /**
     * @notice claim
     * @param user withdraw user
     * @param amount withdraw amount
     */
    function claim(
        address user,
        uint256 amount
    ) external {
        require(amount <= capOfClaim, "ERC20Faucet/withdraw-amount-gt-capOfClaim");
        require(lastClaim[user] <= block.timestamp - claimInterval, "ERC20Faucet/last-withdraw-interval-gt-delay");

        token.mint(user, amount);
    }

    /**
     * @notice setCap
     * @param _capOfClaim capOfClaim of withdraw
     */
    function setCap(
        uint256 _capOfClaim
    ) external onlyOwner {
        capOfClaim = _capOfClaim;
    }

    /**
     * @notice setClaimInterval
     * @param _claimInterval interval of claim
     */
    function setClaimInterval(
        uint256 _claimInterval
    ) external onlyOwner {
        claimInterval = _claimInterval;
    }

    /**
     * @notice withdraw
     * @param amount withdraw amount
     * @param user user
     */
    function withdraw(
        uint256 amount,
        address user
    ) external onlyOwner {
        require(amount <= address(this).balance, "ERC20Faucet/amount-gt-balance");

        payable(user).transfer(amount);
    }

    fallback() payable external {}

    receive() payable external {}
}
