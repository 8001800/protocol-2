pragma solidity ^0.4.21;

import "../AbacusKernel.sol";
import "../identity/IdentityProvider.sol";

contract SandboxIdentityProvider is IdentityProvider {
    AbacusKernel kernel;

    function SandboxIdentityProvider(
        AbacusKernel _kernel,
        IdentityToken _identityToken,
        uint256 _providerId
    ) IdentityProvider(
        _identityToken,
        _kernel.providerRegistry(),
        _providerId
    ) public
    {
        kernel = _kernel;
    }

    function writeBytes32Field(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes32 value
    ) external onlyOwner {
        kernel.onAsyncServiceCompleted(providerId, user, requestId);
        writeBytes32Field(user, fieldId, value);
    }

    function writeBytesField(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes value
    ) external onlyOwner {
        kernel.onAsyncServiceCompleted(providerId, user, requestId);
        writeBytesField(user, fieldId, value);
    }

}