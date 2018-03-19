pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "../NeedsAbacus.sol";
import "./ComplianceStandard.sol";
import "../provider/ProviderRegistry.sol";

/**
 * Registry for compliance providers.
 */
contract ComplianceCoordinator is NeedsAbacus {
    ProviderRegistry public providerRegistry;

    function ComplianceCoordinator(ProviderRegistry _providerRegistry) public  {
        providerRegistry = _providerRegistry;
    }

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
     * @dev Mapping of action id => check status.
     */
    mapping (uint256 => CheckStatus) public statuses;

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
     * @dev Emitted when an asynchronous compliance check is requested.
     * This event is to be subscribed to and read by the provider off-chain.
     * Once the off-chain provider sees this event and ensures the correct cost
     * has been paid, they are to perform a compliance check then call `writeCheckResult`
     * with the appropriate parameters.
     *
     * @param providerId The id of the provider.
     * @param providerVersion The version of the provider.
     * @param instrumentAddr The address of the instrument contract.
     * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
     * @param from The from address of the token transfer.
     * @param to The to address of the token transfer.
     * @param data Any additional data related to the action.
     * @param cost The amount the user paid to the compliance provider.
     */
    event ComplianceCheckRequested(
        uint256 indexed providerId,
        uint256 providerVersion,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 cost
    );

    /**
     * @dev Emitted when the result of an asynchronous compliance check is written.
     *
     * @param providerId The id of the provider.
     * @param providerVersion The version of the provider.
     * @param instrumentAddr The address of the instrument contract.
     * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
     * @param from The from address of the token transfer.
     * @param to The to address of the token transfer.
     * @param data Any additional data related to the action.
     * @param blockToExpire The block in which the compliance check result expires.
     * @param checkResult The result of the compliance check.
     */
    event ComplianceCheckResultWritten(
        uint256 providerId,
        uint256 providerVersion,
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
     *
     * @param providerId The id of the provider.
     * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
     * @param from The from address of the token transfer.
     * @param to The to address of the token transfer.
     * @param data Any additional data related to the action.
     * @param cost The amount the user paid to the compliance provider.
     */
    function requestCheck(
        uint256 providerId,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 cost
    ) external returns (bool)
    {
        address owner = providerRegistry.providerOwner(providerId);
        if (!kernel.transferTokensFrom(msg.sender, owner, cost)) {
            return false;
        }
        ComplianceCheckRequested(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data,
            cost
        );
    }

    uint8 constant E_RESULT_SERVICE_NOT_FOUND = 1;
    uint8 constant E_RESULT_UNAUTHORIZED = 2;
    uint8 constant E_RESULT_VERSION_MISMATCH = 3;

    /**
     * @dev Writes the result of an asynchronous compliance check to the blockchain.
     *
     * @param providerId The id of the provider.
     * @param providerVersion The version of the provider.
     * @param instrumentAddr The address of the instrument contract.
     * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
     * @param from The from address of the token transfer.
     * @param to The to address of the token transfer.
     * @param data Any additional data related to the action.
     * @param blockToExpire The block in which the compliance check result expires.
     * @param checkResult The result of the compliance check.
     */
    function writeCheckResult(
        uint256 providerId,
        uint256 providerVersion,
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data,
        uint256 blockToExpire,
        uint8 checkResult
    ) external returns (uint8)
    {
        // Check provider version is correct
        if (providerRegistry.latestProviderVersion(providerId) != providerVersion) {
            return E_RESULT_VERSION_MISMATCH;
        }

        uint256 id;
        address owner;
        (id,,, owner,,) = providerRegistry.latestProvider(providerId);

        // Check service exists
        if (id == 0) {
            return E_RESULT_SERVICE_NOT_FOUND;
        }
        // Check service owner is correct
        if (owner != msg.sender) {
            return E_RESULT_UNAUTHORIZED;
        }

        uint256 actionId = computeActionId(
            providerId,
            providerVersion,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );

        statuses[actionId] = CheckStatus({
            blockToExpire: blockToExpire,
            checkResult: checkResult
        });
        ComplianceCheckResultWritten(
            providerId,
            providerVersion,
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
            providerRegistry.latestProviderVersion(providerId),
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        address owner = providerRegistry.providerOwner(providerId);
        if (owner != msg.sender || instrumentAddr != msg.sender) {
            return false;
        }
        delete statuses[actionId];
        return true;
    }

    /**
     * @dev Computes an id for an action using keccak256.
     */
    function computeActionId(
        uint256 providerId,
        uint256 providerVersion,
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
    ) view private returns (uint8)
    {
        uint256 actionId = computeActionId(
            providerId,
            providerRegistry.latestProviderVersion(providerId),
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
        CheckStatus storage status = statuses[actionId];

        // Check that the status check has been performed.
        if (status.blockToExpire == 0) {
            return E_CASYNC_CHECK_NOT_PERFORMED;
        }

        // Check that the status check has not expired. 
        if (status.blockToExpire <= block.number) {
            return E_CASYNC_CHECK_NOT_EXPIRED;
        }

        return status.checkResult;
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
        address owner;
        bool hasMetadata;
        (,,, owner,, hasMetadata) = providerRegistry.latestProvider(providerId);

        // Async checks
        if (hasMetadata) {
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
        ComplianceStandard standard = ComplianceStandard(owner);

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
        bool hasMetadata;
        (,,, owner, providerVersion, hasMetadata) = providerRegistry.latestProvider(providerId);

        uint8 checkResult;

        // Async checks
        if (hasMetadata) {
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
            return (checkResult, 0);
        }

        // Sync checks
        ComplianceStandard standard = ComplianceStandard(owner);

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
            providerVersion,
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
