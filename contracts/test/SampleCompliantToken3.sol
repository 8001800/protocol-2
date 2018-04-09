pragma solidity ^0.4.21;

import "../instruments/AbacusERC20Token.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract SampleCompliantToken3 is AbacusERC20Token {
    string public constant name = "Sample Compliant Token 3";
    string public constant symbol = "SCT3";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000000000 * (10 ** uint256(decimals));

    function SampleCompliantToken3(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY.div(2);
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY.div(2));
        balances[this] = INITIAL_SUPPLY.div(2);
        emit Transfer(0x0, this, INITIAL_SUPPLY.div(2));
    }

    function request() public {
        transfer(msg.sender, 1000 * (10 ** uint256(18)));
    }
}