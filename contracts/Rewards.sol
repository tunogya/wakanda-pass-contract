// SPDX-License-Identifier: GPL-3.0

pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MintableERC20.sol";
import "./interfaces/IRewards.sol";

/**
 * @title Rewards
 * @author Wakanda Labs
 */
contract Rewards is IRewards, Ownable {
    using SafeERC20 for IERC20;
    /* ============ Global Variables ============ */

    /// @notice Token for which the promotions are created.
    MintableERC20 public immutable token;

    /// @notice Period during which the promotion owner can't destroy a promotion.
    uint32 public constant GRACE_PERIOD = 365 days;

    /// @notice Settings of each promotion.
    mapping(uint256 => Promotion) internal _promotions;

    /**
     * @notice Latest recorded promotion id.
     * @dev Starts at 0 and is incremented by 1 for each new promotion. So the first promotion will have id 1, the second 2, etc.
     */
    uint256 internal _latestPromotionId;

    /**
     * @notice Keeps track of claimed rewards per user.
     * @dev _claimedEpochs[promotionId][user] => claimedEpochs
     * @dev We pack epochs claimed by a user into a uint256. So we can't store more than 256 epochs.
     */
    mapping(uint256 => mapping(address => uint256)) internal _claimedEpochs;

    /* ============ Events ============ */

    /**
     * @notice Emitted when a promotion is created.
     * @param promotionId Id of the newly created promotion
     */
    event PromotionCreated(uint256 indexed promotionId);

    /**
     * @notice Emitted when a promotion is ended.
     * @param promotionId Id of the promotion being ended
     * @param recipient Address of the recipient that will receive the remaining rewards
     * @param epochNumber Epoch number at which the promotion ended
     */
    event PromotionEnded(
        uint256 indexed promotionId,
        address indexed recipient,
        uint8 epochNumber
    );

    /**
     * @notice Emitted when a promotion is destroyed.
     * @param promotionId Id of the promotion being destroyed
     * @param recipient Address of the recipient that will receive the unclaimed rewards
     */
    event PromotionDestroyed(
        uint256 indexed promotionId,
        address indexed recipient
    );

    /**
     * @notice Emitted when a promotion is extended.
     * @param promotionId Id of the promotion being extended
     * @param numberOfEpochs Number of epochs the promotion has been extended by
     */
    event PromotionExtended(uint256 indexed promotionId, uint256 numberOfEpochs);

    /**
     * @notice Emitted when rewards have been claimed.
     * @param promotionId Id of the promotion for which epoch rewards were claimed
     * @param epochIds Ids of the epochs being claimed
     * @param user Address of the user for which the rewards were claimed
     * @param amount Amount of tokens transferred to the recipient address
     */
    event RewardsClaimed(
        uint256 indexed promotionId,
        uint8[] epochIds,
        address indexed user,
        uint256 amount
    );

    /* ============ Constructor ============ */

    /**
     * @notice Constructor of the contract.
     * @param _token token address for which the promotions will be created
     */
    constructor(
        MintableERC20 _token
    ) {
        token = _token;
    }

    /* ============ External Functions ============ */

    /// @inheritdoc IRewards
    function createPromotion(
        uint64 _startTimestamp,
        uint256 _tokensPerEpoch,
        uint48 _epochDuration,
        uint8 _numberOfEpochs
    ) external override onlyOwner returns (uint256) {
        require(_tokensPerEpoch > 0, "Rewards/tokens-not-zero");
        require(_epochDuration > 0, "Rewards/duration-not-zero");
        _requireNumberOfEpochs(_numberOfEpochs);

        uint256 _nextPromotionId = _latestPromotionId + 1;
        _latestPromotionId = _nextPromotionId;

        _promotions[_nextPromotionId] = Promotion({
        startTimestamp : _startTimestamp,
        numberOfEpochs : _numberOfEpochs,
        epochDuration : _epochDuration,
        createdAt : uint48(block.timestamp),
        tokensPerEpoch : _tokensPerEpoch,
        rewardsClaimed : 0
        });

        emit PromotionCreated(_nextPromotionId);

        return _nextPromotionId;
    }

    /// @inheritdoc IRewards
    function endPromotion(uint256 _promotionId, address _to)
    external
    override
    onlyOwner
    returns (bool)
    {
        require(_to != address(0), "Rewards/payee-not-zero-addr");

        Promotion memory _promotion = _getPromotion(_promotionId);
        _requirePromotionActive(_promotion);

        uint8 _epochNumber = uint8(_getCurrentEpochId(_promotion));
        _promotions[_promotionId].numberOfEpochs = _epochNumber;

        emit PromotionEnded(_promotionId, _to, _epochNumber);

        return true;
    }

    /// @inheritdoc IRewards
    function destroyPromotion(uint256 _promotionId, address _to)
    external
    override
    onlyOwner
    returns (bool)
    {
        require(_to != address(0), "Rewards/payee-not-zero-addr");

        Promotion memory _promotion = _getPromotion(_promotionId);

        uint256 _promotionEndTimestamp = _getPromotionEndTimestamp(_promotion);
        uint256 _promotionCreatedAt = _promotion.createdAt;

        uint256 _gracePeriodEndTimestamp = (
        _promotionEndTimestamp < _promotionCreatedAt
        ? _promotionCreatedAt
        : _promotionEndTimestamp
        ) + GRACE_PERIOD;

        require(block.timestamp >= _gracePeriodEndTimestamp, "Rewards/grace-period-active");

        delete _promotions[_promotionId];

        emit PromotionDestroyed(_promotionId, _to);

        return true;
    }

    /// @inheritdoc IRewards
    function extendPromotion(uint256 _promotionId, uint8 _numberOfEpochs)
    external
    override
    onlyOwner
    returns (bool)
    {
        _requireNumberOfEpochs(_numberOfEpochs);

        Promotion memory _promotion = _getPromotion(_promotionId);
        _requirePromotionActive(_promotion);

        uint8 _currentNumberOfEpochs = _promotion.numberOfEpochs;

        require(
            _numberOfEpochs <= (type(uint8).max - _currentNumberOfEpochs),
            "Rewards/epochs-over-limit"
        );

        _promotions[_promotionId].numberOfEpochs = _currentNumberOfEpochs + _numberOfEpochs;

        emit PromotionExtended(_promotionId, _numberOfEpochs);

        return true;
    }

    /// @inheritdoc IRewards
    function claimRewards(
        address _user,
        uint256 _promotionId,
        uint8[] calldata _epochIds
    ) external override returns (uint256) {
        Promotion memory _promotion = _getPromotion(_promotionId);

        uint256 _rewardsAmount;
        uint256 _userClaimedEpochs = _claimedEpochs[_promotionId][_user];
        uint256 _epochIdsLength = _epochIds.length;

        for (uint256 index = 0; index < _epochIdsLength; index++) {
            uint8 _epochId = _epochIds[index];

            require(!_isClaimedEpoch(_userClaimedEpochs, _epochId), "Rewards/rewards-claimed");

            _rewardsAmount += _promotion.tokensPerEpoch;
            _userClaimedEpochs = _updateClaimedEpoch(_userClaimedEpochs, _epochId);
        }

        _claimedEpochs[_promotionId][_user] = _userClaimedEpochs;
        _promotions[_promotionId].rewardsClaimed += _rewardsAmount;

        token.mint(_user, _rewardsAmount);

        emit RewardsClaimed(_promotionId, _epochIds, _user, _rewardsAmount);

        return _rewardsAmount;
    }

    /// @inheritdoc IRewards
    function getPromotion(uint256 _promotionId) external view override returns (Promotion memory) {
        return _getPromotion(_promotionId);
    }

    /// @inheritdoc IRewards
    function getCurrentEpochId(uint256 _promotionId) external view override returns (uint256) {
        return _getCurrentEpochId(_getPromotion(_promotionId));
    }

    /// @inheritdoc IRewards
    function getRewardsAmount(
        address _user,
        uint256 _promotionId,
        uint8[] calldata _epochIds
    ) external view override returns (uint256[] memory) {
        Promotion memory _promotion = _getPromotion(_promotionId);

        uint256 _epochIdsLength = _epochIds.length;
        uint256[] memory _rewardsAmount = new uint256[](_epochIdsLength);

        for (uint256 index = 0; index < _epochIdsLength; index++) {
            if (_isClaimedEpoch(_claimedEpochs[_promotionId][_user], uint8(index))) {
                _rewardsAmount[index] = 0;
            } else {
                _rewardsAmount[index] = _promotion.tokensPerEpoch;
            }
        }

        return _rewardsAmount;
    }

    /* ============ Internal Functions ============ */

    /**
     * @notice Determine if a promotion is active.
     * @param _promotion Promotion to check
     */
    function _requirePromotionActive(Promotion memory _promotion) internal view {
        require(
            _getPromotionEndTimestamp(_promotion) > block.timestamp,
            "Rewards/promotion-inactive"
        );
    }

    /**
     * @notice Allow a promotion to be created or extended only by a positive number of epochs.
     * @param _numberOfEpochs Number of epochs to check
     */
    function _requireNumberOfEpochs(uint8 _numberOfEpochs) internal pure {
        require(_numberOfEpochs > 0, "Rewards/epochs-not-zero");
    }

    /**
     * @notice Get settings for a specific promotion.
     * @dev Will revert if the promotion does not exist.
     * @param _promotionId Promotion id to get settings for
     * @return Promotion settings
     */
    function _getPromotion(uint256 _promotionId) internal view returns (Promotion memory) {
        Promotion memory _promotion = _promotions[_promotionId];
        require(_promotion.tokensPerEpoch != 0, "Rewards/invalid-promotion");
        return _promotion;
    }

    /**
     * @notice Compute promotion end timestamp.
     * @param _promotion Promotion to compute end timestamp for
     * @return Promotion end timestamp
     */
    function _getPromotionEndTimestamp(Promotion memory _promotion)
    internal
    pure
    returns (uint256)
    {
    unchecked {
        return
        _promotion.startTimestamp + (_promotion.epochDuration * _promotion.numberOfEpochs);
    }
    }

    /**
     * @notice Get the current epoch id of a promotion.
     * @dev Epoch ids and their boolean values are tightly packed and stored in a uint256, so epoch id starts at 0.
     * @dev We return the current epoch id if the promotion has not ended.
     * If the current timestamp is before the promotion start timestamp, we return 0.
     * Otherwise, we return the epoch id at the current timestamp. This could be greater than the number of epochs of the promotion.
     * @param _promotion Promotion to get current epoch for
     * @return Epoch id
     */
    function _getCurrentEpochId(Promotion memory _promotion) internal view returns (uint256) {
        uint256 _currentEpochId;

        if (block.timestamp > _promotion.startTimestamp) {
        unchecked {
            _currentEpochId =
            (block.timestamp - _promotion.startTimestamp) /
            _promotion.epochDuration;
        }
        }

        return _currentEpochId;
    }

    /**
    * @notice Set boolean value for a specific epoch.
    * @dev Bits are stored in a uint256 from right to left.
        Let's take the example of the following 8 bits word. 0110 0011
        To set the boolean value to 1 for the epoch id 2, we need to create a mask by shifting 1 to the left by 2 bits.
        We get: 0000 0001 << 2 = 0000 0100
        We then OR the mask with the word to set the value.
        We get: 0110 0011 | 0000 0100 = 0110 0111
    * @param _userClaimedEpochs Tightly packed epoch ids with their boolean values
    * @param _epochId Id of the epoch to set the boolean for
    * @return Tightly packed epoch ids with the newly boolean value set
    */
    function _updateClaimedEpoch(uint256 _userClaimedEpochs, uint8 _epochId)
    internal
    pure
    returns (uint256)
    {
        return _userClaimedEpochs | (uint256(1) << _epochId);
    }

    /**
    * @notice Check if rewards of an epoch for a given promotion have already been claimed by the user.
    * @dev Bits are stored in a uint256 from right to left.
        Let's take the example of the following 8 bits word. 0110 0111
        To retrieve the boolean value for the epoch id 2, we need to shift the word to the right by 2 bits.
        We get: 0110 0111 >> 2 = 0001 1001
        We then get the value of the last bit by masking with 1.
        We get: 0001 1001 & 0000 0001 = 0000 0001 = 1
        We then return the boolean value true since the last bit is 1.
    * @param _userClaimedEpochs Record of epochs already claimed by the user
    * @param _epochId Epoch id to check
    * @return true if the rewards have already been claimed for the given epoch, false otherwise
     */
    function _isClaimedEpoch(uint256 _userClaimedEpochs, uint8 _epochId)
    internal
    pure
    returns (bool)
    {
        return (_userClaimedEpochs >> _epochId) & uint256(1) == 1;
    }
}
