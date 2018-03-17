pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../NeedsAbacus.sol";
import "./ComplianceStandard.sol";
import "../provider/ProviderRegistry.sol";

/**
 * Registry for compliance providers.
 */
contract ComplianceRegistry is ProviderRegistry, NeedsAbacus {
    /**
     * @dev Stores the status of an asynchronous compliance check.
     */
    struct CheckStatus {
        /**
         * @dev Block when this check status has expired.
         */
        uint256 blockToExpire;

        /**
         * @dev Result of the check. 0 indicates success, non-zero is left to the caller.
         */
        uint8 checkResult;
    }

    /**
     * @dev Mapping of provider id => address => action id => check status.
     */
    mapping (uint256 => mapping (address => mapping (uint256 => CheckStatus))) public statuses;

    /**
     * @dev Emitted when a compliance check is performed.
     */
    event ComplianceCheckPerformed(
        uint256 providerId,
        address standard,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint8 checkResult,
        uint256 nextProviderId
    );

    /**
     * @dev Emitted when an asynchronous compliance check is requested.
     */
    event ComplianceCheckRequested(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 cost
    );

    /**
     * @dev Emitted when the result of an asynchronous compliance check is written.
     */
    event ComplianceCheckResultWritten(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 blockToExpire,
        uint8 checkResult
    );

    /**
     * @dev Requests a compliance check from a Compliance Provider.
     */
    function requestCheck(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 cost
    ) fromKernel external
    {
        ComplianceCheckRequested(
            providerId,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data,
            cost
        );
    }

    /**
     * @dev Writes the result of an asynchronous compliance check to the blockchain.
     */
    function writeCheckResult(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 blockToExpire,
        uint8 checkResult
    ) external returns (uint8)
    {
        uint256 actionId = computeActionId(
            providerId,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
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
            instrumentIdOrAmt,
            from,
            to,
            data,
            blockToExpire,
            checkResult
        );
    }

    /**
     * @dev Invalidates a stored asynchronous compliance check result.
     * This can only be called by the owner of the provider or by the instrument that
     * requested the compliance check.
     */
    function invalidateCheckResult(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) external returns (bool)
    {
        uint256 actionId = computeActionId(
            providerId,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        ProviderInfo storage providerInfo = providers[providerId];
        if (providerInfo.owner != msg.sender || instrumentAddr != msg.sender) {
            return false;
        }
        delete statuses[providerId][instrumentAddr][actionId];
        return true;
    }

    /**
     * @dev Computes an id for an action using keccak256.
     */
    function computeActionId(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) pure private returns (uint256)
    {
        return uint256(
            keccak256(
                providerId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            )
        );
    }

    /**
     * @dev Checks the result of an async service.
     * Assumes the service is async. Check your preconditions before using.
     */
    function checkAsync(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) view private returns (uint8)
    {
        uint256 actionId = computeActionId(
            providerId,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
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

    /**
     * @dev Checks the result of a compliance check.
     */
    function check(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) view public returns (uint8)
    {
        ProviderInfo storage providerInfo = providers[providerId];

        // Async checks
        if (bytes(providerInfo.metadata).length > 0) {
            return checkAsync(
                providerId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(providerInfo.owner);

        uint8 checkResult;
        uint256 nextProviderId;
        (checkResult, nextProviderId) = standard.check(
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );

        if (nextProviderId != 0) {
            // recursively check next service
            checkResult = check(
                nextProviderId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
        }
        return checkResult;
    }

    /**
     * @dev Checks the result of a compliance check and performs any necessary state changes.
     */
    function hardCheck(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) fromKernel public returns (uint8, uint256)
    {
        ProviderInfo storage providerInfo = providers[providerId];

        uint8 checkResult;

        // Async checks
        if (bytes(providerInfo.metadata).length > 0) {
            checkResult = checkAsync(
                providerId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
            ComplianceCheckPerformed(
                providerId,
                address(0),
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data,
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
        (checkResult, nextProviderId) = standard.check(
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        standard.onHardCheck(
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );

        // For auditing
        ComplianceCheckPerformed(
            providerId,
            standard,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data,
            checkResult,
            nextProviderId
        );

        if (nextProviderId != 0) {
            // recursively check next service
            (checkResult, nextProviderId) = hardCheck(
                nextProviderId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
        }
        return (checkResult, nextProviderId);
    }
}
