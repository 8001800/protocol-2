pragma solidity ^0.4.24;

import "../../protocol/IdentityToken.sol";
import "../../protocol/AnnotationDatabase.sol";
import "../../library/compliance/ComplianceStandard.sol";

contract OutsideUSCS is ComplianceStandard {
    IdentityToken identityToken;

    uint256 operations = 0;
    uint256 identityProviderId;
    uint256 constant public FIELD_NON_US = 1776;

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
        bytes32 fromNonUsVal;
        (,fromNonUsVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_NON_US
        );
        bool fromNonUs = fromNonUsVal != bytes32(0);

        // initial issuance
        if (token == from) {
            fromNonUs = true;
        }

        bytes32 toNonUsVal;
        (,toNonUsVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_NON_US
        );
        bool toNonUs = toNonUsVal != bytes32(0);

        if (fromNonUs && toNonUs) {
            return 0;
        }

        uint256 err = 0x10;
        if (fromNonUs) {
            err |= 0x8;
        }
        if (toNonUs) {
            err |= 0x2;
        }
        return err;
    }

}