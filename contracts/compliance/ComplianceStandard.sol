pragma solidity ^0.4.19;

import "../AbacusKernel.sol";

contract ComplianceStandard {
  // TODO hardcode once deployed?
  AbacusKernel constant ABACUS_KERNEL = AbacusKernel(0);

  modifier fromKernel() {
    require(msg.sender == address(ABACUS_KERNEL));
    _;
  }

  function check(address instrumentAddr, uint256 instrumentId, uint8 action) view external returns (uint8);
}