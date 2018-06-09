pragma solidity ^0.4.21;

import "../library/instruments/AbacusERC20Token.sol";

/**
 * @dev Token that takes all necessary details in as constructor parameters.
 * Meant to be used as a factory contract of sorts.
 */
contract AbacusERC20WithDetails is AbacusERC20Token {
    string public name;
    string public symbol;
    uint8 public decimals;

    function AbacusERC20WithDetails(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId,
        string _name,
        string _symbol,
        uint8 _decimals,
        uint256 _initialSupply
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
        name = _name;
        symbol = _symbol;
        totalSupply_ = _initialSupply;
        balances[msg.sender] = _initialSupply;
        emit Transfer(0x0, msg.sender, _initialSupply);
    }
}