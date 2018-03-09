pragma solidity ^0.4.19;

import "./ComplianceStandard.sol";

contract AsyncComplianceStandard is ComplianceStandard {
    struct ComplianceCheckStatus {
        // Block when this check status has expired.
        uint256 blockToExpire;

        // 0 indicates success, non-zero is left to the caller.
        uint8 checkResult;
    }
    mapping (address => mapping (uint256 => mapping(uint8 => ComplianceCheckStatus))) statuses;

    event RequestCheckEvent(
        address instrumentAddr,
        uint256 instrumentId,
        uint8 action
    );

    event CheckCompletedEvent(
        address instrumentAddr,
        uint256 instrumentId,
        uint8 action,
        uint256 blockToExpire,
        uint8 checkResult
    );

    function requestCheck(
        address instrumentAddr, uint256 instrumentId, uint8 action
    ) fromKernel external returns (uint8)
    {
        RequestCheckEvent(instrumentAddr, instrumentId, action);
    }

    function onCheckCompleted(
        address instrumentAddr,
        uint256 instrumentId,
        uint8 action,
        uint256 blockToExpire,
        uint8 checkResult
    ) external
    {
        require(isAuthorizedToCheck(msg.sender));
        statuses[instrumentAddr][instrumentId][action] = ComplianceCheckStatus({
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });
        CheckCompletedEvent(
            instrumentAddr,
            instrumentId,
            action,
            blockToExpire,
            checkResult
        );
    }

    function softCheck(address instrumentAddr, uint256 instrumentId, uint8 action) view public returns (uint8) {
        ComplianceCheckStatus storage status = statuses[instrumentAddr][instrumentId][action];
        // Check that the status check has been performed.
        require(status.blockToExpire != 0);
        // Check that the status check has not expired. 
        require(status.blockToExpire > block.number);
        return status.checkResult;
    }

    function check(address instrumentAddr, uint256 instrumentId, uint8 action) external returns (uint8) {
        uint8 result = softCheck(instrumentAddr, instrumentId, action);
        delete statuses[instrumentAddr][instrumentId][action];
        return result;
    }

    /**
     * Cost of performing a check.
     */
    function cost(address instrumentAddr, uint256 instrumentId, uint8 action) external view returns (uint256);

    function isAuthorizedToCheck(address sender) view public returns (bool);
}
