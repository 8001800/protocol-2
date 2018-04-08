pragma solidity ^0.4.21;

import "../identity/IdentityDatabase.sol";
import "../identity/IdentityProvider.sol";

contract SandboxIdentityProvider is IdentityProvider {
    IdentityDatabase identityDatabase;

    function SandboxIdentityProvider(
        IdentityDatabase _identityDatabase,
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) IdentityProvider(_identityCoordinator, providerId) public
    {
        identityDatabase = _identityDatabase;
    }

    function writeBytes32Field(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes32 value
    ) external onlyOwner returns (bool) {
        // First lock the verification so we can "start".
        if (!identityCoordinator.lockVerification(providerId, user, requestId, 10)) {
            return false;
        }
        // Then complete the verification.
        if (!identityCoordinator.onVerificationCompleted(providerId, user, requestId)) {
            return false;
        }
        return identityDatabase.writeBytes32Field(providerId, user, fieldId, value);
    }

    function writeBytesField(
        address user,
        uint256 requestId,
        uint256 fieldId,
        bytes value
    ) external onlyOwner returns (bool) {
        // First lock the verification so we can "start".
        if (!identityCoordinator.lockVerification(providerId, user, requestId, 10)) {
            return false;
        }
        // Then complete the verification.
        if (!identityCoordinator.onVerificationCompleted(providerId, user, requestId)) {
            return false;
        }
        return identityDatabase.writeBytesField(providerId, user, fieldId, value);
    }

}