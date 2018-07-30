pragma solidity ^0.4.24;

import "../../library/instruments/AbacusERC20Token.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract AccreditedUSToken is AbacusERC20Token {
    string public constant name = "Accredited US Token";
    string public constant symbol = "AUS";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
    }
}