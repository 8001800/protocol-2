pragma solidity ^0.4.21;

import "openzeppelin-solidity/contracts/ownership/Ownable.sol";
import "../AbacusCoordinator.sol";
import "./ComplianceStandard.sol";
import "../provider/ProviderRegistry.sol";

/**
 * Registry for compliance providers.
 */
contract ComplianceCoordinator is AbacusCoordinator {
    ProviderRegistry public providerRegistry;

    function ComplianceCoordinator(ProviderRegistry _providerRegistry) public  {
        providerRegistry = _providerRegistry;
    }

    uint256 nextRequestId = 1;

    struct CheckResult {
        /**
         * @dev Id of the escrow associated with this request.
         */
        uint256 requestId;

        /**
         * @dev Id of the action associated with the request.
         */
        uint256 actionHash;

        /**
         * @dev Block when this check status has expired. 0 if we haven't writen.
         */
        uint256 blockToExpire;

        /**
         * @dev Result of the check. 0 indicates success, non-zero is left to the caller.
         */
        uint8 checkResult;
    }

    /**
     * @dev Mapping of requester and requestId to the check result.
     */
    mapping (address => mapping(uint256 => CheckResult)) checkResults;

    struct CheckRequest {
        address requester;
        uint256 requestId;
    }

    /**
     * @dev Mapping of action ids to request ids.
     */
    mapping (uint256 => CheckRequest) actionsToRequests;

    /**
     * @dev Emitted when a compliance check is performed.
     *
     * @param providerId The id of the provider.
     * @param providerVersion The version of the provider.
     * @param instrumentAddr The address of the instrument contract.
     * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
     * @param from The from address of the token transfer.
     * @param to The to address of the token transfer.
     * @param data Any additional data related to the action.
     * @param checkResult The result of the compliance check.
     * @param nextProviderId The id of the compliance provider used after this provider.
     */
    event ComplianceCheckPerformed(
        uint256 providerId,
        uint256 providerVersion,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint8 checkResult,
        uint256 nextProviderId
    );

    /**
     * @dev Emitted when the result of an asynchronous compliance check is written.
     *
     * @param providerId The id of the compliance check request.
     * @param blockToExpire The block in which the compliance check result expires.
     * @param checkResult The result of the compliance check.
     */
    event ComplianceCheckResultWritten(
        uint256 requestId,
        address requester,
        uint256 actionHash,
        uint256 providerId,
        uint256 providerVersion,
        uint256 blockToExpire,
        uint8 checkResult
    );

    /**
     * @dev Writes the result of an asynchronous compliance check to the blockchain.
     *
     * @param requestId The id of the request.
     * @param blockToExpire The block in which the compliance check result expires.
     * @param checkResult The result of the compliance check.
     */
    function writeCheckResult(
        uint256 requestId,
        address requester,
        uint256 providerId,
        uint256 providerVersion,
        uint256 actionHash,
        uint256 blockToExpire,
        uint8 checkResult
    ) external
    {
        uint256 id;
        address owner;
        uint256 version;
        (id,,, owner,version,) = providerRegistry.latestProvider(providerId);

        // Check service exists
        require(id != 0);
        // Check provider version is correct
        require(version == providerVersion);
        // Check service owner is correct
        require(msg.sender == owner);

        // Overwrite existing action
        actionsToRequests[actionHash] = CheckRequest({
            requester: requester,
            requestId: requestId
        });
        checkResults[requester][requestId] = CheckResult({
            requestId: requestId,
            actionHash: actionHash,
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });

        kernel.onAsyncServiceCompleted(providerId, requester, requestId);

        emit ComplianceCheckResultWritten({
            requestId: requestId,
            requester: requester,
            actionHash: actionHash,
            providerId: providerId,
            providerVersion: providerVersion,
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });
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
    ) external
    {
        uint256 actionHash = computeActionHash(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        address owner = providerRegistry.providerOwner(providerId);
        require(msg.sender == owner || msg.sender == instrumentAddr);
        CheckRequest storage request = actionsToRequests[actionHash];
        delete checkResults[request.requester][request.requestId];
        delete actionsToRequests[actionHash];
    }

    /**
     * @dev Computes an id for an action using keccak256.
     */
    function computeActionHash(
        uint256 providerId,
        uint256 providerVersion,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) pure public returns (uint256)
    {
        return uint256(
            keccak256(
                providerId,
                providerVersion,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            )
        );
    }

    uint8 constant E_CASYNC_CHECK_NOT_PERFORMED = 100;
    uint8 constant E_CASYNC_CHECK_NOT_EXPIRED = 101;

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
    ) view private returns (uint8, uint256)
    {
        uint256 actionHash = computeActionHash(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        CheckRequest storage request = actionsToRequests[actionHash];
        CheckResult storage result = checkResults[request.requester][request.requestId];

        // Check that the status check has been performed.
        if (result.blockToExpire == 0) {
            return (E_CASYNC_CHECK_NOT_PERFORMED, 0);
        }

        // Check that the status check has not expired. 
        if (result.blockToExpire < block.number) {
            return (E_CASYNC_CHECK_NOT_EXPIRED, 0);
        }

        return (result.checkResult, actionHash);
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
    ) view public returns (uint8, uint256)
    {
        uint8 checkResult;
        address owner;
        bool isAsync;
        (,,, owner,, isAsync) = providerRegistry.latestProvider(providerId);

        // Async checks
        if (isAsync) {
            (checkResult,) = checkAsync(
                providerId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
            if (checkResult != 0) {
                return (checkResult, providerId);
            }
            return (checkResult, 0);
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(owner);

        uint256 nextProviderId;
        (checkResult, nextProviderId) = standard.performCheck(
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );

        if (nextProviderId != 0) {
            // recursively check next service
            (checkResult, nextProviderId) = check(
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

    uint8 constant E_CHECK_INSTRUMENT_WRONG_SENDER = 140;

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
    ) public returns (uint8, uint256)
    {
        if (msg.sender != instrumentAddr) {
            return (E_CHECK_INSTRUMENT_WRONG_SENDER, 0);
        }
        address owner;
        uint256 providerVersion;
        bool isAsync;
        (,,, owner, providerVersion, isAsync) = providerRegistry.latestProvider(providerId);

        uint8 checkResult;

        // This variable is used for two purposes to save on stack space.
        uint256 nextProviderIdOrActionHash;

        // Async checks
        if (isAsync) {
            (checkResult, nextProviderIdOrActionHash) = checkAsync(
                providerId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
            emit ComplianceCheckPerformed(
                providerId,
                providerVersion,
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
            // Invalidate check result if successful check.
            delete actionsToRequests[nextProviderIdOrActionHash];
            return (checkResult, 0);
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(owner);

        (checkResult, nextProviderIdOrActionHash) = standard.performCheck(
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        standard.performHardCheck(
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );

        // For auditing
        emit ComplianceCheckPerformed(
            providerId,
            providerVersion,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data,
            checkResult,
            nextProviderIdOrActionHash
        );

        if (nextProviderIdOrActionHash != 0) {
            // recursively check next service
            (checkResult, nextProviderIdOrActionHash) = hardCheck(
                nextProviderIdOrActionHash,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
        }
        return (checkResult, nextProviderIdOrActionHash);
    }
}
