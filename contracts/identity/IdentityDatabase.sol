pragma solidity ^0.4.19;

import "../NeedsAbacus.sol";
import "../provider/ProviderRegistry.sol";

contract IdentityDatabase is ProviderRegistry, NeedsAbacus {
    event IdentityVerificationRequested(
        uint256 providerId,
        address user,
        string args,
        uint256 cost,
        uint256 requestToken
    );

    function requestVerification(
        uint256 providerId,
        address user,
        string args,
        uint256 cost,
        uint256 requestToken
    ) fromKernel external
    {
        IdentityVerificationRequested(providerId, user, args, cost, requestToken);
    }

}
