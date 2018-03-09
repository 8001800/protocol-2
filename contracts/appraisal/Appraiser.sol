pragma solidity ^0.4.19;

import "../AbacusKernel.sol";

contract Appraiser {
  // TODO hardcode once deployed?
  AbacusKernel constant ABACUS_KERNEL = AbacusKernel(0);

  modifier fromKernel() {
    require(msg.sender == address(ABACUS_KERNEL));
    _;
  }

  function appraise(address instrumentAddr, uint256 instrumentId) external returns (uint256);

  function invalidate(address instrumentAddr, uint256 instrumentId) external;
}