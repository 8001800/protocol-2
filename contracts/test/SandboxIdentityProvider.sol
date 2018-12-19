pragma solidity ^0.4.24;

import "../library/provider/IdentityProvider.sol";

contract SandboxIdentityProvider is IdentityProvider {

    constructor(
        ProviderRegistry _providerRegistry,
        IdentityToken _identityToken,
        uint256 _providerId
    ) IdentityProvider(
        _providerRegistry,
        _identityToken,
        _providerId
    ) public
    {
    }

    function writeBytes32FieldForService(
        address tokenAddr,
        uint256 tokenId,
        uint256 fieldId,
        bytes32 value,
        address requester
    ) external onlyAdmin {
        writeBytes32Field(tokenAddr, tokenId, fieldId, value);
    }

    function writeBytesFieldForService(
        address tokenAddr,
        uint256 tokenId,
        uint256 fieldId,
        bytes value,
        address requester
    ) external onlyAdmin {
        writeBytesField(tokenAddr, tokenId, fieldId, value);
    }

    function writeIdentityBytes32FieldForService(
        address user,
        uint256 fieldId,
        bytes32 value
    ) external onlyAdmin {
        writeIdentityBytes32Field(user, fieldId, value);
    }

    function writeIdentityBytesFieldForService(
        address user,
        uint256 fieldId,
        bytes value
    ) external onlyAdmin {
        writeIdentityBytesField(user, fieldId, value);
    }

}