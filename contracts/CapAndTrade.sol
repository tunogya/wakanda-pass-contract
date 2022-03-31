// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "./interfaces/ICarbonCredit.sol";

pragma solidity ^0.8.6;

/**
 * @title CapAndTrade
 * @author Wakanda Labs
 * @notice
 */
contract CapAndTrade is Ownable {
    /* ============ Global Variables ============ */

    uint256 public immutable genesis;
    uint256 public immutable start;
    uint256 public immutable end;

    /// @notice CarbonCredit Token address
    ICarbonCredit public immutable token;

    /// @notice Maps user => year => allowance
    mapping(address => mapping(uint256 => uint256)) public allowances;

    /* ============ Initialize ============ */

    /**
     * @notice Deploy CapAndTrade contract
     * @param _token Address of the CarbonCredit.
     */
    constructor(
        ICarbonCredit _token,
        uint256 _genesis,
        uint256 _start,
        uint256 _end
    ) {
        require(_start < _end, "CapAndTrade: end year should larger than start year");

        token = _token;
        genesis = _genesis;
        start = _start;
        end = _end;
    }

    /* ============ External Functions ============ */

    function yearOf(
        uint256 timestamp
    ) external virtual pure returns (uint256) {
        return _yearOf(timestamp);
    }


    function capOf(
        uint256 timestamp
    ) external virtual view returns (uint256) {
        return _capOf(timestamp);
    }


    function claim() external virtual {
        _claim();
    }

    /* ============ Internal Functions ============ */

    function _yearOf(
        uint256 timestamp
    ) internal pure returns (uint256) {
        return (timestamp / 365 days) + 1970;
    }

    function _capOf(
        uint256 timestamp
    ) internal view returns (uint256) {
        uint256 year = _yearOf(timestamp);
        if (year >= end || year < start) {
            return 0;
        }

        return genesis - (year - start) * genesis / (end - start);
    }

    function _claim() internal {
        uint256 currentYear = _yearOf(block.timestamp);
        require(currentYear <= end, "CapAndTrade: end");

        mapping(uint256 => uint256) storage user = allowances[msg.sender];
        require(user[currentYear] == 0, "CapAndTrade: you had claimed this year");

        uint256 cap = _capOf(block.timestamp);
        user[currentYear] = cap;
        token.mint(msg.sender, cap);
    }
}
