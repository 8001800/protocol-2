pragma solidity ^0.4.19;

import "../NeedsAbacus.sol";
import "../provider/ProviderRegistry.sol";

contract IdentityDatabase is ProviderRegistry, NeedsAbacus {
    event IdentityVerificationRequested(
        uint256 providerId,
        string args
    );

    function requestIdentity(
        uint256 providerId,
        string args
    ) fromKernel external
    {
        IdentityVerificationRequested(providerId, args);
    }

}
