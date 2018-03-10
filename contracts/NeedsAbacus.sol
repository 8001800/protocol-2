pragma solidity ^0.4.19;

contract NeedsAbacus {
    /**
     * Address of the Abacus kernel.
     */
    address kernel = address(0);

    modifier fromKernel() {
        require(msg.sender == address(kernel));
        _;
    }
}