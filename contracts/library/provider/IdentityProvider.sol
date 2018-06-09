pragma solidity ^0.4.21;

import "../../protocol/IdentityToken.sol";
import "./AsyncProvider.sol";

contract IdentityProvider is AsyncProvider {
    IdentityToken identityToken;

    function IdentityProvider(
        IdentityToken _identityToken,
        ProviderRegistry _providerRegistry,
        AbacusKernel _abacusKernel,
        AbacusToken _abacusToken,
        uint256 _providerId
    ) AsyncProvider(_providerRegistry, _abacusKernel, _abacusToken, _providerId) public
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
