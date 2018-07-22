pragma solidity ^0.4.24;

import "../protocol/AbacusKernel.sol";
import "../library/provider/IdentityProvider.sol";

contract SandboxIdentityProvider is IdentityProvider {

    constructor(
        IdentityToken _identityToken,
        AbacusKernel _kernel,
        uint256 _providerId
    ) IdentityProvider(
        _identityToken,
        _kernel,
        _providerId
    ) public
    {
    }

    function writeBytes32FieldForService(
        address tokenAddr,
        uint256 tokenId,
        uint256 requestId,
        uint256 fieldId,
        bytes32 value,
        address requester
    ) external onlyRole(ROLE_ADMIN) {
        kernel.onAsyncServiceCompleted(providerId, requester, requestId);
        writeBytes32Field(tokenAddr, tokenId, fieldId, value);
    }

    function writeBytesFieldForService(
        address tokenAddr,
        uint256 tokenId,
        uint256 requestId,
        uint256 fieldId,
        bytes value,
        address requester
    ) external onlyRole(ROLE_ADMIN) {
        kernel.onAsyncServiceCompleted(providerId, requester, requestId);
        writeBytesField(tokenAddr, tokenId, fieldId, value);
    }

    function writeIdentityBytes32FieldForService(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes32 value
    ) external onlyRole(ROLE_ADMIN) {
        kernel.onAsyncServiceCompleted(providerId, user, requestId);
        writeIdentityBytes32Field(user, fieldId, value);
    }

    function writeIdentityBytesFieldForService(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes value
    ) external onlyRole(ROLE_ADMIN) {
        kernel.onAsyncServiceCompleted(providerId, user, requestId);
        writeIdentityBytesField(user, fieldId, value);
    }

}