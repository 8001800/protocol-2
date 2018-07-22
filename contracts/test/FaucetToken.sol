pragma solidity ^0.4.24;

import "../library/instruments/AbacusERC20Token.sol";

/**
 * @dev Faucet token
 */
contract FaucetToken is AbacusERC20Token {
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000000000000 * (10 ** uint256(decimals));
    uint256 constant faucetAmt = 1000 * (10 ** uint256(decimals));

    constructor(
        ComplianceCoordinator _complianceCoordinator,
        uint256 _complianceProviderId
    ) AbacusERC20Token(_complianceCoordinator, _complianceProviderId) public
    {
        totalSupply_ = INITIAL_SUPPLY;
        balances[this] = INITIAL_SUPPLY;
        emit Transfer(0x0, this, INITIAL_SUPPLY);
    }

    function canRequest() public view returns (uint256, uint256) {
        return canTransferFrom(this, msg.sender, faucetAmt);
    }

    function request() public {
        balances[this] = balances[this].sub(faucetAmt);
        balances[msg.sender] = balances[msg.sender].add(faucetAmt);
        emit Transfer(this, msg.sender, faucetAmt);
    }

    function requestPermissioned() public {
        transfer(msg.sender, faucetAmt);
    }
}