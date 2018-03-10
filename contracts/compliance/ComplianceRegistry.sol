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
        string costLookup;
        bool isAsync;
        mapping (address => mapping(uint256 => ComplianceCheckStatus)) statuses;
    }
    mapping (uint256 => ComplianceServiceInfo) public complianceServices;

    event ComplianceCheckPerformed(
        uint256 serviceId,
        address standard,
        address instrumentAddr,
        uint256 actionId,
        uint8 checkResult,
        uint256 nextServiceId
    );

    event ComplianceCheckRequested(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId
    );

    event ComplianceCheckResultWritten(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId,
        uint256 blockToExpire,
        uint8 checkResult
    );

    function requestCheck(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId
    ) fromKernel external
    {
        ComplianceCheckRequested(serviceId, instrumentAddr, actionId);
    }

    function writeCheckResult(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId,
        uint256 blockToExpire,
        uint8 checkResult
    ) external returns (uint8)
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];

        // Check service exists
        if (serviceInfo.id == 0) {
            return 1;
        }
        // Check service owner is correct
        if (serviceInfo.owner != msg.sender) {
            return 2;
        }

        serviceInfo.statuses[instrumentAddr][actionId] = ComplianceCheckStatus({
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });
        ComplianceCheckResultWritten(
            serviceId,
            instrumentAddr,
            actionId,
            blockToExpire,
            checkResult
        );
    }

    function invalidateCheckResult(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId
    ) external
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];
        require(serviceInfo.owner == msg.sender || instrumentAddr == msg.sender);
        delete serviceInfo.statuses[instrumentAddr][actionId];
    }

    /**
     * Checks the result of an async service.
     * Assumes the service is async. Check your preconditions before using.
     */
    function checkAsync(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId
    ) view private returns (uint8) {
        ComplianceCheckStatus storage status = complianceServices[serviceId]
            .statuses[instrumentAddr][actionId];

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
        uint256 actionId
    ) view public returns (uint8)
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];

        // Async checks
        if (serviceInfo.isAsync) {
            return checkAsync(
                serviceId,
                instrumentAddr,
                actionId
            );
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(serviceInfo.owner);

        uint8 checkResult;
        uint256 nextServiceId;
        (checkResult, nextServiceId) = standard.check(instrumentAddr, actionId);

        if (nextServiceId != 0) {
            // recursively check next service
            checkResult = softCheck(nextServiceId, instrumentAddr, actionId);
        }
        return checkResult;
    }

    function check(
        uint256 serviceId,
        address instrumentAddr,
        uint256 actionId
    ) fromKernel public returns (uint8, uint256)
    {
        ComplianceServiceInfo storage serviceInfo = complianceServices[serviceId];

        uint8 checkResult;

        // Async checks
        if (serviceInfo.isAsync) {
            checkResult = checkAsync(
                serviceId,
                instrumentAddr,
                actionId
            );
            ComplianceCheckPerformed(
                serviceId,
                address(0),
                instrumentAddr,
                actionId,
                checkResult,
                0
            );
            if (checkResult != 0) {
                return (checkResult, serviceId);
            }
            return (checkResult, 0);
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(serviceInfo.owner);

        checkResult;
        uint256 nextServiceId;
        (checkResult, nextServiceId) = standard.check(instrumentAddr, actionId);

        // For auditing
        ComplianceCheckPerformed(
            serviceId,
            standard,
            instrumentAddr,
            actionId,
            checkResult,
            nextServiceId
        );

        if (nextServiceId != 0) {
            // recursively check next service
            (checkResult, nextServiceId) = check(nextServiceId, instrumentAddr, actionId);
        }
        return (checkResult, nextServiceId);
    }

    function serviceOwner(uint256 serviceId) view external returns (address) {
        return complianceServices[serviceId].owner;
    }
}
