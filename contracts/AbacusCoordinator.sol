pragma solidity ^0.4.19;

import "zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./AbacusKernel.sol";

contract AbacusCoordinator is Ownable {
    /**
     * Address of the Abacus kernel.
     */
    AbacusKernel public kernel = AbacusKernel(address(0));

    function setKernel(AbacusKernel _kernel) onlyOwner external {
        require(kernel == address(0));
        kernel = _kernel;
    }
}