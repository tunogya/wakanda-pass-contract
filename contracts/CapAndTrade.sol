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

    /// @notice cycle interval
    uint256 internal immutable interval;

    /// @notice cap of cycle allowances
    uint256 internal cap;

    /// @notice CycleCalculator address
    /// ICycleCalculator internal cycleCalculator;

    /// @notice CarbonCredit Token address
    ICarbonCredit internal immutable token;

    /// @notice Maps user => cycle id => allowances balance
    mapping(address => mapping(uint256 => uint256)) internal userCycleAllowances;

    /* ============ Initialize ============ */

    /**
     * @notice Deploy CapAndTrade contract
     * @param _token Address of the CarbonCredit.
     * @param _interval cycle interval.
     * @param _cap Cap of carbon allowance.
     */
    constructor(
        ICarbonCredit _token,
        uint256 _interval,
        uint256 _cap
    ) {
        require(_interval > 0, "CapAndTrade/interval-not-zero");

        interval = _interval;
        cap = _cap;
        token = _token;
    }

    /* ============ External Functions ============ */

    function claim() external virtual {
        _claim();
    }

    function redeem(
        uint256[] calldata ids
    ) external virtual {
        _redeem(ids);
    }

    function getUserAllowances(
        uint256[] calldata _cycleIds,
        address user
    ) external virtual view returns (uint256[] memory) {
        uint256 cycleIdsLength = _cycleIds.length;
        uint256[] memory userAllowances = new uint256[](cycleIdsLength);

        for (uint256 i = 0; i < cycleIdsLength; i++) {
            userAllowances[i] = userCycleAllowances[user][i];
        }

        return userAllowances;
    }

    function getCycleInterval() external view returns (uint256) {
        return interval;
    }

    function getCap() external view returns (uint256) {
        return cap;
    }

    function setCap(
        uint256 _cap
    ) external virtual onlyOwner {
        cap = _cap;
    }

    function getCurrentCycleId() external view returns (uint256) {
        return _getCurrentCycleId();
    }

    /* ============ Internal Functions ============ */

    function _claim() internal {
        uint256 index = _getCurrentCycleId();
        require(userCycleAllowances[msg.sender][index] == 0, "");
        userCycleAllowances[msg.sender][index] = cap;
    }

    /// @notice for test
    function _redeem(
        uint256[] calldata _cycleIds
    ) internal {
        uint256 cycleIdsLength = _cycleIds.length;
        uint256 totalMint;

        for (uint256 i = 0; i < cycleIdsLength; i++) {
            uint256 index = _cycleIds[i];
            uint256 allowance = userCycleAllowances[msg.sender][index];
            totalMint += allowance;
        }

        token.mint(msg.sender, totalMint);
    }

    function _getCurrentCycleId() internal view returns (uint256) {
        return block.timestamp / interval;
    }
}
