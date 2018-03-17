pragma solidity ^0.4.19;

import "../provider/Upgradable.sol";

contract ComplianceStandard is Upgradable {
  /**
   * Checks for compliance.
   * @return result and next serviceId.
   */
  function check(
    address instrumentAddr,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data
  ) view external returns (uint8, uint256);

  /**
   * Called when a hard check is performed.
   */
  function onHardCheck(
    address instrumentAddr,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data
  ) external;
}
