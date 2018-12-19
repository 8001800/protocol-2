pragma solidity ^0.4.24;

import "../../library/instruments/AbacusERC20Token.sol";

/**
 * @dev A token that requires being on a whitelist.
 */
contract BaseTestToken is AbacusERC20Token {
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000000000000 * (10 ** uint256(decimals));

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
        _mint(msg.sender, INITIAL_SUPPLY);
    }
}