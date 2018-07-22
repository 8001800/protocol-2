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
    ) AsyncProvider(
        _kernel, 
        _identityToken.annotationDatabase(),
        _providerId
        ) public
    {
        identityToken = _identityToken;
    }

    function writeIdentityBytes32Field(
        address user,
        uint256 fieldId,
        bytes32 value
    ) public onlyRole(ROLE_ADMIN) {
        writeBytes32Field(
            identityToken,
            identityToken.tokenOf(user),
            fieldId,
            value
        );
    }

    function writeIdentityBytesField(
        address user,
        uint256 fieldId,
        bytes value
    ) public onlyRole(ROLE_ADMIN) {
        writeBytesField(
            identityToken,
            identityToken.tokenOf(user),
            fieldId,
            value
        );
    }
}
