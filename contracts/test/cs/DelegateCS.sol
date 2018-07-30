pragma solidity ^0.4.24;

import "../../library/compliance/ComplianceStandard.sol";
import "../../protocol/coordinator/ComplianceCoordinator.sol";

/**
 * @dev A compliance standard that ensures everyone is on a whitelist.
 */
contract DelegateCS is ComplianceStandard {

    mapping (address => bool) allowed;

    uint256 constant E_UNWHITELISTED = 1;
    uint256 operations = 0;
    uint256 delegateProviderId;

    ComplianceCoordinator complianceCoordinator;

    constructor(
        ProviderRegistry _providerRegistry,
        uint256 _providerId,
        uint256 _delegateProviderId,
        ComplianceCoordinator _complianceCoordinator
    ) Provider(_providerRegistry, _providerId) public
    {
        delegateProviderId = _delegateProviderId;
        allowed[msg.sender] = true;
        complianceCoordinator = _complianceCoordinator;
    }

    function allow(address user) external returns (bool) {
        allowed[user] = true;
    }

    function performCheck(
        address instrumentAddr,
        uint256 instrumentIdOrAmt,
        address from,
        address to,
        bytes32 data
    ) external returns (uint256)
    {
        operations++;
        if (allowed[from] && allowed[to]) {
            return complianceCoordinator.check(
                delegateProviderId,
                instrumentAddr,
                instrumentIdOrAmt,
                from,
                to,
                data
            );
        } else {
            return E_UNWHITELISTED;
        }
    }
}