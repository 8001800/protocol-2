pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../NeedsAbacus.sol";
import "./ComplianceStandard.sol";
import "../provider/ProviderRegistry.sol";

contract ComplianceRegistry is ProviderRegistry, NeedsAbacus, Ownable {
    function setKernel(address _kernel) onlyOwner external {
        require(kernel == address(0));
        kernel = _kernel;
    }

    struct CheckStatus {
        // Block when this check status has expired.
        uint256 blockToExpire;

        // 0 indicates success, non-zero is left to the caller.
        uint8 checkResult;
    }

    /**
     * Mapping of provider id => address => action id => check status.
     */
    mapping (uint256 => mapping (address => mapping (uint256 => CheckStatus))) public statuses;

    uint256 providerIdAutoInc;

    event ComplianceCheckPerformed(
        uint256 providerId,
        address standard,
        address instrumentAddr,
        uint256 actionId,
        uint8 checkResult,
        uint256 nextProviderId
    );

    event ComplianceCheckRequested(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId
    );

    event ComplianceCheckResultWritten(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId,
        uint256 blockToExpire,
        uint8 checkResult
    );

    function requestCheck(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId
    ) fromKernel external
    {
        ComplianceCheckRequested(providerId, instrumentAddr, actionId);
    }

    function writeCheckResult(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId,
        uint256 blockToExpire,
        uint8 checkResult
    ) external returns (uint8)
    {
        ProviderInfo storage providerInfo = providers[providerId];

        // Check service exists
        if (providerInfo.id == 0) {
            return 1;
        }
        // Check service owner is correct
        if (providerInfo.owner != msg.sender) {
            return 2;
        }

        statuses[providerId][instrumentAddr][actionId] = CheckStatus({
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });
        ComplianceCheckResultWritten(
            providerId,
            instrumentAddr,
            actionId,
            blockToExpire,
            checkResult
        );
    }

    function invalidateCheckResult(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId
    ) external
    {
        ProviderInfo storage providerInfo = providers[providerId];
        require(providerInfo.owner == msg.sender || instrumentAddr == msg.sender);
        delete statuses[providerId][instrumentAddr][actionId];
    }

    /**
     * Checks the result of an async service.
     * Assumes the service is async. Check your preconditions before using.
     */
    function checkAsync(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId
    ) view private returns (uint8)
    {
        CheckStatus storage status = statuses[providerId][instrumentAddr][actionId];

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

    function check(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId
    ) view public returns (uint8)
    {
        ProviderInfo storage providerInfo = providers[providerId];

        // Async checks
        if (bytes(providerInfo.metadata).length > 0) {
            return checkAsync(
                providerId,
                instrumentAddr,
                actionId
            );
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(providerInfo.owner);

        uint8 checkResult;
        uint256 nextProviderId;
        (checkResult, nextProviderId) = standard.check(instrumentAddr, actionId);

        if (nextProviderId != 0) {
            // recursively check next service
            checkResult = softCheck(nextProviderId, instrumentAddr, actionId);
        }
        return checkResult;
    }

    function hardCheck(
        uint256 providerId,
        address instrumentAddr,
        uint256 actionId
    ) fromKernel public returns (uint8, uint256)
    {
        ProviderInfo storage providerInfo = providers[providerId];

        uint8 checkResult;

        // Async checks
        if (bytes(providerInfo.metadata).length > 0) {
            checkResult = checkAsync(
                providerId,
                instrumentAddr,
                actionId
            );
            ComplianceCheckPerformed(
                providerId,
                address(0),
                instrumentAddr,
                actionId,
                checkResult,
                0
            );
            if (checkResult != 0) {
                return (checkResult, providerId);
            }
            return (checkResult, 0);
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(providerInfo.owner);

        checkResult;
        uint256 nextProviderId;
        (checkResult, nextProviderId) = standard.check(instrumentAddr, actionId);
        standard.onHardCheck(instrumentAddr, actionId);

        // For auditing
        ComplianceCheckPerformed(
            providerId,
            standard,
            instrumentAddr,
            actionId,
            checkResult,
            nextProviderId
        );

        if (nextProviderId != 0) {
            // recursively check next service
            (checkResult, nextProviderId) = check(nextProviderId, instrumentAddr, actionId);
        }
        return (checkResult, nextProviderId);
    }
}
