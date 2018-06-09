pragma solidity ^0.4.21;

import "../../protocol/IdentityToken.sol";
import "./Provider.sol";

contract IdentityProvider is Provider {
    IdentityToken identityToken;

    function IdentityProvider(
        IdentityToken _identityToken,
        ProviderRegistry _providerRegistry,
        uint256 _providerId
    ) Provider(_providerRegistry, _providerId) public
    {
        identityToken = _identityToken;
    }

    function writeBytes32Field(
        address user,
        uint256 fieldId,
        bytes32 value
    ) public {
        identityToken.annotationDatabase().writeBytes32Field(
            identityToken,
            identityToken.tokenOf(user),
            providerId,
            fieldId,
            value
        );
    }

    function writeBytesField(
        address user,
        uint256 fieldId,
        bytes value
    ) public {
        identityToken.annotationDatabase().writeBytesField(
            identityToken,
            identityToken.tokenOf(user),
            providerId,
            fieldId,
            value
        );
    }
}
