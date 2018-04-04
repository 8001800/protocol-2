pragma solidity ^0.4.19;

import "../provider/Provider.sol";
import "../identity/IdentityCoordinator.sol";

contract IdentityProvider is Provider {
    IdentityCoordinator identityCoordinator;

    function IdentityProvider(
        IdentityCoordinator _identityCoordinator,
        uint256 providerId
    ) Provider(_identityCoordinator.providerRegistry(), providerId) public
    {
        identityCoordinator = _identityCoordinator;
    }
}
