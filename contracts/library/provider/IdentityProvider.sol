pragma solidity ^0.4.24;

import "../../protocol/IdentityToken.sol";
import "../../protocol/AbacusKernel.sol";
import "./AsyncProvider.sol";

contract IdentityProvider is AsyncProvider {
    IdentityToken identityToken;

    constructor(
        IdentityToken _identityToken,
        AbacusKernel _kernel,
        uint256 _providerId
    ) AsyncProvider(_kernel, _providerId) public
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
