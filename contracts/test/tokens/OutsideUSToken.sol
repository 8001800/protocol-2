pragma solidity ^0.4.24;

import "../../library/instruments/AbacusERC20Token.sol";

/**
 * @dev A token that may only be used outside of the US.
 */
contract OutsideUSToken is AbacusERC20Token {
    string public constant name = "Outside US Token";
    string public constant symbol = "OUS";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
    }
}