pragma solidity ^0.4.21;

import "../../identity/IdentityToken.sol";
import "../../AnnotationDatabase.sol";
import "../../compliance/ComplianceStandard.sol";

contract AccreditedUSCS is ComplianceStandard {
    IdentityToken identityToken;

    uint256 operations = 0;
    uint256 identityProviderId;
    uint256 constant public FIELD_NON_US = 1776;
    uint256 constant public FIELD_ACCREDITED = 506;

    function AccreditedUSCS(
        IdentityToken _identityToken,
        ProviderRegistry _providerRegistry,
        uint256 _providerId,
        uint256 _identityProviderId
    ) Provider(_providerRegistry, _providerId) public
    {
        identityToken = _identityToken;
        identityProviderId = _identityProviderId;
    }

    function fromAllowed(address token, address from) view internal returns (uint8) {
        bytes32 fromNonUsVal;
        (,fromNonUsVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_NON_US
        );
        bool fromNonUs = fromNonUsVal != bytes32(0);

        bytes32 fromAccreditedVal;
        (,fromAccreditedVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(from), identityProviderId, FIELD_ACCREDITED
        );
        bool fromAccredited = fromAccreditedVal != bytes32(0);

        if (token == from) {
            fromNonUs = true;
            fromAccredited = true;
        }

        if (fromNonUs || fromAccredited) {
            return 0;
        }

        uint8 err = 0x10;
        if (fromNonUs) {
            err |= 0x8;
        }
        if (fromAccredited) {
            err |= 0x4;
        }
        return err;
    }

    function toAllowed(address to) internal view returns (uint8) {
        bytes32 toNonUsVal;
        (,toNonUsVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_NON_US
        );
        bool toNonUs = toNonUsVal != bytes32(0);

        bytes32 toAccreditedVal;
        (,toAccreditedVal) = identityToken.annotationDatabase().bytes32Data(
            identityToken, identityToken.tokenOf(to), identityProviderId, FIELD_ACCREDITED
        );
        bool toAccredited = toAccreditedVal != bytes32(0);

        if (toNonUs || toAccredited) {
            return 0;
        }

        uint8 err = 0x10;
        if (toNonUs) {
            err |= 0x2;
        }
        if (toAccredited) {
            err |= 0x1;
        }
        return err;
    }

    function performCheck(
        address token,
        uint256,
        address from,
        address to,
        bytes32 
    ) view external returns (uint8, uint256)
    {
        uint8 fromAllowedRes = fromAllowed(token, to);
        uint8 toAllowedRes = toAllowed(to);
        if ((fromAllowedRes == 0) && (toAllowedRes == 0)) {
            return (0, 0);
        }

        return (fromAllowedRes | toAllowedRes, 0);
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