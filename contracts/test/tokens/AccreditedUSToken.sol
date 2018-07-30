pragma solidity ^0.4.24;

import "./BaseTestToken.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract AccreditedUSToken is BaseTestToken {
    string public constant name = "Accredited US Token";
    string public constant symbol = "AUS";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) BaseTestToken(_complianceCoordinator, _complianceProviderId) public
    {
    }
}