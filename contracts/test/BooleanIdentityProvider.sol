pragma solidity ^0.4.19;

import "../identity/IdentityProvider.sol";

contract BooleanIdentityProvider is IdentityProvider {
    uint256 constant public FIELD_PASSES = 0x198254;

    mapping (address => bool) passes;

    function BooleanIdentityProvider(
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) IdentityProvider(_identityCoordinator, providerId) public
    {
    }

    function getBoolField(address user, uint256 fieldId) view external returns (bool) {
        if (fieldId == FIELD_PASSES) {
            return passes[user];
        }
        assert(false);
    }

    function addPassing(address user, uint256 requestId) external returns (bool) {
        // First check if the verification request is valid.
        if (!identityCoordinator.onVerificationCompleted(providerId, user, requestId)) {
            return false;
        }

        // Then we make it pass.
        passes[user] = true;
        return true;
    }

}