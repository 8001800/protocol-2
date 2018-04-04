pragma solidity ^0.4.21;

import "../identity/IdentityDatabase.sol";
import "../identity/IdentityProvider.sol";

contract BooleanIdentityProvider is IdentityProvider {
    uint256 constant public FIELD_PASSES = 0x198254;
    IdentityDatabase identityDatabase;

    function BooleanIdentityProvider(
        IdentityDatabase _identityDatabase,
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) IdentityProvider(_identityCoordinator, providerId) public
    {
        identityDatabase = _identityDatabase;
    }

    function addPassing(address user, uint256 requestId) external returns (bool) {
        // First check if the verification request is valid.
        if (!identityCoordinator.onVerificationCompleted(providerId, user, requestId)) {
            return false;
        }

        // Then we make it pass.
        identityDatabase.writeBytes32Field(providerId, user, FIELD_PASSES, bytes32(1));
        return true;
    }

}