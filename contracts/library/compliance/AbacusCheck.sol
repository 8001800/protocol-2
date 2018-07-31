pragma solidity ^0.4.24;

import "../../protocol/coordinator/ComplianceCoordinator.sol";

/**
 * @dev An ERC20 token that uses Abacus for compliance.
 */
contract AbacusCheck {
    ComplianceCoordinator complianceCoordinator;
    uint256 complianceProviderId;

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) public
    {
        complianceCoordinator = _complianceCoordinator;
        complianceProviderId = _complianceProviderId;
    }

    function check(
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) internal returns (uint256 checkResult) {
        checkResult = complianceCoordinator.check(
            complianceProviderId,
            this,
            instrumentIdOrAmt,
            from,
            to,
            data
        );
    }

}

