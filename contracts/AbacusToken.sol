pragma solidity ^0.4.21;

import "zeppelin-solidity/contracts/token/ERC20/StandardToken.sol";

contract AbacusToken is StandardToken {
    string public constant name = "Abacus Token";
    string public constant symbol = "ABA";
    uint8 public constant decimals = 18;

    uint256 public constant INITIAL_SUPPLY = 1000000000 * (10 ** uint256(decimals));

    function AbacusToken() public {
        totalSupply_ = INITIAL_SUPPLY;
        balances[msg.sender] = INITIAL_SUPPLY;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);
    }
}