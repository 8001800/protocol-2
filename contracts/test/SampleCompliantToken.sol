pragma solidity ^0.4.19;

import "../instruments/AbacusERC20Token.sol";

/**
 * @dev A very simple token that implements a single compliance standard.
 */
contract SampleCompliantToken is AbacusERC20Token {
    string public constant name = "Sample Compliant Token";
    string public constant symbol = "SCT";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    function SampleCompliantToken(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}