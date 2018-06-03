pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract SampleToken is StandardToken{
    uint8 public constant decimals = 18;
    uint256 public constant INITIAL_SUPPLY = 1000000000000 * (10 ** uint256(decimals));
    string name;

    function SampleToken(string _name) public {
        name = _name;
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}