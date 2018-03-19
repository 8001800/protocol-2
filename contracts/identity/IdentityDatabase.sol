pragma solidity ^0.4.19;

import "../NeedsAbacus.sol";
import "../provider/ProviderRegistry.sol";

contract IdentityDatabase is NeedsAbacus {
    ProviderRegistry public providerRegistry;

    function IdentityDatabase(ProviderRegistry _providerRegistry) public {
        providerRegistry = _providerRegistry;
    }

    event IdentityVerificationRequested(
        uint256 providerId,
        address user,
        string args,
        uint256 cost,
        uint256 requestToken
    );

    /**
     * @dev Requests verification of identity from a provider.
     */
    function requestVerification(
        uint256 providerId,
        string args,
        uint256 cost,
        uint256 requestToken
    ) external returns (bool)
    {
        address owner = providerRegistry.providerOwner(providerId);
        if (!kernel.transferTokensFrom(msg.sender, owner, cost)) {
            return false;
        }
        IdentityVerificationRequested(providerId, msg.sender, args, cost, requestToken);
    }

}
