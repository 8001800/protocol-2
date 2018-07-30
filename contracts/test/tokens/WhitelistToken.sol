pragma solidity ^0.4.24;

import "../../library/instruments/AbacusERC20Token.sol";

/**
 * @dev A token that requires being on a whitelist.
 */
contract WhitelistToken is AbacusERC20Token {
    string public constant name = "Whitelist Token";
    string public constant symbol = "WHT";

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
    }
}