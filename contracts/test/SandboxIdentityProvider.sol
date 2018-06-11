pragma solidity ^0.4.21;

import "../protocol/AbacusKernel.sol";
import "../library/provider/IdentityProvider.sol";

contract SandboxIdentityProvider is IdentityProvider {

    function SandboxIdentityProvider(
        AbacusKernel _kernel,
        AbacusToken _token,
        IdentityToken _identityToken,
        uint256 _providerId
    ) IdentityProvider(
        _identityToken,
        _kernel.providerRegistry(),
        _kernel,
        _token,
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