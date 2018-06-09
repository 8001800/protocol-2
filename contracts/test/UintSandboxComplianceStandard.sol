pragma solidity ^0.4.21;

import "../protocol/IdentityToken.sol";
import "../protocol/AnnotationDatabase.sol";
import "../library/compliance/ComplianceStandard.sol";

contract UintSandboxComplianceStandard is ComplianceStandard {
    IdentityToken identityToken;

    uint8 constant E_UNWHITELISTED = 1;
    uint256 operations = 0;
    uint256 identityProviderId;
    uint256 constant public FIELD_NUM = 888;

    function UintSandboxComplianceStandard(
        IdentityToken _identityToken,
        ProviderRegistry _providerRegistry,
        uint256 _providerId,
        uint256 _identityProviderId
    ) Provider(_providerRegistry, _providerId) public
    {
        identityToken = _identityToken;
        identityProviderId = _identityProviderId;
    }

    function performCheck(
        address token,
        uint256,
        address from,
        address to,
        bytes32 
    ) view external returns (uint8, uint256)
    {
        bytes32 fromVal;
        (,fromVal) = 
            identityToken.annotationDatabase().bytes32Data(
                identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_NUM
            );
        bool fromAllowed = token == from || (uint256(fromVal) > 10);
        bytes32 toVal;
        (,toVal) = 
            identityToken.annotationDatabase().bytes32Data(
                identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_NUM
            );
        if (fromAllowed && uint256(toVal) > 10) {
            return (0, 0);
        } else {
            return (E_UNWHITELISTED, 0);
        }
    }

    function performHardCheck(
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