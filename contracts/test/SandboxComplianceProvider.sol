pragma solidity ^0.4.24;

import "../library/provider/AsyncProvider.sol";
import "../protocol/coordinator/ComplianceCoordinator.sol";

contract SandboxComplianceProvider is AsyncProvider {
    ComplianceCoordinator complianceCoordinator;

    constructor(
        ProviderRegistry _providerRegistry,
        AnnotationDatabase _annotationDatabase,
        uint256 _providerId,
        ComplianceCoordinator _complianceCoordinator
    ) AsyncProvider(
        _providerRegistry,
        _annotationDatabase,
        _providerId
    ) public
    {
        complianceCoordinator = _complianceCoordinator;
    }

    /**
     * @dev Writes the result of an asynchronous compliance check to the blockchain.
     *
     * @param blockToExpire The block in which the compliance check result expires.
     * @param checkResult The result of the compliance check.
     */
    function writeCheckResult(
        uint256 providerVersion,
        uint256 actionHash,
        uint256 blockToExpire,
        uint256 checkResult
    ) external
    {
        complianceCoordinator.writeCheckResult(
            providerId,
            providerVersion,
            actionHash,
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
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) external
    {
        complianceCoordinator.invalidateCheckResult(
            providerId,
            instrumentAddr,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
    }
}