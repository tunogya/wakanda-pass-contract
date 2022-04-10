// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./interfaces/IMintableERC20.sol";

pragma solidity ^0.8.9;

/**
 * @title CapAndTrade
 * @author Wakanda Labs
 */
contract CapAndTrade {
    /* ============ Global Variables ============ */

    struct AnnualBill {
        uint256 allowance;
        uint256 bill;
    }

    /// @notice IMintableERC20 Token address
    IMintableERC20 public immutable token;

    uint256 public immutable initialCap;

    // @notice Initial time used to computed
    uint256 public immutable initialTime;

    // @notice Every period's interval is 365 days
    uint256 public immutable interval = 365 days;

    // @notice Record reckoning of every period
    mapping(address => mapping(uint256 => AnnualBill)) public reckoning;

    /* ============ Initialize ============ */

    /**
     * @notice Deploy ERC20Faucet contract
     * @param _token Address of the IMintableERC20
     */
    constructor(
        IMintableERC20 _token,
        uint256 _initialCap,
        uint256 _initialTime
    ) {
        token = _token;
        initialCap = _initialCap;
        initialTime = _initialTime;
    }

    /* ============ External Functions ============ */

    /**
     * @notice claim
     */
    function claim() external {
        AnnualBill storage annualBill = reckoning[msg.sender][_getPeriodOf(block.timestamp)];
        require(annualBill.allowance == 0, "ERC20Faucet/had-claimed-this-period");

        uint256 allowance = _getCapOf(block.timestamp);
        annualBill.allowance = allowance;
        token.mint(msg.sender, allowance);
    }

    function getCapOf(
        uint256 time
    ) external view returns (uint256) {
        return _getCapOf(time);
    }

    function getCapOfNow() external view returns (uint256) {
        return _getCapOf(block.timestamp);
    }

    function getPeriodOf(
        uint256 time
    ) external view returns (uint256) {
        return _getPeriodOf(time);
    }

    function getPeriodOfNow() external view returns (uint256) {
        return _getPeriodOf(block.timestamp);
    }

    function recordBill(
        uint256 amount
    ) external {
        AnnualBill storage annualBill = reckoning[msg.sender][_getPeriodOf(block.timestamp)];
        annualBill.bill += amount;
    }

    /* ============ Internal Functions ============ */

    function _getCapOf(
        uint256 time
    ) internal view returns (uint256) {
        if (time <= initialTime) {
            return 0;
        }

        return initialCap * 2 >> (time - initialTime) / (4 * 365 days);
    }

    function _getPeriodOf(
        uint256 time
    ) internal view returns (uint256) {
        if (time <= initialTime) {
            return 0;
        }

        return (time - initialTime) / 365 days;
    }
}
