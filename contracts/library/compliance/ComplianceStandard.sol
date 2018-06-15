pragma solidity ^0.4.24;

import "../provider/Provider.sol";

/**
 * @title ComplianceStandard
 * @dev An on-chain Compliance Provider.
 */
contract ComplianceStandard is Provider {
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
  function performCheck(
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
  function performHardCheck(
    address instrumentAddr,
    uint256 instrumentIdOrAmt,
    address from,
    address to,
    bytes32 data
  ) external;
}
