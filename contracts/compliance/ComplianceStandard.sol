pragma solidity ^0.4.19;

import "../provider/Upgradable.sol";

/**
 * @title ComplianceStandard
 */
contract ComplianceStandard is Upgradable {
  /**
   * @dev Checks to see if an action is compliant.
   *
   * @param instrumentAddr The address of the instrument contract.
   * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
   * @param from The from address of the token transfer.
   * @param to The to address of the token transfer.
   * @param data Any additional data related to the action.
   *
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
   * @dev Called when a hard check is performed.
   *
   * @param instrumentAddr The address of the instrument contract.
   * @param instrumentIdOrAmt The instrument id (NFT) or amount (ERC20).
   * @param from The from address of the token transfer.
   * @param to The to address of the token transfer.
   * @param data Any additional data related to the action.
   */
  function onHardCheck(
    address instrumentAddr,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data
  ) external;
}
