pragma solidity ^0.4.24;

import "../FaucetToken.sol";

/**
 * @dev A token that may only be used outside of the US.
 */
contract OutsideUSToken is FaucetToken {
    string public constant name = "Outside US Token";
    string public constant symbol = "OUS";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) FaucetToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}