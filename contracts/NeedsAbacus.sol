pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";

contract NeedsAbacus is Ownable {
    /**
     * Address of the Abacus kernel.
     */
    address kernel = address(0);

    modifier fromKernel() {
        require(msg.sender == address(kernel));
        _;
    }

    function setKernel(address _kernel) onlyOwner external {
        require(kernel == address(0));
        kernel = _kernel;
    }
}