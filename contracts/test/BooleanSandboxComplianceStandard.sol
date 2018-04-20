pragma solidity ^0.4.21;

import "../identity/IdentityToken.sol";
import "../AnnotationDatabase.sol";
import "../compliance/ComplianceStandard.sol";

contract BooleanSandboxComplianceStandard is ComplianceStandard {
    IdentityToken identityToken;

    uint8 constant E_UNWHITELISTED = 1;
    uint256 operations = 0;
    uint256 identityProviderId;
    uint256 constant public FIELD_NUM = 88;

    function BooleanSandboxComplianceStandard(
        IdentityToken _identityToken,
        ProviderRegistry _providerRegistry,
        uint256 _providerId,
        uint256 _identityProviderId
    ) Provider(_providerRegistry, _providerId) public
    {
        identityToken = _identityToken;
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
        bool fromPasses = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_NUM
        ) != bytes32(0);
        if (token == from) {
            fromPasses = true;
        }
        bool toPasses = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_NUM
        ) != bytes32(0);
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