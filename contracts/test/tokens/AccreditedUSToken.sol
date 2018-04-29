pragma solidity ^0.4.21;

import "../FaucetToken.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract AccreditedUSToken is FaucetToken {
    string public constant name = "Accredited US Token";
    string public constant symbol = "AUS";

    function AccreditedUSToken(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) FaucetToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}