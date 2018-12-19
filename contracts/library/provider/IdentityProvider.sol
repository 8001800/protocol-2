pragma solidity ^0.4.24;

import "../../protocol/IdentityToken.sol";
import "./AsyncProvider.sol";

contract IdentityProvider is AsyncProvider {
    IdentityToken identityToken;

    constructor(
        ProviderRegistry _providerRegistry,
        IdentityToken _identityToken,
        uint256 _providerId
    ) AsyncProvider(
        _providerRegistry,
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
    ) public onlyAdmin {
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
    ) public onlyAdmin {
        writeBytesField(
            identityToken,
            identityToken.tokenOf(user),
            fieldId,
            value
        );
    }
}
