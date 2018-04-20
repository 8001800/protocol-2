pragma solidity ^0.4.21;

import "../identity/IdentityToken.sol";
import "../AnnotationDatabase.sol";
import "../compliance/ComplianceStandard.sol";

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

    function check(
        address token,
        uint256,
        address from,
        address to,
        bytes32 
    ) view external returns (uint8, uint256)
    {
        uint256 fromVal = uint256(
            identityToken.annotationDatabase().bytes32Data(
                identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_NUM
            )
        );
        bool fromAllowed = token == from ? true : fromVal > 10;
        uint256 toVal = uint256(
            identityToken.annotationDatabase().bytes32Data(
                identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_NUM
            )
        );
        if (fromAllowed && toVal > 10) {
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