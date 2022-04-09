// SPDX-License-Identifier: GPL-3.0

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IMintableERC20.sol";

pragma solidity ^0.8.9;

/**
 * @title CapAndTrade
 * @author Wakanda Labs
 */
contract CapAndTrade {
    /* ============ Global Variables ============ */

    /// genesis cap of start year
    uint256 public immutable genesis;
    /// start year
    uint256 public immutable start;
    /// end year
    uint256 public immutable end;

    /// @notice CarbonCredit Token address
    IMintableERC20 public immutable token;

    /// @notice Maps user => year => allowance
    mapping(address => mapping(uint256 => uint256)) public allowances;

    /* ============ Initialize ============ */

    /**
     * @notice Deploy CapAndTrade contract
     * @param _token Address of the CarbonCredit
     * @param _genesis genesis cap of start year
     * @param _start start year
     * @param _end end year
     */
    constructor(
        IMintableERC20 _token,
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

    /**
     * @notice get the year of timestamp
     * @param timestamp the query timestamp
     * @return year the year of timestamp
     */
    function yearOf(
        uint256 timestamp
    ) external virtual pure returns (uint256) {
        return _yearOf(timestamp);
    }

    /**
     * @notice get the cap of timestamp
     * @param timestamp the query timestamp
     * @return cap the cap of timestamp
     */
    function capOf(
        uint256 timestamp
    ) external virtual view returns (uint256) {
        return _capOf(timestamp);
    }

    /**
     * @notice claim current year's allowance
     */
    function claim(
        address _user
    ) external virtual {
        _claim(_user);
    }

    /* ============ Internal Functions ============ */

    /**
     * @notice get the year of timestamp
     * @param timestamp the query timestamp
     * @return year the year of timestamp
     */
    function _yearOf(
        uint256 timestamp
    ) internal pure returns (uint256) {
        return (timestamp / 365 days) + 1970;
    }

    /**
     * @notice get the cap of timestamp
     * @param timestamp the query timestamp
     * @return cap the cap of timestamp
     */
    function _capOf(
        uint256 timestamp
    ) internal view returns (uint256) {
        uint256 year = _yearOf(timestamp);
        require(year >= start && year <= end, "CapAndTrade: year out of range");

        return genesis - (year - start) * genesis / (end - start);
    }

    /**
     * @notice claim current year's allowance
     */
    function _claim(
        address _user
    ) internal {
        uint256 year = _yearOf(block.timestamp);
        require(year >= start && year <= end, "CapAndTrade: year out of range");

        mapping(uint256 => uint256) storage user = allowances[msg.sender];
        require(user[year] == 0, "CapAndTrade: you had claimed this year");

        uint256 cap = _capOf(block.timestamp);
        user[year] = cap;
        token.mint(_user, cap);
    }
}
