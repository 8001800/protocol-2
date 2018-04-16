pragma solidity ^0.4.21;

import "../AbacusKernel.sol";
import "../identity/IdentityCoordinator.sol";
import "../identity/IdentityProvider.sol";

contract SandboxIdentityProvider is IdentityProvider {
    AbacusKernel kernel;

    function SandboxIdentityProvider(
        AbacusKernel _kernel,
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) IdentityProvider(_identityCoordinator, providerId) public
    {
        kernel = _kernel;
    }

    function writeBytes32Field(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes32 value
    ) external onlyOwner {
        kernel.lockRequest(providerId, user, requestId, 10);
        kernel.onServiceCompleted(providerId, user, requestId);
        identityCoordinator.writeBytes32Field(providerId, user, fieldId, value);
    }

    function writeBytesField(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes value
    ) external onlyOwner {
        kernel.lockRequest(providerId, user, requestId, 10);
        kernel.onServiceCompleted(providerId, user, requestId);
        identityCoordinator.writeBytesField(providerId, user, fieldId, value);
    }

}