pragma solidity ^0.4.21;

import "../identity/IdentityCoordinator.sol";
import "../compliance/ComplianceStandard.sol";

contract BooleanSandboxComplianceStandard is ComplianceStandard {
    IdentityCoordinator identityCoordinator;

    uint8 constant E_UNWHITELISTED = 1;
    uint256 operations = 0;
    uint256 identityProviderId;
    uint256 constant public FIELD_NUM = 88;

    function BooleanSandboxComplianceStandard(
        IdentityCoordinator _identityCoordinator,
        ProviderRegistry _providerRegistry,
        uint256 _providerId,
        uint256 _identityProviderId
    ) Provider(_providerRegistry, _providerId) public
    {
        identityCoordinator = _identityCoordinator;
        identityProviderId = _identityProviderId;
    }

    function check(
        address token,
        uint256,
        address from,
        address to,
        bytes32 
    ) view external returns (uint8, uint256)
    {
        bool fromPasses = identityCoordinator.bytes32Data(identityProviderId, from, FIELD_NUM) != bytes32(0);
        if (token == from) {
            fromPasses = true;
        }
        bool toPasses = identityCoordinator.bytes32Data(identityProviderId, to, FIELD_NUM) != bytes32(0);
        if (fromPasses && toPasses) {
            return (0, 0);
        } else {
            return (E_UNWHITELISTED, 0);
        }
    }

    function onHardCheck(
        address,
        uint256,
        address,
        address,
        bytes32
    ) external
    {
        operations++;
    }

}