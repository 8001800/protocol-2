pragma solidity ^0.4.19;

import "../NeedsAbacus.sol";
import "../AbacusKernel.sol";

contract ComplianceStandard is NeedsAbacus {
  /**
   * Checks for compliance.
   * @return result and next serviceId.
   */
  function check(
    address instrumentAddr,
    uint256 instrumentId,
    uint256 actionId
  ) view external returns (uint8, uint256);
}