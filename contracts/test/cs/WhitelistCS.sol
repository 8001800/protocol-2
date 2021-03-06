pragma solidity ^0.4.24;

import "../../protocol/IdentityToken.sol";
import "../../protocol/AnnotationDatabase.sol";
import "../../library/compliance/ComplianceStandard.sol";

contract WhitelistCS is ComplianceStandard {
    IdentityToken identityToken;

    uint256 operations = 0;
    uint256 identityProviderId;
    uint256 constant public FIELD_WHITELISTED = 0xfaceb00c;

    constructor(
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
    ) external returns (uint256)
    {
        operations++;
        bytes32 fromWhitelistedVal;
        (,fromWhitelistedVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_WHITELISTED
        );
        bool fromWhitelisted = fromWhitelistedVal != bytes32(0);

        // initial issuance
        if (token == from) {
            fromWhitelisted = true;
        }

        bytes32 toWhitelistedVal;
        (,toWhitelistedVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_WHITELISTED
        );
        bool toWhitelisted = toWhitelistedVal != bytes32(0);

        if (fromWhitelisted && toWhitelisted) {
            return 0;
        }

        uint256 err = 0x10;
        if (fromWhitelisted) {
            err |= 0x8;
        }
        if (toWhitelisted) {
            err |= 0x2;
        }
        return err;
    }

}