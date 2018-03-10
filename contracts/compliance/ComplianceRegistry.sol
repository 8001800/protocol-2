pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../NeedsAbacus.sol";
import "./ComplianceStandard.sol";

contract ComplianceRegistry is NeedsAbacus, Ownable {
    function setKernel(address _kernel) onlyOwner external {
        require(kernel == address(0));
        kernel = _kernel;
    }

    struct ComplianceCheckStatus {
        // Block when this check status has expired.
        uint256 blockToExpire;

        // 0 indicates success, non-zero is left to the caller.
        uint8 checkResult;
    }

    struct ComplianceServiceInfo {
        uint256 id;
        string name;
        address owner;
        uint256 cost;
        bool isAsync;
        mapping (address => mapping (uint256 => mapping(uint256 => ComplianceCheckStatus))) statuses;
    }
    mapping (uint256 => ComplianceServiceInfo) complianceServices;

    event ComplianceCheckPerformed(
        uint256 serviceId,
        address standard,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 actionId,
        uint8 checkResult,
        uint256 nextServiceId
    );

    event ComplianceCheckRequested(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 action
    );

    event ComplianceCheckResultWritten(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 action,
        uint256 blockToExpire,
        uint8 checkResult
    );

    function requestCheck(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 action
    ) fromKernel external returns (uint8)
    {
        ComplianceCheckRequested(serviceId, instrumentAddr, instrumentId, action);
    }

    function writeCheckResult(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint8 action,
        uint256 blockToExpire,
        uint8 checkResult
    ) external
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];

        // Check service exists
        require(serviceInfo.id != 0);
        // Check service owner is correct
        require(serviceInfo.owner == msg.sender);

        serviceInfo.statuses[instrumentAddr][instrumentId][action] = ComplianceCheckStatus({
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });
        ComplianceCheckResultWritten(
            serviceId,
            instrumentAddr,
            instrumentId,
            action,
            blockToExpire,
            checkResult
        );
    }

    function invalidateCheckResult(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 actionId
    ) external
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];
        require(serviceInfo.owner == msg.sender || instrumentAddr == msg.sender);
        delete serviceInfo.statuses[instrumentAddr][instrumentId][actionId];
    }

    /**
     * Checks the result of an async service.
     * Assumes the service is async. Check your preconditions before using.
     */
    function checkAsync(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 actionId
    ) view private returns (uint8) {
        ComplianceCheckStatus storage status = complianceServices[serviceId]
            .statuses[instrumentAddr][instrumentId][actionId];

        // Check that the status check has been performed.
        if (status.blockToExpire == 0) {
            return 100;
        }

        // Check that the status check has not expired. 
        if (status.blockToExpire <= block.number) {
            return 101;
        }

        return  status.checkResult;
    }

    function softCheck(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 actionId
    ) view public returns (uint8)
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];

        // Async checks
        if (serviceInfo.isAsync) {
            return checkAsync(
                serviceId,
                instrumentAddr,
                instrumentId,
                actionId
            );
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(serviceInfo.owner);

        uint8 checkResult;
        uint256 nextServiceId;
        (checkResult, nextServiceId) = standard.check(instrumentAddr, instrumentId, actionId);

        if (nextServiceId != 0) {
            // recursively check next service
            checkResult = softCheck(nextServiceId, instrumentAddr, instrumentId, actionId);
        }
        return checkResult;
    }

    function check(
        uint256 serviceId,
        address instrumentAddr,
        uint256 instrumentId,
        uint256 actionId
    ) fromKernel public returns (uint8)
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];

        uint8 checkResult;

        // Async checks
        if (serviceInfo.isAsync) {
            checkResult = checkAsync(
                serviceId,
                instrumentAddr,
                instrumentId,
                actionId
            );
            ComplianceCheckPerformed(
                serviceId,
                address(0),
                instrumentAddr,
                instrumentId,
                actionId,
                checkResult,
                0
            );
            return checkResult;
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(serviceInfo.owner);

        checkResult;
        uint256 nextServiceId;
        (checkResult, nextServiceId) = standard.check(instrumentAddr, instrumentId, actionId);

        // For auditing
        ComplianceCheckPerformed(
            serviceId,
            standard,
            instrumentAddr,
            instrumentId,
            actionId,
            checkResult,
            nextServiceId
        );

        if (nextServiceId != 0) {
            // recursively check next service
            checkResult = check(nextServiceId, instrumentAddr, instrumentId, actionId);
        }
        return checkResult;
    }

    /**
     * Gets the cost of a compliance service.
     */
    function paymentDetails(uint256 serviceId) view external returns (uint256, address) {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];
        return (serviceInfo.cost, serviceInfo.owner);
    }
}
