pragma solidity ^0.4.21;

import "../FaucetToken.sol";

/**
 * @dev A token that requires being on a whitelist.
 */
contract WhitelistToken is FaucetToken {
    string public constant name = "Whitelist Token";
    string public constant symbol = "WHT";

    function WhitelistToken(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) FaucetToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}