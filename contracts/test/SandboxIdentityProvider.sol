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
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes32 value
    ) external onlyOwner {
        kernel.onAsyncServiceCompleted(providerId, user, requestId);
        writeBytes32Field(user, fieldId, value);
    }

    function writeBytesFieldForService(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes value
    ) external onlyOwner {
        kernel.onAsyncServiceCompleted(providerId, user, requestId);
        writeBytesField(user, fieldId, value);
    }

}