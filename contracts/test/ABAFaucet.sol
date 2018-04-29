pragma solidity ^0.4.21;

import "../AbacusToken.sol";

contract ABAFaucet {
    AbacusToken token;

    function ABAFaucet(AbacusToken _token) public {
        token = _token;
    }

    function request() external {
        // Faucet pays out 10 ABA each time (if it can)
        token.transfer(msg.sender, 10 * (10 ** token.decimals()));
    }
}