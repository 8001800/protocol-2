pragma solidity ^0.4.19;

import "./Appraiser.sol";

contract AsyncAppraiser is Appraiser {
    struct AppraisalStatus {
        // Block when this check status has expired.
        uint256 blockToExpire;

        // Value of appraisal in some currency
        uint256 appraisalValue;
    }
    mapping (address => mapping (uint256 => AppraisalStatus)) statuses;

    event AppraisalRequested(
        address instrumentAddr,
        uint256 instrumentId
    );

    event AppraisalCompleted(
        address instrumentAddr,
        uint256 instrumentId,
        uint256 blockToExpire,
        uint256 appraisalValue
    );

    function requestAppraisal(
        address instrumentAddr, uint256 instrumentId, uint8 action
    ) fromKernel external returns (uint8)
    {
        AppraisalRequested(instrumentAddr, instrumentId, action);
    }

    function onAppraisalCompleted(
        address instrumentAddr,
        uint256 instrumentId,
        uint256 blockToExpire,
        uint256 appraisalValue
    ) external
    {
        require(isAuthorizedToAppraise(msg.sender));
        statuses[instrumentAddr][instrumentId] = AppraisalStatus({
            blockToExpire: blockToExpire,
            appraisalValue: appraisalValue
        });
        AppraisalCompleted(
            instrumentAddr,
            instrumentId,
            blockToExpire,
            appraisalValue
        );
    }

    function appraise(address instrumentAddr, uint256 instrumentId) external returns (uint256) {
        AppraisalStatus storage status = statuses[instrumentAddr][instrumentId];
        // Check that the status check has been performed.
        require(status.blockToExpire != 0);
        // Check that the status check has not expired. 
        require(status.blockToExpire > block.number);
        return status.appraisalValue;
    }

    function invalidate(address instrumentAddr, uint256 instrumentId) external {
        require(msg.sender == instrumentAddr);
        delete statuses[instrumentAddr][instrumentId];
    }

    /**
     * Cost of performing an appraisal.
     */
    function cost(address instrumentAddr, uint256 instrumentId) external view returns (uint256);

    function isAuthorizedToAppraise(address sender) view public returns (bool);
}
